---
project: stowed
type: reference
status: building
stage: 02-build
tags: [stowed, marketing, web]
updated: 2026-06-23
---

# Stowed Demo Video Script

**Target length:** 90 to 120 seconds
**Tone:** Direct, confident, peer-to-peer. Not salesy. Like a founder talking to another business owner.
**Format:** Screen recording of the iOS app (simulator or device) with narration voiceover.
**Placement:** Embedded on stowedapp.app, plays in a modal lightbox when clicked.

---

## Narration Script

---

**[OPEN ON: a spreadsheet full of inventory rows, multiple tabs, manual formulas]**

> "If you run a wholesale business, you probably know this screen.
> Inventory in a spreadsheet. Orders in your email. Customer pricing tracked in your head.
> It works. Until it does not."

---

**[CUT TO: iPhone booting Stowed — clean dark launch screen, logo appears]**

> "Stowed is an iPhone app built specifically for small wholesale businesses.
> Inventory, orders, customer pricing, and your team — all in one place."

---

**[SHOW: Home dashboard — metrics, recent orders, role badge showing Owner]**

> "The moment you open it, you see what matters.
> Revenue. Open orders. Stock that needs attention.
> No digging. No switching apps."

---

**[SHOW: Order creation — selecting a customer, prices auto-populate per customer]**

> "Every customer gets their own negotiated price.
> When you create an order for Harbor Market, Stowed pulls their prices automatically.
> Not the list price. Their price."

---

**[SHOW: Order moving through stages — draft, confirmed, packed, shipped]**

> "Orders move through a clear pipeline.
> Your team knows exactly what to pick, what to pack, and what has shipped."

---

**[SHOW: Inventory screen — scanning a barcode, quantity updates live]**

> "Receiving stock is a scan, not a spreadsheet row.
> Quantities update in real time. Low-stock alerts catch problems before your customer does."

---

**[SHOW: Team screen — pending approval for a new joiner, owner taps Approve]**

> "When a new team member joins, they enter your warehouse code.
> You see the request. You approve it. They are in.
> No email invite. No admin portal."

---

**[SHOW: Money tab — revenue, receivables, expenses, net profit]**

> "And because everything is connected, you can see profit, not just revenue.
> What came in. What went out. What you actually made."

---

**[CLOSE ON: App icon + stowedapp.app URL, white on dark background]**

> "Stowed is coming to the App Store.
> Get early access at stowedapp.app."

---

## Production Notes

### What to record
- Record in the iOS Simulator at iPhone 15 Pro size, or on a real device
- Use the Northbeam / demo data that already exists in the app
- QuickTime > File > New Movie Recording, select iPhone as camera source for device recording
- For simulator: use `xcrun simctl io booted recordVideo stowed-demo.mov`

### Voiceover
- Record narration separately in a quiet room (AirPods mic is fine for a draft; re-record with a better mic before going live)
- Match the pacing to the on-screen transitions — let each screen breathe for 2 to 3 seconds before cutting

### Editing
- Free option: iMovie (trim, add voiceover track, export 1080p)
- Better option: DaVinci Resolve (free, professional quality)
- Add a subtle background music track underneath the narration (something neutral — no beats, no lyrics)

### Upload
1. Upload final video to YouTube as Unlisted
2. Copy the video ID from the URL (the string after `v=`, e.g. `dQw4w9WgXcQ`)
3. Open `~/stowed/web/index.html`
4. Find the line: `data-src="https://www.youtube.com/embed/YOUR_YOUTUBE_VIDEO_ID?autoplay=1..."`
5. Replace `YOUR_YOUTUBE_VIDEO_ID` with your real ID
6. `git add web/index.html && git commit -m "feat(web): add real demo video" && git push origin main`

---

## Thumbnail

The poster / thumbnail that shows before the video plays is already built into the site:
dark background, centered play button, "How Stowed works in 2 minutes" title.
No separate thumbnail image needed unless you want to add a real screenshot behind the play button.
