---
project: stowed
type: build-log
status: building
stage: 02-build
tags: [stowed, backend, supabase]
updated: 2026-06-12
---

# Build log: backend phase

What landed in the Supabase project `arqkutfkziicuxfesghm` on 2026-06-12.
The UI-phase build log is owned by the iOS session and lives at
`build-log-ui-phase.md`; this file is the backend equivalent and is
disjoint from it.

## Session 1 (2026-06-12): foundation

Goal: land the schema, RLS, and a small RPC surface that closes the
acceptance criteria in [[spec-backend-phase]] for the join flow. Out of
scope: edge functions, RevenueCat, Sentry, App Attest, iOS client
wiring. Those move to follow-up specs.

### What landed

Ten migrations, 0001 through 0010. See [[migration-history]] for the
table. Net result:

- 16 tables, all RLS-enabled.
- 2 views, both `security_invoker = true` with inline owner-only filters.
- 9 RPCs covering org creation, code lookup, join request, approve,
  deny, cancel, role change, remove. Internal helper `generate_warehouse_code`
  not exposed to clients.
- 3 append-only tables (`audit_log`, `order_status_history`,
  `stock_ledger`) enforced by a `block_audit_log_changes` trigger plus
  revoked grants on `audit_log`.
- 10 enums covering every state-machine and category field.
- `updated_at` maintained by a shared trigger on every table that has
  the column.
- `auth.users` insert mirrored into `public.user_profiles` via the
  `handle_new_auth_user` trigger.

### Decisions taken

- Three roles, not five. Decision doc: [[decision-3-role-collapse]].
- Email and password for v1, Apple Sign in later. Decision doc:
  [[decision-auth-email-password-v1]].
- RLS policies use the inline `(select auth.uid())` subquery pattern
  rather than a helper function, because Supabase's advisor only
  treats the inline form as an initPlan. See [[rls-policies]] for the
  pattern and [[backend-threat-model]] T8 for the search-path
  hardening that lets us keep doing this safely.
- Customer balances and gross profit are owner-only views, not views
  exposed to all members. Matches `canViewReceivables` and
  `canViewProfit` in `Models.swift`. Differs from the 2026-06-08 draft
  spec, which let managers see payments.
- `order_items.line_total` is a generated stored column so the views
  cannot disagree with the client's arithmetic.
- Audit log is part of the foundation, not deferred. Privileged
  actions write to it inside the same transaction as the action.

### Advisor pass

- Initial security scan: 2 mutable-search_path warnings on
  `set_updated_at` and `block_audit_log_changes`. Both fixed in 0009 by
  setting `search_path = public, pg_temp`.
- Initial security scan: 1 anon-callable SECURITY DEFINER on
  `handle_new_auth_user`. Fixed in 0009 by revoking EXECUTE from anon
  and authenticated (it's a trigger function, not an RPC).
- Initial security scan: 8 authenticated-callable SECURITY DEFINER
  warnings on the RPCs. Accepted; these are the RPC API. Documented
  in [[backend-threat-model]].
- Initial security scan: 1 anon-callable SECURITY DEFINER on
  Supabase-managed `rls_auto_enable`. Defense-in-depth revoke in 0010.
- Initial performance scan: 4 unindexed-FK warnings on
  `recorded_by_user_id` / `changed_by_user_id`. Indexes added in 0009.
- Initial performance scan: 11 multiple-permissive-policy warnings on
  SELECT, caused by `FOR ALL` write policies overlapping with read
  policies. Fixed in 0009 by splitting write policies into per-command
  INSERT/UPDATE/DELETE. Two retained on `user_profiles` and
  `memberships` because the "self plus org-mates" union IS the access
  rule; merging would obscure the intent.

### Verified manually via SQL inspection

- `list_tables(public)` shows 16 tables, every one with
  `rls_enabled = true`.
- `list_migrations` shows 0001 through 0010 in order.
- Both views are present and have the security_invoker option set.

### Not yet verified

These need real auth sessions, which means iOS client wiring or pgTAP
probes from a service-role connection switching to a per-user JWT:

- Cross-tenant isolation probe with two seeded owners (the
  [[spec-backend-phase]] acceptance criterion).
- Pending-user read-block probe.
- RPC happy-path and error-path probes.
- Manager attempting to read payments (must get zero rows).

These belong in 03-test as a pgTAP suite. Not blocking 02-build.

### What did not land this session

Carried forward to the next backend session:

- iOS client wiring (the other Claude Code session is handling this).
- `transfer_ownership`, `advance_order_status`, `record_payment`,
  `cancel_order` RPCs (see [[rpc-functions]] "What's not here (yet)").
- Edge Functions for any privileged work that needs the service role
  beyond what SECURITY DEFINER covers.
- RevenueCat entitlements.
- Sentry config (scrubbing) on the iOS side.
- App Attest verification on RPC calls.
- pgTAP regression suite.

### Open questions for Ish

- Whether the warehouse_code default length should stay at 6 or move to
  7 to match what's in `data-model-and-specs.md` (the spec said
  "for example, 7 characters"; the iOS implementation uses 6, the
  backend matches the iOS implementation).
