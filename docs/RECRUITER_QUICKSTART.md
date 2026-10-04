# Recruiter Quickstart

## In 5 minutes

### 1. Understand the product

Read `docs/DEMO_SCENARIO.md`.

### 2. See the architecture

Read `docs/ARCHITECTURE.md` and `docs/ENGINEERING_HIGHLIGHTS.md`.

### 3. Inspect the critical path

Open:

- `functions/src/bookings/hold.ts`
- `functions/src/bookings/confirm_cash.ts`
- `functions/src/infra/idempotency.ts`
- `firebase/firestore.rules`

### 4. Inspect tests

Open `apps/mobile/test/` and `functions/test/`.

### 5. Try the UI

```powershell
cd apps/mobile
flutter pub get
flutter run
```

The application uses explicitly labelled in-memory Demo Mode at startup, so a reviewer can inspect the passenger booking journey without production credentials.
