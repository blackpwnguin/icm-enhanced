---
project: stowed
type: reference
status: building
stage: 02-build
tags: [security, stowed, backend, threat-model]
updated: 2026-06-16
---

# Backend threat model: RPC surface acceptance and out of scope

Spoke of [[backend-threat-model]]. Covers the accepted SECURITY DEFINER
RPC surface and the concerns deferred to follow-up specs.

## RPC surface acceptance

Supabase's security advisor warns on every SECURITY DEFINER function that
`authenticated` can EXECUTE. After 0012 we have 10 such warnings,
corresponding to:

- create_org_and_self_owner
- lookup_org_by_code
- join_org_by_code
- approve_membership
- deny_membership
- cancel_pending_membership
- set_member_role
- remove_member
- user_org_ids (RLS helper, returns the caller's active-member org ids)
- user_owned_org_ids (RLS helper, returns the caller's active-owner org ids)

These warnings are accepted because:

1. The functions ARE the backend's privileged-write API. They cannot run
   under SECURITY INVOKER because they must atomically write to tables
   the caller's RLS does not permit (audit_log, the target's
   memberships row, etc.).
2. EXECUTE is revoked from `anon` and granted only to `authenticated`,
   so the surface is minimum.
3. Every function checks `auth.uid() is not null` at the top and raises
   `42501` if not, so an unauthenticated caller cannot execute even if
   the grant slipped.
4. Inputs are validated before any write.
5. Search_path is pinned, so search-path shadowing fails.

For the two helpers specifically: the SQL body filters on
`user_id = (select auth.uid())`, so calling the helper returns only
the caller's own org ids. Calling it is no escalation; the caller could
equivalently compute the same value via a direct `select organization_id
from memberships where user_id = auth.uid()`.

A future hardening pass can move all of these (RPCs and helpers) to a
`stowed_api` or `stowed_priv` schema exposed through PostgREST's
allow-list and clear the lint. Today the cost-benefit does not justify
the schema reshuffle.

## Out of scope for this iteration

These are real concerns and they belong in follow-up specs:

- Field-level encryption for payroll amounts (`employee_costs.amount`).
- Per-tenant rate limiting (current rate limiting is per-IP via Supabase
  Auth).
- App Attest verification on RPC calls (planned per
  [[platform-shared-responsibility]]).
- Sentry scrubbing config (the iOS client side).
- Privacy manifest (`PrivacyInfo.xcprivacy`) and Privacy Nutrition Labels.
- pgTAP regression suite for RLS, scheduled for 03-test.
