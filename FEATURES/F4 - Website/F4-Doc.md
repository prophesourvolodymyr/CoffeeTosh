# 🌐 F4-Doc: Coffeetosh Website
**Date:** 2026-03-04
**Status:** 🟡 Planning
**Classification:** Marketing / Documentation
**Source:** `NOTES/Branding & Website/N1.md` + `GENERAL/G1 - Styles.md`

---

## 1. 👁️ The Vision

A cinematic, one-session build website for Coffeetosh — a macOS menu bar utility that keeps your Mac awake when the lid is closed. The site is the product's public face: it onboards developers from first impression to first `brew install` in under 60 seconds. It leads with the exact problem being solved, not the features. Every section feels like it continues the same visual story as the native macOS app.

**Core promise of the site:** *"You close the lid. It keeps working. No root hacks. One command."*

---

## 2. 🗂️ Pages & Sitemap

```
WEBSITE/
  index.html          ← Page 1: Home (hero + problem + how it works + CTA)
  download.html       ← Page 2: Download (Homebrew, .dmg direct, manual build)
  about.html          ← Page 3: Open Source / Story / Contributors
  docs.html           ← Page 4: CLI & App Documentation (copyable commands)
  assets/
    logo-animated.svg ← Inline in hero — no img tag
    logo-outline.svg
    logo-filled.svg
  css/
    style.css
  js/
    main.js           ← Three.js, GSAP ScrollTrigger, wave borders, Lego scroll
```

**Framework:** Zero build tools. Pure HTML/CSS/JS. CDN imports only.  
**Deployment:** GitHub Pages from `/WEBSITE` folder. No CI required.

---

## 3. 🎨 Visual System (G1 Lock — Do Not Override)

### Color Tokens (CSS variables)
```css
--bg-base:       #1A1310;   /* Page/Window Base */
--bg-popover:    #2A2019;   /* Popover Base */
--bg-card:       #342920;   /* Section/Card */
--bg-sidebar:    #171110;   /* Sub-sections */
--accent:        #D4923A;   /* Warm Amber — ALL active states */
--text-primary:  #F0E6D8;
--text-secondary:#A89680;
--text-tertiary: #7A6655;
```

### Typography
- **Font:** `Inter` (body) + `JetBrains Mono` (code blocks) via Google Fonts CDN
- **Hero headline:** 72–96px, `font-weight: 800`, tight letter spacing
- **Section headers:** 40–56px, `font-weight: 700`
- **Body:** 16–18px, `font-weight: 400`, line-height 1.7
- **Code:** `JetBrains Mono`, 14px, bg `#171110`, border-radius 8px

### Geometry
- **Base radius:** 14px (cards, panels)
- **Inner radius:** 10px
- **Max content width:** 1120px, centered
- **Section padding:** 120px top/bottom minimum — "Breathing Room" rule strictly enforced

---

## 4. 🏗️ Architecture & Technical Stack

### Libraries (CDN — no npm, no build step)
```html
<!-- Three.js r160 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r160/three.min.js"></script>
<!-- GSAP 3.12 + ScrollTrigger -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/ScrollTrigger.min.js"></script>
<!-- Lenis smooth scroll -->
<script src="https://cdn.jsdelivr.net/npm/@studio-freight/lenis@1.0.42/bundled/lenis.min.js"></script>
```

### Three.js Scene (Hero Only)
- Full-bleed `<canvas>` behind the hero section
- Dither shader: renders the Coffeetosh SVG logo as a dithered quad, scanline pattern
- Particle field: ~300 tiny coffee-brown dots floating slowly (depth-sorted, subtle)
- Mouse parallax: scene shifts ±8° on cursor movement using GSAP quickTo
- Performance: `requestAnimationFrame` only while hero is in viewport (IntersectionObserver)

### Wave Section Dividers
- SVG `<path>` wave between every major section — generated procedurally in `main.js`
- Wave amplitude: 40px, frequency: 2 cycles across viewport width
- Wave color matches the NEXT section's background, creating seamless flow
- Subtle GSAP animation: waves drift slowly horizontally on scroll

### Lego Scroll Animations
- Every section block: `opacity: 0; transform: translateY(40px) scale(0.96)`
- On ScrollTrigger enter: spring to `opacity: 1; translateY(0); scale(1)`
- Stagger: children within a section animate 80ms apart
- Easing: `cubic-bezier(0.22, 1, 0.36, 1)` — same spring feel as the macOS onboarding

---

## 5. 📄 Page Specifications

### Page 1 — Home (`index.html`)

**Section 1.1: Hero**
- Full-viewport height
- Three.js canvas as background layer
- Animated SVG logo, 120px, centered, amber tinted
- Headline: `"Your Mac doesn't sleep on the job. Neither does your code."`
- Sub-headline: `"Keep macOS awake lid-closed. One command. No root hacks."`
- Two CTAs side-by-side: `[Download Free]` (amber fill) + `[View Docs]` (ghost)

**Section 1.2: Problem Statement** *(the "hook")*
- Dark card background (`--bg-card`)
- Bold typographic statement: `"You close the lid. Your SSH session dies."`
- Three micro-cards below: `Overnight builds canceled` / `SSH tunnels dropped` / `Downloads interrupted`
- Each card has a small icon (SF Symbol-equivalent SVG) + one-line description

**Section 1.3: How It Works**
- Three-column horizontal flow with connector lines between them
- Step 1: `Install` → Step 2: `coffeetosh start 8` → Step 3: `Mac stays awake 8h`
- Animated line drawing between steps (SVG stroke-dashoffset on scroll)

