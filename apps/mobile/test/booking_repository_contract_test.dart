import 'package:flutter_test/flutter_test.dart';
import '../lib/domain/booking/booking_action_result.dart';

void main() {
  test('cash confirmation result can carry ticket and commission evidence', () {
    const result = BookingActionResult(
      bookingId: 'booking-1',
      status: 'confirmed',
      ticketId: 'booking-1',
      fareSyp: 50,
      commissionSyp: 2,
    );

    expect(result.status, 'confirmed');
    expect(result.ticketId, 'booking-1');
    expect(result.commissionSyp, 2);
  });
}
