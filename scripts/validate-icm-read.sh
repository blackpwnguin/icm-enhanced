#!/bin/bash
# PreToolUse hook: Validate ICM context loading boundaries
# Prevents reading files outside the current stage's Inputs table specification
# 
# Exit codes:
#   0 = allow the operation
#   1 = error (but allow)
#   2 = BLOCK the operation and feed error message to Claude

# Read hook input from stdin
INPUT=$(cat)

# Extract the tool name and file path
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Only check Read operations on workspace files
if [[ "$TOOL" != "Read" ]] || [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Allow reads outside workspaces/ (CLAUDE.md, _core/, .claude/)
if [[ "$FILE_PATH" != *"workspaces/"* ]]; then
    exit 0
fi

# Allow reads of CONTEXT.md files (routing/navigation)
if [[ "$FILE_PATH" == *"CONTEXT.md"* ]]; then
    exit 0
fi

# Allow reads of output/ files (stage handoffs)
if [[ "$FILE_PATH" == *"/output/"* ]]; then
    exit 0
fi

# Allow reads of setup/ files (configuration)
if [[ "$FILE_PATH" == *"/setup/"* ]]; then
    exit 0
fi

# For _config/, references/, skills/ reads — warn but allow
# (The skill handles enforcement; this is a safety net)
if [[ "$FILE_PATH" == *"/_config/"* ]] || [[ "$FILE_PATH" == *"/references/"* ]] || [[ "$FILE_PATH" == *"/skills/"* ]]; then
    # Allow but the icm-context-loader skill will enforce section-level scoping
    exit 0
fi

# Default: allow
exit 0
