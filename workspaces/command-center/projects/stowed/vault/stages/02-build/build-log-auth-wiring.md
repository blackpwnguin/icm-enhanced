---
project: stowed
type: build-log
status: building
stage: 02-build
tags: [ios, stowed, auth, supabase]
updated: 2026-06-13
---

# Build log: auth wiring slice

Replaces the mock-only Welcome / Owner-account flow with real Supabase
Auth (email + password, deep-link confirmation). Data tables stay on the
mock `Store` for this slice. Backend project ref: `arqkutfkziicuxfesghm`.
RPC contract: [[rpc-functions]]. The site-by-site map evolves at
[[frontend-wiring-map]].

The slice is structured as four checkpoints. STOP after each.

## Checkpoint 1: SDK + client setup (2026-06-13)

### What landed

- `apps/ios/Stowed/project.yml`: switched from `GENERATE_INFOPLIST_FILE`
  to an explicit `info:` block managed by xcodegen (sets up clean
  CFBundleURLTypes for Checkpoint 2). Added `configFiles:` referencing
  `Stowed.xcconfig` for both Debug and Release. Added the supabase-swift
  SPM package (`https://github.com/supabase/supabase-swift`, `from: 2.0.0`).
- `apps/ios/Stowed/Stowed.xcconfig` (gitignored): real `SUPABASE_URL`
  and `SUPABASE_ANON_KEY`. URL uses the `/$()/` escape trick so the `//`
  in `https://` is not interpreted as a comment.
- `apps/ios/Stowed/Stowed.xcconfig.example` (committed): same shape with
  placeholder values, for any other dev cloning the repo.
- `.gitignore`: excludes `apps/ios/Stowed/Stowed.xcconfig`.
- `Stowed/Stowed/Core/AppConfig.swift`: reads `SupabaseURL` and
  `SupabaseAnonKey` from `Bundle.main.infoDictionary`. Crashes with a
  clear message if either is missing. A misconfigured dev build should
  be obvious at launch, not silently broken.
- `Stowed/Stowed/Core/SupabaseService.swift`: a single
  `SupabaseClient` exposed as `SupabaseService.client`. One client per
  process keeps the SDK's auth, REST, and realtime modules on the same
  session store.

### Credentials hygiene

- The **anon / publishable** key (`sb_publishable_...`) is the only key
  embedded in the app. It is designed to ship to clients; RLS is the
  real protection (see [[backend-threat-model]]).
- The **service-role** key never touches this repo, never touches a
  device. It bypasses RLS and lives only in server-side configuration
  (Supabase dashboard, future Edge Functions).
- Rotating the anon key is a one-line xcconfig change.

### Build evidence

- `xcodebuild -resolvePackageDependencies` resolved Supabase 2.46.0 plus
  transitive deps (swift-asn1, swift-crypto, swift-clocks,
  swift-concurrency-extras, swift-http-types, xctest-dynamic-overlay).
- Debug build for `generic/platform=iOS Simulator`: `BUILD SUCCEEDED`.
- Debug build for the booted iPhone 17 Pro (iOS 26.2):
  `BUILD SUCCEEDED`.
- `PlistBuddy` against the built bundle's `Info.plist` confirmed the
  xcconfig substitution: `SupabaseURL` -> the real project URL,
  `SupabaseAnonKey` -> the publishable key. The on-disk source
  `Info.plist` keeps `$(SUPABASE_ANON_KEY)` placeholders.
- App installed and launched on the simulator; Welcome screen renders
  identically to before. The SDK link did not break the existing UI.

### Open question for review

- App URL scheme: Sam asked for `stowed://auth-callback`. Checkpoint 2
  will register that. Custom schemes are not unique on a device, so any
  other app registering `stowed` could intercept the callback. Fine for
  dev; should be replaced with Universal Links for TestFlight. Not
  blocking.

## Checkpoint 2: deep link plumbing (2026-06-13)

Wires the three places that must agree on the callback URL so a Supabase
Auth email-confirmation link, tapped on the device, opens the app, hands
the URL to the SDK, and the SDK can establish a session from the tokens
embedded in it.

### The exact string

`stowed://auth-callback`

