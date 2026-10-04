# Architecture

## Context

VIA is a multi-tenant transportation system. The mobile client is a presentation/application layer; the trusted backend owns authorization and high-impact state transitions.

```text
Flutter UI
   |
Application / Use Cases
   |
Repositories
   |
Firebase SDK / HTTPS API
   |
Cloud Functions 2nd gen
   |
Domain Commands
   |
Firestore transactions
   |
Authoritative business state
```

## Booking command path

```text
POST /v1/bookings/holds
        |
Authentication
        |
Tenant resolution
        |
Capability check
        |
Input validation
        |
Idempotency check
        |
Firestore transaction
        |
Seat availability validation
        |
Seat hold write
        |
Audit/event record
```

## Design principles

- Explicit commands instead of generic writes
- Server-owned business state
- Fail-closed authorization
- Tenant isolation at every mutation boundary
- Atomic seat transitions
- Idempotent retries
- Immutable financial corrections
- Backward-compatible migrations
- Offline-aware reads without offline authority
