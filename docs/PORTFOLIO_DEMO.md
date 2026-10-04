# Portfolio Demo Walkthrough

This is the fastest path for a hiring manager or reviewer who wants to see the implemented booking flow before reading the entire repository.

## App demo

1. Start the Flutter application from `apps/mobile/`.
2. Keep the top bar in `Demo Mode`.
3. Search `Damascus` → `Daraa University Area`.
4. Select a representative scheduled trip.
5. Select one or two seats from the 50-seat layout.
6. Choose `oneWay` or `roundTrip`.
7. Hold the seats and observe the 10-minute expiry countdown.
8. Request cash confirmation.
9. Use the clearly-labelled demo cash-confirmation action.
10. Observe the issued ticket ID, fare, and commission evidence.

The demo adapter is intentionally in-memory. It is there so a reviewer can exercise the domain journey without production credentials. It is not presented as a live Firebase connection.

## Backend review

Open these files in order:

```text
functions/src/index.ts
functions/src/bookings/hold.ts
functions/src/bookings/cash_confirmation.ts
functions/src/bookings/confirm_cash.ts
functions/src/infra/idempotency.ts
firebase/firestore.rules
functions/test/booking.test.ts
functions/test/idempotency.test.ts
```

## Emulator review

When Firebase Auth and Firestore emulators are running, use:

```powershell
$env:FIRESTORE_EMULATOR_HOST="127.0.0.1:8080"
$env:FIREBASE_AUTH_EMULATOR_HOST="127.0.0.1:9099"
$env:GCLOUD_PROJECT="via-dev-5ca8e"
cd functions
npm run test:emulator
```

The emulator tests intentionally exercise concurrency, idempotency, booking state transitions, and the ticket/finance/commission transaction boundary.

## Evidence rule

Only real local execution can move a capability from `IMPLEMENTED` to `TESTED` or `VERIFIED`. The repository keeps that distinction visible to reviewers.
