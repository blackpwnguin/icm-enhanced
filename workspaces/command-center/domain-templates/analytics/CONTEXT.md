# domains/analytics/ — router

Measurement & analytics. Inherits base four files + `40-events-map.md`.

- **Reads** — changes classified `analytics` (GA4, gtag, GTM, PostHog, Plausible,
  Mixpanel, Segment, conversions, events).
- **Does** — records the analytics stack, tracked events, how success is measured.
- **Writes** (Curator only): base files + `40-events-map.md`. Cross-link SEO
  measurement to `../seo/50-analytics-integration.md`.
