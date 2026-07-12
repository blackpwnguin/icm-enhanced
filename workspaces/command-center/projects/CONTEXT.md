# projects/ — router

The correct place. One folder per tracked repo, all shaped identically (from
`_TEMPLATE/`). Only the `@curator` writes here; Field Agents never do.

## Contract
- **Reads** — routing decisions + reports (via the Curator); `_config/registry.md`.
- **Does** — holds each project's overview, architecture, domains, change-log,
  recommendations, research in the identical ICM shape.
- **Writes** — Curator only.

## Shape (see `_config/structure.md`)
```
<owner__repo>/  CONTEXT.md overview.md architecture.md change-log.md
                recommendations.md research.md domains/
```

Add a project only via `/project:onboard-project` (clones `_TEMPLATE/`).
Seeded example: `nihilo/` (SEO + analytics domains auto-created).
