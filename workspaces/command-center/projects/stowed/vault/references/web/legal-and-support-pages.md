---
project: stowed
type: reference
status: building
stage: 02-build
tags: [web, stowed]
updated: 2026-06-21
---

# Legal and support pages

Three static pages Apple requires a public home for. Drafted 2026-06-21,
deployed to Vercel at the apex. Raw files archived at
`_session-artifacts/2026-06-21-launch-prep/`. Source of record once placed in
the repo: the deployed web repo's `public/` directory.

## Pages

- **`privacy.html`** — Privacy Policy. Sections: who we are, information we
  collect, how we use it, sharing, retention, security, choices and rights,
  account deletion, children, changes, contact.
- **`terms.html`** — Terms of Use. Includes the Apple auto-renewable
  subscription disclosures. Sections: license, accounts and roles,
  subscriptions and billing, your data, acceptable use, availability,
  disclaimers, limitation of liability, termination, governing law, changes,
  contact.
- **`support.html`** — Support. Contact, common questions (FAQ), and the
  account-deletion steps Apple expects.

## Live URLs (target)

- `stowedapp.app/privacy.html`
- `stowedapp.app/terms.html`
- `stowedapp.app/support.html`

## Operating entity

The pages' company name and address are **Nihilo Solutions LLC** — Stowed is
not yet its own LLC (see `projects/stowed.md` › Business entity). When Stowed
spins out into its own entity, update the company name + address on these pages.

## Open items

- [ ] `privacy.html` — fill company mailing address placeholder (Nihilo Solutions LLC address).
- [ ] `terms.html` — fill governing law state placeholder.
- [ ] Confirm `support@stowedapp.app` is a monitored inbox (Apple may email it).
- [ ] Attorney review of privacy + terms (B2B product storing customer and
  financial data) — current drafts are solid starting points, not reviewed.
- [ ] Confirm the three URLs load on the live deployment.

These pages must be linked from both the app and the App Store metadata for a
subscription app. See [[ship-readiness]].
