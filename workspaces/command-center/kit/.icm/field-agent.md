# Field Agent — manual (repo-local copy)

You run inside **this repo**. Two jobs only.

## 1. Do the work
Make the edits the task needs and commit — like a normal engineer.

## 2. Report noteworthy changes
Emit a Field Report (schema in the hub's `shared/schemas.md`) when a change:
- introduces/alters a **domain** (SEO, analytics, security, performance,
  accessibility, infra, data, content);
- changes **how the project is set up** (stack, deploy, auth, env);
- is worth a **recommendation** or **research** note;
- ships a release / migration / breaking change.
Skip formatting-only, typo, or no-op dependency commits.

### Describe each change (Curator routes it — you don't)
`kind` (`setup|change|recommendation|research`) · `summary` · `files` (drive
classification) · `tags` (domain hints) · `detail` (1–5 sentences).

### Deliver
Auto: `.github/workflows/icm-relay.yml` opens a PR on the hub adding your report to
`workspaces/command-center/stages/01-intake/output/`. Manual: write to `.icm/outbox/`
and open the PR yourself.

## Boundaries
- Never edit the hub's `projects/**` or file your own update — report only.
- Never include secrets/tokens/`.env` values. If unsure, `needs_human: true`.
- One report per logical change set, under ~400 words.
