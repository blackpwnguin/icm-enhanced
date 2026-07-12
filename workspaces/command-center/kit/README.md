# kit — drop-in Field Agent for any repo

Attaches the ICM Field Agent + relay to a target repo so its changes flow back to the
command-center and get filed by the Curator.

## Installs (into the target repo)
```
.icm/
  CONTEXT.md          how to report from this repo
  field-agent.md      the Field Agent manual
.github/workflows/
  icm-relay.yml        on push to main → draft report → PR it to the hub
  ci.yml               (optional) portable CI: auto-detects Node/Python/Go, build+test
```

Copy `ci.yml` from this kit into the target repo's `.github/workflows/` to give any
project the same CI dev-pipeline. It's stack-agnostic and additive.

## Install (from inside the target repo)
```bash
curl -fsSL https://raw.githubusercontent.com/blackpwnguin/icm-enhanced/master/workspaces/command-center/kit/install.sh | bash
```
Or copy `.icm/` and `icm-relay.yml` in by hand.

## Prerequisite
The relay opens a PR on the **private** hub, so add a repo secret `ICM_RELAY_TOKEN`
(fine-grained PAT with `contents`+`pull_requests` write on `blackpwnguin/icm-enhanced`).
Without it, reports still write to `.icm/outbox/`; they just aren't auto-delivered.

## Flow
Field Agent edits → emits a report → (Action) opens a PR adding it to
`workspaces/command-center/stages/01-intake/output/` → merge → `/project:file-report`
runs the Curator → filed into `projects/<repo>/`.
