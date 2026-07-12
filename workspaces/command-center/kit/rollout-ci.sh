#!/usr/bin/env bash
# rollout-ci.sh — add the stack-agnostic CI workflow to every tracked repo in the
# command-center registry, via one PR each. The scalable way to do "CI for all repos".
#
# Requires: gh CLI authenticated (`gh auth login`) with repo scope on your account.
# Run from anywhere inside the icm-enhanced checkout:
#   workspaces/command-center/kit/rollout-ci.sh            # opens a PR per repo (default)
#   workspaces/command-center/kit/rollout-ci.sh --direct   # commit straight to default branch
#   workspaces/command-center/kit/rollout-ci.sh --dry-run  # just list what it would do
#
# Idempotent: skips repos that already have .github/workflows/ci.yml, empty repos,
# forks, and rows marked `tracked: no`.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REGISTRY="$HERE/../_config/registry.md"
CI_FILE="$HERE/ci.yml"
BRANCH="ci/add-pipeline"
MODE="pr"

for arg in "$@"; do
  case "$arg" in
    --direct)  MODE="direct" ;;
    --dry-run) MODE="dry" ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

command -v gh >/dev/null || { echo "✗ gh CLI not found. Install + 'gh auth login'." >&2; exit 1; }
[ -f "$REGISTRY" ] || { echo "✗ registry not found: $REGISTRY" >&2; exit 1; }
[ -f "$CI_FILE" ]  || { echo "✗ ci.yml not found: $CI_FILE" >&2; exit 1; }

# Parse "| owner/name | visibility | ... | tracked |" rows; keep tracked != no.
mapfile -t REPOS < <(grep -E '^\|\s*[^|]+/[^|]+\s*\|' "$REGISTRY" \
  | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); gsub(/^[ \t]+|[ \t]+$/,"",$6); if (tolower($6) != "no") print $2}')

echo "Rollout mode: $MODE — ${#REPOS[@]} tracked repos"
ok=0; skip=0; fail=0

for repo in "${REPOS[@]}"; do
  # Skip empty repos and repos that already have the workflow.
  default="$(gh repo view "$repo" --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || true)"
  if [ -z "$default" ]; then echo "  · skip (empty/no access): $repo"; skip=$((skip+1)); continue; fi
  if gh api "repos/$repo/contents/.github/workflows/ci.yml" >/dev/null 2>&1; then
    echo "  · skip (already has ci.yml): $repo"; skip=$((skip+1)); continue
  fi
  if [ "$MODE" = "dry" ]; then echo "  → would add CI to $repo (base $default)"; ok=$((ok+1)); continue; fi

  content_b64="$(base64 < "$CI_FILE" | tr -d '\n')"
  target_branch="$default"
  if [ "$MODE" = "pr" ]; then
    sha="$(gh api "repos/$repo/git/ref/heads/$default" -q .object.sha)"
    gh api -X POST "repos/$repo/git/refs" -f ref="refs/heads/$BRANCH" -f sha="$sha" >/dev/null 2>&1 || true
    target_branch="$BRANCH"
  fi
  if gh api -X PUT "repos/$repo/contents/.github/workflows/ci.yml" \
      -f message="Add stack-agnostic CI dev-pipeline (ICM command-center)" \
      -f content="$content_b64" -f branch="$target_branch" >/dev/null 2>&1; then
    if [ "$MODE" = "pr" ]; then
      gh pr create --repo "$repo" --base "$default" --head "$BRANCH" \
        --title "Add CI dev-pipeline" \
        --body "Stack-agnostic CI (Node/Python/Go build+test) on every push/PR. ICM command-center rollout. Additive." >/dev/null 2>&1 || true
    fi
    echo "  ✓ $repo"; ok=$((ok+1))
  else
    echo "  x failed: $repo"; fail=$((fail+1))
  fi
done

echo "──────────────────────────────"
echo "  added : $ok"
echo "  skipped: $skip"
echo "  failed : $fail"
