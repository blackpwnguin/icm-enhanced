---
project: stowed
type: reference
status: building
stage: 02-build
tags: [ios, stowed, backend, supabase]
updated: 2026-06-13
---

# Frontend wiring map

Where each backend surface gets called from in the iOS app. Updated as
the auth-wiring slice ([[build-log-auth-wiring]]) and subsequent slices
land. Companion to [[rpc-functions]] (the contract) and [[rls-policies]]
(what direct table access permits without an RPC).

## Deep-link callback string

The exact string `stowed://auth-callback` must agree across THREE places.
Mismatch silently breaks email confirmation.

| Piece | Where | Owns the literal? |
|---|---|---|
| App URL scheme | `project.yml` -> `info.properties.CFBundleURLTypes` -> `CFBundleURLSchemes: [stowed]` | scheme only (`stowed`); path is implicit |
| Supabase redirect allow-list | Dashboard -> Auth -> URL Configuration -> Redirect URLs | full URL (`stowed://auth-callback`) |
| iOS deep-link handler | `StowedApp.body.onOpenURL` | scheme-agnostic; routes whatever the OS hands in |
| iOS sign-up call (Checkpoint 3) | `auth.signUp(..., redirectTo: "stowed://auth-callback")` | full URL — must match the allow-list byte-for-byte |

Pre-TestFlight: replace the custom scheme with a Universal Link
(`applinks:auth.stowed.app` + AASA file). Custom schemes are not unique
per device.

## Auth (Checkpoint 1, in progress)

### Supabase client

| Surface | Swift call site |
|---|---|
| Init | `SupabaseService.client` (lazily instantiated on first access) |
| URL source | `AppConfig.supabaseURL` (from Info.plist -> xcconfig) |
| Anon key source | `AppConfig.supabaseAnonKey` (same path) |

The service-role key never appears in the app. See
[[backend-threat-model]] for the keys / surface delineation.

## RPC call sites

Tracked as each RPC gets wired. Filled in during Checkpoints 3 and 4.

| RPC | Swift call site | Notes |
|---|---|---|
| `create_org_and_self_owner(name)` | `AppEnvironment.createOrgAndSelfOwnerRPC` called from `finalizeOwnerOnboarding` | Wired Checkpoint 3 (2026-06-13). Fires AFTER `auth.session(from:)` establishes a session from the email-confirmation deep link, never before. Org name carried as `pending_org_name` in `auth.users.raw_user_meta_data` set at signUp time; cleared post-success. |
| `lookup_org_by_code(code)` | `AppEnvironment.lookupOrgByCode` called from `JoinCodeEntryView` debounced onChange | Stage B (2026-06-14). Anon-callable since migration 0013. |
| `join_org_by_code(code)` | `AppEnvironment.finalizeJoinOnboarding` from `onSessionEstablished` when `pending_join_code` is in user metadata | Stage B (2026-06-14). |
| `cancel_pending_membership(org_id)` | `AppEnvironment.cancelPendingApproval` from PendingApprovalView Cancel button | Stage B (2026-06-14). |
| `approve_membership(membership_id, role)` | `AppEnvironment.approveMembership` from TeamView Approve buttons | Stage B (2026-06-14). |
| `deny_membership(membership_id)` | `AppEnvironment.denyMembership` from TeamView Deny button | Stage B (2026-06-14). |
| `set_member_role(membership_id, role)` | TODO | Used by Owner's role-change action in `TeamView`. |
| `remove_member(membership_id)` | TODO | Used by Owner's remove action in `TeamView`. |

## Auth surface (SDK methods)

| Surface | Swift call site | Notes |
|---|---|---|
| `auth.signUp(email:password:data:redirectTo:)` | `AppEnvironment.signUpOwner` from `BusinessSetupView` button | Wired Checkpoint 3 (2026-06-13). `data` carries `full_name` and `pending_org_name`. `redirectTo: AppConfig.authCallbackURL` (= `stowed://auth-callback`). |
| `auth.signIn(email:password:)` | `AppEnvironment.signIn` from `SignInView` button | Wired Checkpoint 4 (2026-06-14). Success defers routing to the authStateChanges listener; failure surfaces via `env.authError` and reverts to `.unauthenticated`. |
| `auth.session(from: URL)` | `StowedApp.body.onOpenURL` | Wired Checkpoint 2 (2026-06-13). Receives any `stowed://*` URL; SDK parses tokens from fragment/query. Path `auth-callback` is by convention, not enforced by the handler. |
| `auth.session` (read via authStateChanges) | `AppEnvironment.observeAuthState` -> `onSessionEstablished` | Wired Checkpoint 4 (2026-06-14). Keychain restore on launch fires `.initialSession`; same path as fresh sign-in. |
| `auth.signOut()` | `AppEnvironment.signOut` | Wired Checkpoint 4 (2026-06-14). Listener catches `.signedOut` and sets `authStatus = .unauthenticated`. |

## Direct table reads (under RLS)

These will replace the corresponding `store.<collection>` mock reads
once the auth slice lands. Tracked here so the data-wiring slice has a
checklist.

| Mock site | Will read from | RLS policy |
|---|---|---|
| `store.activeOrg` (name, code) | `organizations` by membership | `org: members read` |
| (Checkpoint 4 role resolution) | `memberships` filtered by `user_id` + `status=active` | `membership: self select` (RLS-protected, no RPC needed) |
| `store.members` | `memberships` join `user_profiles` | `membership: org-mates select` + `profile: org-mates select` |
| `store.joinRequests` | `memberships where status='pending'` in own org | `membership: org-mates select` |
| `store.products` | `products` | `product: members read` |
| `store.customers` | `customers` | `customer: members read` |
| `store.orders` | `orders` join `order_items` | `order: members read` + `order_item: members read` |
| `store.payments` | `payments` | `payment: owner read` (owner only) |
| `store.expenses` | `expenses` | `expense: owner read` (owner only) |
| `store.employeeCosts` | `employee_costs` | `payroll: owner read` (owner only) |
| `store.totalReceivables`, etc. | `customer_balances` view | owner-only inline filter |

## Error mapping (Swift)

Backend SQLSTATEs and where they surface in UI. Filled in through
Checkpoints 3-4.

| SQLSTATE | What it means | UI behavior |
|---|---|---|
| `42501` | "not authenticated" / "not authorized" | Route to sign-in or show "you don't have access". |
| `23505` | unique-violation (e.g. `(organization_id, sku)` collision) | Show "that SKU is already in use". |
| `23514` | check-violation (e.g. negative price) | Show the validation message inline. |
| Other | unexpected | Log + show "something went wrong, try again". |

## See also

- [[rpc-functions]] for the RPC contract.
- [[rls-policies]] for the direct-table permission model.
- [[build-log-auth-wiring]] for the auth-slice progress and decisions.
