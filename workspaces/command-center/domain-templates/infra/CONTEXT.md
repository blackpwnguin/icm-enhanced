# domains/infra/ — router

Infrastructure & deployment. Inherits base four files + `40-runbook.md`.

- **Reads** — changes classified `infra` (Vercel, Netlify, Docker, K8s, Terraform,
  CI/CD, GitHub Actions, Supabase, AWS, Azure).
- **Does** — records deploy topology, environments, operational runbook.
- **Writes** (Curator only): base files + `40-runbook.md`. Environment names only,
  never secret values.
