# Portfolio Review Walkthrough

A hiring manager can review the repository in 10–15 minutes without guessing where the important engineering decisions live.

## 1. Product context

Start with `docs/DEMO_SCENARIO.md` and `data/demo/`. The scenario is labelled demo data and uses the supplied Diamond Travel operating model: 21 buses, 50 seats, Damascus ↔ Daraa University Area, approximately hourly service, and the supplied fares.

## 2. Mobile surface

Read `apps/mobile/lib/features/booking/presentation/booking_page.dart`. It demonstrates the passenger journey, seat selection, fare mode, Arabic/English switching, and the actual supplied VIA icon.

The mobile layer does not get to mutate Firestore directly. See `apps/mobile/lib/features/booking/data/remote_booking_repository.dart`.

## 3. Trusted backend

Read these in order:

- `functions/src/index.ts` — authenticated HTTP boundary and tenant derivation
- `functions/src/auth/authorization.ts` — capability policy
- `functions/src/trips/list.ts` and `functions/src/trips/seats.ts` — read boundaries
- `functions/src/bookings/hold.ts` — transactional seat hold
- `functions/src/bookings/cash_confirmation.ts` — state transition
- `functions/src/bookings/confirm_cash.ts` — ticket + finance + commission transaction
- `functions/src/infra/idempotency.ts` — replay protection
- `functions/src/domain/commission.ts` — deterministic financial policy

## 4. Database protection

Read `firebase/firestore.rules` and `docs/FIRESTORE_MODEL.md`. Client writes to authoritative booking, seat, ticket, and financial documents are denied.

## 5. Tests

Start with `functions/test/booking.test.ts`, `functions/test/capabilities.test.ts`, `functions/test/idempotency.test.ts`, and `functions/test/commission.test.ts`. Then read `test/concurrency/seat_hold_cases.md` for the emulator/staging cases that must be executed before release.

## 6. Evidence discipline

Read `PROJECT_STATE.md`, `DELIVERY_MANIFEST.md`, `docs/LOCAL_VERIFICATION.md`, and `evidence/README.md`. The repository deliberately distinguishes `IMPLEMENTED`, `TESTED`, `VERIFIED`, and `RELEASED`.
