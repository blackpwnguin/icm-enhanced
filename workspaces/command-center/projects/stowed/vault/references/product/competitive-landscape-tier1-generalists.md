---
project: stowed
type: reference
status: research
stage: "-"
tags: [stowed, competitive, product]
updated: 2026-06-16
---

# Competitive landscape: Tier 1 generalist deep-dives

Spoke of [[competitive-landscape]]. Deep-dives on the broad-market tier-1
tools: Cin7 Core, Sortly, inFlow, Katana, and Zoho.

## Tier 1 deep-dives

### Cin7 Core (formerly DEAR Inventory)

**Target and price.** Aimed at small-to-mid distributors, wholesalers, and light manufacturers. Pricing runs $349/month (Standard, 5 users), $599 (Pro, 10 users), $999 (Advanced, 15 users). Annual commit only; add-on modules are separately licensed on annual terms even if you need them for one month.

**Onboarding.** Account setup is web-first. The company owner creates an organization, configures warehouse locations and item catalog, then invites teammates by email. There is no join code; new users receive email invitations with role pre-assigned by the admin. Non-trivial setups typically require 3-6 months per Capterra reviewers. A paid implementation package is functionally mandatory for anything beyond a basic catalog.

**Inventory entry.** CSV import, manual entry, and barcode scanning via the WMS mobile app. The mobile app handles barcode-based receiving and pick-pack-ship but is not the primary configuration surface.

**Order pipeline.** Sales orders move through: Draft -> Authorized -> Picked -> Packed -> Shipped -> Fulfilled. "Draft" allows editing; "Authorize" locks the order and triggers stock allocation. Each pick/pack/ship stage requires explicit authorization, which can be done via the web or mobile WMS app. The web UI exposes all stages; the mobile app surfaces the warehouse-facing stages (pick, pack, ship) and has had reported bugs on partial-line-item orders.

**Customer pricing.** Supports multiple price lists and per-customer pricing tiers. You can assign a default price list to a customer record and override at the order line level.

**Team and roles.** Role-based permissions with module-level granularity (view/create/edit/delete per module). Standard roles exist; custom roles are configurable. User counts are tier-gated.

**Mobile vs. web.** Web is primary for setup, reporting, and purchasing. Mobile (iOS/Android) is warehouse-facing, not a full-featured substitute. The mobile app receives consistent complaints about limited bulk actions and a UI that reviewers describe as "SAP from 2008."

**AI and analytics.** No notable AI feature placement. Standard reports and a basic dashboard. No forecasting or chatbot.

**Common complaints.** UI feels dated and non-intuitive. Cancellation is deliberately hard to find. Surprise charges after cancellation. Paid implementation on top of monthly fee. Mobile app is incomplete for management tasks.

### Sortly

**Target and price.** Solo operators to small teams, very SMB-focused. Free tier (100 entries), then $24-$99/month depending on item count and user seats. Price scales sharply with items and users.

**Onboarding.** Email invite-based. Admin creates an account, sets up folders/categories, and invites users by email. No join code. Visual-first setup: drag items into folders, attach photos. Most reviewers say they were operational within a day.

**Inventory entry.** Manual entry, CSV import, QR code and barcode scanning via iPhone camera (no dedicated hardware assumed). Photo-based item tracking is Sortly's signature feature.

**Order pipeline.** Sortly does not have an order pipeline. It is a pure inventory tracking tool, not an OMS. No draft/confirmed/shipped flow. This is a fundamental capability gap.

**Customer pricing.** Not supported. No customer records, no price lists.

**Team and roles.** Granular user permissions available on paid tiers. Free tier is single-user. Roles are configured per-user, not via named role templates.

**Mobile vs. web.** Mobile-first. The iOS app is the primary working surface, with the web app as an admin companion. Offline mode is supported.

**AI and analytics.** None advertised.

**Common complaints.** No purchase orders, no order management, no accounting integration, no dual-price fields (cost vs. sell price). Custom reports gated behind top tier. Can lag with large item counts. Steep price per additional report.

### inFlow Inventory

**Target and price.** Small-to-mid wholesalers and distributors, explicitly marketed to wholesale use cases. Pricing starts around $110/month (Entrepreneur, 2 users) to $999/month (Mid-Size, 10 users), billed monthly; 20% off annually. A mandatory paid onboarding package ($499 base) is required on signup.

**Onboarding.** Email invite. Admin creates the company account, configures products and customers, then invites teammates. An optional B2B showroom (online catalog) lets customers self-serve orders without any app install.

**Inventory entry.** Manual, CSV import, barcode scanning via the inFlow Stockroom companion mobile app (iPhone camera or Bluetooth scanner). Stockroom is designed to run on a cheap Android device or tablet as a dedicated scan station.

