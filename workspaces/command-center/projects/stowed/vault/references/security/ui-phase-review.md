---
project: stowed
type: reference
status: review
stage: 02-build
tags: [security, ios, stowed]
updated: 2026-06-12
---

# Code-level security review: UI phase

Scope honesty up front. This is a mock-data SwiftUI app: no network calls, no persistence, no auth backend, no SQL, no third-party SDK that handles data, no inter-process communication. The classic OWASP / mobile attack surface largely does not apply yet. That ownership moves to the Supabase phase, where [[platform-shared-responsibility]] takes over.

What this review checks is the smaller set of things that DO matter pre-backend: the code we ship into the Supabase phase should not bake in shapes or habits we'd later regret. Specifically:

1. No credentials, secrets, or tokens committed.
2. No logging that would leak credentials or PII if developer logging were turned on.
3. No force-unwraps that crash on malformed user input.
4. No inline hex / magic strings that hide config drift.
5. Multi-org logical isolation in the mock matches the RLS shape the backend will enforce.
6. Password and PII handling habits are right, even though no password is ever sent yet.
7. Demo-only affordances are identifiable so they can be stripped before TestFlight.
8. UI patterns that will affect AI integration (chatbot, analytics) are not locked in wrong.

## Audit method

Static grep across `apps/ios/Stowed/Stowed/`:
- Force-unwraps: `[a-zA-Z\)\]\?][\.\!]|![\.\,\)\]]` patterns.
- Logging: `print`, `NSLog`, `os_log`, `debugPrint`.
- TODO / FIXME / XXX / HACK markers.
- Hardcoded credential patterns: `api_key`, `token`, `secret`, literal password assignments.
- URL / network: `URLSession`, `URL(string:`, http(s) literals.
- Clipboard: `UIPasteboard`.

Plus manual walkthrough of `Store`, `AppEnvironment`, the onboarding flow files, and TeamView for the multi-org isolation check.

## Findings

### F1. One genuine force-unwrap (low risk, fix anyway)

`Core/Store.swift:175`:

```swift
private func makeCompanyCode(length: Int = 6) -> String {
    let alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    var code = ""
    for _ in 0..<length { code.append(alphabet.randomElement()!) }
    return code
}
```

`alphabet` is a non-empty constant, so `randomElement()` cannot return nil. Currently safe. But the habit of `!` after `randomElement()` is exactly the habit that crashes us when someone later edits the alphabet to a computed value, or when this gets ported to a generator that handles a configurable alphabet. Replace with a nil-coalesce default.

### F2. No logging, no debug prints

No `print`, `NSLog`, `os_log`, or `debugPrint` in the codebase. Good baseline. When we add real auth, do not regress this: forbid logging credentials, refresh tokens, full emails, full phone numbers, or payroll figures.

### F3. No TODO / FIXME / XXX

None present. Anything deferred is captured in the build log or this doc.

### F4. No hardcoded credentials

Grep for `api_key`, `token`, `secret`, password literals returns nothing of interest. The hits on "password" are `@State private var password = ""` form fields, not stored credentials. Confirmed.

### F5. No URL / network / pasteboard usage

Zero network, zero URL parsing, zero clipboard. There is no exfiltration surface in the UI phase. Note for Part 6 below: if we add Copy on the Company Code Share screen, that goes through `UIPasteboard.general.string = ...`, which is fine for a code share but is the moment we start having to think about what is and is not safe to put on the system clipboard.

### F6. Multi-org logical isolation in the mock Store

The mock Store models multiple Orgs (`Core/Models.swift`, `Org` struct). Per-org collections (`members`, `joinRequests`, `products`, `customers`, `orders`, `payments`, `expenses`, `employeeCosts`) all nest inside the Org. The view-facing accessors on `Store` (`store.products`, etc.) read from the active org. This is the right shape to mirror Supabase RLS: every read is implicitly scoped to one org.

Cross-org leakage paths I checked, and what I found:

