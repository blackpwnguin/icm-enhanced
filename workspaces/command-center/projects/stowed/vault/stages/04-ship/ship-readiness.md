---
project: stowed
type: build-log
status: building
stage: 04-ship
tags: [ios, stowed]
updated: 2026-06-21
---

# Ship readiness

Pre-ship setup, not a ship yet. Captures what is done and what blocks first TestFlight.

## Done

- Nihilo Solutions LLC formed.
- Mercury business bank account opened.
- Apple Developer Program active for both Sam's Individual account and the LLC (Nihilo Solutions LLC, enrollment `Y235A328VD`).
- Xcode project signing team set to Nihilo Solutions LLC. Will be wiped on the next XcodeGen regenerate. See [[build-log-xcodegen-rebuild]].
- **Ish accepted the App Store Connect Admin invite** (2026-06-21).
- **Domain registered** (`stowedapp.app`, Vercel) and **web repo deployed**. See [[decision-domain-and-web-hosting]].
- **Legal + support pages drafted and deployed** (privacy, terms, support). See [[legal-and-support-pages]].
- **Supabase backend foundation applied** 2026-06-12 (project `arqkutfkziicuxfesghm`). See [[schema-applied]]. (The 06-21 `0001_init.sql` scaffold is a separate, divergent draft — [[alt-scaffold-reconciliation]].)
- **`PrivacyInfo.xcprivacy` manifest** added and wired into xcodeproj (2026-06-25). Covers Supabase UserDefaults (CA92.1), email/name/business data.
- **App icon asset catalog** added (2026-06-25). Programmatic placeholder (3 teal bars on dark bg). `CFBundleIconName: AppIcon` in Info.plist.
- **First TestFlight build uploaded** (2026-06-25). Archive succeeded, IPA uploaded to App Store Connect, processing.

## Pending, in order

1. **Push the clean rebuild to GitHub.** Repo is `github.com/blackpwnguin/stowed` (private). The local rebuild has not been pushed yet, so the remote does not match. This is the first do-first action in [[STATUS]].
2. **Ish gets GitHub Write access** (not yet added).
3. **Fill legal-page placeholders** (mailing address, governing law state) and confirm live URLs + `support@stowedapp.app` inbox. See [[legal-and-support-pages]].
4. **Register the bundle identifier in App Store Connect** (`app.stowed.Stowed`, SKU `STOWED001`). Only needed before the first TestFlight build, not for development.
5. **Add the signing team to `project.yml`** before any device build, so regenerates do not wipe it.
6. **Add the `api.stowedapp.app` CNAME** to the Supabase project.

## Not yet

- No App Store record metadata (screenshots, description, keywords).
- No StoreKit subscriptions wired. See [[pricing-tiers]].
- App icon is a programmatic placeholder (3 teal bars) — replace with final design before public release.

## When TestFlight actually starts

The 03-test stage should have run with on-device verification (see [[test-status]]) and the backend cut should be up. Then: archive in Xcode, upload, internal review, optional external testers.
