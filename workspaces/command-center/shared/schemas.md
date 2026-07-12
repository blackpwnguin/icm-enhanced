# Schemas — Field Report & Update Entry

## Field Report (what a Field Agent emits)

Markdown file with YAML front-matter + sections. Dropped in
`stages/01-intake/output/`.

```markdown
---
id: <repo-slug>-<YYYY-MM-DD>-<slug>   # unique, stable (idempotency)
repo: owner/name                      # must resolve in _config/registry.md
date: YYYY-MM-DD
author: field-agent
needs_human: false
---
## Summary
One or two sentences (becomes the project-wide change-log line).

## Changes            # >= 1 item
- kind: setup|change|recommendation|research
  summary: one sentence
  files: [path, ...]  # drives domain classification
  tags: [seo, ...]    # domain hints
  detail: 1-5 sentences

## Links
- commit: <sha>       # optional; pr:, url: too
```

**Validation (Curator):** `id`,`repo`,`date`,`## Summary`,≥1 change present; `date`
parses; no secrets (`AKIA`, `-----BEGIN`, `password=`) → `_rejected/`; `id` not
already filed → idempotent.

## Update Entry (what the Curator writes)

**Project-wide line** — `projects/<repo>/change-log.md` (prepend):
```
## 2026-07-11 — <summary> [seo, analytics] (commit abc1234)
  ↳ report: <id>
```

**Domain change** — `projects/<repo>/domains/<domain>/10-change-log.md` (prepend):
```
### 2026-07-11 — <summary>
- kind: <kind> · files: <files>
- detail: <detail>
- source: report <id> · commit <sha>
```

**Setup** → replace `00-setup.md` Current state, move old under History.
**Recommendation** → row in `20-recommended-improvements.md` (dedupe by title).
Always cite the source `id`. Append/prepend only.
