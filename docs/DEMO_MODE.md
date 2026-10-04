# VIA Demo Mode

The Android app entry point uses `DemoBookingRepository`, an in-memory adapter designed for portfolio review. It lets a reviewer execute the visible booking journey without provisioning Firebase credentials on the phone.

The demo journey is:

1. Search Damascus → Daraa University Area.
2. Select a demo trip.
3. Select up to 8 seats.
4. Create a 10-minute in-memory hold.
5. Request cash confirmation.
6. Simulate the operator confirmation step.
7. Inspect the generated demo ticket and commission amount.

This is intentionally separate from the production-shaped `RemoteBookingRepository`. The demo adapter is not presented as a backend or a production data source.
