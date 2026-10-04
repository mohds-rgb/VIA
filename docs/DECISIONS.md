# Architecture Decisions

## ADR-001 — Firebase remains the V1 backend

**Decision:** Use Firebase Authentication, Firestore, Storage, FCM and Cloud Functions 2nd gen.

**Reason:** This is the technology boundary defined by VIA V6.1 and keeps V1 architecture narrow.

## ADR-002 — Seat ownership is transactional

**Decision:** Seat holds and booking transitions use Firestore transactions.

**Reason:** Two clients must not both become the authoritative owner of the same seat.

## ADR-003 — No custom authentication subsystem

**Decision:** Do not create custom passwords, refresh tokens or a second JWT/session architecture.

**Reason:** Firebase Authentication owns the identity/session lifecycle.

## ADR-004 — Portfolio claims remain evidence-based

**Decision:** Repository artifacts may be marked implemented when source exists, but deployment/release/verification claims require execution evidence.

**Reason:** Avoid misleading reviewers and preserve traceability.
