---
project: stowed
type: decision
status: shipped
stage: 02-build
tags: [stowed, auth, backend]
updated: 2026-06-12
---

# Decision: collapse five roles to three

## Context

The 2026-06-08 `schema.sql` draft defined five roles: `owner`, `admin`,
`manager`, `staff`, `viewer`. The 2026-06-11 distillation in
[[roles-and-permissions]] cut to three: `owner`, `manager`, `employee`.
The iOS frontend (`apps/ios/Stowed/Stowed/Core/Models.swift`) ships
the three-role capability matrix as the live source of truth.

The backend foundation lands today and has to pick one.

## Decision

Three roles, matching the frontend exactly:

- `owner` (was: owner + admin)
- `manager` (unchanged)
- `employee` (was: staff + viewer)

Encoded as a Postgres enum `public.role_t` in migration 0001.

## Why

1. The frontend is the source of truth. The iOS team has already shipped
   role-aware UI ([[onboarding-flow]], the Role+Capabilities matrix in
   `Models.swift`). Backing the backend with a different role set forces
   ongoing translation in the data layer, which is exactly the kind of
   drift that produces subtle authorization bugs.
2. Ish's product breakdown described three personas. The five-role draft
   was a "flexibility hedge" not driven by customer demand.
3. Fewer roles means a smaller permission matrix to keep in sync. The
   capability matrix in `Models.swift` is 14 rows; the RLS policies in
   [[rls-policies]] are now a direct mirror of those rows rather than a
   superset.

## What we give up

- A senior-manager-but-not-owner concept (the old `admin`). If Ish's
  customers ask for it, we add it back as a new enum value via
  `alter type role_t add value 'admin'`, then add RLS policies for it
  one table at a time. Adding enum values is cheap; removing them is
  not.
- A read-only accountant concept (the old `viewer`). Same fix path. If
  added, the policies would mirror an `employee` for read and refuse
  writes everywhere.

## Migration consequences

The applied schema in [[schema-applied]] uses the three-value enum.
Every RLS policy in [[rls-policies]] references it directly. The 0001
migration is the canonical introduction; later migrations cannot drop
or rename enum values without a full type rebuild, so the value set is
effectively committed.

## See also

- [[roles-and-permissions]] for the canonical capability matrix.
- [[schema-applied]] for the enum definition.
- [[rls-policies]] for how the matrix becomes policies.
- `apps/ios/Stowed/Stowed/Core/Models.swift` for the client mirror.
