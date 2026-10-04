import crypto from "node:crypto";
import type { DocumentReference } from "firebase-admin/firestore";

export function idempotencyDocument(operatorRef: DocumentReference, command: string, key: string) {
  return operatorRef.collection("idempotency").doc(`${command}:${key}`);
}

export function requestFingerprint(value: unknown): string {
  return crypto.createHash("sha256").update(stableJson(value)).digest("hex");
}

function stableJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value !== null && typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, entry]) => `${JSON.stringify(key)}:${stableJson(entry)}`);
    return `{${entries.join(",")}}`;
  }
  return JSON.stringify(value) ?? "null";
}

export function readIdempotentResult<T>(
  snapshot: { exists: boolean; data(): Record<string, unknown> | undefined },
  fingerprint: string,
): T | undefined {
  if (!snapshot.exists) return undefined;
  const data = snapshot.data() ?? {};
  if (data.requestHash !== fingerprint) throw new Error("IDEMPOTENCY_KEY_REUSE");
  return data.result as T;
}
