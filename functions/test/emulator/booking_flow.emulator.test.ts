import { beforeAll, describe, expect, it } from "vitest";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import type { ActorContext } from "../../src/auth/authorization.js";

const run = process.env.VIA_RUN_EMULATOR_TESTS === "1" ? describe : describe.skip;

run("Firestore emulator booking flow", () => {
  let db: ReturnType<typeof getFirestore>;
  const operatorId = `emulator-test-${Date.now()}`;
  const passengerA: ActorContext = { uid: "emulator-passenger-a", operatorId, capabilities: ["trip.read", "booking.read", "booking.create", "ticket.read"] };
  const passengerB: ActorContext = { uid: "emulator-passenger-b", operatorId, capabilities: ["trip.read", "booking.read", "booking.create", "ticket.read"] };
  const cashier: ActorContext = { uid: "emulator-cashier", operatorId, capabilities: ["trip.read", "booking.read", "booking.manage", "ticket.read", "finance.read"] };
  const tripId = "emulator-trip-01";

  beforeAll(async () => {
    if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("FIRESTORE_EMULATOR_HOST is required");
    initializeApp({ projectId: process.env.GCLOUD_PROJECT ?? "via-dev-5ca8e" });
    db = getFirestore();
    const tripRef = db.collection("operators").doc(operatorId).collection("trips").doc(tripId);
    await tripRef.set({
      tripId, operatorId, busId: "DIA-TEST", origin: "Damascus", destination: "Daraa University Area",
      departureLocal: "08:00", seatCapacity: 50, oneWayFareSyp: 50, roundTripFareSyp: 90, status: "scheduled", source: "emulator-test",
    });
    const batch = db.batch();
    for (let seat = 1; seat <= 50; seat += 1) {
      const seatId = `A${String(seat).padStart(2, "0")}`;
      batch.set(tripRef.collection("seats").doc(seatId), { seatId, status: "available", row: Math.ceil(seat / 2), position: seat % 2 === 1 ? "left" : "right" });
    }
    await batch.commit();
  });

  it("allows only one concurrent holder for the same seat", async () => {
    const { holdSeats } = await import("../../src/bookings/hold.js");
    const results = await Promise.allSettled([
      holdSeats(passengerA, { operatorId, tripId, seatIds: ["A01"], fareMode: "oneWay", idempotencyKey: "race-a-0001" }),
      holdSeats(passengerB, { operatorId, tripId, seatIds: ["A01"], fareMode: "oneWay", idempotencyKey: "race-b-0001" }),
    ]);
    expect(results.filter((r) => r.status === "fulfilled")).toHaveLength(1);
    expect(results.filter((r) => r.status === "rejected")).toHaveLength(1);
    const rejected = results.find((r) => r.status === "rejected") as PromiseRejectedResult;
    expect(String(rejected.reason?.message ?? rejected.reason)).toContain("SEAT_UNAVAILABLE");
  });

  it("returns the same booking on an idempotent retry", async () => {
    const { holdSeats } = await import("../../src/bookings/hold.js");
    const command = { operatorId, tripId, seatIds: ["A02"], fareMode: "oneWay" as const, idempotencyKey: "retry-0001" };
    const first = await holdSeats(passengerA, command);
    const second = await holdSeats(passengerA, command);
    expect(second.bookingId).toBe(first.bookingId);
  });

  it("rejects reusing a key for a different request", async () => {
    const { holdSeats } = await import("../../src/bookings/hold.js");
    const command = { operatorId, tripId, seatIds: ["A03"], fareMode: "oneWay" as const, idempotencyKey: "reuse-0001" };
    await holdSeats(passengerA, command);
    await expect(holdSeats(passengerA, { ...command, seatIds: ["A04"] })).rejects.toThrow("IDEMPOTENCY_KEY_REUSE");
  });

  it("commits the booking, ticket, financial record and commission event together", async () => {
    const { holdSeats } = await import("../../src/bookings/hold.js");
    const { requestCashConfirmation } = await import("../../src/bookings/cash_confirmation.js");
    const { confirmCash } = await import("../../src/bookings/confirm_cash.js");
    const held = await holdSeats(passengerA, { operatorId, tripId, seatIds: ["A05", "A06"], fareMode: "roundTrip", idempotencyKey: "flow-0001" });
    await requestCashConfirmation(passengerA, operatorId, held.bookingId, "cash-request-0001");
    const confirmed = await confirmCash(cashier, operatorId, held.bookingId, "cash-confirm-0001");

    expect(confirmed.status).toBe("confirmed");
    expect(confirmed.fareSyp).toBe(90);
    expect(confirmed.commissionSyp).toBe(4);

    const operatorRef = db.collection("operators").doc(operatorId);
    const [booking, ticket, financial, event] = await Promise.all([
      operatorRef.collection("bookings").doc(held.bookingId).get(),
      operatorRef.collection("tickets").doc(held.bookingId).get(),
      operatorRef.collection("financialTransactions").doc(`ticket-sale-${held.bookingId}`).get(),
      operatorRef.collection("businessEvents").doc(`commission-${held.bookingId}`).get(),
    ]);
    expect(booking.data()?.status).toBe("confirmed");
    expect(ticket.data()?.status).toBe("issued");
    expect(financial.data()?.immutable).toBe(true);
    expect(event.data()?.type).toBe("TICKET_COMMISSION_ACCRUAL");
  });
});
