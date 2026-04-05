# Stage 04: Implement

## Role
You are a senior full-stack engineer. You implement the MVP features from the scaffold. You build working code. You do not redesign the architecture.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Scaffold | `../03-scaffold/output/aethercloud-app/` | Full directory | Codebase to build on |
| Spec | `../02-spec/output/spec.md` | Full file | What to build |
| Agent graph | `../02-spec/output/agent-graph.md` | Full file | Agent logic spec |
| Constants | `../../shared/constants.md` | Tech Stack section | Framework APIs |

## Process

Build in this order (each is a sub-task that can be a subagent):

1. **Auth + onboarding flow**
   - Supabase SSO login
   - Cloud account connection wizard (AWS IAM role delegation)
   - ConnectWise + SalesChain API key input + validation
   - Credential vault (encrypted, scoped, never store full creds)

2. **Chat UI + streaming**
   - Vercel AI SDK chat interface with streaming responses
   - Tool call visualization (show what agents are doing)
   - Architecture diagram rendering (from agent output)
   - Cost estimate display

3. **Agent swarm implementation**
   - Planner Agent: parse user intent → recommend architecture
   - Architect Agent: generate Terraform + integration config
   - Executor Agent: call AWS SDK + ConnectWise + SalesChain APIs
   - Safety Agent: risk classification → block/approve/walkthrough
   - LangGraph state machine with conditional routing

4. **AWS integration**
   - STS AssumeRole for secure credential delegation
   - EC2, S3, RDS, Lambda, CloudFront provisioning via boto3
   - Terraform plan generation + dry-run
   - Resource status polling + dashboard feed

5. **ConnectWise + SalesChain integration**
   - pyconnectwise: ticket creation, company lookup, service board ops
   - SalesChain: quote retrieval, order sync, webhook listener
   - Data flow: SalesChain quote → AetherCloud → ConnectWise ticket + AWS deploy

6. **Sandbox simulation**
   - Terraform plan (dry-run) output parser
   - Cost estimation from AWS pricing API
   - Risk assessment display
   - "Apply" button with safety confirmation

### Checkpoint
After step 3 (agent swarm), demonstrate the full prompt-to-plan flow to human. Ask: "Does the agent output match what you'd expect from the demo prompt?"

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Working MVP | `output/aethercloud-app/` | Full running application |
| Integration test results | `output/test-results.md` | Pass/fail for each integration |

## Audit

- [ ] Chat accepts the demo prompt and produces an architecture recommendation
- [ ] Safety agent blocks at least one restricted action and provides walkthrough
- [ ] Hybrid execution works: AI asks for credential → user provides → AI completes
- [ ] ConnectWise ticket creation works with real API (dev/sandbox account)
- [ ] SalesChain quote pull works with real API
- [ ] AWS deploy works in dry-run mode (Terraform plan without apply)
- [ ] Dashboard shows resources, cost estimate, and audit log
- [ ] No hardcoded credentials anywhere in codebase
