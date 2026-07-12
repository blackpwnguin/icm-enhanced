# Stage 02: Build

## Input

| Source | What | Why |
|---|---|---|
| The `01-spec` note | Acceptance criteria | Defines "done" |
| Xcode project / Swift files (named only) | Code to change | Implementation |

## Process

### Step 1: Plan the change
List the views, models, and services to touch. Only these get loaded.

### Step 2: Implement against acceptance criteria
Build the smallest version. Keep the build green between commits.

### Step 3: Keep a build log
Append decisions and surprises to a `build-log-*.md` note.

## Output

Working change + a `build-log` note (`type: build-log`) capturing decisions and
anything future-you would want when recalling this.

## Completion

When the feature compiles and basic flows work in the simulator, proceed to
`stages/03-test/`.
