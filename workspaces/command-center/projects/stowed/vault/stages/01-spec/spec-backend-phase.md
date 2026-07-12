---
project: stowed
type: spec
status: spec
stage: 01-spec
tags: [security, ios, stowed]
updated: 2026-06-11
---

# Spec: backend phase

The first real spec since the workspace was created. Takes Stowed from "runs against a mock store in the simulator" to "runs against Supabase with real auth and a working tenant join."

## Problem

The UI phase is complete: 19 Swift files, role-aware screens, financial math, all against an in-memory mock store. None of it persists, none of it is multi-tenant, none of it is secured. No second user can sign up. No data outlives a simulator restart. To put the app in front of Ish, then internal testers, the backend has to exist.

## Smallest valuable version

Cut everything that is not "two roles can sign in, join the same warehouse, do an inventory and order pass, and see consistent data." Specifically:

1. Create the Supabase project.
2. Apply `schema.sql` (15 tables, 2 views, RLS policies). See [[source-specs]].
3. Wire Supabase, RevenueCat, and Sentry back into `project.yml` and regenerate. They were dropped in the XcodeGen rebuild; see [[build-log-xcodegen-rebuild]].
4. Build real authentication. Sign in with Apple to Supabase identity. The Apple half of the model is in [[platform-shared-responsibility]].
5. Build the warehouse-code join with Owner approval. Pending membership is the default; Owner approves before any data is visible. See [[roles-and-permissions]].
6. Replace the mock `Store` with a Supabase-backed data layer. Views (`customer_balances`, `gross_profit_by_org`) read from a store with a fixed shape, so screens should not need to change.

Out of scope for this cut: RevenueCat entitlement enforcement, audit logging, Edge Functions, field-level encryption, App Attest. Those land in follow-up specs.

## Acceptance criteria

- A new user can sign in with Apple.
- A new user can request to join a warehouse by code; the request stays pending.
- An Owner sees the pending request, approves it, and the new user lands in the right tenant.
- Inventory, orders, customers, and the Money view all read from Supabase, not the mock store.
- Row Level Security blocks cross-tenant reads: a second Owner in a different organization sees zero rows from the first.
- Role-gated screens still match [[roles-and-permissions]] on the server, not just in the UI.
- Sentry receives errors with personal and financial values scrubbed (verify with a forced error).
- The app builds and runs on the simulator end-to-end against the live Supabase project.

## Open questions

- Whether Sign in with Apple is the only auth path at launch, or if email/password is also needed for testers without Apple IDs.
- How an Owner provisions the first warehouse (self-serve at signup, or seeded out-of-band).
- Whether RevenueCat wires up in this cut or the next one. Current call: next one.

## Constraints

- iOS 17 and up, Swift 6 conventions: `@Observable`, `@Environment` injection, `@State` root.
- VoiceOver and Dynamic Type continue to work on new auth and join screens.
