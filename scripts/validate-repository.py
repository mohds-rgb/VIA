from pathlib import Path

required = [
    "README.md",
    "GITHUB_SETUP.md",
    "PROJECT_STATE.md",
    "OPEN_QUESTIONS.md",
    "ASSUMPTIONS.md",
    "DELIVERY_MANIFEST.md",
    "SECURITY.md",
    "CONTRIBUTING.md",
    "docs/ARCHITECTURE.md",
    "docs/API_CONTRACT.md",
    "docs/REQUIREMENTS.md",
    "docs/DATA_MIGRATION_PLAN.md",
    "docs/FIRESTORE_MODEL.md",
    "firebase/firestore.rules",
    "firebase/storage.rules",
    "functions/src/index.ts",
    "functions/src/bookings/hold.ts",
    "functions/src/bookings/cash_confirmation.ts",
    "functions/src/bookings/confirm_cash.ts",
    "functions/src/trips/list.ts",
    "functions/src/trips/seats.ts",
    "functions/src/infra/idempotency.ts",
    "functions/src/domain/commission.ts",
    "functions/test/emulator/booking_flow.emulator.test.ts",
    "assets/branding/via-app-icon.png",
    "docs/BRANDING.md",
    "scripts/validate-demo-data.py",
    "data/demo/trips.json",
    "data/demo/buses.json",
    "functions/eslint.config.mjs",
    "apps/mobile/lib/main.dart",
]

missing = [p for p in required if not Path(p).exists()]
if missing:
    print("Missing required files:")
    for item in missing:
        print(f"- {item}")
    raise SystemExit(1)

forbidden_fragments = ["-----BEGIN PRIVATE KEY-----", "AIzaSy", "serviceAccount"]
tracked_text = []
for path in Path(".").rglob("*"):
    if not path.is_file() or path == Path("scripts/validate-repository.py") or ".git" in path.parts or path.suffix.lower() not in {".md", ".ts", ".dart", ".json", ".yaml", ".yml", ".py", ".arb", ".rules", ".gradle", ".kts", ".txt"}:
        continue
    try:
        tracked_text.append(path.read_text(errors="ignore"))
    except OSError:
        pass
joined = "\n".join(tracked_text)
for fragment in forbidden_fragments:
    if fragment in joined:
        print(f"Potential secret material detected: {fragment}")
        raise SystemExit(1)

print(f"Repository structure OK: {len(required)} required files found.")
print("Secret-pattern scan OK.")
