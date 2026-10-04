# API Examples

Examples use the local emulator and are intentionally illustrative. Replace `TOKEN` with an actual Firebase Auth emulator token in a local test session.

## Search

```http
GET http://127.0.0.1:5001/v1/trips?origin=Damascus&destination=Daraa%20University%20Area
Authorization: Bearer TOKEN
```

## Hold two seats

```http
POST http://127.0.0.1:5001/v1/bookings/holds
Authorization: Bearer TOKEN
Content-Type: application/json
Idempotency-Key: demo-hold-001

{
  "tripId": "demo-dia-01-outbound",
  "seatIds": ["A01", "A02"],
  "fareMode": "oneWay"
}
```

## Request cash confirmation

```http
POST http://127.0.0.1:5001/v1/bookings/{bookingId}/request-cash-confirmation
Authorization: Bearer TOKEN
Idempotency-Key: demo-cash-request-001

{}
```

## Confirm cash

Operator staff with `booking.manage` perform the final mutation. The transaction emits the ticket, financial record, and commission event together.
