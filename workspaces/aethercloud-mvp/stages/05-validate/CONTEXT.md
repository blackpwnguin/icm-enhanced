# Stage 05: Validate

## Role
You are a QA engineer, security auditor, and product marketer. You validate the MVP is investor-ready. You test, audit, and prepare the demo materials.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Working MVP | `../04-implement/output/aethercloud-app/` | Full directory | App to validate |
| Spec | `../02-spec/output/spec.md` | MVP Scope section | What should be working |
| Constants | `../../shared/constants.md` | Target Users section | Who we demo for |
| Voice | `../../_config/voice.md` | Full file | Demo tone |

## Process

1. **Functional Testing**
   - Run the demo prompt end-to-end: "Build a secure client quoting portal for our copier dealership that pulls quotes from SalesChain, creates tickets in ConnectWise, and hosts on AWS under $2k/mo"
   - Verify each agent fires in correct order
   - Verify safety agent blocks a restricted action
   - Verify hybrid execution flow completes
   - Test with 3 different prompt variations

2. **Security Audit**
   - No credentials in code, logs, or git history
   - API keys encrypted at rest (Supabase vault)
   - AWS IAM policies follow least-privilege
   - CORS, CSP, rate limiting configured
   - Input sanitization on all user-facing endpoints

3. **Demo Script**
   - 3-minute investor demo script (what to say, what to click, what they see)
   - Backup flows if live demo hits issues
   - Key talking points that map to investor concerns

4. **Pitch Deck Outline**
   - Problem (fragmented tools, 10-person teams)
   - Solution (one prompt = full deployment with safety)
   - Demo screenshot sequence
   - Market size ($20B+ cloud mgmt + $400B+ MSP)
   - Traction plan (3-5 beta MSPs)
   - Team + ask

5. **Beta Launch Prep**
   - Landing page content
   - Beta signup flow
   - Onboarding checklist for first 5 MSP customers

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Test report | `output/test-report.md` | Pass/fail matrix |
| Security audit | `output/security-audit.md` | Findings + fixes |
| Demo script | `output/demo-script.md` | 3-minute walkthrough |
| Pitch deck outline | `output/pitch-outline.md` | Slide-by-slide content |
| Beta launch plan | `output/beta-plan.md` | First 5 customers playbook |

## Audit

- [ ] Demo prompt produces a complete, correct response every time (3/3 runs)
- [ ] Zero credentials exposed in codebase or logs
- [ ] Security audit has zero critical findings
- [ ] Demo script is under 3 minutes and hits all key investor points
- [ ] Pitch outline covers problem, solution, market, traction, team, ask
- [ ] Beta plan names specific outreach channels (ConnectWise marketplace, MSP forums)
