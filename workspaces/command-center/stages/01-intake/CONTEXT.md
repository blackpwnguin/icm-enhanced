# Stage 01: Intake

## Role
The relay inbox — the only meeting point between Field Agents (in other repos) and the
Curator (here). It receives; it does not process.

## Inputs
| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Field Report | dropped into `output/` | Full file | The change to file |
| Schema | `../../shared/schemas.md` | Field Report | To validate shape |

## Process
1. A Field Agent (or the relay Action) writes one report file into `output/`.
2. Nothing is edited here — reports are read verbatim by stage 02/the Curator.

## Outputs
| Artifact | Location | Format |
|----------|----------|--------|
| Field Report | `output/YYYY-MM-DD__<repo>__<id>.md` | per `shared/schemas.md` |

Processed → `output/_processed/`. Schema-invalid → `output/_rejected/` (audit trail;
never deleted).

## Audit
- [ ] One report per file, valid front-matter (`id`, `repo`, `date`).
- [ ] No secrets present.
