---
project: stowed
type: reference
status: building
stage: "-"
tags: [ios, stowed]
updated: 2026-06-11
---

# Roadmap

Immediate, then the backend phase, then later items. Detail behind each lives in the linked notes.

## Immediate (do first)

1. Push the clean rebuild to GitHub. See [[STATUS]].
2. Move the three spec files out of `~/Downloads` into the repo and commit. See [[source-specs]].
3. Ish accepts the App Store Connect invite. Ish gets GitHub Write access.

## Backend phase (starts next)

See [[spec-backend-phase]] for the full spec. In short:

- Create the Supabase project.
- Apply `schema.sql` and Row Level Security.
- Wire Supabase, RevenueCat, and Sentry back into `project.yml` and regenerate.
- Build real auth and the warehouse-code join with Owner approval.
- Replace the mock `Store` with a Supabase-backed data layer. Screens should not have to change, because views read from a store with a fixed shape.

## Later

- Next.js admin portal on Vercel.
- Azure OpenAI features (a later version; scope not yet defined).
- Add a test target back into `project.yml`. See [[test-status]].
- Plan migration off managed Supabase when cost, control, or scale require it. The portability principle is in [[platform-shared-responsibility]] (final section).