- `mutateActiveOrg` only ever touches the active org. ✓
- `mutateOrg(_:_:)` requires an explicit orgID, used only by `submitJoinRequest` which legitimately writes into the org the employee just joined. ✓
- `member(byEmail:in:)` and `pendingRequest(forEmail:in:)` both require explicit orgID. ✓
- `findOrg(byCode:)` iterates `orgs` globally. This IS supposed to be a directory lookup (the join flow has to find an org by code before the user has access to it). When this becomes a Supabase call, it must be a server-side function (Edge Function) that performs the lookup with elevated privileges and returns only the org's display name and id (never any of its private collections). Do not expose the underlying table to anonymous reads.
- `approve(_:as:)` mutates the active org. The TeamView renders `store.joinRequests` which is `activeOrg.joinRequests`, so the owner can only see and approve requests in their own active org. Logical isolation is correct here.
- `setActiveOrg(_:)` is `public` but only called from `AppEnvironment.enterDemoOrg`, `AppEnvironment.submitJoinAndWait`, and `Store.createOrg`. No view code calls it directly. Could be tightened by making it `internal(set)` and exposing controlled setters, but the call graph is small enough that the current shape is fine.

Conclusion: the mock matches the RLS shape. The thing to enforce in Supabase: every per-org table carries `org_id`, RLS policy is `org_id = (SELECT org_id FROM memberships WHERE user_id = auth.uid())`. Already captured in [[platform-shared-responsibility]].

### F7. Password handling (mock auth)

Passwords are captured in form `@State` and never:

- Stored in the Store
- Passed to `AppEnvironment.createBusiness(orgName:ownerName:ownerEmail:)` (signature does not accept password)
- Passed to `AppEnvironment.submitJoinAndWait(name:email:on:)` (signature does not accept password)
- Logged anywhere

When the view pops, the `@State var password = ""` is released. Correct UI-phase shape: passwords are a UI-only placeholder until Supabase Auth.

When Supabase Auth lands, the password should:

- Use `.textContentType(.newPassword)` so iOS surfaces the password generator and integrates with Keychain.
- Never be logged, even at debug.
- Be sent directly to Supabase Auth's `signUp` / `signIn` and discarded from local state immediately.
- Never be stored in `AppEnvironment` or `Store`.

### F8. Personal data display

Member emails appear in TeamView. Customer emails and phone numbers appear in CustomersView and CustomerDetailView. These are in-app displays for users who legitimately need to see them, not logged, not exfiltrated. Correct.

For AI integration (future): before sending any customer or member data to an LLM endpoint, classify it. The Sentry-scrubbing pattern from [[platform-shared-responsibility]] applies here too: customer phone numbers, member emails, and payroll figures should be redacted or pseudonymized before reaching any third-party LLM unless the user has explicitly opted in.

### F9. Validation rules (mock, will tighten)

Mock rules in onboarding forms:

- Name: `!trimmed.isEmpty` ✓ reasonable
- Email: `contains("@")` — toy validation
- Password: `count >= 6` — toy policy

Both email and password rules are clearly UI-phase placeholders. Supabase Auth will apply its own validation server-side; the client should match (`AsyncEmailValidator`-style regex plus visual feedback). The current `LabeledField.hint: FieldHint?` API already supports this; only the rules need swapping out.

### F10. iOS form metadata not set

Form fields do not declare `.textContentType(...)`:

- Email fields should set `.textContentType(.emailAddress)` so iOS autofill and password managers behave.
- Password fields should set `.textContentType(.newPassword)` on signup screens and `.textContentType(.password)` on sign-in (we have no sign-in screen yet).
- Owner/employee name fields could set `.textContentType(.name)`.

Not critical for mock auth but a low-cost add. Adding them now means we lean into the iOS Keychain / Password autofill story automatically when Supabase Auth lands.

### F11. Demo-only affordances (must be tagged for removal)

These exist for UI-phase demo and must not ship to TestFlight:

1. **WelcomeView "Preview a portal" buttons** — let anyone enter the app as Owner/Manager/Employee of the seed Northbeam org without auth. Strip these in the auth phase.
2. **`AppEnvironment.enterDemoOrg(as:)`** — supports the above. Remove with them.
3. **`Store.demoOrgID` and the seed Northbeam org data** — debug data. Keep behind a `#if DEBUG` or feature flag, not in production builds.
4. **`PendingApprovalView` "Demo: approve as the owner" button** — a self-approval shortcut for single-simulator testing. Remove before TestFlight.

