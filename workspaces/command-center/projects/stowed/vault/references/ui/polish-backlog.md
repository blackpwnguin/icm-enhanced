---
project: stowed
type: reference
status: building
stage: 02-build
tags: [ios, stowed, ux]
updated: 2026-06-13
---

# UI/UX polish backlog

A read-only assessment of the Stowed front end as it stands, against the competitive sweep in [[competitive-landscape]] and standard iOS practice. Builds on the gap list in [[finalized-experience]] but focused on visual hierarchy, consistency, accessibility, empty/loading/error states, and navigation clarity rather than missing features.

Sources: the four `references/ui/` and `references/product/` planning docs, plus a read pass over the current Swift in `apps/ios/Stowed/Stowed/Features/` and `Shared/`. No build was run; no code was changed; this is a plan only.

## How to read this

Tiers, in priority order. Within a tier, ordered by where I'd start.

- **Must-fix:** genuine bugs, accessibility gaps, design-system regressions, or things that make a single-tap demo awkward.
- **High:** visible polish on workflows users actually do. Real differentiation versus competitors.
- **Nice-to-have:** refinements once must-fix and high land.

Effort is rough: S = under an hour, M = half a session, L = a session or more. Anything marked **[coordinate]** likely overlaps the auth-wiring session that's in flight, so it should be checked against that work before touching.

## Must-fix

