# ICM Enhanced — Van Clief Architecture + Claude Code Internals

Combines Jake Van Clief's ICM folder-as-architecture with patterns extracted
from Claude Code's March 2026 source leak and current best practices.

---

## The Token Efficiency Stack (How You Hit Near-Zero)

Four layers of token prevention, not compression:

### Layer A — ICM Staged Loading (Van Clief)
Each stage loads only what its Inputs table specifies.
Per-stage: 2,000–8,000 tokens vs. 30,000–50,000 monolithic.

### Layer B — Subagent Context Isolation (Claude Code)
Each stage runs in `context: fork`. The main context only sees
the summary, not the intermediate reads. Forked subagents inherit
the parent's prompt cache as byte-identical copies — spawning 5
costs barely more than 1.

### Layer C — Selective Section Routing (ICM + grep)
Inputs tables specify SECTIONS, not files. Use sed/grep to extract
only the needed section. Cuts per-file loading by 50-70%.

### Layer D — Prompt Cache Boundary (Leak Pattern)
CLAUDE.md is static (cached across sessions at 90% discount).
Dynamic context lives after the boundary. Cache hits save real money.

**Combined result: main context stays under ~1,000 tokens across
an entire multi-stage pipeline. Each subagent peaks at 2,000–8,000.**

---

## Architecture

```
icm-enhanced/
├── CLAUDE.md                              ← Layer 0 (~800 tokens, prompt-cached)
├── .claude/
│   ├── settings.local.json                ← Permissions + security boundaries
│   ├── agents/
│   │   ├── researcher.md                  ← context:fork, model:sonnet, Explore
│   │   ├── writer.md                      ← context:fork, model:opus
│   │   ├── reviewer.md                    ← context:fork, model:opus
│   │   └── workspace-builder.md           ← Meta-agent: scaffolds new workspaces
│   ├── commands/
│   │   ├── run-stage.md                   ← /project:run-stage [N] [workspace]
│   │   ├── setup-workspace.md             ← /project:setup-workspace [name]
│   │   ├── new-workspace.md               ← /project:new-workspace [name]
│   │   └── audit.md                       ← /project:audit [name]
│   ├── skills/
│   │   ├── icm-context-loader.md          ← Auto: enforces layered loading
│   │   └── icm-output-validator.md        ← Auto: validates before writes
│   └── hooks/
│       └── icm-hooks.json                 ← PreToolUse/PostToolUse enforcement
├── scripts/
│   ├── validate-icm-read.sh               ← Boundary enforcement for reads
│   └── validate-icm-write.sh              ← File size enforcement for writes
├── _core/
│   └── CONVENTIONS.md                     ← 15 rules from Van Clief's methodology
└── workspaces/
    └── my-workspace/                      ← Template workspace (3-stage pipeline)
        ├── CONTEXT.md                     ← Layer 1: pipeline routing
        ├── _config/{voice,structure}.md   ← Layer 3: factory settings
        ├── shared/constants.md            ← Cross-stage terminology
        ├── skills/SKILL-TEMPLATE.md       ← Domain knowledge modules
        ├── setup/questionnaire.md         ← One-time configuration
        └── stages/
            ├── 01-research/               ← CONTEXT.md + references/ + output/
            ├── 02-draft/
            └── 03-review/
```

---

## Key Patterns From the Leak (Applied Here)

### 1. Three-Layer Memory (MEMORY.md Pattern)

The leak revealed Claude Code's memory system:
- MEMORY.md: lightweight index of pointers (~150 chars/line), always loaded
- Topic files: actual knowledge, fetched on-demand
- Raw transcripts: never re-read, only grepped for specific IDs

**How ICM already does this:**
- CLAUDE.md = the pointer index (Layer 0, always loaded, ~800 tokens)
- CONTEXT.md files = topic routing (loaded per-stage)
- output/ files = working artifacts (loaded selectively, never re-read for patterns)

Van Clief independently arrived at the same architecture. ICM's "docs over
outputs" rule matches the leak's "treat memory as hints, verify against source."

