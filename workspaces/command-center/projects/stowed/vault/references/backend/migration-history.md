---
project: stowed
type: reference
status: building
stage: 02-build
tags: [stowed, backend, supabase]
updated: 2026-06-12
---

# Migration history

Supabase project `arqkutfkziicuxfesghm`. Migrations applied in order via
the Supabase MCP `apply_migration` tool on 2026-06-12.

| Version | Name | What |
|---|---|---|
| 0001 | `init_enums` | All 10 Postgres enums (role_t, membership_status_t, org_plan_t, order_status_t, payment_method_t, expense_category_t, stock_reason_t, stock_reference_type_t, location_type_t, cost_type_t). |
| 0002 | `tenancy_tables` | organizations, user_profiles, memberships. Indexes on memberships (organization_id, status) and (user_id). |
| 0003 | `inventory_tables` | locations, products, stock_levels, stock_ledger. FK indexes on each. |
| 0004 | `customers_orders_financials` | customers, customer_pricing, orders, order_items (with generated `line_total`), order_status_history, payments, expenses, employee_costs. |
| 0005 | `audit_log` | audit_log table plus the shared `block_audit_log_changes` trigger function, attached to audit_log, order_status_history, and stock_ledger to enforce append-only on UPDATE/DELETE. |
| 0006 | `views_and_triggers` | customer_balances and gross_profit_by_org views (security_invoker=true, owner-only WHERE filter). set_updated_at trigger function and triggers on every table with updated_at. handle_new_auth_user trigger on auth.users to mirror new users into user_profiles. |
| 0007 | `rls_enable_and_policies` | Enable RLS on all 16 tables. Initial set of capability-matched policies. |
| 0008 | `rpc_functions` | 9 SECURITY DEFINER RPCs: generate_warehouse_code (internal), create_org_and_self_owner, lookup_org_by_code, join_org_by_code, approve_membership, deny_membership, cancel_pending_membership, set_member_role, remove_member. EXECUTE revoked from anon, granted to authenticated. |
| 0009 | `advisor_hardening` | Pinned search_path on `set_updated_at` and `block_audit_log_changes`. Revoked EXECUTE on `handle_new_auth_user` from anon/authenticated (it's a trigger function, not an RPC). Added covering indexes on the four `recorded_by_user_id` / `changed_by_user_id` FKs the advisor flagged. Split every FOR ALL write policy into per-command INSERT/UPDATE/DELETE policies to remove "multiple permissive policies for SELECT" lint. |
| 0010 | `revoke_rls_auto_enable_execute` | Defense in depth: revoked EXECUTE on the Supabase-managed `rls_auto_enable` event-trigger function from anon and authenticated so it doesn't show up on the PostgREST API surface. The event trigger still fires (event triggers run as the function owner). |
| 0011 | `fix_memberships_rls_recursion` | Bug fix. Cross-tenant isolation testing hit `42P17 infinite recursion detected in policy for relation "memberships"` during a seed insert. Root cause: the "org-mates select" policies on memberships and user_profiles subquery memberships, which itself has RLS, so the same policy chain re-enters. Fix: introduced SECURITY DEFINER helper `public.user_org_ids()` that bypasses memberships RLS to return the caller's active-membership org list. Rewrote both org-mates SELECT policies to use the helper. EXECUTE granted only to `authenticated`. |
| 0012 | `fix_memberships_write_recursion` | Second instance of the same bug. UPDATE and DELETE on memberships (and organizations) also subqueried memberships inline, triggering recursion at write time. Added `public.user_owned_org_ids()` helper (active owner org ids) and rewrote `memberships`/`organizations` UPDATE and DELETE policies to use it. |

## How to inspect

Via the MCP:

```
mcp__supabase__list_migrations
mcp__supabase__list_tables  schemas=["public"]  verbose=true
mcp__supabase__get_advisors  type="security"
mcp__supabase__get_advisors  type="performance"
```

Via SQL:

```sql
select version, name from supabase_migrations.schema_migrations
order by version;
```

## Outstanding advisor lints, accepted

After 0012, the security advisor still warns about 8 functions:
`approve_membership`, `cancel_pending_membership`,
`create_org_and_self_owner`, `deny_membership`, `join_org_by_code`,
`lookup_org_by_code`, `remove_member`, `set_member_role`. These are the
RPC API; EXECUTE is correctly granted to `authenticated`. The advisor
flags every SECURITY DEFINER function reachable as an RPC. Accepted.
Rationale in [[backend-threat-model]] (RPC surface section).

The performance advisor still flags:
- Many "unused index" lints. Expected on a zero-row database; will start
  serving once real traffic arrives.
- Two "multiple permissive policies for SELECT" on user_profiles and
  memberships. Retained on purpose: the union of "self" and "org-mates"
  is the actual access rule. Documented in [[rls-policies]].

## Reverting

There is no `down` migration for the foundation. If the project needs to
be wiped, recreate the Supabase project from scratch and re-apply 0001
through 0012 in order. Versioned rollbacks become useful once we are
past the foundation cut and into incremental features.

## Lesson: RLS subqueries against memberships need SECURITY DEFINER helpers

0011 and 0012 are the same shape of bug. Any RLS policy whose USING or
WITH CHECK subqueries memberships directly will recurse once memberships
itself has more than the trivial `user_id = auth.uid()` policy on it.
Pattern moving forward: write a SECURITY DEFINER, STABLE,
`search_path = public` helper that returns the set of org ids the caller
cares about for that policy. Policies reference the helper, never inline
the memberships subquery. The two helpers shipped:

- `public.user_org_ids()` returns active-member org ids
- `public.user_owned_org_ids()` returns active-owner org ids

A `user_managed_org_ids()` helper (owner + manager) is a likely add when
the next batch of policies needs it.

The eight other tables in the foundation still use the inline subquery
pattern. They work today because their subqueries are against
memberships' SELECT RLS, which is now safe via the helper. Migrating
them to the helper is an optimization (one fewer subquery layer per
read), not a correctness issue.
