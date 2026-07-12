# Stage 03: File

## Role
Write the report's facts into their correct, dated, append-only home. Create domain
folders on demand. This stage produces the durable record.

## Inputs
| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Routing decision | `../02-classify/output/` | this report | Where each change goes |
| Report | `../01-intake/output/` | this report | The content |
| Update schema | `../../shared/schemas.md` | Update Entry | Exact write format |
| Templates | `../../domain-templates/`, `../../projects/_TEMPLATE/` | as needed | Scaffolding |

## Process
1. New repo → clone `projects/_TEMPLATE/`. New domain → clone the domain template
   (`/project:new-domain`).
2. Write per Update Entry: project-wide line + domain files + recommendations/research.
3. Refresh `projects/<repo>/overview.md` Status. Archive report → `_processed/`.

## Outputs
| Artifact | Location | Format |
|----------|----------|--------|
| Filed history | `../../projects/<repo>/**` | append/prepend, dated |

## Audit
- [ ] Idempotent: report `id` not already filed.
- [ ] No dated entry rewritten; no folder renumbered.
- [ ] Human edits preserved.
