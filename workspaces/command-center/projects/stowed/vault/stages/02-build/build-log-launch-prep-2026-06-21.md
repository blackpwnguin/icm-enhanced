---
project: stowed
type: build-log
status: building
stage: 02-build
tags: [web, stowed, backend, supabase]
updated: 2026-06-21
---

# Build log: launch-prep session (2026-06-21)

Cowork + Claude Code session focused on pre-launch infrastructure: domain,
web hosting, legal pages, and a backend SQL scaffold. Source handoff archived at
`_session-artifacts/2026-06-21-launch-prep/Stowed-Session-Handoff.md`.

## What got done

- **Domain registered:** `stowedapp.app` through Vercel, connected to the
  Vercel project. Decision and subdomain plan in [[decision-domain-and-web-hosting]].
- **Web repo deployed** to a new Vercel project (apex serves the site + legal pages).
- **Legal + support pages drafted:** `privacy.html`, `terms.html`, `support.html`.
  Reference: [[legal-and-support-pages]].
- **Backend SQL scaffold written** (`0001_init.sql` + `seed.sql`), validated
  against the Postgres grammar but **not applied** to any server this session.
  See the reconciliation note below.
- **Pre-launch tracker** (Word) produced as the canonical open-items checklist:
  `_session-artifacts/2026-06-21-launch-prep/Stowed-Pre-Launch-Open-Items.docx`.
- **Ish confirmed** as App Store Connect Admin (invite accepted).

## ⚠️ Backend divergence — must reconcile before any apply

The SQL scaffold from this session does **not** match the backend already
applied to Supabase project `arqkutfkziicuxfesghm` on 2026-06-12
(see [[schema-applied]], [[migration-history]]). The session worked from an
older "no backend yet" mental model — the tracker doc literally lists "Create
the Supabase project" as *Not started*, which is stale.

Concrete differences (new scaffold vs applied foundation):

| | New `0001_init.sql` | Applied 06-12 |
|---|---|---|
| Schema | `app` (enums) + `public` (tables) | `public` |
| Tables | 13 | 16 |
| Enums | 5 | 10 |
| Inventory | `warehouses`, `inventory` | `locations`, `stock_levels`, `stock_ledger` |
| Pricing | `customer_prices` | `customer_pricing` |
| Billing | `invoices` table | none (payments/expenses/employee_costs) |
| Append-only ledgers | not present | `stock_ledger`, `order_status_history`, `audit_log` |

Full analysis and the recommended path in [[alt-scaffold-reconciliation]].
**Do not apply `0001_init.sql` over the live project.** The applied foundation
is the more complete and the authoritative shape.

## Open placeholders in the legal pages

- `privacy.html` — company mailing address.
- `terms.html` — governing law state.
- Confirm `support@stowedapp.app` is a monitored inbox (referenced on all pages).
- Attorney review of privacy + terms before relying on them.

## Where the deliverables live

All raw files archived under
`knowledge-vault/stowed/_session-artifacts/2026-06-21-launch-prep/`. The web
pages also belong in the deployed repo's `public/` dir so they serve at
`stowedapp.app/privacy.html`, `/terms.html`, `/support.html`.
