# Stage 01: Spec

## Input

| Source | What | Why |
|---|---|---|
| Prompt / idea | The feature or idea to define | The thing being specced |

## Process

### Step 1: State the problem
One paragraph: who has it, why it matters now.

### Step 2: Define the smallest valuable version
What ships first. Cut anything not needed to prove value.

### Step 3: Write acceptance criteria
Bullet list of "done means..." conditions, each testable. Include any device,
OS, or accessibility constraints that affect acceptance.

## Output

A spec note (`type: spec`, `status: spec`) in `stowed/` containing: problem,
smallest version, acceptance criteria, open questions.

## Completion

Proceed to `stages/02-build/`. Set the note `stage: 02-build` when work starts.
