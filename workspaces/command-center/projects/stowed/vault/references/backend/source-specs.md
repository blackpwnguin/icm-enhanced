---
project: stowed
type: reference
status: building
stage: "-"
tags: [ios, stowed]
updated: 2026-06-11
---

# Source spec documents

Three documents fully specify the data model. They are sitting in `~/Downloads` and need to move into the repo and be committed before the backend phase starts.

| File | What | Destination |
|---|---|---|
| `schema.sql` | 15 tables, 2 views, Row Level Security policies | `apps/backend/migrations/` |
| `data-model-and-specs.md` | Written spec of personas, warehouse-code signup, pricing, orders, financials | `docs/` |
| `data-model-map.md` | Entity-relationship diagram (renders on GitHub) plus pricing and profit flow diagrams | `docs/` |

Until the move happens, the canonical text is in those files. This note and [[data-model]] summarize.

The move-and-commit is the second of the two do-first actions in [[STATUS]].
