---
project: stowed
type: reference
status: building
stage: 02-build
tags: [stowed, backend, supabase, schema]
updated: 2026-06-21
---

# Alt scaffold reconciliation (2026-06-21 `0001_init.sql` vs applied)

The 2026-06-21 launch-prep session produced a from-scratch backend scaffold
(`_session-artifacts/2026-06-21-launch-prep/0001_init.sql` + `seed.sql`). It
was written from a "no backend yet" assumption and does **not** match the
foundation already applied to Supabase `arqkutfkziicuxfesghm` on 2026-06-12
([[schema-applied]], [[migration-history]]). This note records the diff and the
recommended path so the two are not confused.

## Recommendation

**Treat the applied 06-12 foundation as authoritative. Do not apply the new
`0001_init.sql` over it.** Mine the new scaffold for the few ideas the applied
schema lacks (notably the `invoices` concept), port those as forward
migrations (`0013+`), and retire the scaffold once harvested.

## Shape diff

| Aspect | New `0001_init.sql` | Applied (authoritative) |
|---|---|---|
| Schema layout | enums in `app`, tables in `public` | all in `public` |
| Tables | 13 | 16 |
| Enums | 5 | 10 |
| Functions | 15 | 9 RPCs + triggers/helpers |
| RLS policies | 37 | per-command split set |
| Append-only ledgers | none | `stock_ledger`, `order_status_history`, `audit_log` |
| Views | none | `customer_balances`, `gross_profit_by_org` |

## Table mapping

| New scaffold | Applied equivalent | Note |
|---|---|---|
| organizations | organizations | same intent |
| profiles | user_profiles | rename only |
| warehouses | locations | applied is more general (`location_type_t`) |
| memberships | memberships | same intent |
| products | products | same |
| inventory | stock_levels (+ stock_ledger) | applied adds append-only ledger |
| customers | customers | same |
| customer_prices | customer_pricing | rename only |
| orders | orders | same |
| order_items | order_items | applied has generated `line_total` |
| invoices | — | **new idea; applied has none** |
| payments | payments | same |
| audit_log | audit_log | applied enforces append-only via trigger + grants |
| — | expenses | applied only |
| — | employee_costs | applied only |
| — | order_status_history | applied only (append-only) |

## What the new scaffold gets right that's worth porting

- **`invoices` table.** The applied schema tracks `payments` and derives
  receivables from the `customer_balances` view but has no first-class invoice
  object. If invoicing becomes a product surface, port an `invoices` table as a
  forward migration rather than reworking the foundation.
- **`app` schema namespacing** for enums is a stylistic preference; the applied
  schema's flat `public` layout is already live and not worth churning.

## What the applied foundation has that the scaffold lacks (do not lose)

- Append-only `stock_ledger` and `order_status_history` with trigger
  enforcement.
- Owner-only financial views with `security_invoker = true`.
- The RLS recursion fix (`user_org_ids()` / `user_owned_org_ids()` SECURITY
  DEFINER helpers) from migrations 0011–0012 — a subtle, hard-won correctness
  fix the scaffold has no equivalent for.
- `expenses` and `employee_costs` for full financial tracking.

## Onboarding RPC naming (reconcile)

The handoff documents app-callable RPCs under `app.*`
(`create_organization`, `request_to_join`, `approve_member`, `set_member_role`).
The applied backend exposes equivalents under `public.*`
(`create_org_and_self_owner`, `join_org_by_code`, `approve_membership`,
`set_member_role` — see [[rpc-functions]]). The iOS auth-wiring slice
([[build-log-auth-wiring]]) targets the applied names. Keep the applied names;
treat the handoff's names as aliases to ignore.

## Action

- [ ] Decide on `invoices`: port as `0013_invoices` or defer. Owner: Sam.
- [ ] Update the launch tracker — "Create the Supabase project" is **done**
  (applied 06-12), not "Not started".
- [ ] Add `api.stowedapp.app` custom-domain CNAME to `arqkutfkziicuxfesghm`.
