# Firestore Model

All authoritative records are tenant-scoped below `operators/{operatorId}`.

```text
operators/{operatorId}
  members/{uid}
  trips/{tripId}
    seats/{seatId}
  bookings/{bookingId}
  tickets/{ticketId}
  financialTransactions/{transactionId}
  businessEvents/{eventId}
  idempotency/{key}
```

## Booking

A booking owns:

- `operatorId`
- `passengerId`
- `tripId`
- `seatIds`
- `status`
- `fareSnapshot`
- `holdExpiresAt`
- audit timestamps and cash confirmation actor

## Seat

Seat state is server-owned:

```text
available → held → booked
```

A seat can only be mutated by trusted backend code. Client Firestore writes are denied by Rules.

## Ticket

A ticket is created in the same transaction that confirms the cash booking. Its identity is derived from the booking ID, making duplicate ticket creation harder to introduce accidentally.

## Financial transaction

The ticket sale record captures:

- amount
- currency
- payment method
- commission policy snapshot
- commission amount
- immutable marker
- authoritative occurrence timestamp

The commission policy used in this portfolio implementation is 4% per ticket and is versioned as `ticket-commission-v1`. The master specification permits either 4% or 10 SYP; this repository chooses 4% as its documented example policy.
