---
project: stowed
type: reference
status: spec
stage: "-"
tags: [ios, stowed]
updated: 2026-06-11
---

# Pricing tiers

Canonical pricing for Stowed. Other notes wikilink here rather than restating, so the numbers cannot drift.

Status: defined as product strategy, not yet wired to StoreKit or RevenueCat.

## Tiers

| Tier | Price per month | Trial |
|---|---|---|
| Starter | $19.99 | 14 days |
| Growth | $49.99 | 14 days |
| Pro | $149.99 | 14 days |

## Wiring plan

Subscriptions ride on Apple In-App Purchase via StoreKit 2, with RevenueCat as the entitlement layer. Apple holds the card; Stowed is never in scope for handling card data. Server-side enforcement of what a paid account may access lives in the backend. See [[platform-shared-responsibility]] for the shared-responsibility model and [[architecture-overview]] for where RevenueCat sits.

## Open questions

- Feature gating per tier not yet defined.
- Annual pricing not yet decided.
- Whether the 14 day trial requires a card up front not yet decided.
