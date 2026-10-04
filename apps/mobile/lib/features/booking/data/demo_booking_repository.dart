import '../../../core/result.dart';
import '../../../domain/booking/booking.dart';
import '../../../domain/booking/booking_action_result.dart';
import '../../../domain/booking/booking_state_machine.dart';
import '../../../domain/trip/trip.dart';
import 'booking_repository.dart';

/// In-memory demo adapter used by the portfolio app entry point.
/// It deliberately does not pretend to be Firebase; the production-shaped
/// RemoteBookingRepository remains the server integration boundary.
class DemoBookingRepository implements BookingRepository {
  DemoBookingRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final BookingStateMachine _stateMachine = const BookingStateMachine();
  final Set<String> _heldSeats = <String>{};
  final Map<String, _BookingRecord> _bookingsById = <String, _BookingRecord>{};
  final Map<String, String> _idempotency = <String, String>{};
  final Map<String, String> _idempotencyFingerprints = <String, String>{};
  int _sequence = 1;

  @override
  Future<Result<Booking>> holdSeats({
    required String tripId,
    required List<String> seatIds,
    required String fareMode,
    required String idempotencyKey,
  }) async {
    _expireElapsedHolds();
    final key = 'hold:$idempotencyKey';
    final normalizedSeats = [...seatIds]..sort();
    final fingerprint = '$tripId|$normalizedSeats|$fareMode';
    final existingId = _idempotency[key];
    if (existingId != null) {
      if (_idempotencyFingerprints[key] != fingerprint) {
        return const Failure('IDEMPOTENCY_KEY_REUSE', 'The idempotency key was already used for another request.');
      }
      final existing = _bookingsById[existingId];
      if (existing != null) return Success(existing.toBooking());
    }

    Trip? trip;
    for (final candidate in demoTrips) {
      if (candidate.id == tripId) {
        trip = candidate;
        break;
      }
    }
    final resolvedTrip = trip;
    if (resolvedTrip == null) return const Failure('TRIP_NOT_FOUND', 'Demo trip not found.');
    if (seatIds.isEmpty) return const Failure('SEATS_REQUIRED', 'Select at least one seat.');
    if (seatIds.length > 8) return const Failure('SEATS_LIMIT', 'You can hold up to 8 seats.');
    if (seatIds.toSet().length != seatIds.length) return const Failure('DUPLICATE_SEATS', 'Duplicate seats are not allowed.');
    if (seatIds.any((seat) => !RegExp(r'^A\d{2}$').hasMatch(seat))) {
      return const Failure('INVALID_SEAT', 'Invalid demo seat number.');
    }
    if (seatIds.any((seat) => _heldSeats.contains('${resolvedTrip.id}:$seat'))) return const Failure('SEAT_UNAVAILABLE', 'One or more seats are already held.');

    final mode = fareMode == 'roundTrip' ? 'roundTrip' : 'oneWay';
    final amount = mode == 'roundTrip' ? resolvedTrip.roundTripFareSyp : resolvedTrip.oneWayFareSyp;
    final createdAt = _now();
    final booking = _BookingRecord(
      id: 'demo-booking-${_sequence++}',
      operatorId: resolvedTrip.operatorId,
      passengerId: 'demo-passenger-ali',
      tripId: resolvedTrip.id,
      seatIds: List.unmodifiable(seatIds),
      status: BookingStatus.held,
      fareMode: mode,
      fareSyp: amount * seatIds.length,
      createdAt: createdAt,
      holdExpiresAt: createdAt.add(const Duration(minutes: 10)),
    );
    _bookingsById[booking.id] = booking;
    _idempotency[key] = booking.id;
    _idempotencyFingerprints[key] = fingerprint;
    _heldSeats.addAll(seatIds.map((seat) => '${resolvedTrip.id}:$seat'));
    return Success(booking.toBooking());
  }

