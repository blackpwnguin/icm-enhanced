# Stowed — App Store ship plan

> Mirror of `blackpwnguin/stowed:docs/SHIP_PLAN.md` (canonical). Kept here so
> the plan lives beside the vault knowledge. Re-sync from the repo when it changes.

**Target:** public App Store release in ~2 weeks.
**Owner:** Sam. **Legend:** 🤖 = done/doable in-repo · 👤 = only you can do it
(Apple portal, Supabase dashboard, Xcode build, App Store Connect).

This is the single source of truth for what's left. Check items off as you
go; re-generate the "Status snapshot" when a PR merges.

---

## 0. Status snapshot (2026-07-12)

**Done / in review:**
- ✅ Compliant subscription gate — no in-app selling/pricing (PR #6)
- ✅ Universal Link auth callback replacing the hijackable custom scheme (PR #7)
- ✅ App Review notes + populated demo account, live-seeded (PR #8)
- ✅ Team member removal (PR #5)
- ✅ Website conversion tracking: GA4 + `begin_checkout`/`waitlist_signup`/`demo_play` (merged)
- ✅ External billing model kept intact: web Stripe + crypto, RevenueCat entitlement sync

**Open PRs to build/test then merge (Swift can't compile in CI):**
- PR #5 member removal · PR #6 compliant paywall · PR #7 universal links → **build in Xcode, then merge**
- PR #8 review notes → docs only, safe to merge now
- PR #1, #2 (Vercel bot drafts) → **close**: the analytics/speed-insights scripts are already in `web/*.html`

---

## 1. P0 — App Store submission blockers

| | Item | Notes |
|---|------|-------|
| 👤 | Enable **Associated Domains** on App ID `app.stowed.Stowed` (Apple Developer portal) → regenerate provisioning profile | Required for PR #7's Universal Link |
| 👤 | Add `https://stowedapp.app/auth/callback` to **Supabase → Auth → URL Configuration** redirect allow-list; update email templates if `RedirectTo` is hardcoded | Keep `stowed://auth-callback` until in-flight emails expire |
| 👤 | Build PRs #5/#6/#7 in Xcode, smoke-test, merge | Compiler-verify; run the app once signed in as the demo account |
| 👤 | Swap RevenueCat key to the **production `appl_` key** in `Stowed.xcconfig` | Currently the Test Store key (see AppConfig comment) |
| 👤 | Set/confirm the **demo account password** and enter it in App Store Connect Sign-In Information | See `docs/app-review-notes.md` |
| 👤 | Confirm bundle version bump: `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml` for the new build | |
| 🤖👤 | Verify AASA serves correctly after deploy: `curl -sI https://stowedapp.app/.well-known/apple-app-site-association` → `content-type: application/json` | vercel.json header added in PR #7 |

## 2. App Store Connect — metadata & assets

| | Item |
|---|------|
| 👤 | App name, subtitle, promotional text, description, keywords |
| 👤 | **Screenshots**: 6.7" (iPhone 15/16 Pro Max) + 6.5" required; capture from the demo org so they look populated |
| 👤 | App preview video (optional) — you already have `web/demo.mp4`; trim to portrait if reusing |
| 👤 | **Privacy "Nutrition Label"** (Data Types collected): email, business/customer data, usage analytics (GA4 + Vercel). Declare linked-to-identity where true |
| 👤 | Age rating questionnaire |
| 👤 | **Support URL** → `https://stowedapp.app/support` (exists) · **Marketing URL** → `https://stowedapp.app` · **Privacy Policy URL** → `https://stowedapp.app/privacy` (exists) |
| 👤 | Category: Business (primary), Productivity (secondary) |
| 👤 | **Paid apps / subscriptions:** you sell externally, so the app can ship as **free** with **no in-app purchases**. Confirm no IAP products are attached, or App Review will expect an in-app buy flow |
| 👤 | Sign **Paid Applications Agreement** only if you ever add IAP; not needed for the free reader-app model |

## 3. Legal / compliance

| | Item |
|---|------|
| 🤖 | Privacy policy exists (`web/privacy.html`) — verify it covers GA4 + Vercel Analytics + RevenueCat + Supabase and is dated |
| 🤖 | Terms exist (`web/terms.html`) — verify billing/refund terms match Stripe + crypto reality |
| 🤖 | **GDPR/cookie consent** for EU visitors (GA4 + Vercel Analytics currently load unconditionally) — see §4, being added |
| 👤 | Confirm you have a **DPA** posture if selling to EU businesses (B2B) |
| 🤖 | Guideline 5.1.1 — app must be usable without forcing account creation for browsing? N/A: it's a business tool, account is the product. Documented in review notes |

## 4. Web / marketing polish (🤖 in-repo)

| | Item | Status |
|---|------|--------|
| 🤖 | **Visible FAQ section** mirroring the FAQPage JSON-LD (Google wants rendered content to match structured data) | ✅ done (this PR) |
| 🤖 | **Cookie/analytics consent banner** — GA4 now runs in Consent Mode v2, denied until opt-in; Vercel Analytics is cookieless | ✅ done (this PR) |
| 🤖 | Crypto link already demoted to a small pricing-note link | ✅ done |
| 🤖 | `sitemap.xml` covers /, /crypto, /support, /privacy, /terms | ✅ verified |
| 🤖 | OG/Twitter cards on all pages (index + crypto done) | verify others |
| 🤖 | Lighthouse pass: LCP image sizing, `demo.mp4` lazy (poster preload=none already) | verify |

## 5. Backend hardening (from earlier audit — 🤖 doable, 👤 to apply)

| | Item |
|---|------|
| 👤 | **Enable leaked-password protection** (Supabase → Auth → Passwords) — currently off |
| 👤 | **Rotate any secrets** that were ever shared in plaintext (B1) |
| 🤖👤 | Confirm RLS coverage on every new demo-seeded table (already RLS-enabled) |
| 🤖 | Pagination for orders/products lists (offline/large-account scale) — deferred, not a blocker |
| 🤖 | Offline minimum / error-state polish — deferred |

## 6. Pre-launch QA (👤 on device)

- [ ] Fresh install → sign up → email confirmation via Universal Link opens the app
- [ ] Demo account → lands in populated org, no paywall
- [ ] Inactive account → sees neutral gate (Refresh / Contact support / Sign out), no prices
- [ ] Purchase on web (Stripe) → entitlement appears in app after Refresh
- [ ] Crypto purchase path → entitlement appears
- [ ] Team: invite, change role, remove member
- [ ] Orders lifecycle: draft → confirmed → packed → shipped → completed; stock ledger updates
- [ ] Push notifications (aps-environment production) deliver

## 7. Launch & post-submission

- [ ] 👤 Submit for review; monitor Resolution Center
- [ ] 👤 Prepare TestFlight external group as fallback if rejected
- [ ] 🤖 Waitlist announce email (edge function `waitlist-signup` already collects addresses)
- [ ] 🤖 Update ICM command-center `projects/stowed/change-log.md` on release

---

## Two-week cut line

**Week 1 (unblock + build):** §1 P0 items — Apple portal capability, Supabase redirect, prod RevenueCat key, merge PRs #5/#6/#7, demo password. Web polish §4.
**Week 2 (submit):** §2 metadata + screenshots, §3 legal verify, §6 QA on device, submit. §5 backend toggles are quick and can land any time.

Nothing on the critical path is code Claude can't already produce — the gating work is Apple-portal / Xcode-build / dashboard-toggle steps only you can perform.
