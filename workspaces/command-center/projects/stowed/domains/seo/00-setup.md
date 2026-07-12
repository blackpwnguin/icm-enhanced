# SEO — How it's set up (stowed / stowedapp.app)

## Current state (as of 2026-07-12, verified against live source)

### Technical
- **Sitemap:** `web/sitemap.xml` present. **robots.txt:** present.
- **Canonical:** `index.html` canonical → https://stowedapp.app ✓
  ⚠ `crypto.html` has **no canonical / OG**. `crypto-thanks.html` has `noindex` ✓.
- **Structured data (JSON-LD):** `SoftwareApplication` + `FAQPage` + `Organization`
  (+ Offer/Question/Answer) on `index.html` ✓
- **Mobile:** responsive; `@media (max-width:768px)` keeps Features/Pricing/Support
  nav visible (100%-iPhone audience) ✓
- **Performance:** ~48KB page, no frameworks, compressed 73s demo video ✓

### On-page
- **Title:** "Stowed: Inventory and B2B Order Management for iPhone"
- **Meta description:** present ✓ · **OG/Twitter:** full card set ✓

### Off-page
- **Search Console verified:** unknown (confirm)

## Baseline metrics
| Metric | Value | Source | Measured |
|--------|-------|--------|----------|
| Indexed pages | TBD | GSC | — |
| Lighthouse SEO | TBD (likely high) | Lighthouse | — |
| Contrast | dark-section text ~3.4:1 (needs 4.5:1) | review | 2026-07-03 |

## History
_2026-07-12: baseline recorded on command-center onboarding._
