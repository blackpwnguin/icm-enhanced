# nihilo — Change log

Project-wide timeline, newest first.

<!-- Curator prepends entries above this line -->

## 2026-07-13 — Finance depth pt.2 (statements/period/credit), build 42 (v1.29) [ios, finance, release] (PR #16)
  ↳ send-statement edge function (statement/reminder + Stripe pay link); Reports Month/Quarter/Year/All period scoping (Order.createdAt); edit customer payment terms + credit limit with order-time credit warning. Completes all 5 finance features. Next: desktop web dashboard.


## 2026-07-13 — Finance depth pt.1: AR aging + per-customer ledger, build 41 (v1.28) [ios, finance, release] (PR #15)
  ↳ Migrations: customers payment_terms_days + credit_limit; get_org_aging RPC (FIFO, buckets Current/1-30/31-60/61-90/90+). iOS: aging bar on Customers hub, per-customer aging breakdown + Payments/Invoices history. Features 1-2 of 5; next: statements/reminders, period scoping, credit warnings, then desktop web dashboard.


## 2026-07-13 — Fixed order status advance revert, build 40 (v1.27) [ios, bugfix] (PR #14)
  ↳ App order pipeline disagreed with backend set_order_status matrix (packed vs preparing order); advancing a packed order reverted. Reordered OrderStatus to placed->preparing->packed->shipped->arrived to match backend. PR #14 CI green, merged, external assigned.


## 2026-07-13 — Fixed finance sort feedback, build 39 (v1.27) [ios, ux, bugfix] (PR #13)
  ↳ Client-financials/Customers sort was wired but invisible on sparse data; now each row trailing value tracks the active sort (Owes/Spent/Orders/Name), ties break by name, list animates. PR #13 CI green, merged, external assigned; Beta review re-submit pending Apple daily limit reset (3 builds same day).


## 2026-07-13 — Owner finance UX shipped as build 38 (v1.27) [ios, ux, release] (PR #12)
  ↳ Customers tab now a finance hub (Outstanding/Paid/Billed summary + sort by Owes/Spent/Orders/Name + per-row balance from server receivables); Home "clients who owe" top-3 quick list; customer detail leads with balance owed + one-tap Record payment. PR #12 CI green (real Swift 6), merged to main, assigned internal+external, Beta review submitted.


## 2026-07-13 — Merged Swift 6 PR #11 + shipped build 37 [ios, release] (main ac44b90)
  ↳ PR #11 merged to main; build 37 (v1.26) archived clean in Release/Swift 6, uploaded, assigned internal+external, Beta App Review submitted (201). Data layer now routes every Postgrest .execute() through nonisolated PG helpers; CI compiles in real Swift 6; supabase-swift pinned 2.46.0. Handoff notes in stowed repo docs/HANDOFF.md.


## 2026-07-13 — Shipped build 36 (Universal Links) + Swift 6 hardening PR [ios, ci, release] (PR #11)
  ↳ build 36 / v1.26 to TestFlight (internal + external, Beta App Review submitted); AASA verified HTTP 200 + application/json after fixing Vercel Bot-Protection (Challenge -> Log); Supabase auth redirect allow-list updated. PR #11: pin supabase-swift 2.46.0 + commit Package.resolved, remove CI SWIFT_VERSION=5 override (real Swift 6 compile), fix xcodegen stripping the associated-domains entitlement.


## 2026-07-11 — Implemented on-page SEO and wired GA4 [seo, analytics] (commit <sha>)
  ↳ report: nihilo-2026-07-11-seo · auto-created domains: seo, analytics

## 2026-07-11 — Project onboarded to command-center [meta]
  ↳ scaffolded from projects/_TEMPLATE/
