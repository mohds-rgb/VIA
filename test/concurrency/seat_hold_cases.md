# Seat hold concurrency cases

These cases define the behavior that must be verified against Firestore Emulator Suite and, before any production release, against a real staging project.

| Case | Expected result |
|---|---|
| Two requests hold the same seat concurrently | Exactly one transaction succeeds; the other receives `SEAT_UNAVAILABLE`. |
| Same request retried with same idempotency key | Same booking result is returned; no second booking is created. |
| Same request retried with a different idempotency key | A new command is evaluated independently. |
| Duplicate seat IDs in one request | Request rejected with `DUPLICATE_SEATS`. |
| Hold expires before cash confirmation | Confirmation rejected with `HOLD_EXPIRED`. |
| Cash confirmation races with another mutation | Firestore transaction preserves a valid state transition. |
| One of multiple requested seats is unavailable | Whole transaction fails; no partial seat hold is created. |

## Evidence status

These are required verification cases. They are not represented as runtime pass results until the emulator/staging test is actually executed.
