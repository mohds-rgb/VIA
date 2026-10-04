import { FieldValue } from "firebase-admin/firestore";
import { db } from "../infra/firebase.js";
import { type ActorContext, requireAnyCapability, requireTenant } from "../auth/authorization.js";
import { assertTransition } from "../domain/booking.js";
import { idempotencyDocument, readIdempotentResult, requestFingerprint } from "../infra/idempotency.js";

export async function requestCashConfirmation(actor: ActorContext, operatorId: string, bookingId: string, idempotencyKey: string) {
  requireTenant(actor, operatorId);
  requireAnyCapability(actor, ["booking.create", "booking.manage"]);

  const operatorRef = db.collection("operators").doc(operatorId);
  const bookingRef = operatorRef.collection("bookings").doc(bookingId);
  const idempotencyRef = idempotencyDocument(operatorRef, "requestCashConfirmation", idempotencyKey);
  const fingerprint = requestFingerprint({ bookingId, actor: actor.uid });

  return db.runTransaction(async (tx) => {
    const [bookingSnap, idemSnap] = await Promise.all([tx.get(bookingRef), tx.get(idempotencyRef)]);
    const replay = readIdempotentResult<{ bookingId: string; status: string }>(idemSnap, fingerprint);
    if (replay) return replay;
    if (!bookingSnap.exists) throw new Error("BOOKING_NOT_FOUND");

    const booking = bookingSnap.data()!;
    if (booking.passengerId !== actor.uid && !actor.capabilities.includes("booking.manage")) throw new Error("PERMISSION_DENIED");
    assertTransition(booking.status, "awaitingCashConfirmation");
    if (booking.holdExpiresAt?.toDate && booking.holdExpiresAt.toDate().getTime() <= Date.now()) throw new Error("HOLD_EXPIRED");

    const tripRef = operatorRef.collection("trips").doc(booking.tripId);
    const seatRefs = (booking.seatIds as string[]).map((seatId) => tripRef.collection("seats").doc(seatId));
    const seats = await Promise.all(seatRefs.map((ref) => tx.get(ref)));
    for (const snapshot of seats) {
      const seat = snapshot.data();
      if (!snapshot.exists || seat?.status !== "held" || seat.bookingId !== bookingId) throw new Error("SEAT_HOLD_MISMATCH");
    }

    tx.update(bookingRef, { status: "awaitingCashConfirmation", updatedAt: FieldValue.serverTimestamp() });
    const result = { bookingId, status: "awaitingCashConfirmation" };
    tx.create(idempotencyRef, { command: "requestCashConfirmation", requestHash: fingerprint, result, createdAt: FieldValue.serverTimestamp() });
    return result;
  });
}
