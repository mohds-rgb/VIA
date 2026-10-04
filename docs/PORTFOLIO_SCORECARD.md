# Portfolio Engineering Scorecard

This is a reviewer aid, not a claim of production readiness.

| Reviewer question | Where to look |
|---|---|
| How is the user authenticated? | `functions/src/index.ts` |
| How is the tenant chosen safely? | `functions/src/index.ts`, `auth/authorization.ts` |
| Can passengers create bookings without operator powers? | `data/demo/capabilities.json`, `functions/src/auth/authorization.ts` |
| Can two callers claim the same seat? | `functions/src/bookings/hold.ts`, `test/concurrency/seat_hold_cases.md` |
| What happens on a retry? | `functions/src/infra/idempotency.ts` |
| Can a hold expire? | `functions/src/bookings/*.ts` |
| How is financial state protected? | `functions/src/bookings/confirm_cash.ts`, `firebase/firestore.rules` |
| What is immutable? | `docs/FIRESTORE_MODEL.md`, transaction code |
| Is the demo data honest? | `data/demo/README.md`, `docs/DEMO_SCENARIO.md` |
| Where are actual runtime results stored? | `evidence/` |


## Current evidence

The latest owner-machine run passed repository validation, Flutter analysis, the full Flutter test suite (11 tests), backend lint, backend typecheck, and backend unit/domain tests (10 tests). Four Firebase Emulator integration tests are present but were skipped because the Emulator Suite was not running during the captured command. APK/release verification is outside the acceptance target for this portfolio repository.

## Publication

Use `GITHUB_SETUP.md` to initialize Git history under the project owner's GitHub account. The portfolio package does not rely on pre-created history as evidence of authorship.
