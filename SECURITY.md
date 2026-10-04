# Security Policy

## Scope

VIA is a portfolio implementation. Security controls in this repository are design and source-level artifacts unless a runtime verification record explicitly says otherwise.

## Reporting

Do not publish credentials, tokens, production configuration, private keys, or personal data in an issue. For a real deployment, security reports should use a private channel defined by the deployment owner.

## Repository rules

- Production credentials and signing keys are excluded.
- Client code does not directly mutate booking, seat, or financial state.
- Backend mutations require authenticated identity, tenant authorization, capability checks, and idempotency keys.
- Firestore rules are a second authorization layer.
- Destructive migrations require an explicit migration plan and rollback strategy.
