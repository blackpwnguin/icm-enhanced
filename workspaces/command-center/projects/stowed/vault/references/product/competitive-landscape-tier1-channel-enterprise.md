---
project: stowed
type: reference
status: research
stage: "-"
tags: [stowed, competitive, product]
updated: 2026-06-16
---

# Competitive landscape: Tier 1 channel and enterprise deep-dives

Spoke of [[competitive-landscape]]. Deep-dives on the channel-commerce and
enterprise tier-1 tools: Veeqo, Brightpearl, and Fishbowl.

## Tier 1 deep-dives (continued)

### Veeqo

**Target and price.** E-commerce sellers managing multi-channel shipping (Amazon, Shopify, eBay, Walmart). Free core tier (shipping, inventory, unlimited users and shipments); $250/month Priority tier for high-volume operations. Acquired by Amazon in 2021, which explains the free tier subsidization.

**Onboarding.** Email invite. Setup focuses on connecting sales channels (Amazon Seller Central, Shopify, etc.) before configuring products. Channel-first rather than catalog-first.

**Inventory entry.** Pulled automatically from connected channels; manual entry supported. Barcode scanning for pick-pack-ship via the mobile app.

**Order pipeline.** Orders arrive from channels as Pending, move to Picking (digital pick list on mobile or paper), then Packed, then Shipped. The digital picking flow on mobile is well-regarded: scan item barcodes to confirm picks, tote-based batching for multi-line orders.

**Customer pricing.** Not a first-class feature; Veeqo is channel-driven. Pricing is managed in the source channel (Amazon, Shopify) rather than in Veeqo.

**Team and roles.** Unlimited users. Role configuration covers order processing and shipping; it is not granular for financial or catalog management.

**Mobile vs. web.** More balanced than most. The mobile app handles warehouse operations well. Web handles reporting and channel management.

**AI and analytics.** Demand forecasting built in (claimed 94% accuracy based on 12 months of sales trends). This lives in the Analytics tab as a "Forecasting" sub-section, surfaced as a report-style view with a recommended reorder quantity per SKU. No chatbot.

**Common complaints.** Not suited for pure wholesale (no B2B pricing, no customer-specific catalogs). Amazon ownership creates concern about data use among non-Amazon sellers. Limited support for businesses that aren't channel-commerce-driven.

### Brightpearl

**Target and price.** Mid-market retail and wholesale, $1M+ revenue businesses. Starts at $1,200/month. Pricing is bespoke and order-volume-based. Unlimited users always included.

**Onboarding.** Email invite. Onboarding is a project: typically 3-6+ months, managed by a Brightpearl implementation team. Not self-serve. Implementation is a paid engagement.

**Inventory entry.** CSV import, manual, integration-pulled. Barcode scanning supported. Assumes warehouse hardware.

**Order pipeline.** Full pick-pack-ship with configurable statuses. Automation rules can advance orders between stages based on triggers (payment received, stock confirmed, etc.). Workflow automation is a differentiator.

**Customer pricing.** Supported. Price lists per customer or segment.

**Team and roles.** Module-level permissions. Unlimited users. Financial data can be restricted from warehouse roles.

**Mobile vs. web.** Web-primary. Mobile app exists but reviewers note it feels dated.

**AI and analytics.** Inventory Planner integration provides demand forecasting with seasonality, promotions, and lead times factored in. As of Q2 2025, TikTok Shop trend analysis was added. Forecasting lives in a dedicated "Planning" module, not inline with the order pipeline. No chatbot feature.

**Common complaints.** Promised integrations don't work as described. No custom report builder. Steep learning curve. Implementation-heavy. Product development has slowed. Interface feels dated. Accounting audit trails are weak.

### Fishbowl

**Target and price.** Manufacturers and distributors that need QuickBooks sync. Fishbowl Drive (cloud): $349/month, 2 users. Fishbowl Advanced (on-premises): $399/month. Extra users and onboarding add-ons are separately priced ($225/hour to $2,947/day for professional services).

**Onboarding.** Email invite. QuickBooks integration is the primary setup task. For non-trivial catalogs, professional implementation is expected and expensive. Some users report year-long implementations.

**Inventory entry.** Manual, CSV, barcode scanning. Barcode support is a core feature, not an add-on, which is notable.

**Order pipeline.** Sales orders: Quote -> Sales Order -> Pick -> Pack -> Ship -> Invoice. Accounting integration (QuickBooks) is tightly coupled to the order pipeline; fulfillment drives bookkeeping entries automatically.

**Customer pricing.** Supported. Multiple price lists with customer assignment.

**Team and roles.** Configurable roles and permissions. Restricted access for warehouse workers vs. office staff is a documented use case.

**Mobile vs. web.** Web-primary. Mobile app is widely reported as limited and sometimes described as "useless." Barcode scanning on mobile has been a persistent complaint.

**AI and analytics.** No AI features advertised.

**Common complaints.** Mobile app is seriously undercooked. Reporting is inflexible and requires multiple exports to get one answer. Customization requires paid professional services. The implementation horror stories on Capterra are severe.
