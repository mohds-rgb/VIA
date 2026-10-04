import crypto from "node:crypto";
import { Request, Response } from "express";

export function ok(res: Response, data: unknown, requestId: string) {
  return res.status(200).json({ data, requestId });
}

export function fail(
  res: Response,
  status: number,
  code: string,
  message: string,
  requestId: string,
) {
  return res.status(status).json({
    error: { code, message, requestId },
  });
}

export function requestId(req: Request): string {
  return req.header("X-Request-Id") ?? crypto.randomUUID();
}
