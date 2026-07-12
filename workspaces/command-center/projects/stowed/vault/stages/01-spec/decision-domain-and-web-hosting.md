---
project: stowed
type: decision
status: building
stage: 01-spec
tags: [web, stowed]
updated: 2026-06-21
---

# Decision: domain and web hosting

Made 2026-06-21. See [[build-log-launch-prep-2026-06-21]].

## Decision

- **Domain:** `stowedapp.app`, registered through Vercel.
- **Hosting:** website + legal pages on Vercel at the apex.
- **Backend subdomain:** `api.stowedapp.app` reserved for Supabase — a CNAME
  added once the Supabase project's custom-domain is set up.

## Why

- The bundle ID stays `app.stowed.Stowed`. The marketing domain does not have
  to match the bundle ID, so nothing in the app changes.
- Pointing the app at `api.stowedapp.app` rather than the raw `*.supabase.co`
  URL makes a future migration off Supabase a DNS change, not an app update.
- Apple requires a public home for the privacy policy and terms; the apex site
  provides it.

## Current wiring (confirmed 2026-06-21)

- A real Supabase backend is set up and **connected to Vercel** (the applied
  foundation, project `arqkutfkziicuxfesghm`). This is the live backend —
  reinforces that the 06-21 `0001_init.sql` scaffold must not be applied over
  it ([[alt-scaffold-reconciliation]]).

## Consequences

- Add the `api.stowedapp.app` CNAME to the (existing) Supabase project
  `arqkutfkziicuxfesghm` — note the applied backend already lives there.
- Legal pages must serve at `stowedapp.app/privacy.html`, `/terms.html`,
  `/support.html`. See [[legal-and-support-pages]].
