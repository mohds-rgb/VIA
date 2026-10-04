# Project State

## Identity

- Project: VIA
- Product: VIA — Transportation & Bus Management Platform
- Author: Mohammed Yaman Aldous
- Role: Mobile App & Full-Stack Developer
- GitHub: https://github.com/mohds-rgb
- Specification baseline: VIA V6.1

## Portfolio mode

**Mode: Engineering Portfolio / MVP**

This repository is intentionally scoped as a credible GitHub engineering project rather than a production release.

## Current scope

Implemented:

1. Flutter passenger booking experience.
2. Demo Mode with explicit local data.
3. Trip and seat domain models.
4. Booking state machine.
5. Trusted backend booking commands.
6. Transaction-oriented seat holds.
7. Idempotency and request-fingerprint checks.
8. Tenant/capability authorization.
9. Firestore security rules and indexes.
10. Cash confirmation workflow.
11. Ticket, financial record and commission-event boundary.
12. Arabic/English presentation layer.
13. Tests for mobile/domain/backend invariants.
14. Emulator seed and integration-test scaffolding.
15. Architecture, API, data-model, migration and security documentation.

## Verified locally

Based on the owner-machine run captured on 2026-10-04:

- Repository validation: PASS
- Demo-data validation: PASS
- Flutter dependency resolution: PASS
- Flutter static analysis: PASS
- Flutter tests: 11 PASS
- Backend install: PASS
- Backend lint: PASS
- Backend TypeScript typecheck: PASS
- Backend unit/domain tests: 10 PASS

Firebase Emulator integration was not run during that snapshot. APK/release build is outside the acceptance target for this repository.

## Not claimed

- Production Firebase deployment
- Commercial customer deployment or endorsement
- Live users
- Production authentication configuration
- Production payment provider integration
- Production FCM/App Check configuration
- Release signing or APK distribution
- Full operator, driver, Amanat, subscription and finance UI

## Scenario note

Diamond Travel, 21 buses, 50 seats per bus, Damascus ↔ Daraa University Area, flexible approximately hourly service, and the stated fare examples are represented as **portfolio/demo data** supplied for this project. The repository does not claim a real business relationship or endorsement.
