# Assumptions

These are implementation assumptions for the portfolio repository, not production approvals.

1. Firebase is the authoritative backend boundary for V1.
2. Google Sign-In is the intended authentication provider.
3. Cash is the primary passenger payment workflow.
4. Firestore transactions are used for seat ownership transitions.
5. Server timestamps are authoritative for hold expiry.
6. Client state is never authoritative for booking or financial state.
7. The initial portfolio implementation focuses on the passenger booking vertical slice.
8. Production credentials and signing material are intentionally excluded.
9. Real production deployment requires owner-controlled decisions and environment configuration.
