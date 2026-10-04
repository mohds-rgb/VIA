export type BookingStatus =
  | "initiated"
  | "held"
  | "awaitingCashConfirmation"
  | "confirmed"
  | "checkedIn"
  | "boarded"
  | "completed"
  | "cancelled"
  | "expired"
  | "noShow"
  | "refunded";

export type FareMode = "oneWay" | "roundTrip";

const transitions: Record<BookingStatus, readonly BookingStatus[]> = {
  initiated: ["held", "cancelled"],
  held: ["awaitingCashConfirmation", "expired", "cancelled"],
  awaitingCashConfirmation: ["confirmed", "expired", "cancelled"],
  confirmed: ["checkedIn", "cancelled", "refunded"],
  checkedIn: ["boarded"],
  boarded: ["completed"],
  completed: [],
  cancelled: [],
  expired: [],
  noShow: [],
  refunded: [],
};

export function canTransition(from: BookingStatus, to: BookingStatus): boolean {
  return transitions[from]?.includes(to) ?? false;
}

export function assertTransition(from: BookingStatus, to: BookingStatus): void {
  if (!canTransition(from, to)) {
    throw new Error(`ILLEGAL_BOOKING_TRANSITION:${from}:${to}`);
  }
}
