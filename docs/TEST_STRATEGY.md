# Test strategy

VIA uses layered tests so business rules can be checked without requiring production services.

| Layer | Scope | Current evidence |
|---|---|---|
| Flutter unit | result models, booking state machine, demo adapter | owner run: 11 passed |
| Backend unit | booking invariants, capability policy, commissions, idempotency | owner run: 10 passed |
| Emulator integration | Auth + Firestore booking transaction | configured, 4 cases skipped in unit-only run |
| Device smoke | Android debug APK + physical device | device connection observed; APK build and app run not yet verified |

The project intentionally separates `IMPLEMENTED`, `TESTED`, and `VERIFIED` so source presence is never treated as runtime proof.
