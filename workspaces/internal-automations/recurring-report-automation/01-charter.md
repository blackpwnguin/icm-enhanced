# Charter — Recurring Report Automation

> ICM layer. This file is the single home for scope, timeline, and the business case.
> Metrics detail lives in `04-roi-tracking.md`; build detail lives in `03-build-plan.md`.

## Problem
Someone at Nihilo rebuilds the same report by hand on a fixed cadence (weekly/monthly).
The work is repetitive, error-prone (manual copy/paste), and its timing depends on a
person being free. The output is valuable; the way it is produced is pure overhead.

## Objective
Deliver the identical report automatically, on schedule, with no human compile time,
for a few dollars a month — and prove the saved hours as a hard number.

## Scope

### In scope (v1)
- One report, one data source (or a small fixed set), one delivery channel (email/Teams).
- Scheduled trigger (e.g. every Monday 07:00, or first business day of the month).
- Same format the recipients already expect (parity, not redesign).
- Full DevOps loop: repo, CI/CD to Nihilo Azure, board tracking, ICM ROI record.

### Out of scope (v1 — park for later)
- Multiple reports / self-service report builder.
- New KPIs or redesigned layouts (do parity first, improve second).
- Interactive dashboard UI (that is a separate future project).

## Success criteria
1. Report generates and delivers on schedule with zero manual steps for 4 consecutive runs.
2. Output matches the current manual version (recipients accept it as equivalent).
3. Measured human compile time drops to ~0. See `04-roi-tracking.md`.
4. Run cost stays under the target in `02-architecture.md`.

## Timeline (indicative — 2 short sprints)

| Phase | Work | Duration |
|-------|------|----------|
| Sprint 0 | Confirm the target report, lock baseline hours, provision Azure + repo | ~2-3 days |
| Sprint 1 | Build Function, wire data source, generate report to storage | ~1 week |
| Sprint 2 | Delivery channel, CI/CD deploy, 2 supervised live runs, ROI close-out | ~1 week |

## Stakeholders (fill in)
- **Sponsor:** _who is funding / cares about the saved hours_
- **Process owner:** _who compiles the report today (baseline source)_
- **Recipients:** _who receives the report_
- **Builder:** _who develops it_

## Risks
- Baseline not measured -> ROI unprovable. Mitigation: measure before building.
- Data source access/permissions in Azure -> confirm in Sprint 0.
- Scope creep into "while we're at it, redesign it" -> parity first, log extras to backlog.
