import { z } from "zod";

export const HoldSeatsSchema = z.object({
  tripId: z.string().min(1),
  seatIds: z.array(z.string().min(1)).min(1).max(8),
  fareMode: z.enum(["oneWay", "roundTrip"]).default("oneWay"),
});

export const IdempotencyKeySchema = z.string().trim().min(8).max(128).regex(/^[A-Za-z0-9._:-]+$/);

export const TripSearchSchema = z.object({
  origin: z.string().min(1).optional(),
  destination: z.string().min(1).optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export type HoldSeatsInput = z.infer<typeof HoldSeatsSchema>;
