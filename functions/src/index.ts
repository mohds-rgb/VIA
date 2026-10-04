import { onRequest } from "firebase-functions/v2/https";
import type { Request, Response } from "express";
import { getAuth, type DecodedIdToken } from "firebase-admin/auth";
import { db } from "./infra/firebase.js";
import { HoldSeatsSchema, IdempotencyKeySchema, TripSearchSchema } from "./contracts/api.js";
import { holdSeats } from "./bookings/hold.js";
import { requestCashConfirmation } from "./bookings/cash_confirmation.js";
import { confirmCash } from "./bookings/confirm_cash.js";
import { listTrips } from "./trips/list.js";
import { listTripSeats } from "./trips/seats.js";
import { fail, ok, requestId } from "./http/response.js";
import { type ActorContext, candidateOperatorId } from "./auth/authorization.js";


async function authenticate(req: Request): Promise<ActorContext> {
  const header = req.header("Authorization");
  if (!header?.startsWith("Bearer ")) throw new Error("UNAUTHENTICATED");
  const decoded: DecodedIdToken = await getAuth().verifyIdToken(header.substring("Bearer ".length));
  const operatorId = candidateOperatorId(decoded);
  const memberSnap = await db.collection("operators").doc(operatorId).collection("members").doc(decoded.uid).get();
  if (!memberSnap.exists) throw new Error("TENANT_ACCESS_DENIED");
  const raw = memberSnap.data()?.capabilities;
  const capabilities = raw && typeof raw === "object"
    ? Object.entries(raw).filter(([, enabled]) => enabled === true).map(([capability]) => capability)
    : [];
  return { uid: decoded.uid, operatorId, capabilities };
}

export const api = onRequest(async (req: Request, res: Response): Promise<void> => {
  const rid = requestId(req);
  try {
    const actor = await authenticate(req);

    if (req.method === "GET" && req.path === "/v1/trips") {
      const parsed = TripSearchSchema.safeParse(req.query);
      if (!parsed.success) { fail(res, 400, "INVALID_REQUEST", "Invalid trip search parameters.", rid); return; }
      ok(res, await listTrips(actor, parsed.data), rid); return;
    }

    const tripSeatMatch = req.path.match(/^\/v1\/trips\/([^/]+)\/seats$/);
    if (req.method === "GET" && tripSeatMatch?.[1]) {
      ok(res, await listTripSeats(actor, actor.operatorId, tripSeatMatch[1]), rid); return;
    }

    if (req.method === "POST" && req.path === "/v1/bookings/holds") {
      const parsed = HoldSeatsSchema.safeParse(req.body);
      if (!parsed.success) { fail(res, 400, "INVALID_REQUEST", "Invalid booking request.", rid); return; }
      const parsedKey = IdempotencyKeySchema.safeParse(req.header("Idempotency-Key"));
      if (!parsedKey.success) { fail(res, 400, "INVALID_IDEMPOTENCY_KEY", "Use an 8–128 character idempotency key.", rid); return; }
      const idempotencyKey = parsedKey.data;
      ok(res, await holdSeats(actor, {
        operatorId: actor.operatorId, tripId: parsed.data.tripId, seatIds: parsed.data.seatIds, fareMode: parsed.data.fareMode, idempotencyKey,
      }), rid); return;
    }

    const cashMatch = req.path.match(/^\/v1\/bookings\/([^/]+)\/(request-cash-confirmation|confirm-cash)$/);
    if (req.method === "POST" && cashMatch?.[1] && cashMatch[2]) {
      const bookingId = cashMatch[1];
      const operation = cashMatch[2];
      const parsedKey = IdempotencyKeySchema.safeParse(req.header("Idempotency-Key"));
      if (!parsedKey.success) { fail(res, 400, "INVALID_IDEMPOTENCY_KEY", "Use an 8–128 character idempotency key.", rid); return; }
      const idempotencyKey = parsedKey.data;
      const result = operation === "request-cash-confirmation"
        ? await requestCashConfirmation(actor, actor.operatorId, bookingId, idempotencyKey)
        : await confirmCash(actor, actor.operatorId, bookingId, idempotencyKey);
      ok(res, result, rid); return;
    }

    fail(res, 404, "NOT_FOUND", "Route not found.", rid); return;
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    const code = message.split(":", 1)[0];
    const mapping: Record<string, number> = {
      UNAUTHENTICATED: 401, PERMISSION_DENIED: 403, TENANT_ACCESS_DENIED: 403, AUTH_CONTEXT_INCOMPLETE: 403,
      BOOKING_NOT_FOUND: 404, TRIP_NOT_FOUND: 404, SEAT_UNAVAILABLE: 409, HOLD_EXPIRED: 409, ILLEGAL_BOOKING_TRANSITION: 409,
      SEATS_REQUIRED: 400, DUPLICATE_SEATS: 400, TRIP_FARE_INVALID: 422, SEAT_HOLD_MISMATCH: 409, IDEMPOTENCY_KEY_REUSE: 409, INVALID_IDEMPOTENCY_KEY: 400,
    };
    fail(res, mapping[code] ?? 500, code, "The operation could not be completed.", rid); return;
  }
});
