# Security References

## Security boundaries

1. Firebase Authentication establishes identity.
2. Backend code verifies the identity context.
3. Tenant membership is resolved from trusted data.
4. Capability checks are performed server-side.
5. Firestore rules provide a second enforcement layer.
6. State transitions are explicit.
7. High-impact writes are transactionally constrained.
8. Idempotency prevents duplicate command effects.

## Threats considered

- Cross-tenant data access
- Client-supplied role escalation
- Seat double-booking
- Replay of booking commands
- Duplicate cash confirmation
- Stale client state
- Unauthorized financial mutation
- Secret leakage
- Destructive migration

## Secrets

No production secrets are stored in the repository.