Custom scheme `stowed`, path `auth-callback`. Used identically in every
piece below. Mismatch in any one of them silently breaks email
confirmation; Supabase responds 400 against an unlisted redirect, and
iOS refuses to route a URL whose scheme isn't registered.

### The three pieces

1. **App URL scheme** in `apps/ios/Stowed/project.yml` (the `info:`
   block, not a separate file):
   ```yaml
   CFBundleURLTypes:
     - CFBundleURLName: app.stowed.auth
       CFBundleURLSchemes:
         - stowed
   ```
   Registers the `stowed://` scheme on the bundle. The path
   `auth-callback` is implicit; every `stowed://*` URL routes to the
   Stowed app.

2. **Supabase redirect allow-list**: `stowed://auth-callback` added at
   Dashboard -> Authentication -> URL Configuration -> Redirect URLs.
   Sam added this manually on 2026-06-13 because the connected Supabase
   MCP doesn't expose Auth-config endpoints. A future Management-API
   pass could automate this; not blocking.

3. **Deep-link handler** in `apps/ios/Stowed/Stowed/App/StowedApp.swift`:
   ```swift
   .onOpenURL { url in
       Task {
           try? await SupabaseService.client.auth.session(from: url)
       }
   }
   ```
   Receives any URL whose scheme matches piece 1, hands it to
   `Auth.session(from:)`, which parses the access and refresh tokens out
   of the URL fragment / query and sets the SDK's current session.

### Verification done this checkpoint

- `xcodegen generate` succeeded; project regenerates cleanly with the
  new info block.
- `xcodebuild ...` BUILD SUCCEEDED on iPhone 17 Pro (iOS 26.2). The
  Supabase Swift SDK's `Auth.session(from:)` API resolved, so the
  handler is properly typed and the SDK version (2.46.0) supports the
  shape we're calling.
- `PlistBuddy -c "Print :CFBundleURLTypes" .../Info.plist` returns the
  registered scheme. The source Info.plist on disk holds the same.
- `xcrun simctl openurl booted "stowed://auth-callback?demo=1"` against
  the running app brought up the OS-level "Open in Stowed?" consent
  dialog. That dialog is iOS 16+'s per-launch protection for custom
  schemes; its appearance is itself proof the scheme is registered
  (otherwise simctl would error with "no app for scheme").

### Not verified this checkpoint

The deep-link handler actually firing end-to-end against a real
confirmation URL. iOS requires explicit user-tap on the consent dialog
for simctl-triggered URLs and the test environment can't synthesize
that tap without Accessibility permission for osascript. The real flow
in Checkpoint 3 routes through Mail.app, which is a trusted source for
deep links and bypasses the consent dialog; that flow will be the true
end-to-end test.

### Pre-TestFlight follow-up: Universal Links

Custom schemes aren't unique on a device. Any other app that registers
`stowed` could intercept Stowed's auth callbacks. For dev and TestFlight
internal testing the risk is acceptable; for public release we MUST
switch to Universal Links (an `applinks:auth.stowed.app` domain with an
apple-app-site-association file served over HTTPS). Tracked as a
follow-up task; not landing this checkpoint.

### Commits

- Code: TBD (one commit for project.yml + StowedApp.swift).
- Vault: this build-log entry plus the wiring-map update.

## Checkpoint 3: sign-up flow with email confirmation (2026-06-13, END-TO-END VERIFIED)

Replaces the mock OwnerAccountSetupView -> BusinessSetupView ->
CompanyCodeShareView flow with real Supabase Auth sign-up, an
intermediate "check your email" screen, and a deep-link-driven
org-creation step that runs AFTER the session is established.

### Critical ordering

The org never gets created without a valid session in front of it. The
chain:

1. User submits BusinessSetupView. `signUpOwner` calls
   `auth.signUp(email, password, data: ["full_name", "pending_org_name"],
   redirectTo: stowed://auth-callback)`. Returns; no session yet.
2. `authStatus = .awaitingEmailConfirmation(email)`. RootView swaps to
   ConfirmEmailView.
3. User opens Mail, taps the confirmation link.
   `stowed://auth-callback#access_token=...&refresh_token=...` arrives.
4. Checkpoint 2's `.onOpenURL` handler in StowedApp.swift calls
   `auth.session(from: url)`. The SDK exchanges/parses the tokens and
   sets the current session.
