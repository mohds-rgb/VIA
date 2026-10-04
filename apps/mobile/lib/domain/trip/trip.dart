class Trip {
  final String id;
  final String operatorId;
  final String busId;
  final String origin;
  final String destination;
  final String departureLocal;
  final int seatCapacity;
  final int oneWayFareSyp;
  final int roundTripFareSyp;

  const Trip({
    required this.id,
    required this.operatorId,
    required this.busId,
    required this.origin,
    required this.destination,
    required this.departureLocal,
    required this.seatCapacity,
    required this.oneWayFareSyp,
    required this.roundTripFareSyp,
  });
}

const demoTrips = <Trip>[
  Trip(
    id: 'demo-dia-01-outbound',
    operatorId: 'diamond-travel',
    busId: 'DIA-01',
    origin: 'Damascus',
    destination: 'Daraa University Area',
    departureLocal: '08:00',
    seatCapacity: 50,
    oneWayFareSyp: 50,
    roundTripFareSyp: 90,
  ),
  Trip(
    id: 'demo-dia-02-outbound',
    operatorId: 'diamond-travel',
    busId: 'DIA-02',
    origin: 'Damascus',
    destination: 'Daraa University Area',
    departureLocal: '09:00',
    seatCapacity: 50,
    oneWayFareSyp: 50,
    roundTripFareSyp: 90,
  ),
];
