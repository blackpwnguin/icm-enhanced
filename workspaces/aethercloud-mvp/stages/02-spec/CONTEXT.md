# Stage 02: Technical Specification

## Role
You are a senior solutions architect. You transform research into a buildable technical spec. You design. You do not code.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Research | `../01-research/output/research.md` | Full file | Market data + API specs |
| Constants | `../../shared/constants.md` | Tech Stack section | Stack decisions |
| Voice | `../../_config/voice.md` | Constraints section | Keep spec crisp |
| Structure | `../../_config/structure.md` | Format section | Document structure |

## Process

1. **System Architecture** — Design:
   - Frontend: Next.js app structure, chat UI components, dashboard layout
   - Backend: LangGraph agent graph (nodes, edges, state schema, tool definitions)
   - Database: Supabase schema (users, projects, deployments, audit_logs, credentials_vault)
   - API layer: REST/tRPC endpoints between frontend and agent backend

2. **Agent Swarm Design** — Specify each agent:
   - Planner Agent: receives user prompt → outputs architecture recommendation
   - Architect Agent: receives plan → outputs IaC templates + integration configs
   - Executor Agent: receives approved plan → calls AWS SDK + ConnectWise + SalesChain APIs
   - Safety Agent: intercepts all actions → classifies risk → blocks or approves
   - Define the LangGraph state graph (nodes, conditional edges, checkpoints)

3. **Safety & Hybrid Execution Model** — Specify:
   - Risk classification rules (what's safe vs restricted vs blocked)
   - Mode A flow: full AI autonomy (safe actions)
   - Mode B flow: AI walkthrough → human provides credential → AI completes
   - Policy engine: company rules + compliance standards (SOC2, HIPAA, GDPR)

4. **Integration Architecture** — For each:
   - AWS: credential delegation (STS AssumeRole), least-privilege IAM policies
   - ConnectWise: API key management, webhook subscriptions, ticket workflow
   - SalesChain: OAuth flow, quote data model, order sync webhook
   - Data flow diagrams for the demo scenario (quote → ticket → deploy)

5. **MVP Scope Contract** — Exact list of what ships in 28 days vs what's Phase 2

### Checkpoint
After step 2 (agent swarm design), present the LangGraph state graph to human. Ask: "Does this agent flow match your vision for the demo?"

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Technical spec | `output/spec.md` | Sections: Architecture, Agent Swarm, Safety Model, Integrations, MVP Scope |
| Database schema | `output/schema.sql` | PostgreSQL DDL for Supabase |
| Agent graph | `output/agent-graph.md` | LangGraph node/edge specification |

## Audit

- [ ] Every component has a clear owner (frontend/backend/agent/database)
- [ ] Agent swarm has defined inputs, outputs, and handoff conditions for each node
- [ ] Safety model covers all three modes (safe/restricted/blocked) with examples
- [ ] Integration specs include auth flow, key endpoints used, and error handling
- [ ] MVP scope is explicit about what's in and what's out
- [ ] Spec is buildable — a developer could start coding from this document alone
- [ ] Under 1000 lines total across all output files
