---
type: moc
title: Command Center
tags: [icm, command-center, moc]
updated: 2026-07-11
---

# Command Center — Map of Content

The account's second brain in GitHub: a durable, Obsidian-readable memory of every
project. Field Agents in each repo relay updates; the Curator files them here.

> Obsidian: this vault-in-GitHub uses `[[wikilinks]]`. Open any note and follow the
> graph. The dashboard's `sync-icm` reads `projects/*/change-log.md` into Supabase.

## Start here
- [[CONTEXT]] — routing (Layer 1)
- [[_config/registry]] — every tracked repo
- [[_config/taxonomy]] — domains a project can start doing
- [[shared/schemas]] — Field Report + Update Entry
- [[shared/references/icm-command-center]] — how this maps onto ICM

## Agents & commands
- Agents: `@field-agent` (per repo) · `@curator` (here only)
- Commands: `/project:relay-report` · `/project:file-report` ·
  `/project:onboard-project` · `/project:new-domain`

## The relay
[[stages/01-intake/CONTEXT|01 Intake]] → [[stages/02-classify/CONTEXT|02 Classify]] →
[[stages/03-file/CONTEXT|03 File]] → `projects/<repo>/`

## Projects
Each tracked repo gets a folder under `projects/`. Seeded example:
- [[projects/nihilo/CONTEXT|nihilo]] — SEO + analytics domains auto-created

## Dashboard link
The Next.js + Supabase dashboard ingests these change-logs via `npm run sync-icm`
(`ICM_PATH` → this folder), surfacing per-repo updates on the Projects/Activity views.