5. The session establishment fires a `.signedIn` event on
   `auth.authStateChanges`. AppEnvironment's listener picks it up and
   calls `onSessionEstablished(_:)`.
6. `onSessionEstablished` reads `session.user.userMetadata` for
   `pending_org_name`. If present, calls `finalizeOwnerOnboarding`,
   which calls `create_org_and_self_owner(name)` via PostgREST RPC.
7. RPC succeeds -> clear `pending_org_name` from the user metadata so a
   future token refresh can't re-trigger this path -> `authStatus =
   .authenticated(role: .owner)` -> RootView swaps to MainTabView.

The RPC checks `auth.uid() is not null` at its top (see
[[rpc-functions]]); calling it without a session would 42501.

### The literal `stowed://auth-callback`

Single Swift source of truth in `AppConfig.swift`:

```swift
static let authCallbackURL: URL = {
    guard let url = URL(string: "stowed://auth-callback") else {
        fatalError("authCallbackURL literal is malformed.")
    }
    return url
}()
```

Used at exactly one call site:

```swift
try await SupabaseService.client.auth.signUp(
    email: email, password: password,
    data: ["full_name": ..., "pending_org_name": ...],
    redirectTo: AppConfig.authCallbackURL
)
```

CFBundleURLSchemes registers `stowed` (scheme only); the path
`auth-callback` is implicit (every `stowed://*` routes to the app).
The Supabase dashboard allow-list holds the full literal
`stowed://auth-callback`. All four agreement points verified by a single
`grep "stowed://auth-callback"` across the iOS source + project.yml.

### Files touched

- `App/AppEnvironment.swift`: rewritten. New `AuthStatus` enum,
  `authError: String?`, `signUpOwner(...)`, `finalizeOwnerOnboarding(...)`,
  `createOrgAndSelfOwnerRPC(...)`, `cancelPendingEmailConfirmation()`.
  Subscribes to `authStateChanges` for the app lifetime. Legacy mock
  paths (`createBusiness`, `enterDemoOrg`, etc.) retained while the
  data-wiring slice is pending.
- `Core/AppConfig.swift`: adds `authCallbackURL` constant.
- `App/RootView.swift`: new `isAwaitingConfirmation` route covering
  `.awaitingEmailConfirmation` and `.finalizingSetup` states. The
  `.signingUp` phase is intentionally NOT a root-swap state so the
  user's nav stack survives sign-up errors.
- `Features/Onboarding/CreateBusinessFlow.swift`: passes password from
  OwnerAccountSetupView through to BusinessSetupView. BusinessSetupView's
  button calls `signUpOwner` in a Task, shows a spinner during
  `.signingUp`, and renders `authError` inline.
- `Features/Onboarding/ConfirmEmailView.swift`: new. Two-phase render
  (awaiting / finalizing) with the email address, an explainer card, a
  "Use a different email" exit, an error banner, and a one-line note
  about the Universal Links pre-TestFlight upgrade.

### Error handling

`signUpOwner` errors set `env.authError` and revert `authStatus =
.unauthenticated`. BusinessSetupView shows the error inline in a red
banner under the button; the user's nav stack survives so they can fix
the email or password and retry. Friendly mapping covers
already-registered, invalid-email, weak-password, and network-down;
unknown errors surface verbatim.

`finalizeOwnerOnboarding` errors used to mask by landing the user in
MainTabView with no org (the silent fail Sam called out during
verification). The instrumentation pass below changed that: failures
now set `authStatus = .setupFailed(orgName:)` and render the verbatim
SDK / PostgREST error in ConfirmEmailView with a Retry CTA.

### Instrumentation pass (2026-06-13)

After the first end-to-end attempt left no organization row despite a
successful `/verify` server-side, instrumented the chain to make every
failure visible. Net + ~150 lines.

- `StowedApp.onOpenURL`: dropped `try?`; delegates to a new
  `env.handleDeepLink(url)` so all error surfacing flows through one
  place.
- `AppEnvironment.handleDeepLink(_:)`: new entry point. Calls
  `auth.session(from: url)` in do/catch. On success, logs hashed user
  id. On failure, sets `env.authError` to a visible message and logs
  the SDK error verbatim. Token-bearing URL components (`fragment`,
  `query`) are never logged; only `scheme`, `host`, `path`, and a
  boolean `hasFragment` go to the log.
