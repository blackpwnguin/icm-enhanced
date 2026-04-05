# Stage 01: Research

## Role
You are a market research analyst and technical API researcher. You gather data. You do not design or build.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Project scope | `../../shared/constants.md` | Full file | MVP scope and tech stack |
| Voice | `../../_config/voice.md` | Constraints section | Output tone |

## Process

1. **Market Landscape** — Document current state of:
   - Multi-cloud management platforms (DuploCloud, Firefly, StackGen, CoreStack, CloudBolt)
   - MSP automation tools (ConnectWise Sidekick/zofiQ, Atera, SuperOps, MSPBots)
   - Agentic AI infrastructure (IBM watsonx, AWS Q, Azure Copilot, Google Vertex)
   - What each does, what each misses, pricing where available

2. **API Specifications** — Research and document for each:
   - **AWS SDK (boto3):** Auth (IAM roles, STS), key MVP services (EC2, S3, RDS, Lambda, CloudFront, VPC, IAM), Terraform provider capabilities
   - **ConnectWise PSA REST API:** Auth (client ID + keys), base URL pattern, ticket CRUD, company/contact management, service board operations, rate limits
   - **SalesChain Open API:** Auth method, quote retrieval, order sync, webhook endpoints, data models
   - **e-Automate:** Available integration points, API or SDK availability, read-only scope for MVP
   - **Supabase:** Auth flows (OAuth, SSO), RLS patterns for multi-tenant

3. **Technical Feasibility** — Validate that these work together:
   - LangGraph multi-agent orchestration patterns (state graphs, tool calling, handoffs)
   - Vercel AI SDK streaming + tool use (useChat, streamText, tool results)
   - Terraform generation + plan/apply simulation (dry-run approaches)
   - Credential vault patterns (never store full creds, scoped delegation)

4. **Competitor Gap Matrix** — Table showing features across 8+ competitors vs AetherCloud

### Checkpoint
After completing steps 1-2, present findings. Ask: "Does this cover the right market angle? Any verticals or APIs to add?"

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Research document | `output/research.md` | Sections: Market Landscape, API Specs, Technical Feasibility, Competitor Matrix, White Space |

## Audit

- [ ] Every market claim has a source or is flagged as assumption
- [ ] API specs include: auth method, base URL, key endpoints, rate limits, SDK availability
- [ ] Competitor matrix covers at least 8 players with feature columns
- [ ] Gap analysis clearly shows what NO existing tool does that AetherCloud will
- [ ] No architecture or design decisions (that's stage 02)
- [ ] Under 600 lines
