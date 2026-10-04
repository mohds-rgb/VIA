import { db } from "../infra/firebase.js";
import { type ActorContext, requireAnyCapability } from "../auth/authorization.js";

type TripRecord = Record<string, unknown> & {
  origin?: string;
  destination?: string;
  departureLocal?: string;
};

export async function listTrips(actor: ActorContext, filters: { origin?: string; destination?: string; limit: number }) {
  requireAnyCapability(actor, ["trip.read", "booking.read", "booking.create", "booking.manage"]);

  const tripsRef = db.collection("operators").doc(actor.operatorId).collection("trips");
  let snapshot;
  if (filters.origin && filters.destination) {
    snapshot = await tripsRef.where("origin", "==", filters.origin).where("destination", "==", filters.destination).where("status", "==", "scheduled").limit(filters.limit).get();
  } else if (filters.origin) {
    snapshot = await tripsRef.where("origin", "==", filters.origin).where("status", "==", "scheduled").limit(filters.limit).get();
  } else if (filters.destination) {
    snapshot = await tripsRef.where("destination", "==", filters.destination).where("status", "==", "scheduled").limit(filters.limit).get();
  } else {
    snapshot = await tripsRef.where("status", "==", "scheduled").limit(filters.limit).get();
  }

  const trips = snapshot.docs
    .map((doc): TripRecord => ({ id: doc.id, ...doc.data() } as TripRecord & { id: string }))
    .sort((a, b) => String(a.departureLocal ?? "").localeCompare(String(b.departureLocal ?? "")));

  return { trips };
}
