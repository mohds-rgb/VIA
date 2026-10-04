import 'booking.dart';

class BookingStateMachine {
  const BookingStateMachine();

  bool canTransition(BookingStatus from, BookingStatus to) {
    const transitions = {
      BookingStatus.initiated: {
        BookingStatus.held,
        BookingStatus.cancelled,
      },
      BookingStatus.held: {
        BookingStatus.awaitingCashConfirmation,
        BookingStatus.expired,
        BookingStatus.cancelled,
      },
      BookingStatus.awaitingCashConfirmation: {
        BookingStatus.confirmed,
        BookingStatus.expired,
        BookingStatus.cancelled,
      },
      BookingStatus.confirmed: {
        BookingStatus.checkedIn,
        BookingStatus.cancelled,
        BookingStatus.refunded,
      },
      BookingStatus.checkedIn: {
        BookingStatus.boarded,
      },
      BookingStatus.boarded: {
        BookingStatus.completed,
      },
    };

    return transitions[from]?.contains(to) ?? false;
  }

  void assertTransition(BookingStatus from, BookingStatus to) {
    if (!canTransition(from, to)) {
      throw StateError('Illegal booking transition: $from -> $to');
    }
  }
}
