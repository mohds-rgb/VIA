import '../../../core/result.dart';
import '../../../domain/booking/booking.dart';
import '../../../domain/booking/booking_action_result.dart';

abstract interface class BookingRepository {
  Future<Result<Booking>> holdSeats({
    required String tripId,
    required List<String> seatIds,
    required String fareMode,
    required String idempotencyKey,
  });

  Future<Result<BookingActionResult>> requestCashConfirmation({
    required String bookingId,
    required String idempotencyKey,
  });

  Future<Result<BookingActionResult>> confirmCash({
    required String bookingId,
    required String idempotencyKey,
  });
}
