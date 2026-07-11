# Reference — how the command-center maps onto ICM

Layer 3 reference. Read to understand *why* the folders are shaped this way.

## Source
Interpretable Context Methodology: Folder Structure as Agentic Architecture — Jake
Van Clief & David McDermott, arXiv:2603.16021 (2026). Reference implementation:
`RinDig/Interpreted-Context-Methdology`.

> "The filesystem is doing the work that a framework would otherwise do in code.
> Stage sequencing is the folder numbering. Context scoping is the folder hierarchy.
> State management is the files on disk."

## This workspace vs classic ICM
Classic ICM = one agent walking one workspace's stages top-to-bottom. The
command-center keeps that spirit but adds **two agent roles across many repos**, with
files as the only coordination mechanism:

| ICM concept | Here |
|-------------|------|
| numbered stages | `stages/01-intake → 02-classify → 03-file` |
| stage contract (reads/does/writes) | every `CONTEXT.md` |
| output = handoff | a report in `stages/01-intake/output/` → Curator → `projects/**` |
| single agent, role by location | `@field-agent` in a repo · `@curator` here |
| filesystem = state | `projects/`, `registry.md`, `domains/`, append-only logs |

## Fidelity to icm-enhanced conventions
- CONTEXT.md files are routers, < 80 lines (Convention 13, 15).
- References < 200 lines. One-way references only (Convention 3).
- Canonical sources: registry, taxonomy, structure each have one home (Convention 5).
- Docs over outputs: the Curator files from reports + templates, never learns from
  prior filed outputs (Convention 10).
