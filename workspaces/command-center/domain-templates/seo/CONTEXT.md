# domains/seo/ — router

Tracks **all SEO** for a project: setup, changes by date, recommended improvements,
market/keyword research, analytics tie-in. Auto-created the first time a project ships
SEO work.

- **Reads** — changes classified `seo` (sitemap, robots.txt, canonical, meta
  description, schema.org/JSON-LD, hreflang, OG, Core Web Vitals, keywords, backlinks).
- **Does** — the durable SEO record.
- **Writes** (Curator only): `00-setup.md`, `10-change-log.md`,
  `20-recommended-improvements.md`, `30-market-research.md`, `40-keyword-research.md`,
  `50-analytics-integration.md`.
