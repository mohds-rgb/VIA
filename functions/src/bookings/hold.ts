import { FieldValue } from "firebase-admin/firestore";
import { db } from "../infra/firebase.js";
import { requireAnyCapability, requireTenant, type ActorContext } from "../auth/authorization.js";
import { idempotencyDocument, readIdempotentResult, requestFingerprint } from "../infra/idempotency.js";
import type { FareMode } from "../domain/booking.js";

const HOLD_DURATION_MS = 10 * 60 * 1000;

export interface HoldSeatsCommand {
  tripId: string;
  operatorId: string;
  seatIds: string[];
  fareMode: FareMode;
  idempotencyKey: string;
}

function uniqueSeatIds(seatIds: string[]): string[] {
  return [...new Set(seatIds)];
}

export async function holdSeats(actor: ActorContext, command: HoldSeatsCommand) {
  requireTenant(actor, command.operatorId);
  requireAnyCapability(actor, ["booking.create", "booking.manage"]);

  const seatIds = uniqueSeatIds(command.seatIds);
  if (seatIds.length === 0) throw new Error("SEATS_REQUIRED");
  if (seatIds.length !== command.seatIds.length) throw new Error("DUPLICATE_SEATS");

  const operatorRef = db.collection("operators").doc(command.operatorId);
  const idempotencyRef = idempotencyDocument(operatorRef, "holdSeats", command.idempotencyKey);
  const bookingRef = operatorRef.collection("bookings").doc();
  const tripRef = operatorRef.collection("trips").doc(command.tripId);
  const expiresAt = new Date(Date.now() + HOLD_DURATION_MS);
  const fingerprint = requestFingerprint({ tripId: command.tripId, seatIds: [...seatIds].sort(), fareMode: command.fareMode, actor: actor.uid });

  return db.runTransaction(async (tx) => {
    const previous = await tx.get(idempotencyRef);
    const replay = readIdempotentResult<{
      bookingId: string; operatorId: string; passengerId: string; tripId: string; seatIds: string[]; fareMode: FareMode; fareSyp: number; status: string; holdExpiresAt: string;
    }>(previous, fingerprint);
    if (replay) return replay;

    const tripSnap = await tx.get(tripRef);
    if (!tripSnap.exists) throw new Error("TRIP_NOT_FOUND");
    const trip = tripSnap.data()!;
    const fareSyp = command.fareMode === "roundTrip" ? trip.roundTripFareSyp : trip.oneWayFareSyp;
    if (!Number.isInteger(fareSyp) || fareSyp < 0) throw new Error("TRIP_FARE_INVALID");

    const seatRefs = seatIds.map((seatId) => tripRef.collection("seats").doc(seatId));
    const seats = await Promise.all(seatRefs.map((ref) => tx.get(ref)));
    for (const snapshot of seats) {
      const data = snapshot.data();
      if (!snapshot.exists || data?.status !== "available") throw new Error("SEAT_UNAVAILABLE");
    }

    const booking = {
      id: bookingRef.id,
      operatorId: command.operatorId,
      passengerId: actor.uid,
      tripId: command.tripId,
      seatIds,
      status: "held",
      fareSnapshot: { mode: command.fareMode, amountSyp: fareSyp, capturedAt: FieldValue.serverTimestamp() },
      createdAt: FieldValue.serverTimestamp(),
      holdExpiresAt: expiresAt,
    };

    tx.create(bookingRef, booking);
    for (const ref of seatRefs) {
      tx.update(ref, { status: "held", bookingId: bookingRef.id, heldBy: actor.uid, holdExpiresAt: expiresAt, updatedAt: FieldValue.serverTimestamp() });
    }

    const result = {
      bookingId: bookingRef.id, operatorId: command.operatorId, passengerId: actor.uid, tripId: command.tripId,
      seatIds, fareMode: command.fareMode, fareSyp, status: "held", holdExpiresAt: expiresAt.toISOString(),
    };

    tx.create(idempotencyRef, { command: "holdSeats", requestHash: fingerprint, result, createdAt: FieldValue.serverTimestamp() });
    return result;
  });
}
