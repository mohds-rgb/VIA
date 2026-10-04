# Local Verification Record

## Owner-provided Windows evidence — 2026-10-04 around 03:00

The supplied owner-machine evidence confirms the Flutter/Dart, Android, Java, Node.js, npm, Firebase CLI, and Git toolchain required by VIA. The latest run also reported a physical Android 11 handset, but the handset was temporarily offline during that session.

### Completed checks

- demo-data validation: passed — 21 buses, 42 trips, 6 personas
- repository structure + secret-pattern validation: passed
- `flutter pub get`: passed
- `flutter analyze --no-pub`: passed with no issues
- Flutter tests: 11 passed
- backend `npm install`: passed
- backend lint: passed
- backend TypeScript typecheck: passed
- backend unit/domain tests: 10 passed; 4 emulator integration cases skipped because the Emulator Suite was not running

### Not yet verified

- Firebase Emulator integration: not yet executed with the Emulator Suite running
- APK/release build: outside the acceptance target for this portfolio package
- Physical-device app run/install: not verified because the handset was offline in the latest session
- Production deployment: intentionally not claimed

## Truth boundary

This record summarizes actual owner-machine output. It must not be edited to manufacture pass results and does not prove production readiness, staging concurrency verification, or a production deployment.

## Source-level verification command

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-windows.ps1
```