| # | Screen / component | What's weak now | Proposed fix | Effort |
|---|---|---|---|---|
| 1 | Money -> Record payment | Dead end when there are no customers: the picker shows "Add a customer first." but the Record button stays disabled and there's no way out without backing out of the sheet | Add a "Add a customer" button inline in the empty state of the customer picker that opens AddCustomerView as a second sheet; or auto-redirect with a one-line note when the sheet opens against zero customers | S |
| 2 | Inventory -> Add product | A product added while a search filter is active does not appear in the list until search is cleared. No visual feedback that the add succeeded | Clear `searchText` automatically when `dismiss()` returns; or surface a brief toast (`Theme.shipped` pill at top) confirming the SKU was added | S |
| 3 | Company Code Share -> Copy code | Rapid double-tap spawns overlapping `Task.sleep` resets, causing the "Copied" affordance to revert to "Copy code" mid-state | Replace the in-line `Task` with a stored `Task?` on the view; cancel any previous task before scheduling the next. Or debounce taps via `.disabled(copied)` for the 2-second window | S |
| 4 | App-wide | No Dynamic Type support. Every `font(.system(size: N))` is a hardcoded pixel size. Users with larger text sizes see the same 11-15pt text regardless of system settings. This is the single biggest accessibility miss | Migrate body / subhead / caption usages to semantic font styles (`.body`, `.callout`, `.subheadline`, `.footnote`, `.caption`). Keep the serif display sizes as fixed since they're brand. Test at `.accessibility5` to verify line wrapping | L |
| 5 | App-wide | Icon-only buttons (the `+` toolbar buttons in Inventory and Customers, the `Copy code` button, approve/deny buttons in Team, status chips in Orders) have no `.accessibilityLabel`. VoiceOver reads them as "plus" or skips them | Add `.accessibilityLabel("Add product")` / `.accessibilityLabel("Approve {name}")` / etc. to every icon-only or symbol-only button | M |
| 6 | Tap targets | The Low pill (11pt + 8pt h-pad + 3pt v-pad), Order status chips (12pt + 12pt + 4pt v-pad), and Team approve/deny buttons (13pt + 12pt + 8pt v-pad) are all under the 44x44pt HIG minimum. The Low pill is informational only so it's tolerable; the chips and team buttons are interactive | Pad chips and team buttons to at least 44pt tall using `.frame(minHeight: 44)` plus `.contentShape(Rectangle())` so the whole tap area registers | S |
| 7 | Settings -> Sign out button | Uses `Theme.red` background with white text. The rest of the app's primary buttons use `Theme.ink` background with `Theme.bg` text. Destructive buttons elsewhere (Cancel-and-go-back on PendingApprovalView, Deny in Team) use a quieter treatment | Restyle Sign out as a quiet destructive button (red text on a Theme.card background with a thin Theme.red border) to match the rest of the destructive vocabulary. **[coordinate]** with auth session before changing the sign-out surface | S |
| 8 | Inline section labels | `ProductDetailView`, `OrderDetailView`, and `SettingsView` still use literal `Text("PRICING").font(.system(size: 11, weight: .semibold)).tracking(0.5).foregroundStyle(Theme.muted)` instead of the `SectionLabel` component that was added for exactly this. Three places where the design-system migration is incomplete | Replace the three inline section-label call sites with `SectionLabel(...)` | S |
| 9 | Literal padding and corner radii | `WelcomeView` uses `padding(.horizontal, 28)`, `padding(.top, 60)`, `cornerRadius: 14`, `cornerRadius: 16` directly. `HomeView` uses `padding(20)`, `spacing: 14`. The Theme.Space and Theme.Radius tokens exist but are bypassed in these two files | Migrate the literals to `Theme.Space.*` and `Theme.Radius.*`. Welcome's 28pt horizontal padding sits between `xl` (24) and `xxl` (32); pick one and stick with it. **[coordinate]** for WelcomeView | S |
| 10 | JoinCodeEntryView | The dev hint "Try `NB4X9K2` to join Northbeam Coffee Co in the demo." is shipped end-user copy today. Won't read well to a non-dev demo audience | Wrap the line in a `// UI-PHASE DEMO: remove before TestFlight` marker the same way the other demo affordances are tagged. **[coordinate]** with auth session since it's onboarding-flow-adjacent | S |
| 11 | Color contrast | `Theme.muted` (#6B7A70) on `Theme.bg` (#F7F4ED) is roughly 4.0:1 contrast. WCAG AA wants 4.5:1 for body text. `Theme.amber` text on `Theme.amber.opacity(0.15)` pills is similar | Verify with a contrast checker. If muted text fails, darken muted by ~10% toward `Theme.ink` (~#5A6960). Status pills can keep current treatment if the text size is large enough that AA-large applies (3:1) | M |

## High

| # | Screen / component | What's weak now | Proposed fix | Effort |
|---|---|---|---|---|
| 12 | Home dashboard | Metric cards stack vertically. For Owner there are five-to-six of them and the screen is heavy scroll. Veeqo and Cin7 use 2-column grids for the same density. The current cards are also tap-dead | Move metric cards into a 2-column `LazyVGrid` (single column on smaller iPhones via size class). Make each card tappable: "Orders to fulfill" jumps to Orders filtered to non-completed; "Low stock" jumps to Inventory sorted low-first; "Outstanding receivables" opens Money | M |
| 13 | Home dashboard | The "Today" label is the literal string "Today" with no date | Show the actual date ("Friday, June 13") underneath or alongside. Use `.formatted(.dateTime.weekday(.wide).month(.wide).day())` | S |
| 14 | Order pipeline | Tap-only advancement via "Mark Packed" buttons. Katana's drag-to-advance kanban cards are loved in reviews. iOS-native equivalent is swipe actions on the order row from the list | Add `.swipeActions(edge: .trailing)` on Order list rows: leading-swipe to mark next-stage, trailing-swipe to cancel. Keep the Mark-button on the detail screen too for discoverability | M |
| 15 | Order cancellation | `OrderStatus.cancelled` exists in the model and as a status pill color, but there is no UI surface to actually cancel an order. Cin7 reviewers complain about cancellation being hidden; this is the opposite problem (it's totally absent) | Add a "Cancel order" action on OrderDetailView's pipeline card. Confirm with an alert (`"Cancel SO-1042? This cannot be undone."`). Status becomes `.cancelled` and the Mark-next button disappears | S |
| 16 | Customer detail | Email and phone are display-only text. Native iOS apps make them tap-actionable to open Mail / dial / send Messages | Wrap the email row in `Link("...", destination: URL(string: "mailto:\(email)"))` and the phone row in `Link("...", destination: URL(string: "tel:\(phone.filter(\.isNumber))"))`. Add `.accessibilityLabel("Email this customer")` etc | S |
| 17 | Company Code Share | Copy-to-clipboard is the only sharing affordance. Owners onboarding employees will more often want to SMS or email the code | Add a `ShareLink(item: "Join my Stowed warehouse with code \(org.code)")` alongside the Copy button. Native iOS share sheet handles SMS, Mail, AirDrop, etc | S |
| 18 | Add expense | Category is freeform `TextField`. Reporting later will be much cleaner if categories are constrained, and users save typing | Replace category text field with a horizontal chip picker of common categories (Rent, Utilities, Supplies, Materials, Shipping, Software, Other). Selecting Other reveals a TextField. This is pure UI work; the Expense model already takes a String | S |
| 19 | Record payment | Customer picker is a vertical list inside a Card. At 20+ customers this is unwieldy. No search | Inline search field at the top of the customer picker card, filtering on name. Same `searchText.trimmed.lowercased().contains` pattern InventoryView uses | S |
| 20 | Recording amount | Amount field on Record Payment doesn't preview the outcome ("Bula Coffee owes $75.00; after this payment $0.00") | Below the amount field, show a one-line projected balance using the same balance math Store already has. Updates as the user types. Helps catch fat-finger entries | S |
| 21 | More menu | List-based menu (uses SwiftUI `List`) is visually inconsistent with the rest of the app's Card-based design. Reads as Settings, not as primary navigation | Restyle the More menu as a series of `RowLink` cards in a `ScrollView`, matching Inventory / Orders / Customers patterns. Keeps the design language consistent | M |
| 22 | More menu | Team menu item gives no signal when there are pending join requests. The owner has to remember to check | Show a badge dot or count chip next to "Team" in More when `store.joinRequests.count > 0`. Same on the Home dashboard "Join requests" metric (already exists) but cross-link | S |
| 23 | Empty states | The component (`EmptyStateCard`) is used on Inventory, Customers, Orders, Payroll. Money's three sections use inline plain text instead ("No payments yet. Tap Record to log one.") The visual hierarchy is uneven | Use `EmptyStateCard` consistently across all empty-list surfaces. The inline-text approach is fine for one-line empties inside an existing card; the card approach is better when the entire screen is empty | S |
| 24 | Loading and saving | Form sheets dismiss the moment the local `Store.add*` call returns. There's no progress indication. When backend wires, sheets will need to await an async call and the UI today doesn't expect that | Add a `@State isSaving` to each add/edit sheet. Disable the form and show a small spinner on the PrimaryButton while submitting. The mock Store will return instantly so this is design hygiene now, real value when the backend lands | M |
| 25 | Refresh control | List screens have no pull-to-refresh. Backend phase will need it for syncing remote changes | Add `.refreshable { /* no-op for mock; reload from server when wired */ }` to Inventory, Orders, Customers, Money, Team, Payroll | S |
| 26 | Haptic feedback | Approving a join request, advancing an order, copying the code, and other key actions land silently. iOS users expect a brief `UIImpactFeedbackGenerator(.light).impactOccurred()` on satisfying actions | Add haptics: light on copy-code and advance-order, medium on approve / save-role / record-payment, success on add-product / add-customer | S |
| 27 | Inventory list density | Single-column row list. Competitive apps use a denser layout (small thumbnail + title + qty) at 50+ SKUs | Keep the current row at the default; offer a "compact" view toggle later. Defer for now but worth flagging in the doc. Out of scope for tonight if effort budget is short | M |
| 28 | Inventory and Orders | No sort affordance. Insertion order is the default. Owners at 50+ SKUs want low-stock-first or alphabetical | Add a sort menu (`Menu` with `Picker`) in the toolbar next to the `+` button. Inventory sorts: Name asc / Name desc / Low stock first / Recently added. Orders sorts: Status / Newest / Largest total | M |
| 29 | CreateOrderView | The line-items step is still stubbed with placeholder text. This is the single biggest missing flow in the operational surface. inFlow and Veeqo both shine on this | Build the line-items step: picker for product, qty stepper, auto-resolved unit price from the customer's pricing, running total card. Save-as-Draft and Save-and-Confirm buttons. This is the full Create Order flow noted in [[finalized-experience]] item 12 | L |

## Nice-to-have

| # | Screen / component | What's weak now | Proposed fix | Effort |
|---|---|---|---|---|
| 30 | Typography tokens | Font sizes are repeated as literals across all view files (`size: 11, size: 12, size: 13, size: 14, size: 15`). No `Theme.Type` layer | Define `Theme.Type.body`, `.subheadline`, `.caption`, `.label`, `.headline`, etc. on top of the semantic SwiftUI fonts. This also helps #4 (Dynamic Type) by giving us one place to migrate | M |
| 31 | Customers list | No search bar. At 5 customers it's fine; competitor pattern across the board is search by default | Add `.searchable` to CustomersView the same way Inventory has it | S |
| 32 | Tab bar shape | Today: Home / Inventory / Scan / Orders / More for everyone. Owners are more in Money and Customers than they are in Scan; Employees are more in Scan than they are in Inventory | Role-aware tab bars: Owner gets Home / Orders / Customers / Money / More; Manager gets Home / Inventory / Orders / Customers / More; Employee keeps the current shape. Already flagged in [[finalized-experience]] but ties into navigation hierarchy | M |
| 33 | Settings | The company code sits as a small monospaced line inside the Warehouse card. Owners onboarding a new employee in person want to find it fast | Promote the code to a dedicated "Invite your team" entry at the top of Settings that re-opens the Company Code Share view, with a Share button right there | S |
| 34 | Welcome screen | The "Welcome to Stowed." display heading at 38pt and the brand mark at 56x56 are both large for the available vertical space, pushing the primary CTAs below the fold on smaller iPhones. **[coordinate]** since onboarding is auth-adjacent | Reduce brand mark to 48pt and display heading to 32pt to fit the first CTA above the fold on iPhone SE | S |
| 35 | Product detail | The edit-price flow opens an inline Card inside the same Screen. Every other "edit" action in the app opens a sheet. Inconsistent | Migrate edit-base-price to a sheet, matching the AddProductView pattern. Owner stays oriented | S |
| 36 | Symbol decoration | Decorative icons (the brand mark, the lock icon in LockedNote, the hourglass in PendingApprovalView) are not marked `.accessibilityHidden(true)`. VoiceOver reads them with no context | Add `.accessibilityHidden(true)` to purely decorative icons. The `hourglass` on PendingApprovalView is a state indicator and could instead get `.accessibilityLabel("Waiting for approval")` | S |
| 37 | Status pill | `StatusPill` uses a colored capsule. It's not labeled for VoiceOver beyond the status string. Fine, but the status colors are the only signal that distinguishes Confirmed from Completed (both use `Theme.accent`). For users who can't see the colors, the text label carries it | Consider varying the symbol or weight by status, not just hue. Or accept that text is the primary signal. Flag rather than fix | S |
| 38 | Animations | State changes (a join request being approved, an order advancing) happen instantly. iOS apps usually animate disappearance / arrival with `.transition` and `.animation` | Add `.transition(.opacity.combined(with: .move(edge: .top)))` to list rows that appear or disappear. Wrap mutations in `withAnimation { ... }`. Small touch, big perceived polish | S |
| 39 | Bullet styling | `CompanyCodeShareView` uses `Text("•")` literally for bullet points. Functional but a hack | Replace with `Image(systemName: "circle.fill").font(.system(size: 4))` or just rely on the design system's preferred list style. Or extract a `Bullet` component if used more than once | S |
| 40 | Order list | The "Move orders through the pipeline..." helper text sits above the filter chips and the list. Redundant with the chips themselves | Drop the helper text. Pipeline understanding can live in a one-time tooltip or the empty state | S |
| 41 | Pluralization | `"\(store.products.count) SKUs"` in Inventory header reads "1 SKUs" when there's one product. Same issue could surface elsewhere with counts | Use `^[\(count) SKU](inflect: true)` or a small helper that pluralizes. Not critical but cheap to do right | S |
| 42 | Demo affordances | Settings has a "Switch portal" section that's a UI-PHASE DEMO of role switching with no marker comment. WelcomeView's preview buttons already have it. Consistency matters when we grep before TestFlight | Add `// UI-PHASE DEMO: remove before TestFlight` to the SettingsView portal switcher. **[coordinate]** with auth session | S |
| 43 | Scan screen | Currently a dark placeholder that explains the feature is coming. Fine, but no CTA path. A scanned-but-not-wired demo flow could simulate the eventual UX | A "Try a scan" button that opens a sheet with a hardcoded simulated barcode-scan result, just to show the eventual interaction shape. Out of scope until the Scan stage spec is written; flag only | M |
| 44 | Per-customer order link | Stowed's positioning angle is per-customer pricing and B2B catalogs (per [[finalized-experience]] bet #4 and [[competitive-landscape]] gap #4). Today the CustomerDetailView shows the per-customer pricing but there's no affordance to send the customer a link to place their own draft | Add a "Send order link" button on CustomerDetailView (Manager and Owner only). For now opens a sheet stub with placeholder content; the eventual implementation needs backend (signed URL plus a customer-facing web view). UI shell first, wire later | M |

## Cross-cutting concerns

Items that aren't single-screen fixes but patterns to apply consistently.

**Spacing and radius tokens.** Theme.Space and Theme.Radius exist but adoption is uneven. Welcome and Home are the worst offenders; the rest of the app has mostly migrated. A grep for literal `padding(\d+)` and `cornerRadius: \d+` would find every remaining stale call site.

**SectionLabel adoption.** The component was added specifically to dedupe the uppercased / 0.5-tracked / muted-grey label pattern, but inline `Text(...).font(.system(size: 11, weight: .semibold)).tracking(0.5).foregroundStyle(Theme.muted)` still exists in three view files. Item #8 above lists them.

**Sheet vs inline edit.** Add flows open sheets. Inline edit (the price edit on Product detail) breaks the pattern. Pick one and stick with it. Sheet is the iOS-native choice for "edit one thing" flows.

**Form validation pattern.** The onboarding flows use `LabeledField`'s `hint` parameter plus a disabled-reason caption beneath the primary CTA. The add-flows (product, customer, payment, expense) do not. Could be made consistent by using `FieldHint` on the add-flow fields too, particularly Amount fields that today silently disable the submit when empty.

**Loading and async UI patterns.** When the backend lands, every Store mutation becomes async. Today the UI has no `@State isLoading`, no progress indicators, no error states. The shape needs to be designed before the wiring session so we don't bolt on a spinner here and a toast there. Recommendation: a single `OperationState` pattern (`.idle / .loading / .error(String)`) used by every async-eligible view, plus a single `ErrorBanner` component.

**Empty / loading / error state design system.** Today only the empty state has a component (`EmptyStateCard`). We'll want sibling components for loading skeletons and error-with-retry. Designing these as a family in advance keeps them visually coherent.

**Accessibility audit.** Beyond #4 (Dynamic Type) and #5 (VoiceOver labels), the app needs: `.accessibilityElement(children: .combine)` on tappable Card-shaped buttons so VoiceOver reads them as one element rather than four; explicit reading order on screens with mixed text + icons; `.accessibilityRespondsToUserInteraction` on the metric cards once they become tappable per #12.

**Haptics and animation.** Both are inexpensive to add, both compound the felt quality of the app. Worth a dedicated pass once must-fix is clean.

## What competitors do well that Stowed is missing

Pulling from [[competitive-landscape]] and ranked by how much of it is genuinely UI/UX-shaped (i.e. can be designed and partially built without backend).

1. **Veeqo's digital picking flow.** Scan to confirm pick, errors flagged inline. Stowed's Scan screen is a placeholder. When the Scan stage lands, the picking interaction should be modelled on Veeqo's, not on Cin7's (which reviewers complain about). UI shape worth designing now even though camera comes later.
2. **Katana's kanban-style drag-to-advance orders.** SwiftUI equivalent is swipe actions, already in #14 above.
3. **inFlow's per-customer B2B catalog.** UI shell in #44; backend later.
4. **Zoho's Zia assistant button as a persistent floating affordance.** Stowed's plan is a dedicated Insights tab. The competitive sweep notes Zoho is the only one with inline AI surface; everyone else uses a dedicated section. Stowed's Insights tab is the right pattern; the floating button is optional polish and can be deferred.
5. **2-column metric dashboards.** Veeqo and Cin7 both. Item #12.
6. **Native iOS Share Sheet on shareable artifacts.** Standard expectation; today only Copy exists. Item #17.
7. **Notification badges on tab items / menu items.** Standard iOS. Item #22.
8. **Order cancellation surfaced clearly.** Cin7 hides it; Capterra reviewers complain. Stowed has no UI yet. Item #15.
9. **Tap-actionable contact rows on customer detail.** iOS-native; missing in Stowed. Item #16.
10. **Pull-to-refresh on list screens.** Standard iOS; Stowed will need it when backend wires. Item #25.

What competitors do that Stowed is **right** to defer or not adopt:
- CSV import / export (deferred per [[finalized-experience]])
- QuickBooks integration (deferred)
- Multi-warehouse per org (deferred)
- Web app companion (out of scope; Stowed bets on mobile-first per [[finalized-experience]] positioning bet #1)
- "Implementation engineer" paid onboarding (intentionally not adopted; that's the anti-pattern)

## Out of scope for this backlog

Per the session instruction: nothing here proposes backend or data-layer changes, and nothing here depends on the auth wiring in flight. Items tagged **[coordinate]** brush up against the auth surface and should be checked with that session before implementation. Pure-UI items are safe to land in parallel.

Also excluded:
- Feature gaps already enumerated in [[finalized-experience]]'s "What I am explicitly NOT trying to ship in this phase" section (CSV, push notifications, multi-warehouse, audit log UI, etc.)
- Anything requiring the AI / chatbot to be live (the Insights stub is the placeholder; the actual chat surface is post-backend)
- Pricing tier / subscription gating UI (depends on RevenueCat wiring per [[platform-shared-responsibility]])
- Privacy manifest / App Store submission prep (a TestFlight-time concern)

## Suggested next session shape

If we run a polish session, my recommendation is to land items 1-11 (all must-fix) in one focused pass. That's roughly half a day of work and produces a visible quality jump across every screen without touching the auth wiring. Items 12-29 (high) are then a second session, with #29 (full Create Order flow) being its own session given the L effort.
