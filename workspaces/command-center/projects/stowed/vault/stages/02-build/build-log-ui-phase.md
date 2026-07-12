---
project: stowed
type: build-log
status: building
stage: 02-build
tags: [swift, ios, stowed]
updated: 2026-06-12
---

# Build log: UI phase

What exists today, after the XcodeGen rebuild and the SwiftUI build-out. The app runs end-to-end in the simulator against a mock store. No backend yet.

## Files

22 Swift files, one target (`Stowed`). No test target. See [[test-status]].

## Source layout

```
~/stowed/apps/ios/Stowed/Stowed/
  App/
    StowedApp.swift          app entry point
    RootView.swift           routes Welcome vs MainTab
    MainTabView.swift        role-aware tab bar
    AppEnvironment.swift     holds role and store, no backend yet
  Core/
    Models.swift             Role, OrderStatus, data structs
    Store.swift              in-memory mock data and financials
  Shared/
    Theme.swift              colors and fonts
    Components.swift         reusable cards, pills, buttons
  Features/
    Auth/WelcomeView.swift
    Onboarding/CreateBusinessFlow.swift
    Onboarding/JoinCompanyFlow.swift
    Onboarding/PendingApprovalView.swift
    Home/HomeView.swift
    Inventory/InventoryView.swift
    Scan/ScanView.swift
    Orders/OrdersView.swift
    Customers/CustomersView.swift
    Money/MoneyView.swift
    Team/TeamView.swift
    Payroll/PayrollView.swift
    More/MoreMenuView.swift
    Settings/SettingsView.swift
```

The Xcode Project navigator mirrors this layout because XcodeGen builds groups from folders. See [[build-log-xcodegen-rebuild]].

## What runs

The app boots, the Welcome screen presents three portal previews and a warehouse code field, and the tab bar reshapes by role. Inventory, Orders, Customers, Money, Team, and Payroll all render against the mock `Store`. Net profit, receivables, and store credit compute correctly against mock data because the math mirrors what the views will compute server-side.

For the per-screen list, see [[screen-inventory]]. For why none of this is multi-tenant or secure yet, see [[platform-shared-responsibility]].

## What it does not do yet

- No persistence outside the simulator.
- No real authentication.
- No multi-tenant isolation.
- No subscription gating.
- No camera barcode scanning (`DataScannerViewController` not yet wired).

## Edits

- 2026-06-11: Aligned all locked-state copy with the `Role` capability matrix. Team locked note no longer references a non-existent "Admins" role, Money no longer advertises itself to "Managers and up" when every Money capability is owner-only, and the inventory and customer pricing notes now name "Managers and the Owner" instead of "Manager and up."
- 2026-06-11: Built the owner and employee onboarding flows against the mock Store. Welcome now offers Create-a-business and Join-a-company alongside the three portal previews. Owner flow runs account setup -> business setup -> company-code share -> owner portal. Employee flow runs code entry -> account setup -> a pending-approval waiting room. The waiting room observes the active org's members and auto-transitions the employee into their portal the moment the owner approves the join request from the existing TeamView. To make the flow demoable in one simulator session, the pending screen has an explicit "Demo: approve as the owner" button. Under the hood the mock Store now models multiple Orgs, with members, join requests, products, customers, orders, payments, expenses, and employee costs scoped per Org. View-facing accessors are computed off the active Org so existing screens read unchanged. See [[onboarding-flow]].
- 2026-06-12: Polished the design system and the onboarding flow in three passes, reviewed in the simulator on each pass. Theme gained a named spacing scale (Theme.Space.xxs through xxl) and a named corner-radius scale (Theme.Radius.field, .card, .brand). The inline shipped-green hex now lives as Theme.shipped. A new SectionLabel component encapsulates the uppercased-tracked-muted label pattern. Card and MetricCard corner radius dropped from 16 to 14 so every card-shaped surface in the app shares the same radius. The onboarding screens got their own pass on top: form fields breathe at Theme.Space.md, the Company Code Share screen treats the code as a centered 40pt hero, the Join code-entry screen validates live with green found / red not-found indicators, the Pending Approval screen has an animated pulsing hourglass and consolidates production explanation and demo affordance into a single Demo helper card. Finally, the two account-setup forms previously had a silently-disabled submit button; they now render inline red hints under fields with bad content plus a persistent muted line beneath the button explaining the next thing to fix.
