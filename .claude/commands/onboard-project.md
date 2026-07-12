---
description: Scaffold command-center tracking for a repo by cloning the project template, so every project follows the identical ICM structure.
argument-hint: [owner/repo]
---

Onboard a repo into the command-center.

## Instructions

1. Parse `owner/repo` from `$ARGUMENTS`.
2. Register it in `workspaces/command-center/_config/registry.md`
   (repo, visibility, status: scaffolded, tracked: true).
3. Clone `workspaces/command-center/projects/_TEMPLATE/` →
   `workspaces/command-center/projects/<owner__repo>/` verbatim.
4. Replace `<repo>` / `<owner/name>` / `<visibility>` placeholders in `overview.md`
   and `CONTEXT.md`. Set the onboarding line date in `change-log.md` to today.
5. Leave `domains/` empty except its `CONTEXT.md` (domains are created on demand).
6. Report: the new folder path + registry entry.

## New GitHub project → same structure automatically
When a brand-new repo appears, this command gives it the identical ICM structure.
That is the self-propagating guarantee: one template, cloned identically, forever.
