---
project: stowed
type: reference
status: spec
stage: 02-build
tags: [ios, stowed, ux]
updated: 2026-06-16
---

# Finalized experience: screen inventory

Spoke of [[finalized-experience]]. The full finalized screen inventory
with status against the mock Store.

## Finalized screen inventory

Status legend: ✓ shipped, △ partial / placeholder, ✗ missing.

### Authentication and onboarding

- ✓ Welcome with Create-a-business, Join-a-company, three portal previews (preview buttons are UI-PHASE DEMO, see [[ui-phase-review]] F11)
- ✓ Owner account setup with inline validation
- ✓ Business setup
- ✓ Company code share with copy affordance — **Add copy-to-clipboard, currently missing**
- ✓ Join code entry with live validation
- ✓ Join account setup with inline validation
- ✓ Pending approval waiting room with animated icon and demo helper

### Home and navigation

- ✓ Home dashboard with role-aware metric cards
- △ Tab bar (Home / Inventory / Scan / Orders / More). **Consider promoting Insights to a tab when AI lands.**

### Inventory

- ✓ Inventory list with low-stock pills
- ✓ Product detail with price-edit for Manager+
- ✗ **Add Product flow** (the `+` button is a no-op)
- ✗ **Inventory search** (no search bar; list is fine at 5 SKUs, breaks at 50+)
- △ **Stock adjustment** (no "received 12 units" / "wrote off 3 damaged" interaction; this is the Scan stage)

### Orders

- ✓ Orders list with status pills
- ✓ Order detail with stage advancement
- △ **Create order flow** — exists but is incomplete; line items are stubbed ("Wiring comes with the orders stage")
- ✗ **Order search and status filter** (with 5-50 active orders this is the screen people live in)

### Customers

- ✓ Customers list with receivables summary
- ✓ Customer detail with per-customer pricing
- ✗ **Add Customer flow** (the `+` button is a no-op)
- ✗ **Customer order history** on the detail screen (right now there's no per-customer view of past orders)

### Scan

- △ **Scan placeholder.** Real camera scanner deferred to scanning stage. UI phase is fine to leave as placeholder if we're not landing camera tonight; if we are, this is a major piece.

### Money

- ✓ Profit summary, receivables list, expenses list
- △ **Record payment** — the "Record" link in MoneyView is dead
- ✗ **Add expense flow**

### Team

- ✓ Members list, join request approval
- ✗ **Change member role** (the prompt history says owners can change roles "in the existing Team UI" but the action does not exist)
- ✗ **Remove member**

### Payroll

- ✓ Per-employee cost list, period total

### Settings

- ✓ Warehouse info card, viewing-as card, portal switcher, sign out
- △ **Company code prominence** — code exists in Settings but isn't presented as something the owner can easily re-share
- ✗ **Edit company name**
- ✗ **Edit member self (name, email)**
- ✗ **Notification preferences** (deferred until push lands)

### Insights (new)

- ✗ **Insights tab or screen.** Where forecasting, anomaly alerts, and the AI chatbot will live. Per the competitive research, AI lives in a dedicated section in every tool that has it. Worth adding a stub now so the surface exists before backend.
