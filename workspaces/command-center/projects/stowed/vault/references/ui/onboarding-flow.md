---
project: stowed
type: reference
status: building
stage: "-"
tags: [ios, stowed, onboarding]
updated: 2026-06-11
---

# Onboarding flow (UI phase)

How a user becomes either an owner of a new business or an employee of an existing one, in the UI phase. No backend, no real auth, mock data only. The shape mirrors what the Supabase repository will replace next stage.

## Entry points

Welcome offers three groups of actions, top to bottom:

1. Create a business (owner path)
2. Join a company (employee path)
3. Preview a portal as Owner, Manager, or Employee (demo only; routes into the seed Northbeam Coffee Co org)

The three preview buttons are for clicking through each portal without going through onboarding. They always route into the seed org regardless of any custom org just created.

## Owner path

`OwnerAccountSetupView` -> `BusinessSetupView` -> `CompanyCodeShareView` -> Owner portal.

The owner enters name, email, password, then a company name. `AppEnvironment.createBusiness` calls `Store.createOrg`, which appends a new `Org` to `store.orgs`, generates a six-character code from a no-ambiguous-glyph alphabet (drops `0/O/1/I`), and seats the owner as the only member with role `.owner`. The Company Code Share screen displays the generated code in a monospaced display and lands the owner in their portal via `env.enter(as: .owner)`.

The code is also visible on the Settings screen, under the Warehouse card.

## Employee path

`JoinCodeEntryView` -> `JoinAccountSetupView` -> `PendingApprovalView` -> Employee portal (after owner approves).

The employee enters the company code. `Store.findOrg(byCode:)` is case-insensitive and whitespace-trimmed. If no org matches, the code field shows a red inline error. If a match is found, push to the account-setup screen for name, email, password. Submitting calls `AppEnvironment.submitJoinAndWait`, which appends a `JoinRequest` to that org's `joinRequests` and sets `pendingJoinOrgID` on the environment.

`RootView` is a three-way switch: pending state -> `PendingApprovalView`; signed in -> `MainTabView`; otherwise -> `WelcomeView`.

`PendingApprovalView` watches `Store.member(byEmail:in:)` for the user's email in the org. When the owner approves the request from the existing Team screen, the new `Member` appears, the view's `onChange` fires, and `env.enter(as: member.role)` lands the employee in their portal at the approved role.

## Demo affordance

The pending screen also has a clearly labelled "Demo: approve as the owner" button that calls `Store.approve` on the user's own join request. This is for single-simulator testing only. In production the owner is on a separate device and approves through the existing Team UI; that path still works and is what the auto-transition observes.

## Data shape

The mock `Store` now models multiple `Org`s, defined in `Core/Models.swift`. Each `Org` holds its own:

- `members: [Member]`
- `joinRequests: [JoinRequest]`
- `products`, `customers`, `orders`, `payments`, `expenses`, `employeeCosts`

`Store` exposes view-facing computed accessors (`store.products`, `store.orders`, etc.) that read from the active org, so the rest of the app sees no change. Mutations route through a private `mutateActiveOrg` helper. This shape maps cleanly onto an `orgs` table with all per-org collections foreign-keyed to it. See [[data-model]].

## Limitations to know about

- The seed Northbeam org and any user-created org both live in `store.orgs` for the life of the process. There is no persistence, so app launch resets to seed plus nothing.
- Once an owner signs out of a custom-created org, there is no way back in as the owner because there is no auth. The Join flow with the same code would land them as a pending employee, not as the owner. This is a deliberate UI-phase gap.
- The "Demo: approve as the owner" button is a UI-phase affordance. It does not exist in the production design.

See [[screen-inventory]] for the screen list, [[roles-and-permissions]] for what each role can do, [[data-model]] for the table-level mapping.
