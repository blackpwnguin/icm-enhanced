---
project: stowed
type: reference
status: spec
stage: "-"
tags: [security, ios, stowed]
updated: 2026-06-11
---

# Platform shared-responsibility model

Distilled from the working doc Sam prepared for Ish, "Stowed Platform Security Responsibilities," dated 2026-06-07 (confidential, internal). Captures what Apple secures, what the Stowed backend secures, and where each category of data lives.

Stowed holds tenant financial data, so this model is load-bearing. It is referenced from [[data-model]] and [[roles-and-permissions]].

## The principle

Apple secures the device and the identity. The Stowed backend secures the data and the rules. Apple can prove who is using the app and protect the phone it runs on. Apple structurally cannot know that an Employee must not see profit margins, or that one business must never read another business's inventory. That logic lives only in the backend.

## What Apple handles

| Capability | What Apple does | Data Apple touches |
|---|---|---|
| Sign in with Apple | Authenticates the user, returns a signed identity token | Apple ID, optional relay email |
| Keychain and Secure Enclave | Hardware-protected on-device storage | Session and refresh tokens, never leave the device |
| Face ID and Touch ID | Reconfirms the person before sensitive screens | Nothing leaves the device |
| App Transport Security | Forces encrypted connections | All network traffic, in transit |
| In-App Purchase | Processes subscription payments | Card and billing; never touches Stowed infrastructure |
| App Attest | Proves a request comes from the genuine app on a real device | Hardware-backed attestation, verified server-side |

Two of these directly help the backend:

- **Payment data never reaches Stowed.** Apple holds the card and runs billing, so Stowed is never in scope for handling card data.
- **App Attest protects the API.** The backend can reject requests that do not come from the genuine app, which blunts scripted abuse even when someone holds a stolen token.

## What Apple cannot handle

Not shortcomings; just outside what a device-and-identity platform can do. Each is the Stowed backend's responsibility.

- Authorization (what a user may do). Apple knows the user's identity, not roles or pricing rules.
- Tenant isolation. Apple has no concept of Stowed organizations.
- Protection of data at rest. Inventory, orders, financials, payroll all live in the Stowed database.
- Server-side business logic (approvals, fulfillment transitions, price changes).
- Secrets management. Backend keys must live on the server.
- Subscription enforcement. Apple processes the payment; the backend decides what a paid account may access.
- Webhook trust. Verifying RevenueCat events is the backend's job.
- Audit logging. Recording who changed a price or accessed payroll is application logic.

**Critical:** the role logic in `Role+Capabilities.swift` only hides buttons. It is not security. Anyone can bypass the app and call the API directly with a valid token. Every permission must be enforced again on the server. See [[roles-and-permissions]].

## Where each category of data lives

| Data | Lives now | Apple's role | At scale |
|---|---|---|---|
| Apple ID, identity credential | Apple | Authenticates | Stays with Apple |
| Card, billing, payment method | Apple | Processes payment | Stays with Apple |
| Session and refresh tokens | On device (Keychain) | Hardware-protected | Unchanged |
| Subscription receipts and entitlements | Apple, RevenueCat, Supabase | Originates the receipt | Entitlement state moves with the backend |
| App integrity attestation | Apple | Issues and signs | Stays with Apple |
| Inventory, products | Supabase | None | Migrates |
| Orders, fulfillment pipeline | Supabase | None | Migrates |
| Customers, customer-specific pricing | Supabase | None | Migrates |
| Financials (receivables, store credit, profit) | Supabase | None | Migrates |
| Payroll, employee records | Supabase | None | Migrates, same protections |
| Memberships, roles, warehouse joins | Supabase | None | Migrates |
| Audit log | Supabase | None | Migrates |
| Product images and files | Supabase Storage | None | Migrates to object storage |
| Crash and error data | Sentry (scrubbed) | None | Unchanged |

Pattern: everything Apple holds (identity, payment, attestation) never migrates. Everything in the second group is Stowed application data, all in Supabase today, all portable to a larger cloud later.

## Controls implemented

Each maps to a gap above.

- **Row Level Security on every table.** Every business-scoped table carries an organization identifier; a database policy guarantees a user only ever reads or writes rows for their own organization, within their own role. Required on every table. A table without it is fully readable by anyone holding the public client key.
- **Server-side role enforcement that mirrors the client.** Every capability in `Role+Capabilities.swift` has a matching database policy. Price setting is restricted to Manager and Owner inside the database itself. Warehouse approvals are server-side state changes a user cannot perform on themselves.
- **Edge Functions for privileged work.** Anything needing the powerful backend key, RevenueCat's private interface, or audit-row writes runs server-side. The app calls it with the user's token; the function holds credentials the app never sees.
- **Secrets discipline.** Public client key ships in the app and is safe only because RLS protects the data behind it. The powerful backend key, which bypasses RLS, lives only in server-side configuration, never in the app binary, never in the repo.
- **Subscription enforcement on the server.** Apple and RevenueCat handle the purchase. The backend decides what a paid account can access and verifies RevenueCat notifications by signature, so no one can grant themselves a subscription by guessing the notification address.
- **Encryption and data minimization.** Encrypted in transit (ATS) and at rest (database). Minimize personal data collected, payroll and employee data especially. Field-level encryption for values stored but never aggregated.
- **Audit logging.** Append-only log: actor, action, target, time. No role can edit or delete. Covers price changes, join approvals, payroll access.
- **Monitoring without leaks.** Sentry configured to remove personal and financial values before any error is stored, so error tracking never becomes a side channel.
- **Device hardening.** Keychain for tokens, biometric gates on Money and Payroll, App Attest on sensitive backend functions so only the genuine app can reach them.

## Portability

Moving off managed Supabase later (cost, control, or scale) should be a migration, not a security rewrite, because the design targets portable principles:

- Tenant isolation, role enforcement, server-side privileged logic, audit logging, and secrets-out-of-client are all standard patterns.
- Row Level Security is standard Postgres functionality and moves to any compatible host.
- Edge Functions become whatever serverless or container platform is chosen.
- The Apple side does not move at all.

Designing against these principles now, rather than features unique to one provider, is what keeps a future migration from becoming a security rewrite.

## Bottom line

- Use Apple fully for identity, on-device secrets, biometrics, transport encryption, payment, and app attestation.
- Build all authorization, tenant isolation, data protection, and audit logging in the backend.
- Client role logic is interface only. Server is real enforcement.
- Design to portable principles so scaling off Supabase later is a migration, not a redo.
