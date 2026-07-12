# Stage 03: Test

## Input

| Source | What | Why |
|---|---|---|
| `02-build` output | Built feature | The thing being tested |
| `01-spec` acceptance criteria | Pass conditions | What "done" looks like |

## Process

### Step 1: Unit tests
Cover new business logic with XCTest. Mock at boundaries (network, storage,
clock). Keep tests deterministic; no real network calls.

Pass criteria:
- New logic has direct unit coverage.
- All tests green on a clean run (`cmd+U` in Xcode or `xcodebuild test`).
- No flaky tests introduced. Three consecutive green runs.

### Step 2: Smoke tests
Run the golden path for the changed feature in the iOS simulator. Cover at
least one happy path and one error path per acceptance criterion.

Pass criteria:
- Every acceptance criterion exercised end to end in the simulator.
- No console errors or runtime warnings on the changed path.
- Memory and frame rate stay within normal range during the smoke pass.

### Step 3: On-device verification
Install on a real device (or TestFlight internal build). Verify behavior the
simulator cannot fake: camera, sensors, push notifications, background tasks,
real network conditions, biometric auth.

Pass criteria:
- Feature works on the lowest supported iOS version available to test.
- VoiceOver and Dynamic Type both work for any new UI.
- No new crashes in the Xcode device log during the verification session.
- Battery and thermal behavior look normal for the time spent.

### Step 4: Record the run
Append results to a `test-log-*.md` note: device, OS version, build SHA, which
criteria passed or failed, and any defects opened.

## Output

A `test-log` note (`type: build-log`) capturing the run, plus all acceptance
criteria marked pass.

## Completion

When every pass criterion above is met, proceed to `stages/04-ship/`. If any
criterion fails, return to `stages/02-build/` with the defect linked.