**Order pipeline.** Sales orders move through: Quote -> Order -> Pick -> Pack -> Ship -> Closed. The web app and iOS app both show the full pipeline. The Stockroom app surfaces just the pick-and-pack steps. Per-customer B2B portals let customers place orders that come in as drafts for review.

**Customer pricing.** First-class feature. You can define multiple pricing schemes (wholesale, retail, VIP) and assign them to customer records. Price list is applied automatically at order creation. Line-level overrides are supported. Private online catalogs per customer show only their applicable products and prices.

**Team and roles.** Customizable access rights per user, not just named tiers. Each user's modules and actions can be configured independently.

**Mobile vs. web.** Web is primary for order management and reporting. Stockroom mobile app is purpose-built for warehouse tasks. Main iOS/Android app supports inventory lookup and basic order review.

**AI and analytics.** No advertised AI features. Standard reporting.

**Common complaints.** User count caps per plan create friction as teams grow. Mandatory onboarding fee is a surprise for small buyers. Reporting is functional but not flexible.

### Katana MRP

**Target and price.** Makers, light manufacturers, and product businesses that need bill-of-materials management alongside inventory. Core plan at $299/month (billed monthly) for 1 location, unlimited SKUs. Add-ons are aggressive: barcode/scanning features cost extra ($99/month WMS add-on), as does demand planning ($199/month). Mandatory onboarding fees range from $999-$2,000+ depending on tier.

**Onboarding.** Email invite. The setup wizard walks through products, BOMs, and locations. Onboarding is praised as intuitive for manufacturing setups but heavy for pure wholesale use.

**Inventory entry.** Manual, CSV, barcode scanning (via the paid WMS add-on). The barcode feature being paywalled behind an add-on is a recurring complaint.

**Order pipeline.** Sales orders: Draft -> Confirmed -> In Progress (picking) -> Shipped -> Completed. Manufacturing-centric variant: Sales Order -> Manufacturing Order -> Done. The UI is kanban-influenced with drag-to-advance order cards, which reviewers like.

**Customer pricing.** Supported. Price lists assignable per customer.

**Team and roles.** Unlimited users included at all paid tiers (a genuine differentiator vs. per-seat competitors). Role configuration is module-level.

**Mobile vs. web.** Web-primary. Mobile app exists for iOS/Android but is thin; warehouse operations rely on the WMS add-on via mobile browser or the app.

**AI and analytics.** No chatbot. The Planning and Forecasting add-on ($199/month) provides demand forecasting based on historical sales, but it lives in a dedicated "Planning" section, not inline.

**Common complaints.** Aggressive add-on model: scanning, forecasting, and warehouse features that most users assume are bundled are separately paid. "Bait and switch" pricing complaints are the most common theme on G2 and Capterra. Pricing has increased significantly for long-term customers.

### Zoho Inventory

**Target and price.** SMBs already in the Zoho ecosystem (CRM, Books, etc.). Priced by monthly order volume rather than users. Free tier for very small volumes; paid plans from approximately $29-$249/month depending on order count. Additional users at $7.50/user/month.

**Onboarding.** Email invite into the Zoho organization. If the business already uses Zoho CRM or Books, inventory connects via shared auth. New businesses go through a wizard covering warehouse locations, items, and tax settings. Zoho offers a free 2-hour "Jumpstart Lite" onboarding session.

**Inventory entry.** Manual, CSV, barcode scanning (iPhone camera supported). Integrates with Zoho's broader product catalog.

**Order pipeline.** Sales orders: Draft -> Confirmed -> Packed -> Shipped -> Invoiced. Zoho separates the financial step (invoicing) from the physical step (shipping) more explicitly than most. Order approval workflows are configurable by role.

**Customer pricing.** Price lists supported. Assignable per customer with automatic application at order time. Zoho CRM integration allows price list to inherit from CRM contact segment.

**Team and roles.** Robust module-level permission system. Admin has unrestricted access. Custom roles can restrict view/create/edit/delete per module (Contacts, Items, Sales, Purchases, Reports, Settings). Warehouse-level access control is also configurable.

**Mobile vs. web.** Web-primary for configuration. iOS and Android apps cover order management, inventory lookup, contacts, invoicing, and basic reports. The mobile experience is more complete than most competitors but still secondary.

**AI and analytics.** Zia (Zoho's cross-platform AI) integrates with Zoho Analytics for demand forecasting, anomaly detection, and conversational queries. This lives outside Zoho Inventory in the Zoho Analytics module, accessed via a separate tab or app. Predictive AI models are available but require the Analytics subscription. Within Inventory itself, AI features are minimal; Zia surfaces as a small assistant button that offers pre-built report suggestions rather than a full chatbot.

**Common complaints.** Feature depth is locked behind higher tiers. Third-party integrations are fewer than competitors. Support response times lag for non-US time zones (24/5 only). Can feel overwhelming to configure for teams not already familiar with Zoho.
