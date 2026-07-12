---
project: stowed
type: project-overview
status: building
stage: 02-build
tags: [ios, stowed]
updated: 2026-06-21
---

# Stowed status

Current phase: TestFlight prep. Data wiring complete (2026-06-23):
StowedRepository replaces mock Store on sign-in; full parallel read of
org, products+stock, customers+pricing, orders+items, members, payments,
expenses, payroll from live Supabase (arqkutfkziicuxfesghm). All writes
(add product/customer, advance/cancel order, record payment, add expense)
go through repository with optimistic update + revert on failure.
Pull-to-refresh wired on all list views. Auth + forgot-password + UI polish
all done. Next: simulator end-to-end test, PrivacyInfo.xcprivacy, App Store
registration, archive + TestFlight upload.

Runs today: the app boots in the iOS simulator against a Northbeam Coffee Co.
mock store. Role-aware tab bar, role-gated screens, live financial math against
mock data, a real Create-a-business / Join-a-company onboarding flow with a
pending-approval waiting room. See [[onboarding-flow]].

## ⚠️ Reconcile before any backend apply

The 2026-06-21 scaffold (`0001_init.sql`) does **not** match the applied 06-12
foundation (13 vs 16 tables, 5 vs 10 enums, different table names, no
append-only ledgers). Do not apply it over the live project. Full diff and the
recommended path: [[alt-scaffold-reconciliation]].

## Do first

1. ~~Push the clean rebuild to GitHub~~ — DONE (2026-06-23)
2. ~~Website live~~ — DONE (2026-06-23): stowedapp.app, /privacy, /terms, /support all 200
3. Fill legal-page placeholders before App Store submission:
   - `web/privacy.html`: Nihilo Solutions LLC mailing address
   - `web/terms.html`: governing law state
   - Confirm `support@stowedapp.app` is a monitored inbox
4. Decide on the `invoices` idea — port as `0013` or defer ([[alt-scaffold-reconciliation]]).

## Pending, not blocking today

- Ish gets GitHub Write access (not yet added).
- Register bundle id `app.stowed.Stowed` / SKU `STOWED001` in App Store Connect
  (needed before first TestFlight build only).
- Add the `api.stowedapp.app` CNAME to the Supabase project.
- Attorney review of privacy + terms.

## Next after do-first

Continue the auth-wiring slice ([[build-log-auth-wiring]]) against the applied
backend. Checkpoint 1 (SDK + client setup) is done; Checkpoint 2 (deep link
plumbing), Checkpoint 3 (sign-up + email confirm + create_org_and_self_owner),
and Checkpoint 4 (sign-in + session restore) are queued. Backend foundation
docs: [[schema-applied]], [[rls-policies]], [[rpc-functions]],
[[backend-threat-model]], [[build-log-backend-phase]].