- `AppEnvironment.onSessionEstablished`: now logs whether
  `pending_org_name` is present and whether it's non-empty, separately.
  Missing-key path stays as `.authenticated(.employee)` with a notice
  log (Checkpoint 4 territory). Present-but-empty case flips to a new
  `.setupFailed(orgName: "")` so it's obvious in UI.
- `AppEnvironment.finalizeOwnerOnboarding`: on RPC failure, transitions
  to `.setupFailed(orgName:)` rather than masquerading as authenticated.
  Logs the RPC error description verbatim.
- `AppEnvironment.retrySetup()`: re-runs `finalizeOwnerOnboarding`
  for the Retry CTA.
- `AuthStatus.setupFailed(orgName:)`: new state for the visible
  failure path.
- `RootView.isAwaitingConfirmation`: includes `.setupFailed` so the
  user stays on ConfirmEmailView while the error is visible.
- `ConfirmEmailView`: third render phase for `.setupFailed` with a
  red icon, monospaced selectable error text, a Retry button (when
  `orgName` is non-empty), and a "Sign out and start over" exit.

Logging uses `os.Logger` (subsystem `app.stowed.Stowed`, category
`auth`). Error descriptions are `.public` so they're searchable in
Console.app; user ids are `.private(mask: .hash)`; URL fragments and
emails are never logged. Stream from a host shell with:
`xcrun simctl spawn booted log stream --level=debug --predicate
'subsystem == "app.stowed.Stowed" AND category == "auth"'`.

### End-to-end verification (2026-06-13)

Test path: fresh email sign-up on the booted simulator, confirmation
link tapped, return through the deep-link handler.

Captured success trace (Console.app filtered to the auth category):

1. `received deep link; scheme=stowed, host=auth-callback, path=,
   hasFragment=false` — the OS routed the URL into the app
   (`handleDeepLink` did fire), and the URL carried a query param, not
   a fragment, consistent with the SDK being in PKCE mode (default).
2. `session(from:) succeeded; user id <hashed>` — the SDK exchanged
   the PKCE auth code for a session via `/auth/v1/token?grant_type=pkce`
   and stored the session in Keychain.
3. `session established for user <hashed>; metadata keys:
   email,email_verified,full_name,pending_org_name,phone_verified,sub;
   pending_org_name present: true; pending_org_name nonempty: true`
   — `onSessionEstablished` saw the metadata.
4. `finalize start: org_name length=7` — `finalizeOwnerOnboarding`
   ran with the right value.
5. `create_org_and_self_owner RPC succeeded`
6. `cleared pending_org_name from user metadata`

Database confirmation:

```
organizations:
  id: <uuid>
  name: "Test123"
  warehouse_code: 6AFTUJ
  created_at: 2026-06-13 (today)

memberships:
  user_id: 89F247A0...
  organization_id: <same as above>
  role: owner
  status: active

audit_log:
  one org.created entry by user 89F247A0...
```

`raw_user_meta_data.pending_org_name` is no longer set on the user
after success, which proves step 6 ran.

### What the UI currently shows after success (expected gap)

The owner portal renders the Northbeam seed data from the mock `Store`,
not the freshly-created Test123 org. This is correct for this slice:
auth is wired, data is not. Every view that reads from
`env.store.activeOrg.<collection>` will keep showing mock data until
the data-wiring slice replaces those reads with PostgREST queries
against the real tables. The auth state and the data state are
deliberately disjoint right now.

### Errata to fold into Checkpoint 4

`onSessionEstablished` defaults to `.authenticated(.employee)` for any
sign-in path without `pending_org_name`. Checkpoint 4 replaces this
default with a real membership read.

## Checkpoint 4: sign-in + session restore (2026-06-14, awaiting Sam's simulator test)

Adds the missing returning-user path. End of this checkpoint: an existing
Stowed account can sign in, and a Keychain-restored session on a fresh
app launch routes the user into the right portal based on a real
membership row instead of a hardcoded `.employee` placeholder.

### Pieces

