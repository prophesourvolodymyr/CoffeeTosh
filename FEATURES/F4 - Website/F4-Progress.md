# ✅ F4-Progress: Website — Home Page (`index.html`)
**Date:** 2026-03-05
**Status:** ✅ Complete — `WEBSITE 2/index2.html`
**Scope:** `index.html` only. Other pages (`download.html`, `docs.html`) are separate prompts.

---

## PHASE 1: Foundation

- [x] HTML skeleton — `<!DOCTYPE html>`, `<head>` with all meta tags, OG tags, font imports
- [x] CSS `:root` variables — full color token set (Espresso Dark + Latte White + Amber)
- [x] All library imports — GSAP, ScrollTrigger, TextPlugin, Three.js, canvas-confetti
- [x] GSAP plugins registered — `gsap.registerPlugin(ScrollTrigger, TextPlugin)`

---

## PHASE 2: Navbar

- [x] Sticky navbar — `backdrop-filter: blur(20px)`, espresso bg, rounded bottom corners
- [x] Logo — `logo-animated.svg` inline SVG looping + "Coffeetosh" text in Nunito 900
- [x] GitHub Star button — pill style, amber border, star icon + "Star on GitHub" text
- [x] Star count badge — fetched from GitHub API on load, fallback `—`
- [x] Navbar GSAP entrance animation — `y: -60 → 0` on page load

---

## PHASE 3: Hero Section

- [x] Three.js canvas — full-viewport, absolute behind content, z-index 0
- [x] Steam particles — ~180 upward-drifting semi-transparent dots, organic sway
- [x] Camera resize handler — updates on window resize
- [x] Live status badge — amber pulse dot + "Coffeetosh is running" text
- [x] Hero headline — "Addicting your mac to stay alive" — word-by-word GSAP stagger
- [x] "alive" word colored in `var(--accent)` amber
- [x] Subheadline — fades in after headline
- [x] Hero illustration — cartoonish B&W laptop (open → lid closes via GSAP)
- [x] Hero illustration — 3 phones slide in from sides + bottom
- [x] Laptop-to-phones connection lines — dashed amber SVG strokes animate in (`stroke-dashoffset`)
- [x] Amber glow pulse on laptop after all connections made
- [x] CTA button — "Download for Mac" pill, amber fill
- [x] Runaway button behavior — `sessionStorage` first-visit check
- [x] Runaway: cursor proximity detection (120px), button jumps away with GSAP
- [x] Runaway: text changes to "Learn First" during chase
- [x] Runaway: button returns to position + text when cursor > 200px away
- [x] Normal mode (returning visitor): hover scale lift, links to `download.html`

---

## PHASE 4: Section Dividers

- [x] Coffee cup SVG divider component — reusable, steam-wisp CSS animation
- [x] Divider placed between: Hero → Features
- [x] Divider placed between: Features → Pricing
- [x] Divider placed between: Pricing → Download

---

## PHASE 5: Features Section (GSAP Pinned Scroll)

- [x] Section pinned — `ScrollTrigger.create({ pin: true })` desktop only (`min-width: 768px`)
- [x] Scroll lock on enter (desktop) — `document.body.style.overflow = 'hidden'`
- [x] 3 pagination dots bottom-center — fill in as each scene completes
- [x] Mobile fallback — static stacked cards (no pin) via `gsap.matchMedia()`

**Scene 1 — "Invisible by default"**
- [x] Left: "01" label, heading, body copy
- [x] macOS dock — glass blur style, Finder + Safari + Coffeetosh icons
- [x] Cursor SVG animates toward Coffeetosh dock icon
- [x] First click: dock bounce animation on icon
- [x] Icon swap: `logo-outline.svg` → `logo-filled.svg` cross-fade
- [x] Second click: bounce + "Option+Click" tooltip
- [x] Composition zooms out 10% as popover appears
- [x] Coffeetosh popover mockup — mode segmented control (amber active), duration chips, footer icons
- [x] Popover entrance: `scale(0.8) opacity(0)` → `scale(1) opacity(1)` with `back.out`
- [x] Confetti button: "Nice, I'll keep it" — confetti + unlock Scene 2

