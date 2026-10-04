import 'package:flutter_test/flutter_test.dart';
import 'package:via_mobile/domain/booking/booking.dart';
import 'package:via_mobile/domain/booking/booking_state_machine.dart';

void main() {
  const machine = BookingStateMachine();

  test('allows a held booking to request cash confirmation', () {
    expect(
      machine.canTransition(
        BookingStatus.held,
        BookingStatus.awaitingCashConfirmation,
      ),
      isTrue,
    );
  });

  test('rejects a direct initiated to boarded transition', () {
    expect(
      machine.canTransition(
        BookingStatus.initiated,
        BookingStatus.boarded,
      ),
      isFalse,
    );
  });
}
