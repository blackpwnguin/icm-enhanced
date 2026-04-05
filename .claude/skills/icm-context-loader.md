---
name: icm-context-loader
description: Enforce ICM layered context loading. Auto-activates when reading workspace files. Prevents loading unnecessary context and enforces selective section routing.
paths: "workspaces/**/*"
disable-model-invocation: false
user-invocable: false
---

## ICM Context Loading Protocol

When working inside a workspace, you MUST follow this loading order:

### Step 1: Identify Current Stage
Read the workspace CONTEXT.md pipeline table to find which stage you're in.

### Step 2: Read Stage Contract
Read ONLY the current stage's CONTEXT.md. This is your contract.

### Step 3: Parse Inputs Table
The stage's CONTEXT.md has an Inputs table:

```
| Source | File/Location | Section/Scope | Why |
```

Load ONLY what this table specifies. If it says "Voice Rules section" — 
use grep to extract ONLY that section, not the entire file:

```bash
# Extract a specific section from a markdown file
sed -n '/^## Voice Rules/,/^## /p' _config/voice.md | head -n -1
```

### Step 4: Load Previous Output (if specified)
If the Inputs table references a previous stage's output/, read it fresh.
The human may have edited it.

### What You Must NEVER Do

- Load all _config/ files "just in case"
- Read all stages' CONTEXT.md files at once
- Load reference files not specified in the Inputs table
- Read previous outputs to "learn patterns" (docs over outputs rule)
- Load the entire workspace to "understand the full picture"

### Token Budget Per Stage

Target: 2,000–8,000 tokens total context loaded.
If you're loading more, you're violating the protocol. Check the Inputs table again.

## Gotchas

- The Inputs table says "Section/Scope" — this means a SECTION, not the whole file.
  Use grep/sed to extract just that section.
- "Full file" in the Inputs table is explicit permission to load the whole file.
  If it doesn't say "Full file", load only the specified section.
- output/ directories might be empty if the stage hasn't run yet. Check before reading.
