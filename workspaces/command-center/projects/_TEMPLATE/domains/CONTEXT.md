# domains/ — router

Per-domain tracking. Folders are created **on demand** by the Curator the first time
this project touches a domain (`/project:new-domain`, see
`.claude/agents/curator.md`).

- **Reads** — classified changes; `_config/taxonomy.md`.
- **Does** — one subfolder per domain (`seo/`, `analytics/`…), each cloned from
  `domain-templates/<domain>/`.
- **Writes** — Curator only.

_No domains yet._
