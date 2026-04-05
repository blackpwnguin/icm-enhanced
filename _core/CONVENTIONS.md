# ICM Conventions

These conventions apply to every workspace. They are borrowed from established practice
and applied to the specific problem of structuring context for AI agents.

---

## Architecture Conventions

### 1. Stage Contracts
Every stage CONTEXT.md has three sections: Inputs, Process, Outputs.
Simple enough for anyone to read. Structured enough for an agent to follow.

### 2. Stage Handoffs
Output folders connect stages. The output of stage N becomes available input for stage N+1.
Edit any output and the next stage picks up your changes.

### 3. One-Way References
If A references B, B does not reference A.
Bidirectional references create O(n²) maintenance. One-way scales linearly.

### 4. Selective Section Routing
CONTEXT.md tables specify which SECTIONS of which files to load.
Not the whole file. The section you need. Same principle as database views.

### 5. Canonical Sources
Every piece of information has one home. Other files point there.
The moment the same rule exists in two files, they drift.

---

## Quality Conventions

### 6. Specs Are Contracts
Specification stages define WHAT and WHEN. They do not prescribe HOW.
The build stage has creative freedom within the quality floor.

### 7. Checkpoints
Creative stages pause for human steering between steps.
The agent completes a unit of work, presents options, human redirects.

### 8. Stage Audits
Quality checklists the agent runs AFTER completing a stage but BEFORE writing output.
Each check has an unambiguous pass condition.

### 9. Value Validation
Content stages define what types of value their output delivers.
The value is locked before drafting begins.

### 10. Docs Over Outputs
Reference docs are the authoritative source for how to build.
Agents do NOT read previous outputs to learn patterns.
Early outputs are the worst outputs. If future agents learn from them, quality never improves.

---

## Onboarding Conventions

### 11. Questionnaire Design
Flat, all-at-once, system-level only.
Configure the factory, not the product.
Voice questions extract concrete examples, not descriptions.

### 12. Shared Constants
Code-producing workspaces define shared constant files that all outputs import from.
Change a value once, it updates everywhere.

---

## Structural Conventions

### 13. CONTEXT.md Is a Router, Not a Container
A CONTEXT.md tells the agent what to load. It does NOT contain knowledge itself.
The moment it starts containing reference material, you have a maintenance burden.

### 14. Token Budget Awareness
- Layer 0: ~800 tokens (paid every conversation, stays lean)
- Layer 1: ~300 tokens
- Layer 2: ~200-500 tokens per stage
- Layer 3: ~500-3000 tokens each, loaded selectively
- Total per stage: 2,000-8,000 tokens (the performance sweet spot)

### 15. File Size Limits
- All CONTEXT.md files: under 80 lines
- All reference files: under 200 lines
- If a file exceeds these limits, split it. The file is doing too many jobs.
