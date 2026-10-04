import '../../../core/network/api_client.dart';
import '../../../core/result.dart';
import '../../../domain/booking/booking.dart';
import '../../../domain/booking/booking_action_result.dart';
import 'booking_repository.dart';

class RemoteBookingRepository implements BookingRepository {
  final ApiClient api;

  const RemoteBookingRepository(this.api);

  @override
  Future<Result<Booking>> holdSeats({
    required String tripId,
    required List<String> seatIds,
    required String fareMode,
    required String idempotencyKey,
  }) async {
    try {
      final json = await api.post(
        '/v1/bookings/holds',
        body: {
          'tripId': tripId,
          'seatIds': seatIds,
          'fareMode': fareMode,
        },
        idempotencyKey: idempotencyKey,
      );
      return Success(_fromHoldResponse(json));
    } on ApiException catch (e) {
      return Failure(e.code, e.message);
    }
  }

  @override
  Future<Result<BookingActionResult>> requestCashConfirmation({
    required String bookingId,
    required String idempotencyKey,
  }) => _postAction('/v1/bookings/$bookingId/request-cash-confirmation', idempotencyKey);

  @override
  Future<Result<BookingActionResult>> confirmCash({
    required String bookingId,
    required String idempotencyKey,
  }) => _postAction('/v1/bookings/$bookingId/confirm-cash', idempotencyKey);

  Future<Result<BookingActionResult>> _postAction(String path, String idempotencyKey) async {
    try {
      final json = await api.post(path, body: const {}, idempotencyKey: idempotencyKey);
      final data = (json['data'] ?? json) as Map<String, dynamic>;
      return Success(BookingActionResult(
        bookingId: data['bookingId'] as String,
        status: data['status'] as String,
        ticketId: data['ticketId'] as String?,
        fareSyp: (data['fareSyp'] as num?)?.toInt(),
        commissionSyp: (data['commissionSyp'] as num?)?.toInt(),
      ));
    } on ApiException catch (e) {
      return Failure(e.code, e.message);
    }
  }

  Booking _fromHoldResponse(Map<String, dynamic> json) {
    final data = (json['data'] ?? json) as Map<String, dynamic>;
    return Booking(
      id: data['bookingId'] as String,
      operatorId: data['operatorId'] as String? ?? '',
      passengerId: data['passengerId'] as String? ?? '',
      tripId: data['tripId'] as String? ?? '',
      seatIds: List<String>.from(data['seatIds'] as List? ?? const []),
      status: BookingStatus.values.byName(data['status'] as String),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? ''),
      holdExpiresAt: DateTime.tryParse(data['holdExpiresAt'] as String? ?? ''),
    );
  }
}
