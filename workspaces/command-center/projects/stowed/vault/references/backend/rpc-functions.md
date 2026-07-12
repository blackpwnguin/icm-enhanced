---
project: stowed
type: reference
status: building
stage: 02-build
tags: [security, stowed, backend, supabase]
updated: 2026-06-12
---

# RPC functions

Server-side functions exposed to the iOS client via PostgREST at
`/rest/v1/rpc/<name>`. Every RPC here:

- Is SECURITY DEFINER (runs as the function owner so it can write across
  policy boundaries).
- Sets `search_path = public` to block search-path shadowing.
- Checks `auth.uid() is not null` at the top and raises with SQLSTATE
  `42501` ("insufficient privilege") if not.
- Validates inputs (length, allowed values) before any insert.
- Writes an `audit_log` row for every privileged action.
- Has `EXECUTE` revoked from `anon` and `public`, granted to `authenticated`.

The Supabase advisor flags every SECURITY DEFINER function that
`authenticated` can call. That warning is accepted: these RPCs ARE the
backend API. The acceptance is documented in [[backend-threat-model]].

## RPC catalog

### create_org_and_self_owner(name text) -> (organization_id uuid, warehouse_code text)
Creates an org and makes the caller its first active Owner. Generates a
unique 6-character warehouse_code from the same ambiguous-glyph-free
alphabet (`ABCDEFGHJKLMNPQRSTUVWXYZ23456789`) the iOS app uses. Writes
`org.created` to the audit log. The owner membership is created in the
same statement, so the org is never reachable without an Owner.

Validation: `name` trimmed, length 1-120, not null.

Errors: `not authenticated`, `organization name is required`,
`organization name is too long`.

### lookup_org_by_code(code text) -> (organization_id uuid, organization_name text)
Directory lookup for the Join flow. Returns ONLY the org id and display
name; never warehouse_code, never members, never any private data. This
is the server-side replacement for the iOS-side `findOrg(byCode:)`
identified as a leak risk in the UI-phase security review F6 (see
[[ui-phase-review]]).

Validation: `code` trimmed, uppercased, non-empty.

Returns zero rows when no org matches. iOS should treat zero rows as
"code not found" without distinguishing further.

### join_org_by_code(code text) -> (organization_id uuid, organization_name text, membership_status membership_status_t)
Submits a join request. Creates a `memberships` row with `role='employee'`
and `status='pending'`. Idempotent: if the caller already has any
membership in that org (pending, active, suspended), the existing status
is returned without modification. Writes `membership.requested` to the
audit log on a new request.

Errors: `not authenticated`, `code is required`,
`no organization found for that code`.

### approve_membership(membership_id uuid, role role_t) -> void
Owner approves a pending request and assigns `manager` or `employee`.
Cannot promote to `owner`; that path needs a separate transfer flow in a
future migration. Writes `membership.approved` to the audit log with the
assigned role.

Authorization: caller must be active owner of the same org as the
membership row.

Errors: `not authenticated`, `cannot assign owner via approval`,
`membership not found`, `membership is not pending`, `not authorized`.

### deny_membership(membership_id uuid) -> void
Owner rejects a pending request. Hard-deletes the membership row so the
target user can request again later if circumstances change. Writes
`membership.denied` to the audit log.

Authorization: caller must be active owner of the same org.

Errors: same shape as approve_membership.

### cancel_pending_membership(organization_id uuid) -> void
Self-service cancel. Lets the calling user remove their own pending
request for the given org. Backs the iOS `PendingApprovalView` "cancel"
affordance. Writes `membership.cancelled` to the audit log if a row was
actually removed.

No-op (no error, no audit row) if there is no pending request to cancel.

### set_member_role(membership_id uuid, role role_t) -> void
Owner changes another member's role between `manager` and `employee`.
Cannot promote to `owner` (use transfer flow) and cannot demote the
existing Owner. Writes `membership.role_changed` to the audit log with
the from/to pair.

Errors: `not authenticated`, `use transfer_ownership to assign owner`,
`membership not found or not active`,
`cannot demote owner; use transfer_ownership first`, `not authorized`.

### remove_member(membership_id uuid) -> void
Owner removes a member. Cannot remove the Owner (use transfer flow).
Writes `membership.removed` to the audit log.

Errors: parallel to `set_member_role`.

### generate_warehouse_code() -> text
Internal helper. EXECUTE is revoked from all client roles; only the
other RPCs (running as function owner) can call it. Lives in the public
schema for migration-history readability; not exposed via PostgREST.

## Errors and SQLSTATEs

Every "not authenticated" and "not authorized" failure raises with
SQLSTATE `42501`. The iOS client can map this code to the same "please
sign in again" or "you don't have access" UI state without parsing
English text. Other validation errors raise without an explicit
SQLSTATE, so they surface as PostgREST 500s with the message in the body.
A future migration could tighten these to `22000` or domain-specific
codes; not worth doing pre-traffic.

## Audit row shape

Every RPC writes to `audit_log` with this contract:

- `organization_id`: the org the action affected.
- `actor_user_id`: the caller (`auth.uid()`).
- `action`: dotted name (`org.created`, `membership.requested`,
  `membership.approved`, `membership.denied`, `membership.cancelled`,
  `membership.role_changed`, `membership.removed`).
- `target_type`: `organization` or `user`.
- `target_id`: the id of the affected entity.
- `payload`: jsonb with action-specific detail (the assigned role, the
  from/to pair for role changes, etc.).

Owners can read their org's audit log via the `audit: owner read` policy.

## What's not here (yet)

These belong in the next migration cut and are not yet implemented:

- `transfer_ownership(membership_id)`: hand Owner to another member.
- `advance_order_status(order_id, target_status)`: server-authoritative
  status transition that also decrements stock on `confirmed` and writes
  the `order_status_history` row.
- `record_payment(...)`: the owner-only payment write that takes a
  customer id, amount, method, and optional order_id, with an audit row.
- `cancel_order(order_id)`: reversing ledger entries when an order is
  past `confirmed`.

These don't block today's spec acceptance ([[spec-backend-phase]]), so
they're follow-up work. The iOS client can write payments and orders
through direct table mutations under RLS for now.

## See also

- [[rls-policies]] for what callers can do without an RPC.
- [[backend-threat-model]] for the abuse paths these RPCs are designed
  to close (timing-attack surface on warehouse_code, race conditions on
  membership state, audit-log tamper resistance).