### 2. Prompt Cache Boundary (SYSTEM_PROMPT_DYNAMIC_BOUNDARY)

Static instructions (CLAUDE.md, conventions) never change between sessions.
Dynamic context (stage contracts, outputs) changes per task.

Anthropic's prompt caching gives 90% discount on cached prefixes.
CLAUDE.md is your static prefix. Everything after it is dynamic.

**Practical rule:** Never edit CLAUDE.md mid-session. It breaks the cache.

### 3. Subagent Fork + Prompt Cache Inheritance

When Claude Code spawns a subagent with `context: fork`, the child inherits
a byte-identical copy of the parent's prompt cache. Five subagents cost
barely more than one because they all share the cached CLAUDE.md prefix.

**Applied here:** Each stage's subagent (researcher, writer, reviewer) forks
from the main context. They inherit the CLAUDE.md cache and load only their
stage-specific context on top. Main thread stays clean.

### 4. Five Compaction Strategies

The leak showed Claude Code has 5 distinct strategies for when context
overflows. The relevant one for ICM: you shouldn't need compaction at all.

If your per-stage context stays under 8,000 tokens (which ICM enforces),
you never hit the compaction threshold. Prevention over compression.

### 5. Security Patterns (23 Bash Checks)

The leak revealed 2,500 lines of bash security. For ICM:
- settings.local.json denies destructive git commands
- PreToolUse hooks validate read boundaries
- PostToolUse hooks enforce file size limits
- Subagents have restricted tool access (researcher gets Read/Grep/Glob only)

### 6. Coordinator Mode (Prompts as Architecture)

The leak confirmed: multi-agent coordination is done via system prompt
instructions, not code-level orchestration. The coordinator tells workers
what to do through prompts.

**ICM does exactly this.** CONTEXT.md files ARE the coordination prompts.
The folder structure IS the orchestration. No framework needed.

---

## Daily Workflow

### First Time
```bash
cd icm-enhanced
claude                                    # Opens Claude Code, reads CLAUDE.md
/project:new-workspace content-pipeline   # Scaffold a workspace
/project:setup-workspace content-pipeline # Answer the questionnaire
```

### Every Run
```bash
/project:run-stage 01 content-pipeline    # Research (→ @researcher subagent)
# Review stages/01-research/output/research.md — edit if needed
/project:run-stage 02                     # Draft (→ @writer subagent)
# Review stages/02-draft/output/draft.md — edit if needed
/project:run-stage 03                     # Review (→ @reviewer subagent)
# Final output in stages/03-review/output/final.md
```

### Maintenance
```bash
/project:audit content-pipeline           # Check convention compliance
```

---

## How to Add Stages

1. Create `stages/04-publish/` with `CONTEXT.md`, `references/`, `output/`
2. Write the stage contract (Inputs, Process, Outputs, Audit sections)
3. Update workspace CONTEXT.md pipeline table
4. Optionally create a matching subagent in `.claude/agents/`

### How to Add Workspaces

1. `/project:new-workspace [name]` — the workspace-builder agent handles it
2. Or copy `workspaces/my-workspace/` and customize
3. Each workspace is fully self-contained

### How to Add Domain Skills

1. Copy `skills/SKILL-TEMPLATE.md` in your workspace
2. Focus on: what pushes the model out of default behavior + gotchas
3. Keep under 200 lines. If bigger, split.

---

## What NOT to Do

1. **Don't load everything "just in case."** The Inputs table exists for a reason.
2. **Don't run stages in the main context.** Use /project:run-stage (subagents).
3. **Don't edit CLAUDE.md mid-session.** You'll break the prompt cache.
4. **Don't learn from previous outputs.** Learn from reference docs only.
5. **Don't exceed file limits.** CONTEXT.md < 80 lines. References < 200 lines.
6. **Don't create bidirectional references.** A→B is fine. B→A is O(n²) maintenance.
7. **Don't store data in CONTEXT.md.** It's a router. It points to files, never contains knowledge.
