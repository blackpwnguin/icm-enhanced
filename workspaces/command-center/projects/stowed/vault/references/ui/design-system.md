---
project: stowed
type: reference
status: building
stage: "-"
tags: [swift, ios, stowed]
updated: 2026-06-12
---

# Design system

The shared visual and component layer.

## Files

- `Shared/Theme.swift`: colors, named spacing scale, named corner-radius scale, serif font helper.
- `Shared/Components.swift`: reusable cards, pills, buttons, labeled form fields, validation hints.

## Tokens

Spacing scale via `Theme.Space`: `xxs` 4, `xs` 8, `sm` 12, `md` 16, `lg` 20, `xl` 24, `xxl` 32. Use these instead of literals so layout stays consistent as the app grows.

Radius scale via `Theme.Radius`: `field` 10 for inputs, `card` 14 for everything card-shaped (cards, row links, locked notes, primary buttons), `brand` 16 reserved for the brand mark.

Colors stay flat on `Theme`: surfaces (`bg`, `card`, `border`, `soft`), text (`ink`, `muted`), brand and status (`accent`, `amber`, `red`, `shipped`). The `shipped` token is the in-motion / completed green used by the Shipped order status pill and the Revenue Completed metric.

## Components

- `Screen` wraps content in a tinted ScrollView with optional icon and subtitle.
- `Card` is a white panel with `Theme.Radius.card` corners and a border.
- `MetricCard` is a Card with a `SectionLabel`, a large serif value, and a muted note.
- `RowLink` is a tappable row styled like a card.
- `StatusPill` renders an `OrderStatus` as a tinted capsule.
- `LockedNote` is a muted callout used for role-gated explanations.
- `PrimaryButton` and the `View.primaryStyled(disabled:)` extension share one styling for primary CTAs whether the caller is a `Button` or a `NavigationLink`.
- `LabeledField` is the onboarding form field: uppercased label, input bedded in `Theme.bg`, optional `FieldHint` beneath for validation feedback.
- `FieldHint` carries a tone (`muted` / `error` / `success`) with matching icon and color, used inline under fields and beneath primary buttons.
- `SectionLabel` is the uppercased, 0.5-tracked, muted-grey label used inside cards; one source of truth for the pattern that used to be inlined ~20 times.

## Swift 6 conventions used

- `@Observable` macro (not `ObservableObject`).
- `@Environment` injection (not `@EnvironmentObject`).
- `@State` for the root environment object.

Target: iOS 17 and up. SwiftUI.

## Mock data

The mock data set is a coffee roaster called Northbeam Coffee Co. It exists to make every screen render end-to-end without a backend. The roaster framing is for development only; product positioning is in [[positioning]].
