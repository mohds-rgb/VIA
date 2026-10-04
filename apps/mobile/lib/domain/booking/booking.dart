enum BookingStatus {
  initiated,
  held,
  awaitingCashConfirmation,
  confirmed,
  checkedIn,
  boarded,
  completed,
  cancelled,
  expired,
  noShow,
  refunded,
}

class Booking {
  final String id;
  final String operatorId;
  final String passengerId;
  final String tripId;
  final List<String> seatIds;
  final BookingStatus status;
  final DateTime? createdAt;
  final DateTime? holdExpiresAt;

  const Booking({
    required this.id,
    required this.operatorId,
    required this.passengerId,
    required this.tripId,
    required this.seatIds,
    required this.status,
    this.createdAt,
    this.holdExpiresAt,
  });
}
