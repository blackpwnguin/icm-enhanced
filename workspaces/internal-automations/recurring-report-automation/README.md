# Recurring Report Automation

First project in the `internal-automations` portfolio.

**What:** Replace a manual, recurring Excel report with a scheduled Azure Function that
pulls the data, builds the report, and delivers it automatically.

**Why:** Cheap to run (< $5/month, serverless), fast to ship (2 short sprints), and the
ROI is a hard number — manual hours in, near-zero hours out. It also exercises the full
DevOps loop end to end: ICM -> repo -> CI/CD -> Azure -> board.

## Status
**Charter.** Scope and plan drafted. Blocked on one input: *which real report does this
replace?* That answer sets the ROI baseline. See `04-roi-tracking.md`.

## Files
| File | What it holds |
|------|---------------|
| `CONTEXT.md` | Read-order router for this project. |
| `01-charter.md` | Scope, timeline, business case (ICM layer). |
| `02-architecture.md` | Azure serverless design, tech stack, cost. |
| `03-build-plan.md` | Repo, CI/CD, and board work items. |
| `04-roi-tracking.md` | Baseline, metrics, return calculation. |

## Next step
Name the target report (who compiles it, how often, how long per run) so the baseline
is real. Then Sprint 0: provision Azure, create the repo, and stand up the board items.
