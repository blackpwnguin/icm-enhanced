---
project: stowed
type: session
topic: "privacyinfo-signing-testflight-prep-2026-06-25"
agent: claude-code
model: claude-sonnet-4-6
status: done
tracked: true
date: 2026-06-25
updated: 2026-06-25

# Token breakdown (fill at end of session)
input_tokens: 0
output_tokens: 0
cache_read_tokens: 0
cache_write_tokens: 0
cost_usd: 0.0000

tags: [ios, stowed]
---

# PrivacyInfo.xcprivacy + Signing Team Persistence (2026-06-25)

## What we did

<!-- 1-3 sentence summary of what was accomplished -->
Added `PrivacyInfo.xcprivacy` manifest (covering Supabase, RevenueCat, Sentry) and persisted `DEVELOPMENT_TEAM: Y235A328VD` in `project.yml` so XcodeGen regenerates no longer wipe signing. Item 4 (bundle ID + App Record) confirmed done by Sam. Created app icon asset catalog (programmatic teal shelf mark). Archived and uploaded first TestFlight build to App Store Connect. Built automated token logging system (cron every 15m posts live token counts to dashboard).

## Key decisions

- Team ID `Y235A328VD` confirmed as Nihilo Solutions LLC via Xcode screenshot (old vault value `P76HTKVD68` was stale)
- App icon is a programmatic placeholder; replace with final design before public release
- Dashboard `sessions` table requires `agent: "claude-code"` (not `"hermes"`) per CHECK constraint

## Artifacts produced

- `apps/ios/Stowed/Stowed/PrivacyInfo.xcprivacy` — Apple privacy manifest (pre-existing, wired into xcodeproj)
- `apps/ios/Stowed/Stowed/Assets.xcassets/AppIcon.appiconset/` — App icon (1024x1024 PNG + Contents.json)
- `apps/ios/Stowed/project.yml` — `CFBundleIconName: AppIcon` added
- `~/.hermes/scripts/auto-log-session.py` — Automated token logger
- `~/.hermes/current-project.json` — Session marker for auto-log cron
- Cron job `session-token-autolog` (every 15m) — live dashboard updates
- TestFlight build uploaded to App Store Connect (v1.0, build 1)

## Open items

- Checkpoint 4 simulator test (Sam doing manually later today)
- App Store Connect: check if build passed processing (email from Apple)
- Replace placeholder app icon with final design
- Fill legal page placeholders (mailing address, governing law state)

## Token log

| Metric           | Value |
|------------------|-------|
| Input tokens     | 0     |
| Output tokens    | 0     |
| Cache read       | 0     |
| Cache write      | 0     |
| Total            | 0     |
| Est. cost        | $0.00 |

<!-- After session, log to dashboard with:
cd ~/Desktop/claudedashboard
npm run log-session -- \
  --agent "claude-code" \
  --model "claude-sonnet-4-6" \
  --project stowed \
  --topic "privacyinfo-signing-testflight-prep-2026-06-25" \
  --input_tokens 0 \
  --output_tokens 0 \
  --cache_read_tokens 0 \
  --cache_write_tokens 0 \
  --cost_usd 0.0000 \
  --summary "PrivacyInfo.xcprivacy + signing team persistence for TestFlight prep"
-->
