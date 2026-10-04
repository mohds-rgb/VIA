import 'package:flutter_test/flutter_test.dart';
import 'package:via_mobile/core/result.dart';

void main() {
  test('Result models represent success without throwing', () {
    const result = Success<String>('booking-1');
    expect(result.value, 'booking-1');
  });

  test('Result models represent a structured failure', () {
    const result = Failure<String>('SEAT_UNAVAILABLE', 'Seat is no longer available');
    expect(result.code, 'SEAT_UNAVAILABLE');
  });
}
