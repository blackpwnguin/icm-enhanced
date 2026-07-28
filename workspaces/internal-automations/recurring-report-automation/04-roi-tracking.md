# ROI Tracking — Recurring Report Automation

> The point of the whole project. Set the baseline BEFORE building; record actuals at close.
> This is the number that goes back to the company.

## Baseline (to confirm — blocks the ROI claim)
Fill these from the process owner interview in Sprint 0:

| Field | Value |
|-------|-------|
| Report name | _____ |
| Cadence | _____ (e.g. weekly / monthly) |
| Runs per year | _____ (weekly = 52, monthly = 12) |
| Manual time per run | _____ hours |
| Loaded hourly rate | $_____ /hr |
| **Baseline annual cost** | runs/yr x hrs x rate = $_____ |

## Metrics tracked

| Metric | Baseline | Target | Actual (at close) |
|--------|----------|--------|-------------------|
| Human compile time / run | _____ hrs | ~0 hrs | _____ |
| Turnaround (data ready -> report sent) | _____ | on schedule, automatic | _____ |
| Error / rework incidents | _____ | 0 | _____ |
| Azure run cost / month | n/a | < $5 | _____ |

## Return calculation
```
Annual gross saving = runs/yr x manual_hrs x rate
Annual run cost      = azure_monthly x 12
Annual net saving    = gross saving - run cost
Payback period       = build_cost / (net saving / 12)   [months]
```

## How the numbers are captured
- **Baseline hours:** ask the process owner; if unsure, time 2-3 real manual runs.
- **Actual hours:** automated runs are ~0 human time by definition; note any exceptions.
- **Run cost:** read from the Azure Cost Analysis blade for the resource group.
- **Acceptance:** recipients confirm the automated output equals the manual one.

## Close-out statement (fill at project end)
> Automating the "____" report eliminated ~___ hours/year of manual work
> (~$_____ /year) at a run cost of ~$___/month, paying back the build in ___ months.
