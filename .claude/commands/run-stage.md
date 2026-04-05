---
description: Run a specific ICM pipeline stage. Delegates to the appropriate subagent (researcher, writer, reviewer) to keep main context clean.
argument-hint: [stage-number] [workspace-name]
---

Run ICM pipeline stage for the specified workspace.

## Instructions

1. Parse the stage number and workspace name from $ARGUMENTS
   - If no workspace specified, check if there's only one workspace and use it
   - If no stage specified, read the workspace CONTEXT.md to find the next unfinished stage

2. Read the workspace's CONTEXT.md to understand the pipeline

3. Read the target stage's CONTEXT.md to understand the contract

4. Delegate to the correct subagent based on stage type:
   - Research stages → use @researcher agent
   - Draft/writing stages → use @writer agent
   - Review/audit stages → use @reviewer agent
   - If unsure, read the stage's Role section to determine type

5. After the subagent completes, report back:
   - What was produced
   - Where it was saved
   - Any flags or gaps noted
   - Suggest: "Review the output, edit if needed, then run the next stage"

## Example Usage

```
/project:run-stage 01 my-workspace
/project:run-stage 02
/project:run-stage    (auto-detects next stage)
```