- **WelcomeView**: new "Already have a Stowed account? Sign in" link
  between the two main onboarding cards and the demo previews. Small
  accent-coloured text so it doesn't compete with the primary CTAs.
- **`Features/Auth/SignInView.swift`** (new): email + password fields
  (`.textContentType(.username)` and `.textContentType(.password)` so
  iOS surfaces saved-password autofill cleanly), Submit button with
  spinner during `.signingIn`, monospaced text-selectable error banner.
- **`AppEnvironment.signIn(email:password:)`**: calls
  `auth.signIn(email:password:)`. On success, just returns; the
  authStateChanges listener picks up `.signedIn` and routes via
  `onSessionEstablished` → `resolveRoleFromMembership`. Errors set
  `env.authError` and revert `authStatus` to `.unauthenticated` so the
  user stays on SignInView and can retry.
- **`AppEnvironment.resolveRoleFromMembership(session:)`** (new):
  bounded backend read against `public.memberships` with
  `.select("role,status,organization_id").eq("user_id", ...)
  .eq("status", "active")`. RLS makes this work under the signed-in
  session via the existing `membership: self select` policy. Active row
  -> `authStatus = .authenticated(role:)`. No active row -> sign the
  user back out with a visible message so they don't sit in a blank
  portal. Membership read failure -> same, plus the verbatim error.
