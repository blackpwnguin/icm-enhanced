# Stage 04: Ship

## Input

| Source | What | Why |
|---|---|---|
| `03-test` output | Verified build | What's being released |
| Spec acceptance criteria | Done conditions | Final check |

## Process

### Step 1: Cut the release build
Archive in Xcode (or via `xcodebuild archive`). Tag the commit.

### Step 2: Distribute
Upload to TestFlight for internal review, then promote to external testers or
the App Store as scoped.

### Step 3: Capture the learning
What worked, what to do differently. One short retro note.

### Step 4: Update status
Set the project/spec notes to `status: shipped`.

## Output

A `decision`/retro note + updated `status: shipped` on related notes.

## Completion

Final stage. Move durable takeaways into `references/` if reusable. Stop.
