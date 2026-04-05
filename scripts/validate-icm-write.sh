#!/bin/bash
# PostToolUse hook: Log writes to output/ and enforce file size limits
#
# Exit codes:
#   0 = success
#   1 = error (non-blocking)

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Only check Write operations to output directories
if [[ "$TOOL" != "Write" ]] || [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

if [[ "$FILE_PATH" != *"/output/"* ]]; then
    exit 0
fi

# Check line count
if [[ -f "$FILE_PATH" ]]; then
    LINES=$(wc -l < "$FILE_PATH")
    if [[ "$LINES" -gt 200 ]]; then
        echo "WARNING: $FILE_PATH is $LINES lines (recommended max: 200). Consider splitting."
    fi
    echo "ICM: Wrote $LINES lines to $FILE_PATH"
fi

exit 0
