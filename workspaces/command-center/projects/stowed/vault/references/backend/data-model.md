---
project: stowed
type: reference
status: building
stage: 02-build
tags: [security, ios, stowed]
updated: 2026-06-12
---

# Data model

This note distills the data model. As of 2026-06-12 the schema is applied
to Supabase project `arqkutfkziicuxfesghm`; [[schema-applied]] is now the
authoritative shape, this is the summary. The earlier `~/Downloads/`
draft documents are superseded.

The security model that wraps every table below is documented in
[[platform-shared-responsibility]]. Stowed holds tenant financial data,
so the RLS and Edge Function patterns there are load-bearing. The applied
RLS is in [[rls-policies]] and the privileged-write API is in
[[rpc-functions]].

## Tables (16)

- `organizations`
- `user_profiles`
- `memberships`
- `locations`
- `products`
- `stock_levels`
- `stock_ledger`
- `customers`
- `customer_pricing`
- `orders`
- `order_items`
- `order_status_history`
- `payments`
- `expenses`
- `employee_costs`
- `audit_log`  (append-only, owner-readable, written only by SECURITY DEFINER RPCs)

## Views (2)

- `customer_balances`: receivables and store credit. A negative balance is store credit.
- `gross_profit_by_org`: live gross profit roll-up per tenant.

## Key design choices

### Tenancy

The organization is the tenant boundary. Row Level Security keeps each warehouse fully separated. Permissions are also enforced at the role layer inside the database (see [[roles-and-permissions]]); the client only hides UI.

### Signup

New users join an organization by entering a warehouse code. The membership stays pending until the Owner approves the request. No data is visible until approval.

### Customer-specific pricing

Resolution order: look up the customer-specific price first, fall back to the product base price. The resolved unit price and unit cost are snapshotted onto the order line at the moment the order is created, so historical orders do not rewrite when prices change later.

### Order pipeline

Orders move through `draft -> confirmed -> packed -> shipped -> completed`, plus `cancelled` as an off-path state. Stock decrements at the `confirmed` transition. `order_status_history` is the audit trail of who moved an order and when.

### Financials

Receivables, store credit, gross profit, and net profit are computed live from the tables through the two views. Net profit shown in the UI is gross profit minus expenses minus labor; the `employee_costs` table feeds the labor side.

### Audit

An append-only log records who changed a price, approved a join, or accessed payroll, with actor, action, target, and timestamp. No role can edit or delete it. The append-only invariant is enforced server-side. See [[platform-shared-responsibility]].
