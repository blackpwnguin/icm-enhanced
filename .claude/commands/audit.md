---
description: Audit an ICM workspace for convention compliance. Checks file sizes, reference directions, canonical sources, and structural rules.
argument-hint: [workspace-name]
context: fork
agent: Explore
---

Audit the workspace specified in $ARGUMENTS for ICM convention compliance.

## Checks to Run

Use bash for efficiency — don't read files one at a time.

### File Size Checks
```bash
# CONTEXT.md files must be under 80 lines
find workspaces/$ARGUMENTS -name "CONTEXT.md" -exec sh -c 'lines=$(wc -l < "$1"); if [ "$lines" -gt 80 ]; then echo "FAIL: $1 ($lines lines, max 80)"; fi' _ {} \;

# Reference files must be under 200 lines
find workspaces/$ARGUMENTS -path "*/references/*" -name "*.md" -exec sh -c 'lines=$(wc -l < "$1"); if [ "$lines" -gt 80 ]; then echo "FAIL: $1 ($lines lines, max 200)"; fi' _ {} \;

# _config files must be under 200 lines
find workspaces/$ARGUMENTS/_config -name "*.md" -exec sh -c 'lines=$(wc -l < "$1"); if [ "$lines" -gt 200 ]; then echo "FAIL: $1 ($lines lines, max 200)"; fi' _ {} \;
```

### Structural Checks
- Every stage has CONTEXT.md with Inputs, Process, Outputs sections
- Every stage has references/ and output/ directories
- No circular references (grep for back-references)
- Stages are numbered sequentially
- No duplicate information across files (canonical sources rule)

### Report
Output a pass/fail summary with specific fixes needed.
