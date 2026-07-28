# Build Plan — Recurring Report Automation

> Repo + CI/CD plan, and the source-of-truth for Azure DevOps board work items.
> Design rationale lives in `02-architecture.md`; scope/timeline in `01-charter.md`.

## Repository layout (proposed)
Repo in the Nihilo Azure DevOps project (or GitHub, mirrored):

```
report-automation/
├─ src/                 # Function code (report pull + build + deliver)
├─ infra/               # Bicep — Function, Storage, Key Vault, ACS
├─ tests/               # unit tests (report-build logic, formatting)
├─ .pipelines/          # azure-pipelines.yml  (or .github/workflows/)
└─ README.md
```

## CI/CD pipeline (build -> test -> deploy)
1. **Build** — restore deps, compile/lint.
2. **Test** — run unit tests on the report-build logic (deterministic sample data).
3. **Deploy (infra)** — `az deployment` of the Bicep to the target resource group.
4. **Deploy (app)** — publish the Function.
5. **Gate** — deploy to a non-prod slot first; promote to prod after a clean supervised run.

## Board — Epics / Stories / Tasks
This is the list to create as work items in Azure DevOps (`ado-nihilo`). Link each
Story back to the charter scope item it satisfies.

### Sprint 0 — Setup & Baseline
- [ ] Confirm target report + interview process owner (capture baseline hours)
- [ ] Provision Azure resource group + Key Vault (Bicep skeleton)
- [ ] Create repo + branch policy + empty CI/CD pipeline
- [ ] Confirm data-source access from Azure

### Sprint 1 — Build
- [ ] Function: connect to data source, pull required data
- [ ] Report build logic (format parity with current manual version)
- [ ] Write generated report to Blob (dated)
- [ ] Unit tests for report-build logic
- [ ] CI: build + test green on every push

### Sprint 2 — Deliver, Deploy, Prove
- [ ] Delivery channel (email dist list / Teams webhook)
- [ ] Timer trigger on the agreed schedule
- [ ] CD: deploy infra + app to non-prod, then prod
- [ ] 2 supervised live runs (compare against manual output)
- [ ] Record ROI close-out in `04-roi-tracking.md`

## Definition of Done (v1)
- 4 consecutive unattended runs deliver correctly.
- Recipients accept output as equivalent to the manual report.
- Baseline vs actual hours recorded; run cost confirmed under target.
- Secrets in Key Vault; nothing sensitive in the repo.
