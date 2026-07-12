---
project: stowed
type: reference
status: building
stage: "-"
tags: [ios, stowed]
updated: 2026-06-11
---

# Screen inventory (UI phase)

Every screen that exists today. One line each. The app runs in the simulator against the Northbeam Coffee Co. mock store with no backend.

| Screen | Notes |
|---|---|
| Welcome | Create-a-business, Join-a-company, plus three portal previews |
| Owner account setup | Name, email, password (mock) |
| Business setup | Company name; creates the Org |
| Company code share | Displays the generated company code for the new owner |
| Join code entry | Validates the code against the Store |
| Join account setup | Name, email, password (mock); submits the join request |
| Pending approval | Waiting room; auto-routes the employee in once the owner approves |
| Tab bar | Role-aware; tabs change per Employee, Manager, Owner |
| Home dashboard | Different metrics per role |
| Inventory list | Quantities per product |
| Product detail | Price editing visible to Manager and Owner only |
| Scan | Placeholder; camera scanner is a later stage |
| Orders list | Pipeline status per order |
| Order detail | Tap to advance through draft, confirmed, packed, shipped, completed |
| Create order | Customer-specific pricing resolves per customer at line creation |
| Customers list | Per-customer summary |
| Customer detail | Owner sees balances and store credit |
| Money | Owner only: payments, receivables, expenses, profit |
| Team | Owner only: members and join-request approval |
| Payroll | Owner only: employee cost tracking |
| More | Role-gated menu |
| Settings | Portal switcher and sign out |

Financial math is real against the mock data. Net profit is gross profit minus expenses minus labor, as the schema describes.

For who can do what, see [[roles-and-permissions]]. For the data behind the screens, see [[data-model]].
