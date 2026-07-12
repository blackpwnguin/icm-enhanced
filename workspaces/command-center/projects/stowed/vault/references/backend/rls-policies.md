---
project: stowed
type: reference
status: building
stage: 02-build
tags: [security, stowed, backend, rls, supabase]
updated: 2026-06-12
---

# RLS policies

Every public table has RLS enabled. Policies map directly to the capability
matrix in `apps/ios/Stowed/Stowed/Core/Models.swift`. The client-side
gating in `Role+Capabilities.swift` is interface only; this is the real
enforcement, per [[platform-shared-responsibility]].

## Pattern

Every policy uses the same inline subquery shape:

```sql
organization_id in (
  select organization_id from public.memberships
  where user_id = (select auth.uid())
    and status = 'active'
    and role in (<allowed roles>)
)
```

Two reasons not to wrap this in a SQL function:

1. Supabase's perf advisor treats `(select auth.uid())` as an initPlan
   when it appears inline. The planner runs it once per query, not once
   per row. Function-wrapped calls do not optimize as cleanly.
2. Every policy reads in place; the role list is right where you check
   it. No jumping to a helper to know what the policy actually permits.

## Policy table

Tenant-isolation column (`organization_id` or, for join tables, a subquery
on the parent table's `organization_id`) appears in every policy below.
"Members" means active membership of any role in the org.

### organizations
- SELECT: members
- UPDATE: owners
- DELETE: owners
- INSERT: blocked at policy layer; use `create_org_and_self_owner` RPC

### user_profiles
- SELECT (self): own row
- SELECT (org-mates): any active member of an org the caller is in
- UPDATE: own row
- INSERT: via the `on_auth_user_created` trigger only
- DELETE: cascades from `auth.users` only

### memberships
- SELECT (self): own row, any status (so iOS can route pending users)
- SELECT (org-mates): same org as caller, both active
- UPDATE: owners
- DELETE: owners
- INSERT: blocked at policy layer; use `join_org_by_code`,
  `create_org_and_self_owner`, or `approve_membership` RPCs

### locations, products, customers, customer_pricing
- SELECT: members
- INSERT: owners + managers
- UPDATE: owners + managers
- DELETE: owners + managers

Matches `canSetPrices` and `canManageCustomers`.

### stock_levels
- SELECT: members
- INSERT: members
- UPDATE: members
- DELETE: members

Matches `canAdjustStock = true` for every role. Employees scan and adjust
on the warehouse floor.

### stock_ledger
- SELECT: members
- INSERT: members
- UPDATE: blocked (append-only trigger raises)
- DELETE: blocked (append-only trigger raises)

### orders
- SELECT: members
- INSERT: members
- UPDATE: members (status pipeline transitions)
- DELETE: members (the iOS app uses status=cancelled instead of delete;
  delete remains available for true data correction)

### order_items
Gated via subquery on the parent order's `organization_id`.
- SELECT, INSERT, UPDATE, DELETE: members

### order_status_history
Gated via subquery on the parent order's `organization_id`.
- SELECT: members
- INSERT: members
- UPDATE: blocked (append-only trigger)
- DELETE: blocked (append-only trigger)

### payments, expenses, employee_costs
- SELECT: owners
- INSERT: owners
- UPDATE: owners
- DELETE: owners

Matches `canRecordPayments`, `canManageExpenses`, `canManagePayroll`.
Owner-only on both read and write.

### audit_log
- SELECT: owners
- INSERT, UPDATE, DELETE: REVOKED from `anon` and `authenticated`
- UPDATE, DELETE: also blocked by the append-only trigger

Writes happen only inside SECURITY DEFINER RPCs that run as the database
owner, bypassing the grant restrictions.

## Pending-user behavior

A user with `memberships.status = 'pending'` sees:
- Their own membership row (so the iOS app knows they are pending).
- Their own user_profile row.
- Nothing else. No org data. No org-mates. No products, orders, customers.

This is the contract from [[roles-and-permissions]]: "no data is visible
until approved." Verified by policy logic: every member-reading policy
filters on `status = 'active'`.

## Suspended users

`memberships.status = 'suspended'` is identical to pending for access
purposes (no active status, no read access). Suspension is a future
admin tool; the current RPCs do not set this status.

## Cross-tenant isolation test contract

For any pair of orgs A and B where Alice is owner of A and Bob is owner
of B, neither can read or write any per-org row from the other's org.
This is the regression test surface; the manual smoke from the spec
([[spec-backend-phase]] acceptance criteria) walks two seeded users
through this and asserts zero rows leak.

## Multiple-permissive-policies and accepted lint

Two tables keep two SELECT policies on purpose:
- `user_profiles`: "self select" plus "org-mates select"
- `memberships`: "self select" plus "org-mates select"

The advisor flags these as multiple permissive policies. Merging into one
OR-ed policy would obscure the rule. The cost is one extra subquery per
row on tables that will never grow into the millions, so the readability
wins.

## See also

- [[schema-applied]] for table shapes.
- [[rpc-functions]] for the writes that bypass these policies through
  SECURITY DEFINER.
- [[backend-threat-model]] for the cross-tenant, IDOR, and escalation
  paths these policies are meant to close.
