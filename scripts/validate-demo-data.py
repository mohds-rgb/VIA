import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
operator = json.loads((root / "data/demo/operator.json").read_text())
buses = json.loads((root / "data/demo/buses.json").read_text())
trips = json.loads((root / "data/demo/trips.json").read_text())
users = json.loads((root / "data/demo/users.json").read_text())

assert len(buses) == operator["fleet"]["busCount"], "Fleet count mismatch"
assert all(bus["capacity"] == operator["fleet"]["seatsPerBus"] for bus in buses), "Bus capacity mismatch"
assert len(trips) == len(buses) * 2, "Expected one outbound and one return sample per bus"
assert {trip["busId"] for trip in trips} == {bus["busId"] for bus in buses}, "Trip/fleet mismatch"
assert all(trip["oneWayFareSyp"] == operator["farePolicy"]["oneWay"] for trip in trips), "One-way fare mismatch"
assert all(trip["roundTripFareSyp"] == operator["farePolicy"]["roundTrip"] for trip in trips), "Return fare mismatch"
assert len(users) == 6, "Expected six demo personas"
print(f"Demo data OK: {len(buses)} buses, {len(trips)} trips, {len(users)} personas")
