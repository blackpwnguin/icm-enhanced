---
project: stowed
type: reference
status: building
stage: 02-build
tags: [security, stowed, backend, threat-model]
updated: 2026-06-16
---

# Backend threat model: threats and mitigations

Spoke of [[backend-threat-model]]. Covers T1 through T11, the threat
catalog with mitigations and residual risk.

## Threats and mitigations

### T1. Cross-tenant data read

Threat: a user from Org A reads rows from Org B.

Mitigation: every business-scoped table FKs to `organizations(id)` and
every RLS policy filters on `organization_id in (select organization_id
from memberships where user_id = (select auth.uid()) and status =
'active')`. Same shape for SELECT, INSERT, UPDATE, DELETE.

Residual: someone with the service role key (the powerful key that bypasses
RLS) can read everything. That key never ships in the client and lives
only in server-side configuration. See [[platform-shared-responsibility]].

Verification: executed manually on 2026-06-12 against the live project.
Two seed users (Alice = Alpha owner, Bob = Bravo owner) under impersonated
JWT sessions. Alice ran the full read matrix (organizations, products,
customers, payments, expenses, employee_costs, memberships, audit_log,
user_profiles, and both views) against Bravo's primary keys: every probe
returned 0 rows. Alice then attempted UPDATE on Bravo's products,
customers, payments, memberships, organizations and DELETE on Bravo's
products, payments, memberships: every write affected 0 rows. A direct
INSERT into Bravo's org with Alice's session was rejected with
`42501: new row violates row-level security policy for table "products"`.
Service-role readback confirmed Bravo's seeded values were untouched.
The probe and results are in [[build-log-backend-phase]] (session 2).

Two recursion bugs surfaced and were fixed during this test (migrations
0011 and 0012). See [[migration-history]] for the lesson. Encode the
matrix as a pgTAP suite in 03-test so this doesn't regress silently.

### T2. Role escalation within an org

Threat: a manager elevates themselves to owner, or an employee writes to
payments.

Mitigation: enums (`role_t`) restrict the value space. The
`set_member_role` RPC refuses to assign `owner` and refuses to demote an
existing owner. The `approve_membership` RPC refuses to assign `owner`.
Payments/expenses/employee_costs policies require active owner status
on every command (SELECT, INSERT, UPDATE, DELETE). A manager calling the
payments REST endpoint gets zero rows on read and zero rows affected on
write.

Residual: an owner can demote themselves only by writing the
memberships table directly, then the org has no owner. Future migration
should add a trigger ensuring at least one active owner per org.

### T3. Pending-user data exposure

Threat: someone with the warehouse_code joins, pending state, and reads
inventory or customer data before approval.

Mitigation: every member-reading policy filters on `status = 'active'`. A
pending membership row exists but does not grant read access to any
per-org table. The pending user CAN see their own user_profile and their
own membership (so the iOS pending-approval screen can route correctly),
nothing else.

Residual: org name leaks through `lookup_org_by_code`, by design. This
is required for the iOS Join flow to show the user what they are joining.

### T4. Warehouse_code brute force

Threat: someone iterates codes through `lookup_org_by_code` or
`join_org_by_code` to discover orgs.

Mitigation: 6-character codes over a 32-character alphabet =
~1.07 billion possible codes. Supabase Auth applies built-in rate
limiting per IP and per user. Both RPCs require an authenticated session
(`auth.uid()` check at top), which means the attacker has to mint and
maintain auth sessions to query at scale.

Residual: a determined attacker with many accounts could harvest org
names over time. Mitigation if the threat materializes: rotate codes,
shorten the `lookup_org_by_code` return surface to just `organization_id`
(force the user to type the name they expect), or add a per-actor rate
limit at the function level.

### T5. Membership-state race

Threat: a user calls `join_org_by_code` twice in parallel and ends up
with two memberships, or `approve_membership` is called twice from two
owner devices and the second call corrupts state.

Mitigation: `memberships` has `unique (user_id, organization_id)`, so a
duplicate insert errors. `join_org_by_code` checks for an existing
membership and returns the existing state idempotently.
`approve_membership` reads the row's status and refuses if not pending.
Postgres transactions provide the atomicity.

Residual: none under default isolation. If we ever switch to
`READ UNCOMMITTED` (we won't), all bets are off.

### T6. Audit-log tampering

Threat: an owner or a compromised authenticated session edits or deletes
their own audit history.

Mitigation: three layers:
1. RLS grants on `audit_log` only allow SELECT to owners. INSERT, UPDATE,
   DELETE are revoked from `anon` and `authenticated` at the GRANT layer.
2. A trigger raises on every UPDATE and DELETE attempt regardless of who
   the caller is.
3. Writes happen only inside SECURITY DEFINER RPCs that the database
   trusts. The audit row is written in the same transaction as the
   privileged action; either both land or neither does.

Residual: someone with direct Postgres access (the service role, the
database password, or shell on the host) can drop the trigger, revoke
the grants, and rewrite history. That's the same threat surface as any
audit log on any database; protect the credentials, not just the schema.

### T7. SQL injection via RPC inputs

Threat: a malicious string parameter to one of the RPCs escapes into a
query.

Mitigation: every RPC uses parameterized PL/pgSQL with no `EXECUTE`
calls on untrusted strings. The only inputs treated as code are values
typed as text, uuid, or `role_t`, and they are used through normal
parameter binding. `format(...)` is never called with user input on the
write path.

Residual: none under this design. Any future RPC that uses
`EXECUTE format(...)` with user input is a regression to flag in review.

### T8. Search-path shadowing in SECURITY DEFINER functions

Threat: a malicious role creates `public.now()` or
`public.gen_random_uuid()` to shadow the built-in and intercept the
SECURITY DEFINER function's writes.

Mitigation: every SECURITY DEFINER function sets
`search_path = public` (or `public, pg_temp`). The non-definer trigger
functions `set_updated_at` and `block_audit_log_changes` are also
pinned in 0009 because plpgsql still resolves through search_path.

Residual: someone with CREATE rights on the public schema can still
shadow non-pg_catalog symbols. We do not grant CREATE on public to
`anon` or `authenticated`. Future change: move our functions to a
private schema (`stowed_priv`) and only expose RPCs through the public
schema as views or wrappers.

### T9. View-based RLS bypass

Threat: a view returns rows to a user that the underlying RLS policies
would not.

Mitigation: both `customer_balances` and `gross_profit_by_org` are
created with `with (security_invoker = true)` so the caller's RLS is
applied to the base tables. They also include an inline owner-only
WHERE filter, so even a misconfigured policy on the underlying tables
cannot leak rows to non-owners through the view.

Residual: none for these two views. Any new view in this project MUST
set `security_invoker = true`; this is a code-review check.

### T10. Trigger function on auth.users exposed as RPC

Threat: an unauthenticated caller invokes the public RPC for the
auth-user mirror trigger and creates spurious user_profile rows.

Mitigation: 0009 revokes EXECUTE on `public.handle_new_auth_user()` from
`anon` and `authenticated`. The trigger itself fires from `auth.users`
INSERT and runs as the function owner, not the caller, so the revoke
does not affect normal signup.

Residual: none.

### T11. Auth.uid() spoofing

Threat: an attacker forges a JWT or replays one to assume another user.

Mitigation: out of scope here. Supabase Auth signs JWTs with the
project's JWT secret; verification is in PostgREST. If the JWT secret
leaks, rotate it in the Supabase dashboard, which invalidates all
existing sessions.

Residual: a stolen JWT until expiry. The iOS client stores tokens in
Keychain (Apple platform responsibility, [[platform-shared-responsibility]]).
