# API Contract

Base path: `/v1`

All mutation requests require:

```http
Authorization: Bearer <Firebase ID token>
Idempotency-Key: <unique command key>
```

## Search trips

`GET /v1/trips?origin=Damascus&destination=Daraa%20University%20Area&limit=20`

The server derives the operator from the verified identity and membership record. The client does not submit an arbitrary tenant ID for authorization.

## Seat map

`GET /v1/trips/{tripId}/seats`

Returns server-owned seat documents for a trip.

## Hold seats

`POST /v1/bookings/holds`

```json
{
  "tripId": "demo-dia-01-outbound",
  "seatIds": ["A01", "A02"],
  "fareMode": "oneWay"
}
```

The server snapshots fare, creates a ten-minute hold, and updates all requested seats inside a Firestore transaction. A duplicate idempotency key with a different request fingerprint is rejected.

## Request cash confirmation

`POST /v1/bookings/{bookingId}/request-cash-confirmation`

A passenger can request cash confirmation for their own booking; operator staff can perform the same transition with `booking.manage`.

## Confirm cash

`POST /v1/bookings/{bookingId}/confirm-cash`

The trusted backend transaction:

1. validates the booking transition and hold expiry;
2. validates every seat still belongs to the booking;
3. marks seats booked;
4. confirms the booking;
5. creates the ticket;
6. creates the immutable financial transaction with fare and commission-policy snapshots;
7. emits one commission accrual business event keyed by the booking;
8. records the idempotency result.

## Error model

```json
{
  "error": {
    "code": "SEAT_UNAVAILABLE",
    "message": "The operation could not be completed.",
    "requestId": "..."
  }
}
```
