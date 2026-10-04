import 'package:flutter_test/flutter_test.dart';
import '../lib/domain/trip/trip.dart';

void main() {
  test('demo trip reflects the documented Diamond Travel scenario', () {
    final trip = demoTrips.first;
    expect(trip.operatorId, 'diamond-travel');
    expect(trip.origin, 'Damascus');
    expect(trip.destination, 'Daraa University Area');
    expect(trip.seatCapacity, 50);
    expect(trip.oneWayFareSyp, 50);
    expect(trip.roundTripFareSyp, 90);
  });
}
