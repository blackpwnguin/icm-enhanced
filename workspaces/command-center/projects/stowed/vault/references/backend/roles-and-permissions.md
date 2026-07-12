---
project: stowed
type: reference
status: spec
stage: "-"
tags: [security, ios, stowed]
updated: 2026-06-11
---

# Roles and permissions

Three roles. Collapsed from an earlier five-role draft to match Ish's breakdown exactly. The matrix below is the source of truth for both UI gating and database policies.

Permissions are enforced in two layers. The app UI hides what a role cannot do. The database enforces the same matrix through Row Level Security and function-level policies. The client gate is for the interface only; the server is the real enforcement. This is the load-bearing point of [[platform-shared-responsibility]].

## Employee

- Scan stock in by barcode.
- See inventory and stock levels.
- Build orders and pick the customer.
- Move orders through the pipeline: confirmed, packed, shipped, completed.
- Cannot set prices. Cannot see any financials.

## Manager

- Everything an Employee can do.
- Set product base prices.
- Set and edit customer-specific prices.
- Manage customer records.
- Cannot see company financials or payroll.

## Owner

- Everything a Manager can do.
- Hire and remove workers. Change roles.
- Approve warehouse join requests.
- See all financials: revenue, gross profit, net profit.
- Track per-customer balances and store credit.
- Track expenses and employee costs (payroll).
- Set prices.
- The only role that can delete the organization.

## Enforcement

- UI: each role file in Swift hides views and disables actions the role lacks. `Role+Capabilities.swift` is the client-side gate.
- Database: every capability above has a matching RLS or function-level policy. Price setting is restricted to Manager and Owner inside the database itself. Warehouse approvals are server-side state changes a user cannot perform on themselves.

Audit log records every privileged action (price changes, join approvals, payroll access). See [[data-model]] for the schema, [[platform-shared-responsibility]] for the rationale.
