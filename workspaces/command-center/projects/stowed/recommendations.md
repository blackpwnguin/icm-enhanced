# stowed — Recommendations backlog

From the **2026-07-03 full product review** (`../../../..` → repo `docs/full-product-review-2026-07-03.md`)
and the vault roadmap. P0 = fix before public launch. Deduped by title.

| Priority | Recommendation | Domain | Rationale | Added | Status |
|----------|----------------|--------|-----------|-------|--------|
| P0 | Rotate + env-var all edge-function secrets; constant-time HMAC compare | security | forged webhooks → free Pro | 2026-07-12 | open |
| P0 | `set_order_status`: add state machine + role gate | backend | replayable stock corruption | 2026-07-12 | open |
| P0 | `place_order`: derive price server-side (don't trust client) | backend | $0 orders corrupt finances | 2026-07-12 | open |
| P0 | `receive_stock`: write to `stock_ledger` | backend | audit trail incomplete | 2026-07-12 | open |
| P0 | Revoke anon EXECUTE on RPCs; enable leaked-password protection; auth+rate-limit `lookup_org_by_code` | security | defense-in-depth / enumeration | 2026-07-12 | open |
| P0 | Account deletion + password change in Settings | ios | App Store 5.1.1(v) rejection risk | 2026-07-12 | open |
| P0 | Strip demo/mock paths + dev copy reachable by users | ios | data-integrity / trust | 2026-07-12 | open |
| P0 | Fix website contradiction, card claim, competitor claims (W1–W3) | web | legal/deceptive-pricing risk | 2026-07-12 | open |
| P1 | Orders → `List` (fixes dead swipe actions + perf) | ios | A1 | 2026-07-12 | open |
| P1 | Pagination on orders/payments (keyset) | ios | multi-second loads at scale | 2026-07-12 | open |
| P1 | ID-based receivables end-to-end (not name-match) | ios | finances split on rename | 2026-07-12 | open |
| P1 | Offline minimum: cached snapshot + connectivity banner + visible errors | ios | #1 product risk (warehouse) | 2026-07-12 | open |
| P1 | Universal Links replacing `stowed://`; server-side comp list | ios/security | token interception | 2026-07-12 | open |
| P1 | Server-side invoice PDF; checkout metadata instead of email matching | backend | tampered PDF / missed entitlement | 2026-07-12 | open |
| P2 | CSV import/export | product | biggest onboarding blocker | 2026-07-12 | open |
| P2 | Expose audit log / stock ledger / order-status history; member role UI | ios | B2B completeness | 2026-07-12 | open |
| P2 | Waitlist form + social proof on site | web | highest-ROI site change | 2026-07-12 | open |

Full detail and week-by-week plan: `vault/references/product/roadmap.md`,
`vault/stages/04-ship/ship-readiness.md`, and the repo product review.
