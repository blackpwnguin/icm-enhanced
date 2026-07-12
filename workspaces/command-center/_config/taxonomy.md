# Taxonomy — domains a project can start doing

When a Field Report's change matches a domain's signals and no folder exists yet, the
Curator clones `domain-templates/<domain>/`. First signal match wins.

| Domain | Signals (lowercased match on summary + files + tags) | Template | Extra files |
|--------|------------------------------------------------------|----------|-------------|
| seo | sitemap, robots.txt, canonical, meta description, schema.org, json-ld, hreflang, og:, core web vitals, lighthouse, keywords, backlinks | `domain-templates/seo` | 40-keyword-research.md, 50-analytics-integration.md |
| analytics | google analytics, ga4, gtag, gtm, tag manager, posthog, plausible, mixpanel, segment, conversion, events | `domain-templates/analytics` | 40-events-map.md |
| security | dependabot, security.md, csp, secrets, snyk, cve, vuln, auth, oauth, rls | `domain-templates/security` | 40-threat-model.md |
| performance | lighthouse, core web vitals, lcp, cls, inp, bundle size, caching, cdn, lazy-load | `domain-templates/performance` | — |
| accessibility | aria, wcag, axe, contrast, screen reader, alt text, focus-visible | `domain-templates/accessibility` | — |
| content | blog, cms, copywriting, content calendar, editorial, docs | `domain-templates/content` | 40-content-calendar.md |
| infra | vercel, netlify, docker, kubernetes, terraform, ci/cd, github actions, supabase, aws, azure | `domain-templates/infra` | 40-runbook.md |
| data | dataset, model, training, embeddings, vector db, huggingface, fine-tune, eval | `domain-templates/data` | 40-model-card.md, 50-eval-log.md |

## Adding a new domain type
1. Add a row here. 2. Create `domain-templates/<domain>/` (copy the closest one).
3. Auto-creation then works everywhere. This is deliberate → `needs_human` unless
pre-approved.

## Normalization
Resolve to the domain **key** (`seo`, not `SEO`/`search-optimization`) so you never
create duplicate folders.
