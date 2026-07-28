# Architecture — Recurring Report Automation

> Design + cost. Deploy target is the Nihilo Solutions Azure environment.
> Task/sprint breakdown for this build lives in `03-build-plan.md`.

## Shape
A single scheduled serverless job. No always-on infrastructure.

```
[Timer trigger]        (CRON: e.g. weekly Mon 07:00)
      |
      v
[Azure Function]  --pull-->  [Data source(s)]   (SQL / API / file share — confirm)
      |
      | build report (xlsx / pdf / html)
      v
[Blob Storage]  --keep a dated copy--
      |
      v
[Delivery]  ->  Email (Azure Communication Services) or Teams webhook
```

## Tech stack (proposed — confirm in Sprint 0)
- **Compute:** Azure Functions, Consumption (serverless) plan, Timer trigger.
- **Language:** Python (pandas/openpyxl) or C# (.NET) — pick what the builder is fastest in.
- **Report build:** openpyxl / pandas for xlsx; simple HTML->PDF if PDF is required.
- **Storage:** Azure Blob Storage — one container, dated filenames for an audit trail.
- **Delivery:** Azure Communication Services Email, or a Teams incoming webhook.
- **Secrets:** Azure Key Vault (data-source creds, connection strings) — no secrets in repo.
- **IaC:** Bicep — the whole stack defined as code so it is reproducible and reviewable.

## Why serverless
Runs seconds per week. Consumption billing means near-zero cost at this volume, and there
is no server to patch or keep alive. Scaling is irrelevant here; cost and simplicity win.

## Cost estimate (low volume)

| Item | Est. monthly |
|------|--------------|
| Azure Functions (Consumption) | ~$0 (within free grant) |
| Blob Storage | cents |
| Email (ACS) or Teams webhook | ~$0 at low volume / free |
| Key Vault | ~$0 (per-operation, negligible) |
| **Total run cost** | **< $5/month (target)** |

CI/CD minutes (Azure Pipelines / GitHub Actions) are within free tiers at this scale.

## Security / guardrails
- Least-privilege identity for the Function (managed identity where possible).
- All credentials in Key Vault, referenced — never committed.
- Report copies retained in Blob with a retention policy (audit + re-send).
- Non-prod first: build against a test data source before pointing at live.

## Open technical questions (resolve in Sprint 0)
1. Data source type and how the Function authenticates to it.
2. Output format the recipients require (xlsx vs pdf vs inline).
3. Delivery channel: email distribution list vs Teams channel.
