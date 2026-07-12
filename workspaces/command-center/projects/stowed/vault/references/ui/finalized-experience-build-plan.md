---
project: stowed
type: reference
status: spec
stage: 02-build
tags: [ios, stowed, ux]
updated: 2026-06-16
---

# Finalized experience: build plan and decisions

Spoke of [[finalized-experience]]. The prioritized build list, the design
decisions to lock before backend, and what is out of scope for this phase.

## Prioritized build list for tonight

In order of value-to-effort. Each line is a discrete tractable unit.

**Critical (block the demo if missing):**

1. Copy-to-clipboard button on Company Code Share. Five-line change.
2. Apply security fixes from [[ui-phase-review]]: F1 (force-unwrap), F10 (textContentType on form fields), F11 (UI-phase demo markers).

**High value (the workflow is broken without these):**

3. Add Product flow (Inventory `+` opens a sheet with name, SKU, cost, base price, reorder threshold).
4. Add Customer flow (Customers `+` opens a sheet with name, email, phone).
5. Record Payment flow (Money "Record" opens a sheet with customer, amount, method).
6. Add Expense flow (Money expenses `+` opens a sheet with category, amount, note).
7. Change member role action in Team (tap a member, choose new role).

**Medium value (visible polish but not blocking):**

8. Inventory search bar.
9. Order status filter chips on Orders list.
10. Customer order history on customer detail.
11. Empty states (new employee with no orders, no expenses yet, etc).

**Larger units (probably more than tonight):**

12. Full Create Order flow with line items, qty entry, price auto-resolution, save-as-draft or confirm.
13. Insights screen stub with three sections (Forecasts, Anomalies, Chat) as "Coming after backend" placeholders.
14. Stock adjustment flow (received N, wrote off N) — depends on Scan stage decisions.

## Open design decisions to lock before backend

These are decisions we should resolve while the front end is still flexible. If we punt them, they get harder to change once Supabase migrations are written.

1. **Company code vs. email invite.** Email invite is the universal pattern in tier-1 inventory tools. Stowed currently uses company codes. The competitive research recommends a hybrid: email invite as default, code as the secondary path for in-person onboarding of hourly workers. Decision needed: keep code-only, or add email invite as a second path with QR code support.
2. **Tab bar vs. More menu.** Today's bar is Home / Inventory / Scan / Orders / More. When Insights lands, does it become a sixth tab (pushing Scan or Orders down), or stay in More? Recommendation: Insights as a tab for Owners, Customers as a tab for Managers (who manage them more than they manage Money), keep current shape for Employees.
3. **Settings prominence of company code.** Today it sits as a small line in the Warehouse card. Recommendation: a dedicated "Invite your team" entry in the Owner's More menu (or top of Settings) that re-shows the Company Code Share screen.
4. **Order pipeline naming.** We use Draft -> Confirmed -> Packed -> Shipped -> Completed. Competitive landscape uses Draft -> Authorized -> Picked -> Packed -> Shipped -> Fulfilled (Cin7), or Quote -> Order -> Pick -> Pack -> Ship -> Closed (inFlow), or Draft -> Confirmed -> In Progress -> Shipped -> Completed (Katana). Our 5-stage shape is clean; the "Confirmed" terminology is the variance worth a second look (vs. "Authorized" which is more explicit about stock allocation). Recommendation: keep Confirmed for now, revisit when Allocation behaviour lands in the backend.
5. **Cancellation flow.** Cin7 hides cancellation deliberately, which Capterra reviewers complain about. Stowed's CancelledOrderStatus exists in the model but there's no UI to cancel an order. Decision: surface cancel on Order Detail, with a confirmation. Treat it as a polish item.
6. **Per-customer order history.** Customer detail currently shows pricing but not orders. Add an Orders section. Decision is about default sort (recent first) and whether to show all orders or limit.

## What I am explicitly NOT trying to ship in this phase

- Real auth (Supabase Auth)
- CSV import / export
- Push notifications
- Real-time updates (Supabase Realtime)
- Live chatbot
- QuickBooks / accounting integration
- Multi-warehouse support per org
- Bundles / kits
- Lot / batch tracking
- Audit log UI
- Privacy manifest / App Store listing

These are backend-phase or later. They are real eventual requirements but not what "finalized UI" means.
