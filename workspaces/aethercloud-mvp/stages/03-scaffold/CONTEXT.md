# Stage 03: Scaffold

## Role
You are a senior full-stack developer. You generate the complete project skeleton from the spec. You create the structure and boilerplate. You do not implement business logic.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Spec | `../02-spec/output/spec.md` | Architecture section | System design |
| Schema | `../02-spec/output/schema.sql` | Full file | Database structure |
| Agent graph | `../02-spec/output/agent-graph.md` | Full file | Agent node definitions |
| Constants | `../../shared/constants.md` | Tech Stack section | Framework versions |

## Process

1. **Frontend scaffold** — Next.js 16 project:
   - App router structure (pages, layouts, components)
   - Chat UI component shell (Vercel AI SDK useChat hook)
   - Dashboard layout shell
   - Auth pages (Supabase SSO)
   - Tailwind + shadcn/ui config

2. **Agent backend scaffold** — Python project:
   - LangGraph state graph skeleton (all nodes defined, empty implementations)
   - Tool definitions for AWS, ConnectWise, SalesChain (typed, empty bodies)
   - FastAPI or Flask endpoints for frontend ↔ agent communication
   - Credential vault service skeleton

3. **Database scaffold** — Supabase:
   - Migration files from schema.sql
   - Row-level security policies
   - Seed data for development

4. **Infrastructure scaffold**:
   - Dockerfile for agent backend
   - vercel.json for frontend
   - Environment variable templates (.env.example)
   - GitHub Actions CI stub

5. **Generate file tree** — Document the complete repo structure

### Checkpoint
After step 2, present the LangGraph skeleton to human. Ask: "Does this node structure match the spec? Any agents to add or merge?"

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Complete repo | `output/aethercloud-app/` | Full project directory |
| File tree doc | `output/file-tree.md` | Tree view of every file + one-line description |

## Audit

- [ ] Frontend runs with `npm run dev` (even if pages are empty shells)
- [ ] Agent backend runs with `python main.py` (even if agents return stubs)
- [ ] Every file from the spec's architecture section has a corresponding file
- [ ] No business logic implemented — stubs and TODOs only
- [ ] .env.example lists every required environment variable
- [ ] README.md with setup instructions exists
