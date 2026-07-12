---
project: stowed
type: build-log
status: building
stage: 02-build
tags: [automation, swift, ios, stowed]
updated: 2026-06-11
---

# Build log: XcodeGen rebuild

The decision that fixed the build, captured so future-Sam and Ish remember why the Xcode project is disposable.

## The problem it solved

Earlier sessions repeatedly broke because files were added to Xcode by hand. Manual "Add Files to project" kept creating duplicate folder trees and stale file references. The project would compile in one window and fail in another because the on-disk layout and the `.xcodeproj` graph disagreed.

## The fix

The whole project was rebuilt clean using XcodeGen. The Xcode project file is now generated from the folder structure plus a `project.yml` spec. Result:

- File references are always correct, because they are generated from disk.
- The `.xcodeproj` is disposable and gitignored.
- Adding a file is now: drop it in the folder, run `xcodegen generate`, open the project.
- No more "Add Files" dialogs and no more duplicate references.

Installed via Homebrew (`brew install xcodegen`).

## What got dropped in the rebuild

- Test targets. Not carried into the rebuild; can be added later when XCTest coverage is on the table. See [[test-status]].
- Supabase, RevenueCat, and Sentry SDKs. They had not been wired up yet, so the rebuild started from a clean SDK-free `project.yml`. They come back in [[spec-backend-phase]].

## Gotcha to remember

XcodeGen wipes any signing-team setting set in Xcode, because every regenerate rewrites the project file. The team is currently fine for simulator builds, but before running on a real device the team must be added to `project.yml` so it persists across regenerates. See [[ship-readiness]].

## Workflow reminder

See [[code-link]] for the open-and-regenerate sequence and the add/remove/edit recipes.
