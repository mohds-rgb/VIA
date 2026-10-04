# VIA Demo Scenario

## Purpose

This scenario makes the portfolio concrete without pretending that a production operator account exists.

The scenario is based on the operating information supplied by the project owner and is labelled demo data throughout the repository.

## Business context

Diamond Travel operates a 21-bus service between Damascus and the Daraa university area in Southern Syria. Each bus has 50 seats. The project owner described a flexible schedule with approximately hourly outbound and return services.

Fare examples supplied by the project owner:

- One way: 50 SYP
- Round trip: 90 SYP

## Passenger journey

1. Ali Hassan signs in.
2. Ali searches Damascus → Daraa University Area.
3. VIA shows an available scheduled trip.
4. Ali selects A01 and A02.
5. The trusted backend atomically holds both seats for 10 minutes.
6. The booking moves to `awaitingCashConfirmation`.
7. Cash confirmation is submitted with a unique idempotency key.
8. The booking becomes `confirmed`.
9. A commission accrual business event is emitted from the authoritative booking transaction.

## Engineering properties demonstrated

- Tenant isolation
- Capability authorization
- Transactional seat allocation
- Duplicate-seat rejection
- Idempotent commands
- Explicit booking state transitions
- Hold expiry checks
- Server-owned booking fields
- Cash-first payment boundary
- Audit/business-event boundary

## Important evidence rule

The identities and trips in this scenario are portfolio/demo records. They do not prove that Diamond Travel has deployed VIA or authorized this repository. A production deployment or business relationship must only be claimed if independently documented by the project owner.