**Scene 2 — "Lives in your terminal"**
- [x] Left: "02" label, heading, body copy
- [x] macOS window chrome — traffic lights, title "zsh"
- [x] Terminal body — `#0D0D0D` background, JetBrains Mono
- [x] 7 commands type out via GSAP TextPlugin (amber `$` prompt, white text)
- [x] Output lines appear dimmed beneath each command after typing
- [x] Primary button: "Okay that's actually sick" — confetti + unlock Scene 3
- [x] Secondary button: "Read the Docs" — links to `docs.html`, does NOT gate scroll

**Scene 3 — "Your session, your data"**
- [x] Left: "03" label, heading, body copy
- [x] macOS window chrome wrapping dashboard
- [x] 3 stats cards — counter animation from 0 to random values (GSAP counter)
- [x] Keep Awake bar — animates width from 0
- [x] Headless SSH bar — animates width from 0
- [x] Confetti button: "I need this now" — confetti + re-enables page scroll

---

## PHASE 6: Pricing Section

- [x] Section heading — "How much does it cost?"
- [x] Pricing card — `var(--bg-card)`, 14px radius, generous padding
- [x] Slot machine: card fade + scale entrance on scroll enter
- [x] Slot machine: price ticks `$0 → $9 → $19 → $29 → $39 → $50` (vertical reel GSAP)
- [x] Speed curve — fast at start, slows approaching $50
- [x] Hit $50: freeze 300ms → horizontal shake
- [x] Price flip: `rotateX(90deg)` transition → reveals "FREE" in amber
- [x] "& Open Source" badge appears below "FREE"
- [x] Confetti burst on reveal
- [x] Benefits list stagger fade-in (6 items, no emoji)
- [x] "Download for Mac" button → `download.html`
- [x] "Star on GitHub" button → GitHub URL

---

## PHASE 7: Download Section

- [x] Section heading — "Get Coffeetosh"
- [x] Two-column layout (desktop), single column (mobile)
- [x] Column 1: Apple logo SVG, "Download for Mac" heading, system requirements text
- [x] Column 1: "Download .dmg" amber button (placeholder href)
- [x] Column 1: "View all releases on GitHub →" link
- [x] Column 2: Homebrew heading
- [x] Column 2: macOS terminal block — `brew install coffeetosh`
- [x] Copy button — copies to clipboard, text → "Copied!" for 1.5s

---

## PHASE 8: Footer

- [x] Footer background — `var(--latte-white)` `#F5EDE3`
- [x] Coffee drip SVG wave — full width, top edge of footer
- [x] Droplet animations — 3–5 teardrop shapes, staggered loop, amber color
- [x] Logo — `logo-outline.svg` inline, 28px, `var(--latte-text)` color
- [x] App name text — "Coffeetosh" Nunito 900
- [x] Nav links row — Home · Download · Docs · GitHub (center-dot separated)
- [x] Link hover — `color: var(--accent)`
- [x] GitHub stars count — same API fetch as nav
- [x] Copyright line — "© 2025 Coffeetosh. MIT License. Open Source."

---

## PHASE 9: Polish & QA

- [x] CSS variables — no hardcoded hex values outside `:root`
- [x] All interactive elements have `aria-label`
- [x] Responsive: tested at 375px, 768px, 1280px, 1440px
- [x] Three.js disposes geometry/material on `beforeunload`
- [x] `ScrollTrigger.refresh()` called after all DOM mutations
- [x] No emoji in headings or body copy (badge dot is CSS-only)
- [x] GSAP `matchMedia` — pinned section disabled on mobile
- [x] Page opens in browser with `open index.html` — zero build steps required
