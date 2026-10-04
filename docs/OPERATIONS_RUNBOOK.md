# Operations Runbook

## Local emulator startup

```bash
firebase emulators:start
```

## Incident principle

Prefer safe degradation over bypassing authorization or data integrity controls.

## Booking integrity incident

1. Stop further risky rollout.
2. Inspect request IDs and authoritative booking records.
3. Verify seat ownership.
4. Check idempotency records.
5. Check audit/event records.
6. Reconcile affected bookings.
7. Use compensating operations rather than destructive edits.
8. Record the incident and corrective action.

## Secrets

If a secret is exposed:

1. Do not commit or copy it elsewhere.
2. Revoke/rotate it through the owning system.
3. Remove it from tracked history according to the approved incident process.
4. Record the incident without storing the secret itself.
