# Release Plan

## Portfolio release

The GitHub repository is the current deliverable.

## Future executable release gate

Before an APK can be called released:

1. Configure a real staging environment.
2. Run dependency and secret checks.
3. Run unit/integration/security tests.
4. Execute real staging concurrency verification.
5. Build the APK.
6. Verify the actual APK file exists and has non-zero size.
7. Record SHA-256.
8. Smoke-test the actual APK on the approved device matrix.
9. Record build versions and command.
10. Package the source repository.
11. Reconcile `DELIVERY_MANIFEST.md`.

No step above is represented as completed merely because the source files exist.
