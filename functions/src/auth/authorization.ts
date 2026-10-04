import type { DecodedIdToken } from "firebase-admin/auth";

export interface ActorContext {
  uid: string;
  operatorId: string;
  capabilities: readonly string[];
}

export function requireCapability(actor: ActorContext, capability: string): void {
  if (!actor.capabilities.includes(capability)) throw new Error("PERMISSION_DENIED");
}

export function requireAnyCapability(actor: ActorContext, capabilities: readonly string[]): void {
  if (!capabilities.some((capability) => actor.capabilities.includes(capability))) {
    throw new Error("PERMISSION_DENIED");
  }
}

export function requireTenant(actor: ActorContext, operatorId: string): void {
  if (actor.operatorId !== operatorId) throw new Error("TENANT_ACCESS_DENIED");
}

export function candidateOperatorId(decoded: DecodedIdToken): string {
  const operatorId = decoded.operatorId;
  if (typeof operatorId !== "string" || operatorId.length === 0) {
    throw new Error("AUTH_CONTEXT_INCOMPLETE");
  }
  return operatorId;
}
