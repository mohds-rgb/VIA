# Requirements Traceability

| ID | Priority | Requirement | Implementation | Status |
|---|---|---|---|---|
| IAM-001 | P0 | Authenticated identity is required | Backend auth boundary | IMPLEMENTED |
| IAM-002 | P0 | Tenant membership is server-derived | authorization helper | IMPLEMENTED |
| SEC-001 | P0 | Client cannot choose role/capabilities | authorization helper | IMPLEMENTED |
| DATA-001 | P0 | Seat ownership is transaction-controlled | booking service | IMPLEMENTED |
| DATA-002 | P0 | Seat hold uses trusted server-controlled expiry | booking service | IMPLEMENTED |
| API-001 | P1 | Versioned HTTPS API | `/v1` contract | IMPLEMENTED |
| API-002 | P0 | Mutations support idempotency | idempotency boundary | IMPLEMENTED |
| DOM-001 | P1 | Booking state machine | domain model | IMPLEMENTED |
| DOM-002 | P1 | Ticket lifecycle | domain model | IMPLEMENTED |
| I18N-001 | P1 | Arabic/English boundary | localization resources | IMPLEMENTED |
| REL-001 | P0 | No destructive migration by default | migration plan | DESIGNED |
| REL-002 | P0 | Production claims require evidence | project controls | IMPLEMENTED |

`IMPLEMENTED` means repository source/documentation exists; it does not imply production deployment.
