import { describe, expect, it } from "vitest";
import { requestFingerprint } from "../src/infra/idempotency.js";

describe("idempotency fingerprints", () => {
  it("is stable when object key order changes", () => {
    expect(requestFingerprint({ a: 1, b: 2 })).toBe(requestFingerprint({ b: 2, a: 1 }));
  });

  it("changes when the command input changes", () => {
    expect(requestFingerprint({ tripId: "t1", seatIds: ["A01"] }))
      .not.toBe(requestFingerprint({ tripId: "t1", seatIds: ["A02"] }));
  });
});
