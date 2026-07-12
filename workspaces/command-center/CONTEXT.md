# Workspace: command-center

## Purpose
The durable memory + correct filing cabinet for **every repo** in the account. A
Field Agent in each repo performs edits and relays a report; the Curator (here) files
each report into the right project and domain. Filesystem = the architecture.

## Pipeline (the relay)

| Stage | Folder | Job | Output |
|-------|--------|-----|--------|
| 01 | `stages/01-intake/` | Receive Field Reports (drop zone) | reports in `output/` |
| 02 | `stages/02-classify/` | Resolve project + classify domain(s) | routing decision |
| 03 | `stages/03-file/` | Append dated entries; create folders on demand | writes to `projects/` |

Run it with `/project:file-report` (delegates to `@curator`). Field Agents feed it
with `/project:relay-report`.

## Persistent stores (not stages — long-lived state)
- `projects/` — one folder per tracked repo (the correct place). Template: `_TEMPLATE/`.
- `domain-templates/` — cloned into a project when it first touches a domain.

## Configuration (Layer 3, load only the section you need)
- `_config/registry.md` — every tracked repo + status
- `_config/taxonomy.md` — domain → signals → template
- `_config/structure.md` — project + domain folder shape
- `shared/schemas.md` — Field Report + Update Entry schemas
- `shared/constants.md` — naming, dates, boundaries

## Entry Point
Filing a report → `stages/01-intake/CONTEXT.md`. Reading a project → its `CONTEXT.md`.
Do not load `projects/` or `domain-templates/` until a stage tells you to.

## Agents
`@field-agent` (per repo, edits + reports) · `@curator` (here only, files). See
`.claude/agents/`.