  @override
  Future<Result<BookingActionResult>> requestCashConfirmation({
    required String bookingId,
    required String idempotencyKey,
  }) async {
    _expireElapsedHolds();
    final key = 'cash-request:$idempotencyKey';
    final fingerprint = 'cash-request|$bookingId';
    final existingId = _idempotency[key];
    if (existingId != null) {
      if (_idempotencyFingerprints[key] != fingerprint) return const Failure('IDEMPOTENCY_KEY_REUSE', 'The idempotency key was already used for another request.');
      return Success(_action(existingId, 'awaitingCashConfirmation'));
    }
    final booking = _bookingsById[bookingId];
    if (booking == null) return const Failure('BOOKING_NOT_FOUND', 'Demo booking not found.');
    if (_expired(booking)) return const Failure('HOLD_EXPIRED', 'The seat hold has expired.');
    if (!_stateMachine.canTransition(booking.status, BookingStatus.awaitingCashConfirmation)) {
      return const Failure('ILLEGAL_BOOKING_TRANSITION', 'The booking is not waiting for cash confirmation.');
    }
    booking.status = BookingStatus.awaitingCashConfirmation;
    _idempotency[key] = bookingId;
    _idempotencyFingerprints[key] = fingerprint;
    return Success(_action(bookingId, 'awaitingCashConfirmation'));
  }

  @override
  Future<Result<BookingActionResult>> confirmCash({
    required String bookingId,
    required String idempotencyKey,
  }) async {
    _expireElapsedHolds();
    final key = 'cash-confirm:$idempotencyKey';
    final fingerprint = 'cash-confirm|$bookingId';
    final existingId = _idempotency[key];
    if (existingId != null) {
      if (_idempotencyFingerprints[key] != fingerprint) return const Failure('IDEMPOTENCY_KEY_REUSE', 'The idempotency key was already used for another request.');
      return Success(_action(existingId, 'confirmed', includeTicket: true));
    }
    final booking = _bookingsById[bookingId];
    if (booking == null) return const Failure('BOOKING_NOT_FOUND', 'Demo booking not found.');
    if (_expired(booking)) return const Failure('HOLD_EXPIRED', 'The seat hold has expired.');
    if (!_stateMachine.canTransition(booking.status, BookingStatus.confirmed)) {
      return const Failure('ILLEGAL_BOOKING_TRANSITION', 'The booking is not ready for confirmation.');
    }
    booking.status = BookingStatus.confirmed;
    booking.ticketId = 'demo-ticket-${booking.id.substring('demo-booking-'.length)}';
    _idempotency[key] = bookingId;
    _idempotencyFingerprints[key] = fingerprint;
    for (final seat in booking.seatIds) {
      _heldSeats.remove('${booking.tripId}:$seat');
    }
    return Success(_action(bookingId, 'confirmed', includeTicket: true));
  }

  void _expireElapsedHolds() {
    final current = _now();
    for (final booking in _bookingsById.values) {
      if ((booking.status == BookingStatus.held ||
              booking.status == BookingStatus.awaitingCashConfirmation) &&
          !booking.holdExpiresAt.isAfter(current)) {
        booking.status = BookingStatus.expired;
        for (final seat in booking.seatIds) {
          _heldSeats.remove('${booking.tripId}:$seat');
        }
      }
    }
  }

  bool _expired(_BookingRecord booking) => !booking.holdExpiresAt.isAfter(_now());

  BookingActionResult _action(String bookingId, String status, {bool includeTicket = false}) {
    final booking = _bookingsById[bookingId]!;
    final commission = (booking.fareSyp * 4) ~/ 100;
    return BookingActionResult(
      bookingId: bookingId,
      status: status,
      ticketId: includeTicket ? booking.ticketId : null,
      fareSyp: includeTicket ? booking.fareSyp : null,
      commissionSyp: includeTicket ? commission : null,
    );
  }
}

final class _BookingRecord {
  final String id;
  final String operatorId;
  final String passengerId;
  final String tripId;
  final List<String> seatIds;
  final String fareMode;
  final int fareSyp;
  final DateTime createdAt;
  final DateTime holdExpiresAt;
  BookingStatus status;
  String? ticketId;

  _BookingRecord({
    required this.id,
    required this.operatorId,
    required this.passengerId,
    required this.tripId,
    required this.seatIds,
    required this.status,
    required this.fareMode,
    required this.fareSyp,
    required this.createdAt,
    required this.holdExpiresAt,
  });

  Booking toBooking() => Booking(
        id: id,
        operatorId: operatorId,
        passengerId: passengerId,
        tripId: tripId,
        seatIds: seatIds,
        status: status,
        createdAt: createdAt,
        holdExpiresAt: holdExpiresAt,
      );
}
