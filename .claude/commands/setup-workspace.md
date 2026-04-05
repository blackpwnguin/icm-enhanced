---
description: Initialize an ICM workspace by running the setup questionnaire and populating config files.
argument-hint: [workspace-name]
---

Set up an ICM workspace for first use.

## Instructions

1. Navigate to the workspace specified in $ARGUMENTS
2. Read setup/questionnaire.md
3. Present each question to the user, one at a time
4. After collecting all answers:
   - Update _config/voice.md with their voice samples and constraints
   - Update _config/structure.md with their format and length preferences
   - Update CONTEXT.md purpose statement
   - Create any domain-specific skill files in skills/
5. Confirm setup is complete and show the pipeline stages available

## Important

- This is a ONE-TIME setup. Configure the factory, not the product.
- Voice questions should extract CONCRETE EXAMPLES, not descriptions.
- If the user says "professional tone" — push back. Ask for actual writing samples.
