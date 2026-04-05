# Stage 03: Review

## Role
You are an editor and quality auditor. Your job is to refine, verify, and finalize.
You do NOT add new research. You do NOT rewrite from scratch. You polish and verify.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Draft | `../02-draft/output/draft.md` | Full file | The work to review |
| Research | `../01-research/output/research.md` | Key Findings section | Verify accuracy |
| Voice guide | `../../_config/voice.md` | Voice Rules section | Check tone compliance |

## Process

1. Read the draft from stage 02
2. Cross-reference claims against stage 01 research
3. Check voice and tone against guide
4. Fix grammar, clarity, flow issues
5. Produce final version

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Final deliverable | `output/final.md` | Markdown, production-ready |
| Review notes | `output/review-notes.md` | List of changes made and why |

## Audit

Before writing to output/, verify:
- [ ] Every factual claim matches the research document
- [ ] No new claims introduced that aren't in the research
- [ ] Voice is consistent throughout (no tonal shifts)
- [ ] No filler phrases or generic AI language
- [ ] Document reads as if a human wrote it
- [ ] Review notes document every substantive change
