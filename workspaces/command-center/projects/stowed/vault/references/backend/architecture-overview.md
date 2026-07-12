---
project: stowed
type: reference
status: building
stage: 02-build
tags: [security, ios, stowed]
updated: 2026-06-12
---

# Backend architecture overview

What the backend looks like. As of 2026-06-12 the Supabase foundation
(schema + RLS + RPCs + audit log) is applied; see [[schema-applied]],
[[rls-policies]], [[rpc-functions]], [[migration-history]], and
[[backend-threat-model]] for the as-shipped state. The notes below are
the principles.

## Services

- Supabase: Postgres, Auth, Row Level Security, Storage, Edge Functions.
- RevenueCat: subscription management over StoreKit 2.
- Sentry: error monitoring, with personal and financial values scrubbed before any event is stored.
- Azure OpenAI: a later version, scope undefined.

## Tenant model

The organization is the tenant boundary. Every business-scoped table carries an organization identifier. Row Level Security guarantees a user only ever reads or writes rows for their own organization and within their own role. See [[data-model]].

## Edge Functions

Anything that needs the powerful backend key, talks to RevenueCat's private interface, or writes audit rows runs in a server-side Edge Function. The app only holds the public client key, which is safe only because RLS protects the data behind it. The shared-responsibility model that this design implements is in [[platform-shared-responsibility]].

## Portability

The design is vendor-neutral at the principle level: RLS, Edge Functions, and audit logging are all replaceable on any major cloud. Moving off managed Supabase later should be a migration, not a security rewrite. See [[platform-shared-responsibility]] (final section).
