# domains/security/ — router

Security posture & hardening. Inherits base four files + `40-threat-model.md`.

- **Reads** — changes classified `security` (SECURITY.md, CSP, Dependabot, secrets
  handling, auth/OAuth, RLS, CVEs, scanners).
- **Does** — records controls in place, security changes over time, open risks.
- **Writes** (Curator only): base files + `40-threat-model.md`.
- **Rule:** anything mentioning live secrets/tokens → file abstractly, set
  `needs_human: true`. Never store secret values.