- **`AuthStatus.signingIn`**: new transient state, not a root-swap
  state (form spinner on SignInView's button; user stays on the nav
  stack so failure recovery doesn't lose context).
- **`friendlyAuthError`**: maps sign-in-specific GoTrue errors -
  `invalid login credentials` → "That email and password don't match";
  `email not confirmed` → "You haven't confirmed your email yet; tap
  the link we sent you." Sign-up mappings retained.
- **`signOut`**: kept the existing behavior (auth.signOut + local
  state clear); replaced the silent `try?` with logged success / notice
  paths under the same instrumentation pattern. Also clears
  `authError` so a stale error doesn't show on the next sign-in.

### Critical ordering, returning-user flow

1. App launches. `AppEnvironment.init` kicks off `observeAuthState`.
2. `authStateChanges` emits `.initialSession` with the Keychain-stored
   session (if any).
3. `handle(event:session:)` -> `onSessionEstablished`.
4. `pending_org_name` is absent (sign-up cleared it after RPC success
   in Checkpoint 3) -> `resolveRoleFromMembership`.
5. PostgREST GET `/rest/v1/memberships?select=role,status,organization_id
   &user_id=eq.<uuid>&status=eq.active` returns the user's active
   membership.
6. `authStatus = .authenticated(role: <role from row>)` -> RootView
   swaps to MainTabView.

Same chain on fresh sign-in via SignInView; only the trigger is
different (auth.signIn instead of restored session).

### Files touched

- `App/AppEnvironment.swift`: `.signingIn` state, `signIn(...)`,
  `resolveRoleFromMembership(...)`, `MembershipRow` private struct,
  friendlyAuthError additions, signOut instrumentation, replaced
  placeholder in `onSessionEstablished`.
- `Features/Auth/WelcomeView.swift`: sign-in NavigationLink row.
- `Features/Auth/SignInView.swift`: new.

### Verification done this checkpoint

- `xcodegen generate` + `xcodebuild ... -destination 'id=iPhone 17 Pro'`
  -> BUILD SUCCEEDED.
- App installs and launches on the simulator; WelcomeView now shows
  the sign-in link in the right slot (screenshot captured).

### Pending Sam's simulator test

End-to-end with the Test123 owner account created on 2026-06-13:
sign-in, role resolves to `.owner`, lands in the owner portal. Plus a
launch-while-signed-in restore test (kill the app, relaunch, end up in
the same portal without re-typing the password). Plus a sign-out test
(returns to Welcome).

The UI rendered after sign-in still shows the Northbeam mock seed, not
the real Test123 org. Same gap as Checkpoint 3 — auth is wired, data
isn't. Data-wiring slice closes it.

## Stage B: real join + owner approval (2026-06-14, pending Sam's three-role test)

Closes the join surface. The legacy mock JoinCodeEntryView →
`store.findOrg(byCode:)` path is gone; every join-related action now
hits the real backend. First real exercise of the membership RPCs
under RLS.

### Backend changes (migrations)

- **`0013_lookup_org_by_code_allow_anon`**: `lookup_org_by_code` now
  granted to `anon` (in addition to `authenticated`) and the
  `auth.uid()` check removed. A user typing a warehouse code on
  JoinCodeEntryView is unauthenticated; under the previous grants
  the call would 42501. The RPC still returns ONLY
  `(organization_id, organization_name)` — never warehouse_code,
  members, or any private data. Threat model T4 trade-off
  acknowledged: we lose the "must mint a session to enumerate at
  scale" barrier. Mitigation surface still substantial: 6 chars over
  a 32-char ambiguous-glyph-free alphabet ≈ 1.07B combinations,
  Supabase platform rate-limit on /rest, and worst leak is org
  existence + display name.
- **`0014_profile_org_mates_select_includes_pending`**: extends the
  `profile: org-mates select` policy to include pending memberships
  alongside active. Owner's TeamView needs to read pending joiners'
  email + full_name to render the Approve/Deny rows. Pending users
  consented to share their email at signup; cross-org isolation is
  unchanged because `user_org_ids()` still scopes to the caller's
  own orgs.

Advisor pass after 0013/0014: one new lint
(`anon_security_definer_function_executable` on
`lookup_org_by_code`), accepted and rationale captured here +
[[backend-threat-model]]. Other lints unchanged.

### iOS pieces (Stage B)

- **`AppEnvironment.OrgLookup`** (new public Decodable struct) and
  `lookupOrgByCode(_:)` async function: calls the anon-callable
  `lookup_org_by_code` RPC. Empty input returns nil; no match returns
  nil; throw propagates to the call site for inline error rendering.
- **`AuthStatus` new cases**:
  - `.finalizingJoin(code:)` — post-confirmation, RPC in flight.
  - `.joinFailed(code:)` — RPC errored; ConfirmEmailView shows Retry.
  - `.pendingApproval(orgName:, organizationID:)` — joiner waiting on
    the owner.
- **`requestJoin(email:password:fullName:warehouseCode:)`**: parallel
  to `signUpOwner` but carries `pending_join_code` (not
  `pending_org_name`) in the auth.signUp metadata.
- **`onSessionEstablished`** now forks three ways: pending_org_name
  → `finalizeOwnerOnboarding`; pending_join_code →
  `finalizeJoinOnboarding`; neither → `resolveRoleFromMembership`.
- **`finalizeJoinOnboarding(code:)`**: calls `join_org_by_code(code)`
  RPC. Reads the returned `membership_status`:
  - "active" → resolveRoleFromMembership (owner already approved
    before they hit the link)
  - "pending" → `authStatus = .pendingApproval(orgName,
    organization_id)`
  - "suspended" → sign out with a visible message
  - anything else → `.joinFailed(code:)`
  After success, clears `pending_join_code` from user metadata so a
  token refresh doesn't re-trigger.
- **`resolveRoleFromMembership(session:)`** (Stage A method)
  extended: checks for any membership row first; routes to
  `.authenticated(role:)` for active, `.pendingApproval(...)` for
  pending, signs out for nothing. This is what makes a returning
  pending user (Keychain restore on launch) land back on
  PendingApprovalView rather than getting signed out.
- **`refreshMembershipStatus()`**: "Check now" button on
  PendingApprovalView. Re-uses the same membership read, so an
  approval flips the user from `.pendingApproval` into the right
  portal, a deny signs them out with a visible message.
- **`cancelPendingApproval()`**: calls `cancel_pending_membership
  (organization_id)` RPC then signOut. Used by the Cancel button on
  PendingApprovalView. Continues to sign out even if the RPC errors
  (the row might already be gone from a parallel deny).
- **`loadPendingMemberships()`**: PostgREST read of memberships in
  the owner's org with status=pending, plus an embed of
  `user_profiles(email, full_name)`. Works because of the relaxed
  RLS in migration 0014 and because memberships's `user_id` is a FK
  to `user_profiles(id)`.
- **`approveMembership(membershipID:role:)` /
  `denyMembership(membershipID:)`**: call the corresponding RPCs.
  Used by TeamView.
- **`retryJoin()`**: ConfirmEmailView's Retry CTA when in
  `.joinFailed`.
- **`currentOrganizationID: UUID?`** — set during role resolution so
  TeamView can scope its pending-membership read without a separate
  lookup. Reset on sign-out.

### UI files touched

- **`Features/Onboarding/JoinCompanyFlow.swift`**: full rewrite.
  Debounced (300ms) real `lookupOrgByCode` on every code keystroke;
  ProgressView, found-state, not-found-state, and error-state
  inline. "Try `NB4X9K2`" demo hint removed; replaced with
  "Ask the owner for their warehouse code" copy. The submit button
  on JoinAccountSetupView now calls `requestJoin` (real
  auth.signUp + pending_join_code metadata).
- **`Features/Onboarding/PendingApprovalView.swift`**: backend-aware.
  Reads org name from `authStatus = .pendingApproval(...)`. "Check
  now" runs `refreshMembershipStatus`. Cancel runs
  `cancelPendingApproval`. The UI-PHASE DEMO self-approval button is
  gone; no shortcut.
- **`Features/Team/TeamView.swift`**: Join-requests card reads real
  pending memberships via `loadPendingMemberships`. Approve as
  Employee / Approve as Manager / Deny buttons call the real RPCs
  with per-row spinners. Refresh button + pull-to-refresh.
  Members list still reads from mock store with an inline note;
  data-wiring slice closes that.
- **`Features/Onboarding/ConfirmEmailView.swift`**: phases extended.
  Awaiting / finalizing / failed now branch on whether the active
  state is the owner setup or the join. Headline copy differs
  ("Setting up your business" vs "Submitting your request"; "Setup
  didn't finish" vs "Couldn't submit your request"). Retry routes to
  `retrySetup` or `retryJoin` accordingly.
- **`App/RootView.swift`**: routes on `env.isPendingApproval`
  instead of the legacy `env.isPending`; `isAwaitingConfirmation`
  covers `.finalizingJoin` and `.joinFailed` too.

### Verification done this stage

- `xcodegen generate` clean.
- `xcodebuild ... iPhone 17 Pro` → BUILD SUCCEEDED on first try.
- App installs and launches on the simulator; Welcome renders
  identically (the polished "Sign in" link from Stage A still there).
- `get_advisors(security)` after 0013/0014 returns one new lint
  (`lookup_org_by_code` anon-callable, accepted) plus the pre-
  existing accepted-RPC lints.

### What this is the first real exercise of

- A non-member calling `lookup_org_by_code` under the anon key — the
  Stage A signup/signin only used `authenticated`.
- A joiner inserting their own pending membership via
  `join_org_by_code` — relies on the RPC's SECURITY DEFINER to write
  the row even though direct INSERT on memberships is blocked.
- An owner approving / denying via `approve_membership` /
  `deny_membership` — relies on the RPC's owner-check.
- A backend-aware "pending" UI on the joiner side that resolves to
  the right portal once approved (or signs out on deny).

### Pending Sam's three-role test on device

End-to-end against the live Test123 org from Checkpoint 3:

1. Sign out the Test123 owner (Sam, samoakescyber@proton.me) so the
   join can run against a clean session.
2. From Welcome, tap "Join a company", enter `6AFTUJ`. Expect:
   "Found: Test123" in real time.
3. Continue → JoinAccountSetupView. Fill a fresh email + password +
   name. "Request to join" → ConfirmEmailView.
4. Tap the email confirmation link. App lands on PendingApprovalView
   with org "Test123".
5. Sign back in as the Test123 owner. TeamView's Join requests card
   should show the new joiner. Approve as Employee.
6. As the joiner: tap "Check now" on PendingApprovalView (or sign
   out + sign back in). Should route to Employee portal.

### Errata to fold into the data-wiring slice

- TeamView's Members list still reads from the mock store. Replace
  with a real memberships read (role + user_profile embed) so the
  approved joiner appears alongside the owner.
- The "preview a portal" demo buttons on WelcomeView still set
  `authStatus = .demo(role:)` which uses mock data. Strip
  pre-TestFlight per F11.

## See also

- [[rpc-functions]] for the RPC contract.
- [[frontend-wiring-map]] for the call-site map (evolves through this slice).
- [[backend-threat-model]] for why the anon key is safe to ship.
