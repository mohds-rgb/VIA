# Publishing VIA to GitHub

This package is prepared as a source portfolio repository. The final public history should be created under the project owner's GitHub account.

## First publish

```powershell
git init
git add .
git commit -m "Initial VIA engineering portfolio"
git branch -M main
git remote add origin https://github.com/mohds-rgb/via
# create the repository at GitHub, then:
git push -u origin main
```

## Keep out of GitHub

Never commit:

- `.env` files
- `google-services.json`
- Firebase service-account credentials
- private signing keys
- passwords or access tokens
- real customer/user data
- raw local logs containing machine or device identifiers

## Recommended README tour

1. `README.md`
2. `docs/DEMO_SCENARIO.md`
3. `docs/ARCHITECTURE.md`
4. `docs/ENGINEERING_HIGHLIGHTS.md`
5. `functions/src/bookings/hold.ts`
6. `functions/src/bookings/confirm_cash.ts`
7. `firebase/firestore.rules`
8. `docs/VERIFICATION_STATUS.md`
