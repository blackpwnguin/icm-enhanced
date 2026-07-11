# domains/<domain>/ — router (generic)

Standard shape for tracking one domain in a project. Overlaid with a domain-specific
version on creation.

- **Reads** — Field Report changes classified into this domain (`_config/taxonomy.md`).
- **Does** — tracks how it's set up, changes by date, recommended improvements, market research.
- **Writes** (Curator only): `00-setup.md`, `10-change-log.md`,
  `20-recommended-improvements.md`, `30-market-research.md` (+ taxonomy extras).
