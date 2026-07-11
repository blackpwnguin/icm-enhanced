---
description: Create a domain tracking folder (SEO, analytics, security…) inside a project the first time it touches that domain. Clones the domain template.
argument-hint: [owner/repo] [domain]
---

Create a domain folder for a project.

## Instructions

1. Parse `owner/repo` and `domain` from `$ARGUMENTS`.
2. Look up `domain` in `workspaces/command-center/_config/taxonomy.md`
   (→ template path + extra files). Not in taxonomy → stop, set `needs_human`
   (adding a domain type is a deliberate config change).
3. Clone `workspaces/command-center/domain-templates/_TEMPLATE/` →
   `projects/<owner__repo>/domains/<domain>/`, then overlay
   `domain-templates/<domain>/` (its CONTEXT.md + extra files).
4. Fill `00-setup.md` Current state from the triggering change; prepend the change
   to `10-change-log.md`.
5. Add the domain to `projects/<owner__repo>/overview.md` Active domains and prepend
   a line to that project's `change-log.md`.

## Canonical example (SEO)
A project ships sitemap.xml + GA4 → this creates `domains/seo/` (setup · change-log ·
recommended-improvements · market-research · keyword-research · analytics-integration)
and, because GA4 was tagged, `domains/analytics/` too. See
`.claude/agents/curator.md` and the seeded `projects/nihilo/`.
