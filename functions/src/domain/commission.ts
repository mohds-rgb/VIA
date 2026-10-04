export const TICKET_COMMISSION_POLICY = {
  mode: "percentage" as const,
  value: 4,
  policyVersion: "ticket-commission-v1",
};

export function calculateCommissionSyp(fareSyp: number): number {
  if (!Number.isInteger(fareSyp) || fareSyp < 0) throw new Error("INVALID_FARE");
  return Math.round((fareSyp * TICKET_COMMISSION_POLICY.value) / 100);
}
