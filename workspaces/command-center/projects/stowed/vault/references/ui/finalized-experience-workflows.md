---
project: stowed
type: reference
status: spec
stage: 02-build
tags: [ios, stowed, ux]
updated: 2026-06-16
---

# Finalized experience: critical workflows and AI hooks

Spoke of [[finalized-experience]]. The user journeys to polish end-to-end
and where AI surfaces live in the UI.

## Critical workflows

These are the user journeys we must polish end-to-end.

### Owner: first day

1. Welcome -> Create a business
2. Owner account setup -> Business setup -> Company Code Share
3. **(Add) Copy code with one tap, text it to first employee**
4. Enter the Owner portal
5. **(Add) Add first product** — see something tangible after setup
6. **(Add) Add first customer**
7. Approve the first employee's join request from Team

The two `Add` steps don't have to happen on the first session, but the affordances need to exist. Today they're dead `+` buttons.

### Employee: first day

1. Welcome -> Join a company
2. Code entry -> account setup -> Pending Approval
3. Pending Approval auto-routes them in when owner approves
4. Lands in Employee portal (no Money tab, no Team for non-owner)
5. **Picks up their first order from Orders, advances it through the pipeline**

This already works. The polish item is the empty state on the dashboard when an employee has just joined and there are no orders assigned to them yet.

### Fulfilling an order (the daily loop)

1. Open Orders, tap an order in Confirmed status
2. See line items, customer, total
3. Tap "Mark Packed" -> Status advances
4. Tap "Mark Shipped" -> Status advances
5. Tap "Mark Completed" -> Status advances

This is solid today. The missing piece: from Inventory or Home, **see what's coming up next to fulfill** without going to Orders -> scrolling. The Home dashboard already shows the count; add a tap-through.

### Creating an order (Owner / Manager)

1. Tap + on Orders
2. Pick customer (see their pricing)
3. **(Add) Add line items: select product, set quantity, see price auto-resolved from customer's price list**
4. **(Add) Review totals, save as Draft or Confirm**

This is the most-incomplete workflow today. The customer-selection step is built; the line-item step is stubbed. Polishing this is a multi-screen effort.

### Recording money in (Owner)

1. Tap Money in More
2. **(Add) Tap Record on Payments -> form for customer, amount, method**
3. **(Add) Tap + on Expenses -> form for category, amount, note**

Both screens already have the section headers and lists; only the add affordances are missing.

## AI hooks: where they live in the UI

The competitive sweep was clear: AI lives in a dedicated section, not inline with operational screens. Stowed should follow that pattern with two refinements.

### Dedicated Insights surface

Reachable from More -> Insights for Owner and Manager. Three sub-sections:

- **Forecasts.** Per-SKU demand projection ("you'll likely stock out of House Blend 12oz in 9 days based on the last 4 weeks"), reorder recommendations, seasonality call-outs.
- **Anomalies.** "Roastery Direct ordered 4x their usual quantity this week," "Cold Brew Concentrate hasn't moved in 21 days."
- **Chat.** The role-aware chatbot. Owner's chatbot has tools for reading every metric. Employee's chatbot has tools for "what should I pack next" and "is this barcode something I should accept" — operational, not financial.

### Inline anomaly cards (without crossing the line into AI-everywhere)

In specific contexts where there's a clear, decision-shaped insight, surface a single inline card. Examples:

- On the Home dashboard, a banner if the AI thinks something needs attention this week. Not a wall of cards; one, or none.
- On a product detail screen with a forecast attached, a "predicted stock-out in N days" line under the on-hand count.
- On a customer detail screen with a usage anomaly, a one-line callout.

These are pull-from-Insights, not parallel AI calls. Source of truth is the Insights service.

### Chatbot affordance from anywhere

A small floating button (or a More menu entry, depending on density) opens the chatbot in a sheet. The sheet is contextual: the chatbot knows what screen called it. Tapping it from a customer detail screen pre-seeds with "you're looking at Roastery Direct." Tapping it from an order screen pre-seeds with the order number.

Defer the actual chatbot UI until the backend is wired. For tonight, add a single Insights tab or More entry with a "Coming soon" treatment so the navigation accommodates it.
