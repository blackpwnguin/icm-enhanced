---
description: Curator processes every unprocessed Field Report in the command-center intake inbox and files each into the correct project/domain folder.
argument-hint: [optional: report-id]
---

Process the command-center intake inbox.

## Instructions

1. Use the `@curator` subagent (command-center-only; never edits product code).
2. List unprocessed reports in
   `workspaces/command-center/stages/01-intake/output/` (ignore `_processed/`,
   `_rejected/`). If `$ARGUMENTS[0]` given, process only that report id.
3. For each, follow `.claude/agents/curator.md`:
   validate → resolve project → classify domain(s) → create folders on demand →
   file dated entries → refresh Status → archive to `_processed/`.
4. Report back: reports filed, projects touched, domains created, anything flagged
   `needs_human`.

## Notes
- Append/prepend only; never rewrite history.
- New repo → `/project:onboard-project` first. New domain → `/project:new-domain`.
