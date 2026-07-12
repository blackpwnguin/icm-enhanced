# Stage 02: Classify

## Role
Resolve each report to a project and classify every change into a domain. Decide only;
stage 03 writes.

## Inputs
| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Reports | `../01-intake/output/` | unprocessed files | What to route |
| Registry | `../../_config/registry.md` | matching repo row | Resolve project |
| Taxonomy | `../../_config/taxonomy.md` | signal table | Resolve domain |

## Process
1. Look up `repo` in the registry. Not present → onboarding needed
   (`/project:onboard-project`).
2. For each change, lowercase `summary + files + tags`; first taxonomy signal match
   wins. No match → domain `none`, flag `needs_human`.
3. Note which domains have no folder yet (stage 03 will create them).

## Outputs
| Artifact | Location | Format |
|----------|----------|--------|
| Routing decision | `output/<report-id>.md` | project + per-change domain + create? |

## Audit
- [ ] Every change has a domain or is flagged `needs_human`.
- [ ] Domain keys normalized (no `SEO`/`seo` duplicates).
