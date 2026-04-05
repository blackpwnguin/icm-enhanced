---
name: icm-output-validator
description: Validate output before writing to any stage output/ directory. Runs audit checks from the stage CONTEXT.md before allowing the write.
paths: "workspaces/**/output/**"
disable-model-invocation: false
user-invocable: false
---

## Before Writing to Any output/ Directory

1. Read the current stage's CONTEXT.md
2. Find the "Audit" section
3. Run every check listed
4. If ANY check fails:
   - Do NOT write the output
   - Report which checks failed
   - Fix the issues
   - Re-run checks
   - Only write when all pass

## Universal Checks (apply to ALL stages)

- [ ] Output is under 200 lines (split if needed)
- [ ] No AI-sounding filler language
- [ ] No content that wasn't in the Inputs
- [ ] File follows the naming convention in shared/constants.md
- [ ] Markdown is clean (proper headers, no orphaned formatting)

## Gotchas

- Don't skip the audit because "it looks fine." Run every check explicitly.
- If the stage CONTEXT.md has no Audit section, run only the universal checks.
- Log which checks passed/failed. The human should see this.
