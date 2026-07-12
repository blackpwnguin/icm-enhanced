---
project: stowed
type: reference
status: building
stage: 02-build
tags: [security, stowed, backend, threat-model]
updated: 2026-06-16
---

# Backend threat model

What the backend defends against, how, and where the residual risk lives.
Pairs with [[platform-shared-responsibility]], which covers the Apple side
of the line, and [[ui-phase-review]], which covered the iOS code.

This note is a hub. The assets and trust boundaries are below; the threat
catalog and the RPC acceptance rationale live in the spokes listed under
Sections.

## Sections

- [[backend-threat-model-threats]] — T1 through T11, the full threat
  catalog with mitigations and residual risk.
- [[backend-threat-model-rpc-acceptance]] — the accepted SECURITY DEFINER
  RPC surface and what is out of scope for this iteration.

## Assets

In rough order of sensitivity:

1. Employee cost / payroll rows (`employee_costs`).
2. Financials (`payments`, `expenses`, `customer_balances`,
   `gross_profit_by_org`).
3. Customer-specific pricing (`customer_pricing`, `customers`).
4. Inventory and orders (`products`, `stock_levels`, `stock_ledger`,
   `orders`, `order_items`).
5. Org membership and roles (`memberships`).
6. Audit history (`audit_log`).

Tier 1 is owner-only by RLS. Tier 2 is owner-only by RLS. Tiers 3-5 are
member-readable, manager-writable, with payments and balances kicked up to
tier 2. The audit history is owner-readable and append-only by trigger.

## Trust boundaries

1. **iOS app to Supabase**: every request carries a JWT minted by Supabase
   Auth. The JWT identifies the user, NOT the role. Role enforcement
   happens server-side via memberships + RLS, every time.
2. **PostgREST to Postgres**: PostgREST sets `request.jwt.claims` and
   `auth.uid()` based on the verified JWT and switches role to
   `authenticated` (or `anon`). Every policy keys off `auth.uid()`.
3. **RPC to data**: SECURITY DEFINER functions run as the function owner,
   bypassing RLS. The first check inside every RPC is `auth.uid() is not
   null`. Inputs are validated before any write. Audit row is written
   atomically with the privileged action.

## See also

- [[schema-applied]] for the data shapes.
- [[rls-policies]] for the policy reference.
- [[rpc-functions]] for the RPC catalog.
- [[platform-shared-responsibility]] for what Apple covers.
- [[ui-phase-review]] for the iOS-side review that handed off the F6
  warehouse_code lookup concern, now closed by `lookup_org_by_code`.
