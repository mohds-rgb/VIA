# Engineering Highlights

This page explains the design choices most likely to matter in a technical review.

## 1. Seat booking is treated as a concurrency problem

The seat hold command reads the trip and all requested seat documents inside a Firestore transaction. A seat is only moved from `available` to `held` when its state still matches the expected value. This prevents the client from becoming the authority over seat ownership.

## 2. Retries are expected, not exceptional

Each command uses an idempotency key plus a request fingerprint. Replaying the same command can return the same outcome, while reusing the same key for a different request is rejected.

## 3. Financial state is server-owned

The fare used for a booking is captured as a snapshot. Ticket creation, the cash transaction, and the commission business event happen from the same trusted confirmation boundary rather than being assembled by the mobile client.

## 4. Authorization is capability-driven

A verified identity is not enough to perform every action. The backend derives tenant membership and checks the capability required by the command.

## 5. Demo Mode is separated from the production-shaped adapter

The app can be reviewed without credentials because the entry point uses an in-memory repository. This is deliberately separated from `RemoteBookingRepository`, which models the trusted API boundary. The demo is therefore useful without being misrepresented as a live backend.

## 6. Scope is intentionally bounded

The repository implements the passenger booking vertical slice deeply enough to demonstrate architecture and engineering judgement. Larger product areas from the full VIA specification remain documented as future scope rather than being represented as completed features.
