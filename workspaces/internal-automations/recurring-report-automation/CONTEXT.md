# Project: recurring-report-automation

## Purpose
Replace a recurring manual report (compiled by hand in Excel today) with a scheduled
Azure Function that pulls the data, builds the report, and delivers it automatically.
Chosen as the first internal-automation because the ROI is unambiguous: manual hours
in, near-zero hours out.

## Status
**Charter** — scope drafted, awaiting the specific report/process to lock the baseline.
See `04-roi-tracking.md` -> "Baseline (to confirm)".

## Read order

| Step | File | When to read |
|------|------|--------------|
| 1 | `01-charter.md` | Always first. Scope, timeline, ROI baseline. |
| 2 | `02-architecture.md` | Before any build/deploy decision. |
| 3 | `03-build-plan.md` | When creating repo, CI/CD, or board work items. |
| 4 | `04-roi-tracking.md` | At kickoff (set baseline) and at close (prove return). |

## Open decision (blocks baseline)
Which real report does this replace? Need: who compiles it, how often,
roughly how long per run. Until that is filled in, ROI numbers are placeholders.

## References (one-way, do not edit back)
- Nihilo Azure environment: `ado-nihilo` (Azure DevOps project + repos + pipelines)
