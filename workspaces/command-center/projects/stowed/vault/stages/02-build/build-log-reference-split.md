---
project: stowed
type: build-log
status: building
stage: 02-build
tags: [ios, stowed]
updated: 2026-06-16
---

# Build log: reference file split

Three reference files were over the 200-line conventions limit. Split each
hub-and-spoke so every resulting file is under 200 lines and inbound
`[[wikilinks]]` keep working. The original filename in each case stays put
as a lean hub (index) note, so the ~13 inbound links to
`[[backend-threat-model]]`, plus the links to `[[finalized-experience]]`
and `[[competitive-landscape]]`, do not break. Content moved verbatim;
nothing was rewritten or dropped.

## What I split

### backend-threat-model.md (was 291 lines)

- `backend-threat-model.md` (hub): title, intro, Assets, Trust boundaries,
  See also, plus a Sections index linking the spokes.
- `backend-threat-model-threats.md`: the T1-T11 threat catalog. T-number
  headings kept intact so references like "[[backend-threat-model]] T8"
  stay findable.
- `backend-threat-model-rpc-acceptance.md`: RPC surface acceptance and the
  out-of-scope list.

### finalized-experience.md (was 237 lines)

- `finalized-experience.md` (hub): title, intro, "What finalized means",
  Positioning bets, Sections index.
- `finalized-experience-screens.md`: the finalized screen inventory.
- `finalized-experience-workflows.md`: critical workflows and AI hooks.
- `finalized-experience-build-plan.md`: prioritized build list, open design
  decisions, and what is NOT shipping this phase.

### competitive-landscape.md (was 224 lines)

- `competitive-landscape.md` (hub): title, intro, Sections index, reading
  guide.
- `competitive-landscape-tier1-generalists.md`: Cin7, Sortly, inFlow,
  Katana, Zoho deep-dives.
- `competitive-landscape-tier1-channel-enterprise.md`: Veeqo, Brightpearl,
  Fishbowl deep-dives.
- `competitive-landscape-tier2-3-synthesis.md`: Tier 2, Tier 3, Synthesis,
  Sources.

Competitive Tier 1 was split across two spokes because all nine deep-dives
in one file would have run over 200 lines.

## Final line counts

| File | Lines |
|---|---|
| backend-threat-model.md (hub) | 64 |
| backend-threat-model-threats.md | 196 |
| backend-threat-model-rpc-acceptance.md | 68 |
| finalized-experience.md (hub) | 34 |
| finalized-experience-screens.md | 86 |
| finalized-experience-workflows.md | 94 |
| finalized-experience-build-plan.md | 70 |
| competitive-landscape.md (hub) | 26 |
| competitive-landscape-tier1-generalists.md | 115 |
| competitive-landscape-tier1-channel-enterprise.md | 75 |
| competitive-landscape-tier2-3-synthesis.md | 63 |

All eleven files are under 200 lines.

## Wikilinks

Hub filenames are unchanged, so all inbound `[[basename]]` links from build
logs, rls-policies, schema-applied, rpc-functions, migration-history,
architecture-overview, frontend-wiring-map, STATUS.md, and the rest keep
resolving. Each hub lists its spokes under a Sections heading; each spoke
carries a `[[hub]]` backlink near the top. No inbound links in other notes
were edited.
