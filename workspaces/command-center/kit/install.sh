#!/usr/bin/env bash
# ICM Field-Agent kit installer. Run from the root of a repo you want tracked.
set -euo pipefail

HUB_RAW="https://raw.githubusercontent.com/blackpwnguin/icm-enhanced/master/workspaces/command-center/kit"

[ -d .git ] || { echo "✗ Run from the root of a git repo." >&2; exit 1; }

echo "→ Installing ICM Field-Agent kit into $(basename "$PWD")"
mkdir -p .icm/outbox .github/workflows

fetch() { if command -v curl >/dev/null; then curl -fsSL "$HUB_RAW/$1" -o "$2"; else wget -qO "$2" "$HUB_RAW/$1"; fi; }

fetch ".icm/CONTEXT.md"     .icm/CONTEXT.md
fetch ".icm/field-agent.md" .icm/field-agent.md
fetch "icm-relay.yml"       .github/workflows/icm-relay.yml
: > .icm/outbox/.gitkeep

cat <<'EOF'
✓ Installed: .icm/CONTEXT.md, .icm/field-agent.md, .github/workflows/icm-relay.yml
Next:
  1. Add repo secret ICM_RELAY_TOKEN (PAT with contents+pull_requests write on
     blackpwnguin/icm-enhanced) so the relay can open PRs on the hub.
  2. Commit these files.
  3. Pre-register this repo in the hub's _config/registry.md, or it registers on its
     first report.
EOF
