# Contributing to VIA

This repository is maintained as an engineering portfolio project. Changes should preserve the security and evidence model from the VIA V6.1 specification.

## Before opening a pull request

1. Keep tenant boundaries explicit.
2. Keep high-impact writes behind trusted backend commands.
3. Add or update domain tests for state-machine changes.
4. Update API and Firestore documentation when contracts change.
5. Never commit credentials, signing keys, generated build artifacts, or local machine state.
6. Do not mark a feature `VERIFIED` or `RELEASED` without corresponding runtime/artifact evidence.

## Review focus

Reviewers should pay particular attention to authorization, transaction boundaries, idempotency behavior, migration safety, financial invariants, and failure/retry semantics.