Recommendation: add a single grep-able marker comment to each, e.g. `// UI-PHASE DEMO: remove before TestFlight`. That way removing them later is a five-minute mechanical task and a grep verifies completeness.

### F12. SwiftUI Text markdown rendering (verified safe)

SwiftUI's `Text(_:)` initialized from a `LocalizedStringKey` (the default for string literals) parses Markdown formatting characters. For interpolated values inside literal Text initializers, e.g. `Text("Email: \(member.email)")`, the interpolation segment is treated as opaque and is NOT subject to Markdown parsing. Direct variable Text, `Text(stringVar)`, uses the non-LocalizedStringKey overload and never parses Markdown.

Audit shows: every user-provided value is either rendered directly via `Text(stringVar)` or interpolated inside a literal. Confirmed safe. Convention to keep: use `Text(stringVar)` for raw display, and use interpolation only for formatting (`Text("Created by \(order.createdBy)")` etc.), never for user-provided composite content like a description field that might legitimately contain `**` or `_`.

### F13. Bundle permissions

`Info.plist` is generated by xcodegen from `project.yml`. Today's permission surface:

- No camera entitlement.
- No microphone entitlement.
- No photo library entitlement.
- No location entitlement.
- No background modes.

When ScanView is wired with the camera, we'll need `NSCameraUsageDescription` with clear copy ("Stowed uses the camera to scan barcodes for stock receiving."). Defer that to the scanning stage.

### F14. AI integration: design considerations to capture now

Not actionable code, but design decisions worth fixing in this doc before the AI phase starts:

- **Per-user, role-aware context.** The chatbot's system prompt should include the user's role and the org's display name, never the org's internal id. The set of tools / functions the chatbot can call must be filtered by role. An employee chatbot has no `read_payroll` tool. This is the same role-gating as the UI; just enforced on the LLM side.
- **PII minimization in prompts.** When the chatbot needs to discuss orders, customers, or members, redact: full email addresses (use first-initial + last-name patterns), full phone numbers (last four only), payroll dollar figures (use relative wording like "this period vs. last"). User opts in to fully-disclosed context only when needed.
- **Prompt injection from customer-controlled fields.** Customer notes, order line items typed by users, and customer names are untrusted strings. Before passing them to the LLM, wrap them in clearly-delimited blocks (`<customer_note>...</customer_note>`) and instruct the system prompt to treat content inside those blocks as data, not instructions. Standard defense.
- **No write access without a UI confirmation step.** The chatbot can suggest "I'd advance order SO-1042 to Packed" but cannot actually perform the mutation without the user tapping a confirmation. Tool calls go through the same approval gate as a manual click.
- **Audit log includes chatbot actions.** Every tool call the chatbot performs on the user's behalf gets logged with `actor: chatbot, on_behalf_of: user_id` in the audit table. Required for tenant trust.

### F15. Things I am not auditing tonight

- Cryptographic primitives (none in use yet)
- Token storage (none yet, will be Keychain via Supabase SDK)
- Biometric gates on sensitive screens (deferred to auth phase; planned for Money and Payroll per the shared-responsibility doc)
- Certificate pinning (not applicable to Supabase managed)
- App Attest (deferred to auth phase)
- Privacy manifest `PrivacyInfo.xcprivacy` (needed before TestFlight)
- App Store Privacy Nutrition Labels (submission-time)
- GDPR/CCPA data-subject request handling (backend phase)

## Recommended fixes tonight

In priority order:

1. **F1** — fix the one force-unwrap. Trivial.
2. **F10** — add `.textContentType(...)` to email, password, and name fields across the four account-setup screens. Low-cost ergonomic and security win.
3. **F11** — add `// UI-PHASE DEMO: remove before TestFlight` markers on the four demo affordances so they grep cleanly.

Everything else is captured here and either deferred to the backend phase, captured in [[platform-shared-responsibility]], or design guidance for the AI phase.

## Bottom line

The UI phase code is clean for what it is. Most of the security surface arrives with Supabase tomorrow. The shape of the mock Store correctly mirrors the RLS shape the backend will enforce, the password handling habit is right, and there is no logging or exfiltration to worry about. The three small fixes above are the only code-level actions worth taking before the backend phase.