- Whether to keep `org_plan_t` as a free enum or wire it to RevenueCat
  entitlement state once that lands.
- Whether owner self-demotion should be allowed at all, or whether the
  only path out of `owner` is `transfer_ownership` (which doesn't exist
  yet). Today the policy permits it; the threat-model section T2 flags
  this as a future trigger to add.

## Session 2 (2026-06-12): cross-tenant isolation verification

Goal: actually verify the spec acceptance criterion that "Row Level
Security blocks cross-tenant reads: a second Owner in a different
organization sees zero rows from the first." Not assume, prove.

### Setup

Two minimal `auth.users` rows inserted via service-role:
- Alice (Alpha owner): `7a5f8690-3c75-4076-b71f-8ce88be9c1b0`
- Bob (Bravo owner):   `5d835e01-e725-4a5e-ad28-ab8c47d091ce`

The `on_auth_user_created` trigger mirrored both into `public.user_profiles`
without service-role intervention. Verified: both names present.

Under JWT impersonation (`set local role authenticated; set local
"request.jwt.claims" = '{"sub": <uuid>, "role": "authenticated"}'`), each
user called `create_org_and_self_owner`:
- Alpha Coffee: org `5cdc3272-a240-4797-8115-759ad3d3af4e`, code `ZKHSJT`
- Bravo Beans:  org `484923c1-fc7b-4cec-9982-9a2725358e42`, code `HL86SV`

Both audit rows landed (`org.created`, by the right actor).

Each owner then seeded their org with a product, customer, and payment
via direct INSERTs under their own authenticated session.

### Two bugs found and fixed

Both surfaced as `42P17 infinite recursion detected in policy for
relation "memberships"`.

1. First hit during the Alpha seed (payments INSERT). The
   "org-mates select" policy on memberships subqueried memberships,
   which re-entered the same policy. Fixed in migration 0011 with the
   `public.user_org_ids()` SECURITY DEFINER helper.
2. Second hit during the cross-tenant write matrix (UPDATE on
   memberships). The owner-updates and owner-deletes policies on
   memberships subqueried memberships at write time, same shape.
   Fixed in migration 0012 with the `public.user_owned_org_ids()`
   helper.

Lesson captured in [[migration-history]]: any RLS policy that
subqueries memberships needs a SECURITY DEFINER helper rather than an
inline subquery. The eight other tables in the foundation use inline
subqueries against memberships and continue to work, because
memberships' SELECT RLS is now safe; converting them is an
optimization, not a correctness fix.

### Probe matrix and results

Positive control (Alice reading her own org): 1 row in each of
organizations, products, customers, payments, memberships. RLS is not
silently denying her own data.

Cross-tenant SELECT, every probe targeting Bravo's primary keys:

| Probe | Rows Alice saw |
|---|---|
| B.organization | 0 |
| B.products by org | 0 |
| B.products by pk | 0 |
| B.customers by org | 0 |
| B.customers by pk | 0 |
| B.payments by org | 0 |
| B.payments by pk | 0 |
| B.expenses by org | 0 |
| B.employee_costs by org | 0 |
| B.memberships by org | 0 |
| B.audit_log by org | 0 |
| B.user_profile (Bob) | 0 |
| B.customer_balances view | 0 |
| B.gross_profit_by_org view | 0 |

Cross-tenant write, every probe targeting Bravo's primary keys or org id:

| Probe | Rows affected |
|---|---|
| UPDATE B.products by pk | 0 |
| UPDATE B.customers by pk | 0 |
| UPDATE B.payments by pk | 0 |
| UPDATE B.memberships by org | 0 |
| UPDATE B.organizations by pk | 0 |
| DELETE B.payments by pk | 0 |
| DELETE B.products by pk | 0 |
| DELETE B.memberships by org | 0 |

INSERT into Bravo from Alice's session: rejected outright with
`42501: new row violates row-level security policy for table "products"`.
This is the correct shape; the with-check on the products INSERT policy
refuses the row before it is written.

### Post-probe integrity check

Service-role readback of Bravo's seeded rows:
- product name: `Bravo Espresso` (not `PWNED`)
- customer name: `Bravo Roastery` (not `PWNED`)
- payment amount: `250.00` (not `999999.99`)
- org name: `Bravo Beans` (not `PWNED`)
- owner membership role: `owner` (not demoted to `employee`)
- product count in Bravo: 1 (no `PLANTED-BY-ALICE` slipped in)
- audit_log: exactly two rows, one `org.created` per org by the right
  owner. No spurious entries from Alice's failed writes.

### Status

Spec acceptance criterion for cross-tenant isolation: VERIFIED.

This is a manual run, not a regression test. The same probes belong in
a pgTAP suite in 03-test. The shape is captured here so the suite can be
written against it; the data fixtures and IDs are throwaway and were
cleaned up at the end of the session.

## See also

- [[migration-history]]
- [[schema-applied]]
- [[rls-policies]]
- [[rpc-functions]]
- [[backend-threat-model]]
- [[decision-3-role-collapse]]
- [[decision-auth-email-password-v1]]
