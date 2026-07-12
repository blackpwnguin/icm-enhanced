# stowed — Architecture (how it's set up)

## Current state (as of 2026-07-12)

### iOS app (`apps/ios/Stowed`)
- SwiftUI, ~44 Swift files. `StowedRepository` replaces a mock `Store` on sign-in;
  parallel reads of org, products+stock, customers+pricing, orders+items, members,
  payments, expenses, payroll from live Supabase. Optimistic writes + revert-on-fail.
- Auth: email/password v1 + forgot-password; onboarding = create-a-business /
  join-a-company with pending-approval waiting room. Role-aware tab bar + role-gated screens.
- Detail: `vault/references/ui/*`, `vault/stages/02-build/*`.

### Backend (Supabase `arqkutfkziicuxfesghm`)
- Postgres 17, 14 tables, every row org-scoped, RLS on everything. Enums for state
  fields, generated `line_total`, append-only ledgers with trigger enforcement,
  `pg_advisory_xact_lock` per org serializing order placement. Org-scoped RPCs verify
  membership; owner-gated membership RPCs with audit logging.
- Detail: `vault/references/backend/{schema-applied,rls-policies,rpc-functions,data-model}.md`,
  `vault/references/security/backend-threat-model.md`.

### Web (`web/`, stowedapp.app)
- Static, fast (~48KB), no frameworks. GA4 `G-2CB296FN1W`. Good meta/OG/canonical +
  `SoftwareApplication`/`FAQPage`/`Organization` JSON-LD. Legal pages (privacy/terms/support).
- Detail: `vault/references/web/*`, `domains/seo/`.

## Environments / secrets (names only)
- Supabase project `arqkutfkziicuxfesghm`; edge functions: stripe-webhook,
  paymento-webhook, create-crypto-payment, revenuecat-webhook, send-invoice.
- ⚠ Secrets currently hardcoded in deployed functions — move to Supabase secrets.

## History
_2026-07-12: onboarded to command-center from the Obsidian vault._
