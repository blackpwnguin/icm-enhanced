# Workspace: internal-automations

## Purpose
Container for small, self-contained internal automation projects at Nihilo Solutions.
Each project replaces a recurring manual process with a cheap Azure-hosted automation,
and each carries a hard, trackable ROI number (hours saved x rate, minus run cost).

## How this workspace is organized
Unlike a single-pipeline workspace, this is a **portfolio**. One subfolder per project.
Every project subfolder is self-contained and follows the same file layout.

| Project | Folder | Status | ROI basis |
|---------|--------|--------|-----------|
| Recurring report / data-consolidation pipeline | `recurring-report-automation/` | Charter | Manual report hours eliminated |

## Standard project layout
Every project folder contains:

| File | Job |
|------|-----|
| `CONTEXT.md` | Router for the project. What to read, in what order. |
| `01-charter.md` | ICM layer: business case, scope, timeline, ROI baseline. |
| `02-architecture.md` | Azure design, tech stack, cost estimate. |
| `03-build-plan.md` | Repo + CI/CD plan and board sprint/task breakdown. |
| `04-roi-tracking.md` | Metrics, baseline vs target, how return is measured. |
| `README.md` | One-screen overview and current status. |

## DevOps mapping (applies to every project)
- **ICM** tracks scope, timeline, and ROI  -> `01-charter.md` + `04-roi-tracking.md`
- **Repos + CI/CD** build/test/deploy to Nihilo Azure  -> `02-architecture.md` + `03-build-plan.md`
- **Azure DevOps board** tracks sprints/tasks  -> `03-build-plan.md` (source for work items)

## On entry
Ask which project. Read that project's `CONTEXT.md`. Do not read every project.

## Adding a new project
Copy the standard layout above into a new subfolder, register it in the table,
then fill `01-charter.md` first (scope + ROI baseline before any build).
