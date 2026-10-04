# Portfolio Review Guide

## What a recruiter sees

- A clear product scenario rather than a generic CRUD demo.
- A real Flutter application surface.
- A TypeScript backend boundary.
- Firebase security rules and data modeling.
- Tests around authorization, idempotency, booking state and commission logic.
- Documentation that explains trade-offs and scope.
- An honest distinction between local implementation and production deployment.

## What an engineer can inspect

| Question | File |
|---|---|
| How does an authenticated command enter the backend? | `functions/src/index.ts` |
| How are tenant and capabilities enforced? | `functions/src/auth/authorization.ts` |
| How are seats held atomically? | `functions/src/bookings/hold.ts` |
| How is cash confirmation finalized? | `functions/src/bookings/confirm_cash.ts` |
| How are retries handled? | `functions/src/infra/idempotency.ts` |
| What can the client write directly? | `firebase/firestore.rules` |
| What does the booking lifecycle allow? | `apps/mobile/lib/domain/booking/booking_state_machine.dart` |
| How does the reviewer try the journey? | `docs/DEMO_MODE.md` |

## Credibility rule

The repository deliberately avoids fabricated screenshots, fake production metrics, fake customer accounts, fake deployment claims, and invented test results.
