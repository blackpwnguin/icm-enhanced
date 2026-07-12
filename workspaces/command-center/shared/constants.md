# Shared constants — command-center

One home for cross-cutting terminology and boundaries. Point here; don't duplicate.

## Naming
- Project folder: `owner__repo` (`/` → `__`). Owner's own repos may use short name.
- Report file: `YYYY-MM-DD__<repo-slug>__<short-id>.md`
- Dates: ISO-8601 `YYYY-MM-DD`.

## Change logs
- Newest entry on top. Append/prepend only. Never rewrite a dated entry.

## Actor boundaries (who writes where)
| Actor | May write | Must NOT write |
|-------|-----------|----------------|
| Field Agent | its own repo code; `stages/01-intake/output/` | `projects/**` |
| Curator | `projects/**`; `_config/registry.md`; `_processed/` | any repo's product code |

## Handoff
`stages/01-intake/output/` (a report) → Curator → `projects/<repo>/**`. The inbox is
the only meeting point between the two agents.

## Secrets
Never store secret values anywhere — names only. Any report mentioning live secrets is
filed abstractly with `needs_human: true`.

## Source of ICM
Interpretable Context Methodology — Van Clief & McDermott, arXiv:2603.16021.
See `references/icm-command-center.md`.
