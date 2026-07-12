---
project: stowed
type: reference
status: spec
stage: 02-build
tags: [ios, stowed, ux]
updated: 2026-06-16
---

# Finalized UI/UX experience and workflow

What the Stowed front end needs to look like at the end of the UI phase, before Supabase work begins tomorrow. Informed by the [[competitive-landscape]] sweep, the existing [[screen-inventory]], and the [[ui-phase-review]] security pass.

This note is a hub. The "finalized" definition and positioning bets are below; the screen inventory, the workflows and AI hooks, and the build plan live in the spokes listed under Sections.

## Sections

- [[finalized-experience-screens]] — the full finalized screen inventory with status against the mock Store.
- [[finalized-experience-workflows]] — critical workflows to polish end-to-end and where AI hooks live in the UI.
- [[finalized-experience-build-plan]] — the prioritized build list, open design decisions to lock before backend, and what is NOT shipping this phase.

## What "finalized" means here

The front end is feature-complete against the mock Store: every screen the app needs at first ship is at least present, every critical user journey runs end-to-end on tap-through, and the demo can be handed to a coffee roaster or a small distributor for usability feedback without "this part isn't built yet" caveats. Real persistence, auth, and analytics arrive with Supabase.

## Positioning bets (from the competitive sweep)

The competitive landscape gave us five places to lean. These shape what we polish first.

1. **iOS-native, full-featured on phone.** Every tier-1 competitor treats mobile as a cut-down companion to their web app. Fishbowl's mobile is "useless," Cin7's mobile has known bugs, Katana's mobile is a browser. Stowed wins on the phone or it doesn't win. Every workflow must be completable on iPhone without "go to the web app for that."
2. **Integrated payroll and expenses.** No tier-1 inventory tool we surveyed handles payroll or expense tracking. Stowed does. The roastery owner who currently context-switches between Cin7 and QuickBooks and Gusto sees one app.
3. **Onboarding in minutes.** Brightpearl onboarding takes 3-6 months. Cin7 averages 3 months. inFlow requires a paid onboarding package. Stowed gets a five-SKU wholesaler to their first order in under 30 minutes. The owner-and-employee join-code flow we already built is part of this; the rest is opinionated defaults and progressive disclosure.
4. **Per-customer pricing as a native phone experience.** inFlow's B2B portal is good but it's a web bolt-on. RoasterTools' per-customer storefronts are the right idea but only for coffee. Stowed treats per-customer pricing and per-customer order views as first-class iOS surfaces.
5. **One flat price, everything included.** Every competitor nickel-and-dimes: Katana charges extra for barcode scanning, Cin7 charges for add-ons, Fishbowl bills onboarding by the hour. Stowed publishes one price with scanning, all order statuses, all team roles, payroll, and basic analytics included. That's not a UI feature directly, but it shapes what we don't paywall.
