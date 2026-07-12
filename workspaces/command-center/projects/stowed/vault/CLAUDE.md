# Stowed (L1)

Apple/iOS app build (partner project). Take a feature from spec through device
testing to a shipped build, and keep durable knowledge in `references/`.

## What to load

| Resource | When | Why |
|---|---|---|
| `stages/{current}/CONTEXT.md` | Always | Current stage contract |
| `_reference/conventions.md` | First use only | Frontmatter + naming |

## What NOT to load

| Resource | Why |
|---|---|
| Xcode project / Swift source | Only files identified during 02-build or 03-test |
| Other workspaces | Irrelevant context |
| `_templates/` | Only when scaffolding |

## Stage progression

1. `01-spec`: Define the feature and acceptance criteria.
2. `02-build`: Implement in Swift/SwiftUI; keep a build log.
3. `03-test`: Unit, smoke, and on-device verification against pass criteria.
4. `04-ship`: Release to TestFlight or the App Store, then capture learning.

## Reference library (not pipeline)

Stable knowledge lives in `references/`. Add `decision-*.md` notes as work
generates them.
