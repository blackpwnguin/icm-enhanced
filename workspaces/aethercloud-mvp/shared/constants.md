# Shared Constants

## Project Metadata
- **Project name:** AetherCloud
- **Tagline:** The AI Business + Cloud Operating System
- **Version:** MVP Alpha
- **Timeline:** 28 days to investor-ready demo

## MVP Scope
- Natural language → real AWS deployment + ConnectWise ticket creation + SalesChain quote pull
- Multi-agent swarm: Planner → Architect → Executor → Safety
- Hybrid execution: AI does safe actions fully; restricted actions get walkthrough + human provides one credential → AI finishes
- Digital twin sandbox: dry-run simulation before production deploy
- Unified dashboard with audit log

## MVP Excludes (Phase 2)
- Azure and GCP (AWS only for MVP)
- Full billing consolidation
- Advanced self-healing
- Integration marketplace
- Multi-tenant enterprise features

## Tech Stack
- **Frontend:** Next.js 16, Vercel AI SDK (streaming chat + tool calling)
- **Agents:** LangGraph (stateful multi-agent), Python
- **Database:** Supabase (PostgreSQL + auth + storage)
- **Cloud APIs:** AWS SDK (boto3), Terraform for IaC generation
- **Integrations:** pyconnectwise (ConnectWise PSA), SalesChain REST API, e-Automate (read-only)
- **Hosting:** Vercel (frontend), Fly.io or Render (agent backend)
- **AI Model:** Claude API via Anthropic SDK

## Target Users
- MSPs (Managed Service Providers)
- Office equipment dealers / VARs
- Small companies wanting enterprise-grade cloud without enterprise-sized teams
- Non-technical founders and ops generalists

## Key Terminology
| Term | Definition |
|------|-----------|
| Hybrid execution | AI handles safe actions autonomously; restricted actions require human input of one credential then AI completes |
| Agent swarm | Multiple specialized AI agents (Planner, Architect, Executor, Safety) coordinating via LangGraph |
| Digital twin sandbox | Simulated environment that shows exact cost/performance/risk impact before touching production |
| Safety guardrails | Policy engine that blocks high-risk actions until human approval with plain-English explanation |
