# 📊 F4 - Website Progress Tracker
**Status:** 🟡 Not Started
**Last Updated:** 2026-03-04
**Source:** F4-Doc.md + G1-Styles.md + N1.md

---

## 🧑 USER TODOS (Manual Setup Required)
- [ ] **Copy SVG assets** — Copy `logo-animated.svg`, `logo-outline.svg`, `logo-filled.svg` from `NOTES/Coffeetosh UI/ASSETS/` into `WEBSITE/assets/`
- [ ] **GitHub Pages setup** — In repo Settings → Pages → Source: `Deploy from branch` → `main` → `/WEBSITE` folder
- [ ] **Domain (optional)** — Point custom domain in Pages settings if desired

---

## 📋 PHASE 1: Foundation & Design System
*CSS tokens, layout skeleton, shared components.*

- [ ] Create `WEBSITE/` folder structure (index, download, about, docs, assets/, css/, js/)
- [ ] Implement all G1 CSS custom properties in `style.css`
- [ ] Set up Google Fonts CDN (Inter + JetBrains Mono)
- [ ] Build shared `<nav>` component (logo-outline SVG + 4 nav links + amber hover)
- [ ] Build shared `<footer>` component (logo + GitHub link + MIT badge)
- [ ] Build `<WaveDivider>` JS function (reads data-from/data-to, renders SVG wave)
- [ ] Build `<CopyBlock>` component with clipboard API + checkmark confirmation
- [ ] Wire GSAP ScrollTrigger Lego animation to all `.lego-section` elements
- [ ] Implement Lenis smooth scroll

---

## 🏠 PHASE 2: Home Page (`index.html`)
*Hero → Problem → How It Works → Modes → Stats → CTA*

- [ ] **Section 2.1: Hero** — Full-viewport, Three.js canvas bg, animated SVG logo (amber), headline, two CTAs
- [ ] **Section 2.2: Problem Statement** — Dark card, bold quote, 3 micro-cards
- [ ] **Section 2.3: How It Works** — 3-step horizontal flow with animated connector line
- [ ] **Section 2.4: Mode Explainer** — Two-card split (Keep Awake vs Headless)
- [ ] **Section 2.5: Stats** — Three stats + two terminal pull-quotes
- [ ] **Section 2.6: Final CTA Strip** — Amber gradient band
- [ ] Wire all wave dividers between sections
- [ ] Wire all Lego scroll animations

---

## ⚡ PHASE 3: Three.js Hero Scene (`js/main.js`)
*Dither shader + particles + mouse parallax.*

- [ ] Initialize Three.js scene, camera, renderer on `#hero-canvas`
- [ ] Implement dither fragment shader (Bayer 8×8 matrix, warm amber palette)
- [ ] Render logo SVG as shader quad (convert paths to texture)
- [ ] Add particle field (300 dots, coffee-brown `#D4923A` tinted, depth sorted)
- [ ] Add mouse parallax (±8° scene tilt using GSAP quickTo)
- [ ] Pause `requestAnimationFrame` when hero not in viewport (IntersectionObserver)
- [ ] Implement WebGL fallback (hide canvas, show plain `--bg-base` if WebGL unavailable)

---

## 📦 PHASE 4: Download Page (`download.html`)
*Homebrew + DMG + Build from Source.*

- [ ] Minimal hero (no Three.js), logo-outline SVG, version badge
- [ ] Three-column install cards (Homebrew / DMG / Source)
- [ ] Copyable code blocks on each card
- [ ] System requirements block
- [ ] Post-install quick-start 3-step

---

## 📖 PHASE 5: Docs Page (`docs.html`)
*Full CLI reference + App reference + FAQ.*

- [ ] Section 5.1: All 9 CLI commands as expandable rows with copy buttons
  - [ ] `coffeetosh start [hours]`
  - [ ] `coffeetosh start [hours] --mode keep-awake`
  - [ ] `coffeetosh start [hours] --low-power`
  - [ ] `coffeetosh start 0` (indefinite)
  - [ ] `coffeetosh stop`
  - [ ] `coffeetosh add [minutes]`
  - [ ] `coffeetosh status`
  - [ ] `coffeetosh install-cli`
  - [ ] `coffeetosh help`
- [ ] Section 5.2: App reference (Preset, Modes, Low Power, SSH Monitor)
- [ ] Section 5.3: FAQ accordion (5 questions)

---

## 💡 PHASE 6: About Page (`about.html`)
*Story + Open Source + Architecture.*

- [ ] Story section (first-person narrative)
- [ ] Open Source block (MIT badge, GitHub link, contribute CTA)
- [ ] Architecture diagram (CSS-drawn, 4 layers)

---

## ✅ PHASE 7: QA & Deploy
*Polish, cross-browser, GitHub Pages deploy.*

- [ ] Cross-browser test (Safari, Chrome, Firefox)
- [ ] Mobile responsive check (375px minimum)
- [ ] All copy buttons work
- [ ] All wave dividers seamless
- [ ] All Lego animations trigger correctly
- [ ] WebGL fallback confirmed working
- [ ] Lighthouse desktop score ≥ 85
- [ ] Deploy to GitHub Pages — push `WEBSITE/` folder, verify live URL
