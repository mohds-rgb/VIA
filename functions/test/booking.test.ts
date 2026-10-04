import { describe, expect, it } from "vitest";
import { assertTransition, canTransition } from "../src/domain/booking.js";

describe("booking state machine", () => {
  it("allows held -> awaitingCashConfirmation", () => {
    expect(canTransition("held", "awaitingCashConfirmation")).toBe(true);
  });

  it("allows awaitingCashConfirmation -> confirmed", () => {
    expect(canTransition("awaitingCashConfirmation", "confirmed")).toBe(true);
  });

  it("rejects initiated -> boarded", () => {
    expect(canTransition("initiated", "boarded")).toBe(false);
  });

  it("rejects held -> confirmed so cash confirmation cannot skip the workflow", () => {
    expect(canTransition("held", "confirmed")).toBe(false);
  });

  it("throws for an illegal transition", () => {
    expect(() => assertTransition("initiated", "boarded")).toThrow("ILLEGAL_BOOKING_TRANSITION");
  });
});
