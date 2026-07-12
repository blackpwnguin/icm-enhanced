# Analytics — Events map (stowed)

| Event | Trigger | Parameters | Destination | Status |
|-------|---------|-----------|-------------|--------|
| page_view | page load (gtag config) | page_location, page_title | GA4 | live |
| pricing_cta_click | click a pricing/Get-Early-Access button | plan, location | GA4 | planned |
| demo_play | play the demo video | — | GA4 | planned |
| support_click | click Support / mailto | — | GA4 | planned |
| waitlist_submit | submit the (to-build) waitlist form | plan_interest | GA4 (Key event) | planned |
| app_store_click | click an App Store / TestFlight link | — | GA4 (Key event) | planned |

Wire these with `gtag('event', '<name>', {...})` on the relevant elements, then mark
`waitlist_submit` / `app_store_click` as **Key events** in GA4.
