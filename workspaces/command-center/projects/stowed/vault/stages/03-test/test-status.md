---
project: stowed
type: build-log
status: building
stage: 03-test
tags: [swift, ios, stowed]
updated: 2026-06-11
---

# Test status

Honest snapshot.

## Current state

- No test target. The XCTest target was not carried into the XcodeGen rebuild; see [[build-log-xcodegen-rebuild]].
- No XCTest coverage on any new code.
- Verification so far is simulator-only, manual, against the Northbeam Coffee Co. mock store.
- No on-device verification has happened. The signing team is set in Xcode but will be wiped on the next regenerate; the device path is in [[ship-readiness]].
- No flaky tests, because there are no tests.

## To do, when this stage actually begins

- Add a test target back into `project.yml` and regenerate. Treat that as the moment 03-test starts.
- Cover new business logic (pricing resolution, order pipeline transitions, role gating, financial math) with XCTest. Mock at boundaries (network, storage, clock).
- Smoke pass each acceptance criterion in the simulator. The first batch comes from [[spec-backend-phase]].
- On-device verification once the backend cut is up: real network, real Sign in with Apple, biometrics on Money and Payroll, App Attest on sensitive Edge Function calls.
- VoiceOver and Dynamic Type on all new UI.

Record each run with a `test-log-*.md` note per the stage 03-test contract.
