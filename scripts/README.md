# VIA Scripts

## Validate repository

```powershell
python .\scripts\validate-repository.py
```

## Validate demo data

```powershell
python .\scripts\validate-demo-data.py
```

## Capture source-level Windows verification

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-windows.ps1
```

The verification script checks the local toolchain, Flutter dependencies/analysis/tests, and backend lint/typecheck/tests. It intentionally does not build or distribute APK/release artifacts.

## Emulator seed

The seed script only runs when both Firebase Auth and Firestore emulator variables are set. It refuses to seed a normal Firebase project accidentally.
