---
id: nihilo-2026-07-11-seo
repo: blackpwnguin/nihilo
date: 2026-07-11
author: field-agent
needs_human: false
---
## Summary
Implemented on-page SEO and wired Google Analytics 4.

## Changes
- kind: setup
  summary: Added sitemap.xml, canonical + meta description tags.
  files: [public/sitemap.xml, index.html]
  tags: [seo]
  detail: Static sitemap with 12 routes; per-page canonical to apex; meta descriptions on key routes; basic OG tags on home.
- kind: change
  summary: Added GA4 via gtag.
  files: [src/analytics.ts]
  tags: [analytics]
  detail: Measurement ID stored as env var; default page_view tracking enabled.
- kind: recommendation
  summary: Add JSON-LD Organization schema and per-page OG images.
  files: []
  tags: [seo]
  detail: Would improve rich-result eligibility and social previews.

## Links
- commit: <sha>

<!-- PROCESSED 2026-07-11: filed to projects/nihilo/ ; created domains seo, analytics -->
