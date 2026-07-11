# Structure — folder shapes

Canonical shapes cloned identically for every project and domain. This file is the
one home for these rules (Convention 5: canonical sources).

## Project shape (`projects/_TEMPLATE/` → `projects/<owner__repo>/`)

```
projects/<owner__repo>/
  CONTEXT.md         router: reads/does/writes
  overview.md        what it is + live Status + open questions
  architecture.md    how it's set up
  change-log.md      project-wide timeline, newest first, append-only
  recommendations.md prioritized backlog (deduped by title)
  research.md        market/competitive research
  domains/           per-domain folders, created on demand
    CONTEXT.md
```

Naming: `owner__repo` (`/` → `__`) to stay flat across orgs. Short name allowed for
the owner's own repos; the registry maps both.

## Domain shape (`domain-templates/<domain>/` → `projects/<repo>/domains/<domain>/`)

```
domains/<domain>/
  CONTEXT.md                       reads/does/writes for this domain
  00-setup.md                      how it's set up now (baseline)
  10-change-log.md                 change updates by date (append-only)
  20-recommended-improvements.md   prioritized suggestions
  30-market-research.md            market/competitive research
  (+ extras per taxonomy, e.g. seo adds 40-keyword-research, 50-analytics-integration)
```

## Rules
- Numbering = read order. Never renumber existing folders.
- Every folder that holds work has a `CONTEXT.md` (router, < 80 lines).
- Change logs newest-first, append-only. Dates ISO `YYYY-MM-DD`.
- Created folders inherit `_TEMPLATE` then overlay the domain specifics.