**Section 1.4: Mode Explainer**
- Two-card split layout:
  - Left: **Keep Awake** — light mode feel, IOPMAssertion, no admin needed
  - Right: **Headless (Coffeetosh)** — dark/amber feel, pmset, lid-closed safe, SSH safe
- Amber badge on right card: `"Recommended for SSH workflows"`

**Section 1.5: Testimonials / Stats**
- Three stats: `< 2MB app` / `macOS 13+ compatible` / `Open Source, MIT`
- Two short pull-quotes styled as terminal output blocks

**Section 1.6: Final CTA Strip**
- Full-width amber gradient band
- Headline: `"One command. Your Mac. Unstoppable."`
- `[Download for macOS]` button

---

### Page 2 — Download (`download.html`)

**Section 2.1: Hero**
- Minimal hero, no Three.js (performance)
- Logo outline SVG, 80px
- Headline: `"Get Coffeetosh"`
- Version badge: `v1.0.0 — macOS 13+`

**Section 2.2: Install Options** *(three-column cards)*
| Card | Title | Command/Action |
|---|---|---|
| 1 | Homebrew | `brew install coffeetosh` |
| 2 | Direct .dmg | Download button → GitHub releases |
| 3 | Build from Source | `git clone` + `swift build` instructions |

Each card has copyable code block with one-click copy button.

**Section 2.3: System Requirements**
- macOS 13 Ventura or later
- Apple Silicon or Intel (Universal Binary)
- For Headless mode: Admin password on first start

**Section 2.4: Post-Install Quick Start**
- Mini 3-step block: verify install → first start → first stop

---

### Page 3 — About (`about.html`)

**Section 3.1: Story**
- First-person narrative: why this tool was built
- Pull quote: `"I kept waking up to find my overnight build had crashed because my Mac fell asleep."`

**Section 3.2: Open Source**
- MIT license badge
- GitHub link
- Contribution guide mini-block

**Section 3.3: Architecture Overview**
- Diagram (CSS-drawn, no image): App → Daemon → SleepManager → pmset / IOPMAssertion
- One paragraph per layer

---

### Page 4 — Docs (`docs.html`)

**Section 4.1: CLI Reference**
Full copyable command table. All commands from `coffeetosh help` output, formatted as expandable rows:

```
coffeetosh start [hours]
coffeetosh start [hours] --mode keep-awake
coffeetosh start [hours] --low-power
coffeetosh start 0
coffeetosh stop
coffeetosh add [minutes]
coffeetosh status
coffeetosh install-cli
coffeetosh help
```

Each row expands to show: description, flags, example, output example.
Copy button on every code block (clipboard API).

**Section 4.2: App Reference**
- Quick Preset (how to set in Settings)
- Mode explanations with visual indicators
- Low Power Mode toggle explanation
- SSH Session Monitor explanation

**Section 4.3: FAQ**
- Five common questions in accordion style

---

## 6. 🧩 Component Library

### `<CopyBlock>` — Copyable Terminal Command
```html
<div class="copy-block">
  <pre><code>coffeetosh start 8</code></pre>
  <button class="copy-btn" aria-label="Copy command">
    <svg><!-- clipboard icon --></svg>
  </button>
</div>
```
- On click: `navigator.clipboard.writeText()`, icon swaps to checkmark for 1.5s
- Style: `bg: #171110`, `border: 1px solid rgba(212,146,58,0.2)`, `border-radius: 10px`
- Amber left border accent: `border-left: 3px solid #D4923A`

### `<WaveDivider>` — Between Every Section
```html
<div class="wave-divider" data-from="#1A1310" data-to="#342920"></div>
```
- JS reads `data-from`/`data-to` attributes and renders matching SVG wave

### `<LegoSection>` — Scroll-animate wrapper
Every `<section>` gets class `lego-section` → GSAP picks it up automatically

---

## 7. 🎯 Definition of Done

1. **Build** — Opens correctly in Safari, Chrome, Firefox. Zero JS console errors.
2. **Logo** — Animated SVG plays on hero load in amber color. Uses inline SVG, not `<img>`.
3. **Three.js Hero** — Dither shader renders. Falls back gracefully if WebGL unavailable (canvas hidden, plain bg shown).
4. **Wave Borders** — All section dividers are SVG waves, not flat edges. Match adjacent bg colors perfectly.
5. **Lego Animations** — All sections animate in on scroll. 0 sections are pre-visible without triggering.
6. **Copy Buttons** — All code blocks have working clipboard copy with visual confirmation.
7. **Docs Page** — All 9 CLI commands documented. All have copy buttons.
8. **Responsive** — Mobile layout works at 375px wide minimum.
9. **GitHub Pages** — Deployable from `/WEBSITE` folder with zero config.
10. **Performance** — Lighthouse score ≥ 85 on desktop. Three.js canvas pauses when off-screen.

---

## 8. 📁 File Map

| File | Purpose |
|---|---|
| `WEBSITE/index.html` | Home page |
| `WEBSITE/download.html` | Download page |
| `WEBSITE/about.html` | About / Story page |
| `WEBSITE/docs.html` | CLI + App documentation |
| `WEBSITE/css/style.css` | All tokens + layout + components |
| `WEBSITE/js/main.js` | Three.js, GSAP, waves, Lego anims, copy buttons |
| `WEBSITE/assets/logo-animated.svg` | Inline hero logo |
| `WEBSITE/assets/logo-outline.svg` | Nav + footer logo |
| `WEBSITE/assets/logo-filled.svg` | Active state variants |
