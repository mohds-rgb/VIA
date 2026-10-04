import { FieldValue } from "firebase-admin/firestore";
import { db } from "../infra/firebase.js";
import { type ActorContext, requireCapability, requireTenant } from "../auth/authorization.js";
import { assertTransition } from "../domain/booking.js";
import { TICKET_COMMISSION_POLICY, calculateCommissionSyp } from "../domain/commission.js";
import { idempotencyDocument, readIdempotentResult, requestFingerprint } from "../infra/idempotency.js";

export async function confirmCash(actor: ActorContext, operatorId: string, bookingId: string, idempotencyKey: string) {
  requireTenant(actor, operatorId);
  requireCapability(actor, "booking.manage");

  const operatorRef = db.collection("operators").doc(operatorId);
  const bookingRef = operatorRef.collection("bookings").doc(bookingId);
  const idempotencyRef = idempotencyDocument(operatorRef, "confirmCash", idempotencyKey);
  const fingerprint = requestFingerprint({ bookingId, actor: actor.uid });

  return db.runTransaction(async (tx) => {
    const [bookingSnap, idemSnap] = await Promise.all([tx.get(bookingRef), tx.get(idempotencyRef)]);
    const replay = readIdempotentResult<{ bookingId: string; ticketId: string; status: string; fareSyp: number; commissionSyp: number }>(idemSnap, fingerprint);
    if (replay) return replay;
    if (!bookingSnap.exists) throw new Error("BOOKING_NOT_FOUND");

    const booking = bookingSnap.data()!;
    if (booking.holdExpiresAt?.toDate && booking.holdExpiresAt.toDate().getTime() <= Date.now()) throw new Error("HOLD_EXPIRED");
    assertTransition(booking.status, "confirmed");

    const tripRef = operatorRef.collection("trips").doc(booking.tripId);
    const tripSnap = await tx.get(tripRef);
    if (!tripSnap.exists) throw new Error("TRIP_NOT_FOUND");
    const seatRefs = (booking.seatIds as string[]).map((seatId) => tripRef.collection("seats").doc(seatId));
    const seats = await Promise.all(seatRefs.map((ref) => tx.get(ref)));
    for (const snapshot of seats) {
      const seat = snapshot.data();
      if (!snapshot.exists || seat?.status !== "held" || seat.bookingId !== bookingId) throw new Error("SEAT_HOLD_MISMATCH");
    }

    const ticketRef = operatorRef.collection("tickets").doc(bookingId);
    const financialRef = operatorRef.collection("financialTransactions").doc(`ticket-sale-${bookingId}`);
    const businessEventRef = operatorRef.collection("businessEvents").doc(`commission-${bookingId}`);
    const fareSyp = Number(booking.fareSnapshot?.amountSyp ?? 0);
    const commissionSyp = calculateCommissionSyp(fareSyp);

    tx.update(bookingRef, { status: "confirmed", cashConfirmedBy: actor.uid, cashConfirmedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    for (const ref of seatRefs) {
      tx.update(ref, { status: "booked", bookingId, bookedBy: booking.passengerId, bookedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    }
    tx.create(ticketRef, {
      id: ticketRef.id, bookingId, passengerId: booking.passengerId, tripId: booking.tripId, seatIds: booking.seatIds,
      status: "issued", fareSnapshot: booking.fareSnapshot, issuedAt: FieldValue.serverTimestamp(),
    });
    tx.create(financialRef, {
      id: financialRef.id, type: "ticket_sale", bookingId, ticketId: ticketRef.id, amountSyp: fareSyp, currency: "SYP", paymentMethod: "cash",
      commissionPolicySnapshot: { ...TICKET_COMMISSION_POLICY, commissionSyp }, immutable: true, occurredAt: FieldValue.serverTimestamp(),
    });
    tx.create(businessEventRef, {
      type: "TICKET_COMMISSION_ACCRUAL", aggregateId: bookingId, ticketId: ticketRef.id, amountSyp: commissionSyp,
      policyVersion: TICKET_COMMISSION_POLICY.policyVersion, occurredAt: FieldValue.serverTimestamp(),
    });

    const result = { bookingId, ticketId: ticketRef.id, status: "confirmed", fareSyp, commissionSyp };
    tx.create(idempotencyRef, { command: "confirmCash", requestHash: fingerprint, result, createdAt: FieldValue.serverTimestamp() });
    return result;
  });
}
