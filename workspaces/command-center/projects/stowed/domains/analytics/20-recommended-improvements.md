# Analytics — Recommended improvements (stowed)

Deduped by title. P0 highest. These make the data *readable for decisions* — the
prerequisite for "read analytics → suggest improvements."

| Priority | Recommendation | Rationale | Added | Status |
|----------|----------------|-----------|-------|--------|
| P1 | Define GA4 **conversion events**: `pricing_cta_click`, `demo_play`, `support_click`, `app_store_click`/`waitlist_submit` | today only page_view — can't measure intent | 2026-07-12 | open |
| P1 | Add a **waitlist form** + track `waitlist_submit` as the primary conversion | highest-ROI site change; gives a funnel | 2026-07-12 | open |
| P2 | Mark key events as **Key events (conversions)** in GA4 + build a funnel exploration | enables channel/page ROI reads | 2026-07-12 | open |
| P2 | Link **Search Console ↔ GA4** | query-level SEO data in one place | 2026-07-12 | open |
| P2 | Grant a **GA4 Data API** service account (or scheduled export to Supabase) | lets the ICM/dashboard read analytics automatically | 2026-07-12 | open |
| P3 | Add a **consent banner** or geo-gate before EU marketing | GDPR posture | 2026-07-12 | open |
