import 'package:flutter_test/flutter_test.dart';
import '../lib/core/result.dart';
import '../lib/domain/booking/booking_action_result.dart';
import '../lib/domain/booking/booking.dart';
import '../lib/features/booking/data/demo_booking_repository.dart';

void main() {
  test('demo adapter runs the passenger -> cash -> ticket journey', () async {
    final now = DateTime(2026, 10, 4, 8);
    final repo = DemoBookingRepository(now: () => now);

    final held = await repo.holdSeats(
      tripId: 'demo-dia-01-outbound',
      seatIds: ['A01', 'A02'],
      fareMode: 'roundTrip',
      idempotencyKey: 'journey-0001',
    );
    expect(held, isA<Success<Booking>>());
    final booking = (held as Success<Booking>).value;
    expect(booking.status, BookingStatus.held);
    expect(booking.holdExpiresAt, now.add(const Duration(minutes: 10)));

    final requested = await repo.requestCashConfirmation(bookingId: booking.id, idempotencyKey: 'request-0001');
    expect(requested, isA<Success<BookingActionResult>>());
    expect((requested as Success<BookingActionResult>).value.status, 'awaitingCashConfirmation');

    final confirmed = await repo.confirmCash(bookingId: booking.id, idempotencyKey: 'confirm-0001');
    final action = (confirmed as Success<BookingActionResult>).value;
    expect(action.status, 'confirmed');
    expect(action.ticketId, isNotNull);
    expect(action.fareSyp, 180);
    expect(action.commissionSyp, 7);
  });

  test('same demo idempotency key returns the same booking', () async {
    final repo = DemoBookingRepository(now: () => DateTime(2026, 10, 4));
    final first = await repo.holdSeats(tripId: 'demo-dia-01-outbound', seatIds: ['A01'], fareMode: 'oneWay', idempotencyKey: 'retry-0001');
    final second = await repo.holdSeats(tripId: 'demo-dia-01-outbound', seatIds: ['A01'], fareMode: 'oneWay', idempotencyKey: 'retry-0001');
    expect((first as Success<Booking>).value.id, (second as Success<Booking>).value.id);
  });

  test('reusing a key for a different demo request is rejected', () async {
    final repo = DemoBookingRepository(now: () => DateTime(2026, 10, 4));
    await repo.holdSeats(tripId: 'demo-dia-01-outbound', seatIds: ['A01'], fareMode: 'oneWay', idempotencyKey: 'reuse-0001');
    final reused = await repo.holdSeats(tripId: 'demo-dia-01-outbound', seatIds: ['A02'], fareMode: 'oneWay', idempotencyKey: 'reuse-0001');
    expect((reused as Failure<Booking>).code, 'IDEMPOTENCY_KEY_REUSE');
  });


  test('an expired hold is released so the seat can be held again', () async {
    var now = DateTime(2026, 10, 4);
    final repo = DemoBookingRepository(now: () => now);
    final first = await repo.holdSeats(
      tripId: 'demo-dia-01-outbound',
      seatIds: ['A07'],
      fareMode: 'oneWay',
      idempotencyKey: 'expiry-0001',
    );
    expect(first, isA<Success<Booking>>());

    now = now.add(const Duration(minutes: 11));
    final second = await repo.holdSeats(
      tripId: 'demo-dia-01-outbound',
      seatIds: ['A07'],
      fareMode: 'oneWay',
      idempotencyKey: 'expiry-0002',
    );

    expect(second, isA<Success<Booking>>());
    expect((second as Success<Booking>).value.id, isNot((first as Success<Booking>).value.id));
  });

  test('a held seat cannot be held again', () async {
    final repo = DemoBookingRepository(now: () => DateTime(2026, 10, 4));
    await repo.holdSeats(tripId: 'demo-dia-01-outbound', seatIds: ['A01'], fareMode: 'oneWay', idempotencyKey: 'seat-0001');
    final conflict = await repo.holdSeats(tripId: 'demo-dia-01-outbound', seatIds: ['A01'], fareMode: 'oneWay', idempotencyKey: 'seat-0002');
    expect(conflict, isA<Failure<Booking>>());
    expect((conflict as Failure<Booking>).code, 'SEAT_UNAVAILABLE');
  });
}
