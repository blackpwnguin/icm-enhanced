---
title: Stowed Build Session Handoff
project: Stowed
company: Nihilo Solutions LLC
date: 2026-06-21
status: active
tags: [stowed, handoff, backend, web, launch]
---

# Stowed, Session Handoff (2026-06-21)

Handoff note for continuing in Cowork with Claude Code, tracked in Obsidian and the deployed dashboard. This captures everything done in the session, where each file goes, what is still open, and the recommended next steps.

## TL;DR, what got done

- Built the full pre-launch open items tracker (Word doc) and kept it current as items moved.
- Chose and registered the domain: **stowedapp.app** (through Vercel), and connected it to the Vercel project.
- Deployed the web repo to a new Vercel project.
- Wrote the backend database layer for Supabase: schema, Row Level Security, helper functions, onboarding RPCs, triggers, and a seed file. Validated against the Postgres grammar.
- Wrote the three web pages Apple requires a home for: privacy policy, terms of use, and support.
- Confirmed Ish accepted the App Store Connect Admin invitation.

## Key decisions

- **Domain:** stowedapp.app. The bundle ID stays `app.stowed.Stowed`; the domain name does not have to match it, so nothing in the app changes.
- **Subdomain plan:** the website and legal pages live on Vercel at the apex. `api.stowedapp.app` will point to Supabase later (a CNAME added once the Supabase project exists), so the app talks to your domain rather than the raw supabase.co URL. This makes a later migration off Supabase a DNS change, not an app update.
- **Backend scaffolded from the known data model** (multi-tenant, customer-specific pricing, financial tracking, three roles, warehouse-code signup with owner approval), to be reconciled against the existing `schema.sql`.
- **Roles enforced at the database layer** through Row Level Security, not only in the UI.

## Deliverables produced this session

### 1. Pre-launch open items tracker (Word)
`Stowed-Pre-Launch-Open-Items.docx`. The canonical checklist across backend, iOS, design, App Store Connect, legal, marketing, testing, Apple review, and post-launch. Status, Owner, and Notes per item.

### 2. Backend (Supabase)
- `supabase/migrations/0001_init.sql`, schema plus RLS plus functions plus triggers (13 tables, 5 enums, 15 functions, 37 RLS policies, 16 triggers, 13 indexes).
- `supabase/seed.sql`, Northbeam Coffee Co demo data for local development.
- `README.md`, apply steps and an overview.

Tables: organizations, profiles, warehouses, memberships, products, inventory, customers, customer_prices, orders, order_items, invoices, payments, audit_log.

Built-in behavior: order item prices resolve automatically (customer-specific price, then base price), order numbers generate per organization, order subtotals recompute on change, and the audit log captures pricing, role, status, payment, and invoice changes.

Onboarding RPCs to call from the app:
- `app.create_organization('Name')`, caller becomes owner, a warehouse with a join code is created.
- `app.request_to_join('JOINCODE')`, creates a pending employee membership.
- `app.approve_member('<membership_uuid>')`, owner approves.
- `app.set_member_role('<membership_uuid>', 'manager')`, owner changes a role.

### 3. Website legal and support pages
- `public/privacy.html`
- `public/terms.html` (includes the Apple auto-renewable subscription disclosures)
- `public/support.html` (contact, FAQ, and account deletion steps)

## Where each file goes in your repos

- Backend SQL: `~/stowed/backend/supabase/migrations/0001_init.sql` and `~/stowed/backend/supabase/seed.sql` (create the `backend` folder if it does not exist; adjust the path to your layout).
- Web pages: the `public` (or static) directory of the repo you deployed to Vercel, so they serve at `stowedapp.app/privacy.html`, `/terms.html`, `/support.html`.
- Tracker doc: wherever you keep project docs; it is also mirrored by this handoff for Obsidian tracking.

## Action items that need your input

- [ ] Reconcile `0001_init.sql` against your existing `schema.sql`, merge anything it does not cover, rename tables or columns to match yours where needed.
- [ ] Fill placeholder: company mailing address in `privacy.html`.
- [ ] Fill placeholder: governing law state in `terms.html`.
- [ ] Confirm `support@stowedapp.app` is a monitored inbox (referenced across all pages; Apple may email the support contact).
- [ ] Get a quick attorney review of the privacy policy and terms before relying on them (B2B product storing customer and financial data).

## Recommended next steps in Cowork / Claude Code

Backend
- [ ] Create the Supabase project (align region with the data residency plan).
- [ ] Apply the migration to a branch or local stack: `supabase init`, `supabase start`, `supabase db reset`.
- [ ] Verify Row Level Security: confirm one organization cannot read another's rows, and that employees cannot change pricing.
- [ ] Choose the auth method (for example email and password, or magic link).
- [ ] Build the RevenueCat webhook edge function (verify signature, update entitlements).

iOS
- [ ] Build the networking and auth layer that calls the RPCs above (sign in, session, token refresh, keychain).
- [ ] Replace the Northbeam mock data with live backend calls.
- [ ] Integrate RevenueCat (paywall, entitlements, restore) and Sentry (crash and error reporting).

Web and legal
- [ ] Deploy the three pages, fill the placeholders, confirm the live URLs load.
- [ ] Build out the landing page content.

App Store
- [ ] Register the app record (bundle ID `app.stowed.Stowed`, SKU `STOWED001`).
- [ ] Draft the listing copy (name, subtitle, description, keywords, promo text, review notes).
- [ ] Add the `PrivacyInfo.xcprivacy` manifest covering Supabase, RevenueCat, and Sentry.
- [ ] Add the `api.stowedapp.app` CNAME to Supabase once the project exists.

## Status snapshot (high level)

Done
- Domain registered (stowedapp.app) and connected to Vercel
- Web repo deployed to Vercel
- Ish is an Admin on App Store Connect
- iOS UI shell on mock data (three portals, role-gated)
- Clean XcodeGen project rebuild

In progress
- Backend schema, RLS, role authorization, warehouse-approval flow, audit logging, migration strategy (written and validated, pending apply to Supabase)
- Privacy policy, terms, support page, account deletion path (drafted, pending deploy and placeholders)
- Landing page and support infrastructure (site live, content to finish)

Not started (next major blocks)
- Create the Supabase project and apply the schema
- iOS networking, auth, and live data
- RevenueCat and Sentry integration
- App Store Connect app record and listing
- Testing (functional, sandbox subscriptions, tenant isolation, TestFlight)
- Apple build, privacy manifest, and submission

## Caveats to carry forward

- The SQL was validated against the Postgres grammar and the RLS reviewed by hand, but it was not run against a live server in the session. Apply to a Supabase branch or local stack first and confirm the policies behave before production.
- The legal pages are solid starting drafts, not attorney-reviewed.

## Project reference

- Company: Nihilo Solutions LLC
- Apple Developer enrollment ID: P76HTKVD68
- Bundle ID: app.stowed.Stowed
- SKU: STOWED001
- Domain: stowedapp.app (Vercel), api.stowedapp.app reserved for the backend
- Business banking: Mercury
- iOS repo: ~/stowed/apps/ios/Stowed (XcodeGen from project.yml)
- Mock dataset: Northbeam Coffee Co
- Roles: Owner, Manager, Employee
- Planned stack: Supabase (backend), RevenueCat (subscriptions), Sentry (monitoring), GitHub (source control), Vercel (web)
