---
description: Field Agent drafts a Field Report for the current repo's recent changes and delivers it to the command-center intake inbox.
argument-hint: [repo-name] [optional: since-commit]
---

Relay a Field Report from this repo to the command-center.

## Instructions

1. Use the `@field-agent` subagent (keeps main context clean).
2. Determine the repo (`$ARGUMENTS[0]`, else `git remote get-url origin`).
3. Inspect recent changes (`git diff` since `$ARGUMENTS[1]` or last push).
4. For each noteworthy change, build a report item per
   `workspaces/command-center/shared/schemas.md` (Field Report):
   `kind, summary, files, tags, detail`.
5. Write the report file to
   `workspaces/command-center/stages/01-intake/output/YYYY-MM-DD__<repo>__<id>.md`.
6. Report back: what was written and where. Suggest `/project:file-report` to file it.

## Notes
- Do NOT file it yourself — that is the Curator's job.
- No secrets in reports. If unsure, mark `needs_human: true`.
