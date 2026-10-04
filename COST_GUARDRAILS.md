# Cost Guardrails

- No production billing is enabled by this repository.
- Emulator-first development is preferred.
- Avoid unbounded listeners.
- Paginate large collections.
- Keep Firestore reads proportional to visible data.
- Use server-side aggregation where it reduces repeated client reads.
- Record measured cost triggers before introducing new infrastructure.
- Never infer current provider pricing from memory; check official pricing documentation when a real deployment is planned.
