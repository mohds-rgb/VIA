import { describe, expect, it } from "vitest";
import { requireAnyCapability, requireCapability, requireTenant } from "../src/auth/authorization.js";

const passenger = { uid: "p1", operatorId: "diamond-travel", capabilities: ["booking.create", "booking.read"] } as const;

describe("authorization policy", () => {
  it("allows passenger booking creation without granting management", () => {
    expect(() => requireAnyCapability(passenger, ["booking.create", "booking.manage"])).not.toThrow();
    expect(() => requireCapability(passenger, "booking.manage")).toThrow("PERMISSION_DENIED");
  });

  it("rejects cross-tenant access", () => {
    expect(() => requireTenant(passenger, "other-operator")).toThrow("TENANT_ACCESS_DENIED");
  });
});
