# Workspace: aethercloud-mvp

## Purpose
Build a production-ready MVP of AetherCloud — the AI Business + Cloud Operating System — in 3-4 weeks. Natural language prompts deploy real multi-cloud infrastructure + ConnectWise + SalesChain integrations with safety guardrails and hybrid execution.

## Pipeline

| Stage | Folder | Job | Output |
|-------|--------|-----|--------|
| 01 | `stages/01-research/` | Market validation, competitor gaps, exact API specs | research.md |
| 02 | `stages/02-spec/` | Full architecture, agent swarm design, safety model | spec.md |
| 03 | `stages/03-scaffold/` | Generate complete codebase skeleton | working repo structure |
| 04 | `stages/04-implement/` | Build chat UI, agents, integrations, sandbox | feature-complete MVP |
| 05 | `stages/05-validate/` | Test, security audit, demo script, pitch deck | validated-mvp/ |

## Entry Point
Start at stage 01. Read its CONTEXT.md. Do not skip stages.

## Configuration
- Voice/structure: `_config/`
- Project constants: `shared/`
- Domain skills (AWS, ConnectWise, SalesChain): `skills/`

## Tech Stack (Locked for MVP)
- Frontend: Next.js 16 + Vercel AI SDK
- Agents: LangGraph (stateful multi-agent orchestration)
- Database/Auth: Supabase (PostgreSQL + auth + RLS)
- Cloud: AWS SDK (boto3) — Azure/GCP in Phase 2
- Integrations: ConnectWise PSA REST API, SalesChain Open API, e-Automate (read-only)
- Hosting: Vercel (frontend) + Fly.io or Render (agent backend)
- AI Models: Claude API (reasoning + tool use)
