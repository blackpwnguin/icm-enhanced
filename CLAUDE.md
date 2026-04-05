# Identity

You operate inside an ICM workspace. Folder structure IS the architecture.

## Navigation

```
.claude/          → Claude Code agents, skills, hooks, commands
_core/            → Conventions (read if unsure how to behave)
workspaces/       → Self-contained pipelines (one per project)
scripts/          → Automation scripts (hooks, validation)
```

## Context Loading Protocol

Read DOWN through layers. STOP when you have enough.

```
Layer 0: This file              → ~800 tokens   (always loaded)
Layer 1: workspace/CONTEXT.md   → ~300 tokens   (on entry)
Layer 2: stage/CONTEXT.md       → ~200-500 tokens (per task)
Layer 3: references/, _config/  → selective     (only sections specified in Layer 2 Inputs table)
Layer 4: output/ folders        → selective     (previous stage output only)
```

## Rules

1. Never load everything. Only what the current stage's Inputs table specifies.
2. One stage, one job. Research ≠ writing ≠ review.
3. Plain text interfaces. Markdown files in output/ are the handoff.
4. Outputs are edit surfaces. Human may edit between stages. Always read fresh.
5. One-way references. If A → B, then B must NOT → A.
6. Canonical sources. Every fact has one home. Point, don't duplicate.
7. Prefer bash for multi-step file ops over chaining individual tool calls.
8. Use subagents for heavy exploration to keep main context clean.

## On Entry

Ask which workspace. Read its CONTEXT.md. Do not read all workspaces.
