class BookingActionResult {
  final String bookingId;
  final String status;
  final String? ticketId;
  final int? fareSyp;
  final int? commissionSyp;

  const BookingActionResult({
    required this.bookingId,
    required this.status,
    this.ticketId,
    this.fareSyp,
    this.commissionSyp,
  });
}
