# Firebase Emulator Workflow

This workflow is intentionally safe: the seed script refuses to run unless both Auth and Firestore emulators are active.

## Start emulators

From repository root:

```powershell
firebase emulators:start
```

In a second terminal:

```powershell
$env:FIRESTORE_EMULATOR_HOST="127.0.0.1:8080"
$env:FIREBASE_AUTH_EMULATOR_HOST="127.0.0.1:9099"
$env:GCLOUD_PROJECT="via-dev-5ca8e"
node .\functions\scripts\seed-emulator.mjs
```

The script creates only emulator users and demo records. It refuses to run against a normal Firebase Auth/Firestore environment.

## Seed contents

- Diamond Travel operator record
- 6 fictional demo personas
- capability claims and member records
- 21 demo buses
- 42 representative outbound/return trips
- 50 seats per trip
- demo fare policy

## Transaction verification

After dependencies are installed and the emulators are running:

```powershell
cd functions
npm run test:emulator
```

The integration test exercises:

- same-seat concurrency → exactly one winner;
- same-key retry → same booking result;
- idempotency-key reuse with changed input → rejected;
- hold → cash confirmation request → confirmed;
- booking + ticket + financial transaction + commission event committed together.

Only commit the resulting output to `evidence/` after the test was actually executed.
