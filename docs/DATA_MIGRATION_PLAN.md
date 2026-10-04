# Data Migration Plan

## Principles

- Never treat migration as a destructive reset.
- Additive schema changes are preferred.
- Existing documents remain readable during rolling upgrades.
- New fields have safe defaults.
- Backfills are resumable and idempotent.
- Migration progress is observable.
- Rollback uses compatibility rather than destructive deletion.

## Example migration

`booking.v1` → `booking.v2`

1. Deploy readers that understand both versions.
2. Add new optional fields.
3. Backfill in bounded batches.
4. Verify counts and invariants.
5. Switch writers.
6. Monitor.
7. Retain compatibility window.
8. Remove old representation only after explicit approval.

No production migration is claimed to have been executed by this repository.
