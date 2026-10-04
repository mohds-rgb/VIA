# VIA Backend

Trusted TypeScript backend for the VIA passenger-booking vertical slice.

## Responsibilities

- Verify Firebase identity
- Resolve tenant membership from Firestore
- Enforce capabilities
- Validate command payloads
- Enforce idempotency and request fingerprinting
- Execute seat-sensitive transactions
- Record authoritative booking, ticket, financial, and business-event documents

## HTTP surface

- `GET /v1/trips`
- `GET /v1/trips/{tripId}/seats`
- `POST /v1/bookings/holds`
- `POST /v1/bookings/{bookingId}/request-cash-confirmation`
- `POST /v1/bookings/{bookingId}/confirm-cash`

## Local emulator

Use the root Firebase Emulator Suite configuration. `scripts/seed-emulator.mjs` refuses to seed unless the Auth and Firestore emulator environment variables are present.
