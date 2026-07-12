# Analytics — How it's set up (stowed)

## Current state (as of 2026-07-12, verified against live source)
- **Platform:** Google Analytics 4 (`gtag.js`), measurement ID **`G-2CB296FN1W`**.
- **Install:** inline in `<head>` of every page (index, privacy, terms, support,
  crypto, crypto-thanks).
- **Events:** default `page_view` only. **No custom conversion events.**
- **Consent:** ⚠ GA runs with **no consent banner** (fine US-only; add geo-gating or
  a banner before any EU marketing — review note).
- **Server-side / cross-domain:** none.

## How success is measured today
- Page views only. No funnel, no conversion tracking → can't yet answer
  "which channel / page drives sign-ups."

## History
_2026-07-12: baseline recorded on onboarding._
