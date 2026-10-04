import { describe, expect, it } from "vitest";
import { TICKET_COMMISSION_POLICY, calculateCommissionSyp } from "../src/domain/commission.js";

describe("ticket commission", () => {
  it("keeps the policy snapshot deterministic", () => {
    expect(TICKET_COMMISSION_POLICY.policyVersion).toBe("ticket-commission-v1");
    expect(calculateCommissionSyp(50)).toBe(2);
    expect(calculateCommissionSyp(90)).toBe(4);
  });
});
