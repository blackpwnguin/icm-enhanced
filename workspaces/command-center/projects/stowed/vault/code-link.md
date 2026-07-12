---
project: stowed
type: reference
status: building
stage: "-"
tags: [swift, ios, stowed]
updated: 2026-06-11
---

# Code link

Where the code lives and how to open it.

## Repo

`github.com/blackpwnguin/stowed`, private. Owner: blackpwnguin (Sam). Ish gets Write access once invited.

## Local layout

- Repo root: `~/stowed`
- iOS app folder: `~/stowed/apps/ios/Stowed`
- XcodeGen spec: `~/stowed/apps/ios/Stowed/project.yml`
- Swift source root: `~/stowed/apps/ios/Stowed/Stowed`
- Generated Xcode project: `~/stowed/apps/ios/Stowed/Stowed.xcodeproj`. Gitignored. Do not edit by hand.
- Backup of the prior tangled project: `~/stowed-OLD-backup`.

## Open from a fresh state

```
cd ~/stowed/apps/ios/Stowed
xcodegen generate
open Stowed.xcodeproj
```

## Add or remove a Swift file

1. Create or delete the file under `Stowed/Stowed/...`.
2. Run `xcodegen generate` from `~/stowed/apps/ios/Stowed`.
3. Open the project and build.

Editing an existing file: edit and build, no regenerate needed.

For the why behind XcodeGen, see [[build-log-xcodegen-rebuild]].
