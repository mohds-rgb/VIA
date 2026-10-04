# Security Risk Register

| ID | Risk | Mitigation | Status |
|---|---|---|---|
| SR-001 | Cross-tenant access | Trusted tenant resolution + rules | MITIGATED IN DESIGN |
| SR-002 | Client role escalation | Server-derived capabilities | MITIGATED IN DESIGN |
| SR-003 | Seat double-booking | Firestore transaction | MITIGATED IN DESIGN |
| SR-004 | Replay/duplicate command | Idempotency boundary | MITIGATED IN DESIGN |
| SR-005 | Secret leakage | Secret-free repository policy | MITIGATED |
| SR-006 | Destructive migration | Compatibility-first migration plan | MITIGATED IN DESIGN |
| SR-007 | Stale offline state used as authority | Server-authoritative mutations | MITIGATED IN DESIGN |
