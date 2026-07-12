---
project: stowed
type: reference
status: building
stage: 02-build
tags: [stowed, backend, schema, supabase]
updated: 2026-06-12
---

# Schema as applied

What is actually in the Supabase project `arqkutfkziicuxfesghm` after the
backend foundation migrations landed. This is the authoritative shape; the
older `~/Downloads/schema.sql` was the predecessor draft and is now
superseded. See [[migration-history]] for the migration list and
[[decision-3-role-collapse]] for why the role enum is three values, not five.

## Tables (16)

Tenancy:
- `organizations`
- `user_profiles`
- `memberships`

Inventory:
- `locations`
- `products`
- `stock_levels`
- `stock_ledger` (append-only, enforced by trigger)

Customers and pricing:
- `customers`
- `customer_pricing`

Orders and fulfillment:
- `orders`
- `order_items`
- `order_status_history` (append-only, enforced by trigger)

Financials:
- `payments`
- `expenses`
- `employee_costs`

Audit:
- `audit_log` (append-only, enforced by trigger + revoked write grants)

## Views (2)

Both use `security_invoker = true` and add an inline owner-only filter so
the financial roll-ups they expose only return rows to active owners.

- `customer_balances`: per-customer invoiced vs paid, balance, and store
  credit. Powers the Money view's accounts receivable.
- `gross_profit_by_org`: revenue, cost of goods sold, gross profit per
  org, computed from completed orders only.

## Enums

Every state-machine and category field is a Postgres enum, not text plus
check. Cheaper to validate, cleaner errors, and the iOS client gets a
single source of truth via the generated types.

- `role_t`: `owner`, `manager`, `employee`
- `membership_status_t`: `active`, `pending`, `suspended`
- `org_plan_t`: `starter`, `growth`, `pro`
- `order_status_t`: `draft`, `confirmed`, `packed`, `shipped`, `completed`, `cancelled`
- `payment_method_t`: `cash`, `check`, `card`, `transfer`, `store_credit`
- `expense_category_t`: `rent`, `utilities`, `supplies`, `shipping`, `payroll`, `other`
- `stock_reason_t`: `received`, `sold`, `damaged`, `count_fix`, `transfer_in`, `transfer_out`
- `stock_reference_type_t`: `order`, `adjustment`, `manual`
- `location_type_t`: `warehouse`, `retail`, `transit`, `other`
- `cost_type_t`: `wage`, `salary`, `bonus`, `commission`

## Key shape decisions vs the predecessor draft

1. Three roles. The 2026-06-08 `schema.sql` had five (owner, admin,
   manager, staff, viewer). The 2026-06-11 distillation in
   [[roles-and-permissions]] and `Models.swift` collapsed to three. The
   applied schema follows the frontend. See [[decision-3-role-collapse]].
2. `order_items.line_total` is a `GENERATED ALWAYS AS (quantity * unit_price) STORED`
   column. The predecessor draft had it as a manually-written numeric.
   Generated columns make the gross-profit view bulletproof against
   client math errors.
3. `audit_log` is part of the foundation, not deferred to a later cut.
   Privileged actions write to it from inside SECURITY DEFINER RPCs.
4. Views use `security_invoker = true`. Without it, views silently bypass
   RLS and become a tenant-isolation hole.
5. Payments, expenses, and employee_costs are owner-only on both read and
   write, matching `canRecordPayments`, `canManageExpenses`, and
   `canManagePayroll` in `Models.swift`. The predecessor draft let
   managers read payments; that doesn't match the frontend.
6. `unit_price` and `unit_cost` on `order_items` are still snapshotted at
   order time (frontend writes them in). Historical orders never get
   rewritten by later price or cost changes.
7. `updated_at` columns are maintained by a shared `set_updated_at()` trigger,
   not by client writes. Removes a class of "forgot to bump updated_at" bugs.

## Append-only invariants

Three tables are append-only at the application contract level:

- `stock_ledger`
- `order_status_history`
- `audit_log`

Enforced by a `block_audit_log_changes()` trigger on BEFORE UPDATE and
BEFORE DELETE that raises an exception. For `audit_log`, INSERT/UPDATE/DELETE
are also revoked from `anon` and `authenticated` at the grant layer. Writes
happen only through SECURITY DEFINER RPCs.

## Tenancy invariants

- Every business-scoped table FKs to `organizations(id) on delete cascade`.
- Deleting an organization cascades to every per-org row except `auth.users`
  themselves (memberships drop, the user account survives).
- Every RLS policy filters on `organization_id in (select organization_id
  from memberships where user_id = (select auth.uid()) and status = 'active'
  and ...)`. The wrapped `(select auth.uid())` form is required for the
  query planner to treat the call as an initPlan that runs once per query
  rather than once per row, per Supabase's RLS performance guidance.

## Indexes

Every FK gets a covering index, every (`organization_id`, `status`) pair
that filters in policies has a composite index. Indexes that the Supabase
advisor flagged as "unused" are correct to leave in place for foreign-key
checks and for future query shapes; they will start serving reads once
real traffic arrives.

## What the client sees

iOS hits PostgREST against:
- The 16 tables directly, for normal CRUD that RLS permits.
- The 2 views, for owner financials.
- The 9 RPCs listed in [[rpc-functions]] for everything that needs server
  authority (creating an org, joining by code, approving/denying members,
  changing roles, removing members).

## See also

- [[migration-history]] for the migration timeline.
- [[rls-policies]] for the policy-by-policy reference.
- [[rpc-functions]] for the RPC interface.
- [[backend-threat-model]] for what this design defends against.
- [[platform-shared-responsibility]] for the principle layer behind it.
