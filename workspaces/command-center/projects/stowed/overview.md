# stowed — Overview

- **Repo:** blackpwnguin/stowed (private) · monorepo: `apps/ios/Stowed`, `web/`, `docs/`
- **What it is:** iPhone app for small wholesale businesses — inventory, B2B orders,
  customer pricing, team management. B2B inventory-management SaaS.
- **Stack:** SwiftUI iOS app (~44 Swift files, ~9,100 LOC) · Supabase backend
  (Postgres 17, project `arqkutfkziicuxfesghm`, RLS-first multi-tenant, SECURITY
  DEFINER RPCs, append-only ledgers) · static marketing site (stowedapp.app) with GA4.
- **Live URL:** https://stowedapp.app (site live; app in TestFlight prep)
- **Backend project:** Supabase `arqkutfkziicuxfesghm` ("stowed")

## Status (live — Curator refreshes)
| Field | Value |
|-------|-------|
| Last updated | 2026-07-12 |
| Phase | Pre-launch / TestFlight prep → aiming to ship in ~2 weeks |
| Active domains | seo, analytics |
| Open recommendations | see `recommendations.md` (P0 security + store blockers) |
| Field Agent installed | not yet |

## Assessment (2026-07-03 full product review)
"Well above typical indie quality" — strong auth state machine, RLS-first
multi-tenant design, SECURITY DEFINER RPC discipline, append-only ledgers, fast
honest website. Gaps are product-maturity + a handful of real bugs and **several
security items that must be fixed before public launch** (see `recommendations.md`).

## Open questions / escalations
- **Edge-function secrets are hardcoded** (Stripe/Paymento/RevenueCat) in the
  DEPLOYED Supabase functions — source not in the repo. Rotate + move to `Deno.env`
  before shipping. `needs_human: true`.
