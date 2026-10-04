# Security Test Cases

## Tenant isolation

Given:

- Actor belongs to operator A.
- Resource belongs to operator B.

Expected:

`TENANT_ACCESS_DENIED`

## Capability escalation

Given:

- Actor has `booking.read`.
- Command requires `booking.manage`.

Expected:

`PERMISSION_DENIED`

## Client role spoofing

Given:

- Request body contains `role=owner`.

Expected:

The server ignores the field and derives authorization from trusted membership context.
