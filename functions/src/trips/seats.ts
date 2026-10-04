import { db } from "../infra/firebase.js";
import { type ActorContext, requireAnyCapability, requireTenant } from "../auth/authorization.js";

export async function listTripSeats(actor: ActorContext, operatorId: string, tripId: string) {
  requireTenant(actor, operatorId);
  requireAnyCapability(actor, ["trip.read", "booking.read", "booking.create", "booking.manage"]);
  const tripRef = db.collection("operators").doc(operatorId).collection("trips").doc(tripId);
  const tripSnap = await tripRef.get();
  if (!tripSnap.exists) throw new Error("TRIP_NOT_FOUND");
  const snapshot = await tripRef.collection("seats").orderBy("row").orderBy("seatId").get();
  return {
    tripId,
    seats: snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        seatId: data.seatId,
        status: data.status,
        row: data.row,
        position: data.position,
      };
    }),
  };
}
