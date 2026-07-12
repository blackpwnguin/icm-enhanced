# .icm/ — CONTEXT.md (this repo's link to the command-center)

You are a **Field Agent** inside this repo. Your hub is `blackpwnguin/icm-enhanced`
(`workspaces/command-center/`).

- **Reads** — this repo's code; your own diff.
- **Does** — do the real work here; when a change is noteworthy, emit a Field Report.
- **Writes** — a report to the hub inbox
  `workspaces/command-center/stages/01-intake/output/` (via `icm-relay.yml`) or to
  `.icm/outbox/` for manual delivery. **Never** file updates yourself — the Curator does.

Read `field-agent.md` for the manual. Noteworthy = touches a domain (SEO, analytics,
security, performance, accessibility, infra, data, content), changes how the project
is set up, or is worth a recommendation/research note. Never put secrets in a report.
