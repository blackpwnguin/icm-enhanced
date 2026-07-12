---
project: stowed
type: decision
status: shipped
stage: 02-build
tags: [stowed, auth, backend]
updated: 2026-06-12
---

# Decision: email and password for v1 auth

## Context

[[spec-backend-phase]] left the auth path as an open question: Sign in
with Apple, email/password, both, or magic link. The iOS app's
Welcome / onboarding flow uses email and password form fields today
([[onboarding-flow]]).

## Decision

v1 ships with email and password through Supabase Auth, no third-party
identity providers. Apple Sign in lands in a follow-up.

## Why

1. The iOS onboarding flow is already wired for email and password
   (see `CreateBusinessFlow.swift`, `JoinCompanyFlow.swift`). No frontend
   churn to land the backend.
2. Supabase Auth ships email/password out of the box, with built-in
   rate limiting, password complexity checks, and reset flows. Zero
   additional config.
3. Apple Sign in needs an Apple Developer account, an Apple Services ID,
   a private key, the Stowed app's bundle id registered. Most of that is
   in flight ([[STATUS]]: bundle id pending), but does not block the
   foundation from landing.
4. Testers without Apple IDs can still sign in. Useful for Ish and any
   contractor accounts we cut.

## What we give up

- Slightly worse UX on iOS (passwords vs Apple's one-tap flow).
- Slightly higher account-takeover risk than Apple Sign in's relay email
  pattern.
- The eventual need to also support Apple Sign in (App Store reviewers
  expect it on iOS apps that offer third-party login).

## Hardening that ships with the decision

- Passwords flow directly from iOS form state into
  `supabase.auth.signUp` / `signIn` and are discarded from local state
  on next render. Never written to `Store` or `AppEnvironment`.
- iOS form fields get `.textContentType(.newPassword)` for signup and
  `.textContentType(.password)` for sign-in (open item from
  [[ui-phase-review]] F10).
- Supabase Auth enforces:
  - Email confirmation by default (configurable in the dashboard).
  - Password minimum length policy.
  - Per-IP rate limits on signup, sign-in, and password reset.
- The `handle_new_auth_user` trigger mirrors `auth.users` into
  `public.user_profiles` so the app always has a profile row to read.

## Follow-up

- Apple Sign in: add as a second identity provider once the bundle id
  is registered. Existing email-password accounts continue to work.
- MFA: Supabase Auth supports TOTP. Optional for v1, recommended for
  Owners before payroll data lives in production. Track as a separate
  spec.

## See also

- [[spec-backend-phase]] (open questions section).
- [[platform-shared-responsibility]] (Sign in with Apple coverage).
- [[ui-phase-review]] F7 (password handling in the mock auth).
