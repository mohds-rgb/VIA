# Windows Local Setup

The project owner confirmed a Windows environment with Flutter 3.35.7 / Dart 3.9.2, Java 21.0.1, Node 22.14.0, npm 11.2.0, Firebase CLI 15.20.0, and Git 2.43.0.

The configured development Firebase project ID is `via-dev-5ca8e`.

## 1. Open the repository

```powershell
cd C:\path\to\VIA
```

## 2. Bootstrap Flutter platform files if the Android wrapper is missing

The Android project is included for review. If your local copy was produced from an older archive and the Gradle wrapper is missing, run this once from `apps/mobile`:

```powershell
flutter create --platforms=android --org=com.mohds --project-name=via_mobile .
```

Then restore/verify the repository's Android Gradle configuration and run:

```powershell
flutter pub get
flutter analyze
flutter test
```

## 3. Connect Firebase

The repository contains a `.firebaserc` pointing to the development project supplied by the project owner:

```text
via-dev-5ca8e
```

Never commit `google-services.json`, service-account private keys, signing keys, or `.env` files containing secrets.

## 4. Physical Android phone

Enable Developer Options and USB debugging on the phone, connect it by USB, then verify:

```powershell
flutter devices
adb devices
```

Run the app:

```powershell
cd apps/mobile
flutter run
```

## 5. Capture honest evidence

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-windows.ps1
```

The script writes a timestamped report under `evidence/`. Review it before committing. The evidence file must reflect the actual output; do not manually turn a failure into a pass.

The portfolio verification script is intentionally limited to source-level and test checks; APK/release creation is outside the acceptance target.

For Firebase CLI checks:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-windows.ps1 -RunFirebaseChecks
```

## 6. Run the portfolio demo without Firebase

The Android app defaults to an in-memory `DemoBookingRepository`, so the visible passenger flow can be reviewed without production credentials:

```powershell
cd apps/mobile
flutter run
```

This mode is intentionally labelled `Demo mode` in the UI. The backend remains separately testable against Firebase Emulator Suite.
