# Website Prompt — Coffeetosh Homepage (index.html)
**Version:** 2.0
**Scope:** `index.html` ONLY — Home Page

---

You are three world-class specialists working together to build a single production-ready HTML file. No compromises. Every decision is intentional.

**Role 1 — Senior Product Designer (0.1%):**
You own the visual system — brand fidelity, spacing, color, typography, composition. You never use generic AI aesthetics. You make things feel premium, playful, and alive.

**Role 2 — Senior Front-End Animator:**
You own all motion — GSAP timelines, ScrollTrigger pinning, Three.js scenes. Every animation has purpose. Timing is precise. You do not over-animate. You do not under-animate.

**Role 3 — Senior Web Developer:**
You own the code — clean semantic HTML5, scoped CSS variables, modular vanilla JS. No frameworks. No build steps. One file that opens in a browser and works perfectly.

---

## DESIGN SYSTEM — STRICT, DO NOT DEVIATE

**Colors:**
```
Background base:    #1A1310  (Espresso Dark)
Popover surfaces:   #2A2019
Cards / panels:     #342920
Accent:             #D4923A  (Warm Amber — primary action, buttons, active states)
Text primary:       #F0E6D8
Text secondary:     #A89680
Text muted:         #7A6655
Footer background:  #F5EDE3  (Latte White)
Footer text:        #2C1E12
```

**Typography:**
- Big bubbly headings → **Nunito** ExtraBlack (900). This matches the rounded bold font used in the native app onboarding.
- Body / secondary → **Inter**
- Terminal / code → **JetBrains Mono**
- All three from Google Fonts.

**Shape language:** Rounded everything. Buttons are full pills. Cards are softly rounded. Nothing sharp.

**Emoji policy:** Minimal. Only where it genuinely adds to the UI. Zero decorative emoji in headings or body copy.

---

## REQUIRED LIBRARIES — IMPORT ALL

- GSAP + ScrollTrigger + TextPlugin (cdnjs, v3.12.5)
- Three.js (cdnjs, r134)
- canvas-confetti (jsdelivr, v1.9.3)

Register GSAP plugins at the start of your script.

---

## SVG LOGO ASSETS

Three logo files exist in the project. Use them as inline SVGs — not img tags.

- **logo-outline.svg** — empty cup outline. Used for inactive / neutral states.
- **logo-filled.svg** — filled cup with macintosh face cutout. Used for active / ON states.
- **logo-animated.svg** — self-animating SVG with scale transforms. Used in the navbar, loops infinitely.

Colorize with `currentColor` so they inherit their parent's color. Amber = brand ON state.

---

## BUILD TARGET

One file: `index.html`. Everything inline — CSS in `<style>`, JS in `<script>` at end of body. No build steps. Opens with a double-click.

---

## SECTION-BY-SECTION BRIEF

---

### NAV

Sticky. Full width. Gaussian blur background — feels like frosted glass over the dark page. Rounded bottom corners. Subtle amber glow along the bottom edge.

**Left:** `logo-animated.svg` looping + "Coffeetosh" in Nunito 900.

**Right:** One single button — "Star on GitHub". Pill shape, amber border, amber text. Inside the button: a star icon + label + a small rounded pill badge showing the live GitHub star count fetched on page load from the GitHub API (`https://api.github.com/repos/prophesourvolodymyr/CoffeeTosh`). If the fetch fails, show `—`. No other nav links exist.

The nav slides down into place as part of the hero load sequence.

---

### SECTION 1 — HERO

Full viewport height. Everything centered. Espresso dark background.

**Three.js steam background:** Behind all content, a Three.js canvas renders ~180 tiny semi-transparent particles slowly rising from the bottom of the viewport — like steam rising from a hot cup of coffee. Organic, slow drift. Not techy. Not particle-explosion energy. Just warm, moody atmosphere.

**Live status badge:** A small rounded pill badge above the headline. A tiny amber dot pulses on the left. Text: "Coffeetosh is running". Makes the product feel real and active the moment someone lands.

**Hero headline:** "Addicting your mac to stay alive" — Nunito 900, very large. The word **"alive"** is in amber. Each word staggers in from below on page load.

**Subheadline:** "The open-source sleep preventer for macOS. No root hacks. Free forever." Fades in below the headline after it completes.

**Hero illustration (GSAP timeline, plays after text):**
A composed illustration below the headline. Cartoonish, friendly — not realistic 3D. Think B&W line-art comic style, 2D with a slight perspective feel.

1. A laptop appears open, screen faintly glowing.
2. The lid slowly closes. The screen dims as it shuts.
3. Three phones slide in — one from each side and one from below. Each connects to the closed laptop via a thin dashed amber line that draws itself in.
4. Once all three are connected, a soft amber glow pulses from the laptop body.

Everything built in SVG and CSS — no external images.

**CTA button — the runaway download button:**
Below the illustration. Label: "Download for Mac". Amber fill pill, Nunito 900.

**First-visit behavior (check sessionStorage):**
If this is the visitor's first time on the page, the button runs away from the cursor. When the cursor gets close (~120px), the button jumps to a random nearby spot. The text changes to **"Learn First"** while being chased. When the cursor moves away, the button returns to its original position and the text resets.
On click (if caught), it goes to `download.html`.

**Returning visitor:** Normal behavior. Hover lifts the button slightly. Click goes to `download.html`.

---

### SECTION DIVIDERS

Between every major section (Hero → Features, Features → Pricing, Pricing → Download): a small centered coffee cup SVG with a single animated steam wisp rising and fading in a loop. Replaces any hard divider line.

---

### SECTION 2 — FEATURES (GSAP PINNED SCROLL EXPERIENCE)

This is the centerpiece of the page. The entire section is pinned by GSAP ScrollTrigger. The user scrolls through 3 feature "scenes" one by one. When the user reaches this section, normal page scroll is locked. Each scene advances only when the user clicks the required button. After all 3 scenes are done, scroll unlocks and the page continues.

Three small amber pagination dots sit at the bottom center of the section, filling in as each scene completes.

On mobile (under 768px): the pinned experience is replaced by a simple static stacked card layout. No scroll-locking on mobile.

---

#### Scene 1 — "Invisible by default"

**Left side (text):**
- Big label: "01" in amber
- Heading: "Invisible by default"
- Body: "Lives quietly in your menu bar. Open it with a click, or wake the full controls with Option+Click."

**Right side (dock animation):**
A macOS-style dock sits at the bottom of the panel — glass blur style, with Finder, Safari, and the Coffeetosh icon (logo-outline.svg). A cursor SVG animates in and moves toward the Coffeetosh icon.

1. First click: the icon bounces (macOS dock bounce). logo-outline.svg cross-fades to logo-filled.svg — the cup fills.
2. Second click: icon bounces again. A small tooltip appears — "Option+Click to open full menu".
3. The composition zooms out slightly as the Coffeetosh popover mockup floats up above the dock. The popover is an HTML/CSS recreation of the real app UI:
   - Dark rounded panel
   - Segmented control at top: "Keep Awake" | "Headless SSH" — one segment lit amber
   - Duration chip grid below (30m, 1h, 2h, 3h, 4h, 6h, 8h, 12h, ∞) — one chip amber
   - Gear icon + quit icon in the footer of the popover
   - Popover pops in with a bouncy scale entrance

**Confetti button:** "Nice, I'll keep it" — pill, amber border. Click fires a confetti burst and transitions to Scene 2.

---

#### Scene 2 — "Lives in your terminal"

**Left side (text):**
- Big label: "02" in amber
- Heading: "Lives in your terminal"
- Body: "Full CLI control. Start sessions, set presets, check status — all without touching the GUI."

**Right side (terminal animation):**
A macOS window mockup — traffic light dots (red, yellow, green) in the title bar, "zsh" centered in the title. Black terminal body below.

Commands type out one by one as the scene plays — typewriter effect via GSAP TextPlugin. Each new command appears after the previous finishes:

```
$ coffeetosh install-cli
$ coffeetosh start
$ coffeetosh stop
$ coffeetosh status
$ coffeetosh start 8
$ coffeetosh start 2 --mode keep-awake
$ coffeetosh preset set headless 4
```

Each command: amber $ prompt, white command text, JetBrains Mono. After each command types, a dimmed output line briefly appears beneath it.

**Two buttons at the bottom:**
1. "Okay that's actually sick" — confetti burst + transitions to Scene 3 (this is the scroll gate)
2. "Read the Docs" — links to `docs.html`. This button is supplementary — it does NOT gate the scroll.

---

#### Scene 3 — "Your session, your data"

**Left side (text):**
- Big label: "03" in amber
- Heading: "Your session, your data"
- Body: "Track every session. Know how long your Mac stayed awake and which mode you used."

**Right side (dashboard animation):**
macOS window chrome wrapping an Analytics dashboard mockup. Inside:
- Three stat cards in a row: "Total Sessions", "Hours Prevented", "Headless %". Numbers count up from zero to random realistic values when the scene plays.
- Two horizontal bar indicators below: "Keep Awake" and "Headless SSH" — both animate from zero width to their percentage fill.
- Dark Espresso card panels inside the window chrome.

**Confetti button:** "I need this now" — confetti burst + unlocks page scroll + scene indicator fills final dot.

---

### SECTION 3 — PRICING

Centered. Single card. Espresso dark background continues.

**Section heading:** "How much does it cost?"

**The slot machine card:**
A single, generously padded card centered on screen.

**Animation (triggers when card scrolls into view):**
1. Card scales in from slightly below.
2. A large price counter is visible. It begins ticking upward like a vertical slot machine reel — fast at first, slowing as it approaches the top. It ticks through: $0 → $9 → $19 → $29 → $39 → $50/month.
3. When it hits $50: it freezes briefly, then shakes horizontally like it broke.
4. The entire price display flips to reveal: **FREE** in giant amber Nunito 900. Below it: an "& Open Source" pill badge.
5. Confetti burst on the reveal.
6. Benefits list staggers in below one by one:
   - Full Menu Bar UI
   - Dual-Mode (Keep Awake + Headless SSH)
   - Terminal CLI included
   - Session Dashboard & Analytics
   - Forever Free, Open Source (MIT)
   - macOS 13+ Ventura

**Two buttons below the card:**
- "Download for Mac" → `download.html` — amber fill pill
- "Star on GitHub" → `https://github.com/prophesourvolodymyr/CoffeeTosh` — ghost/outline pill

---

### SECTION 4 — DOWNLOAD

Espresso dark. Two columns on desktop, stacked on mobile.

**Section heading:** "Get Coffeetosh"

**Column 1 — Direct download:**
- Apple logo SVG at top (monochrome, matches text color)
- "Download for macOS" — Nunito 700
- "Requires macOS 13 Ventura or later" — small muted text
- "Download .dmg" button — amber pill (href placeholder pointing to GitHub Releases)
- "View all releases on GitHub →" — small amber link below

**Column 2 — Homebrew:**
- "Install with Homebrew" — Nunito 700
- macOS terminal window mockup (same style as Section 2) showing: `brew install coffeetosh`
- Copy button top-right of the terminal. On click: copies to clipboard, button text briefly shows "Copied!"

---

### FOOTER

**Background:** Latte White (#F5EDE3). All text in dark espresso (#2C1E12). This is the one section that is light — a warm, soft landing after the dark Espresso experience.

**Coffee drip animation at the top edge of the footer:**
An SVG wave runs full-width across the very top of the footer. From it hang 3–5 individual teardrop coffee droplets at different horizontal positions. Each droplet independently animates downward, fades out, and re-forms at the top — staggered so they don't all drip simultaneously. The wave is a slightly darker amber-brown. The droplets are the brand amber. This is the visual transition from the dark page into the latte footer.

**Footer content (centered):**
- logo-outline.svg inline, colored to match footer text
- "Coffeetosh" in Nunito 900
- Nav links row separated by · dots: Home · Download · Docs · GitHub. Hover turns links amber.
- GitHub star count: "★ [live count] stars" — same API fetch as the nav button
- Copyright: "© 2025 Coffeetosh. MIT License. Open Source." — small, muted opacity

---

## CONSTRAINTS

- One HTML file. CSS in `<style>`, JS in `<script>` at bottom of `<body>`. No external stylesheets.
- No build tools. No npm. Opens in browser with zero setup.
- All color tokens in CSS `:root`. No hardcoded hex values outside of `:root`.
- Responsive from 375px to 1440px.
- GSAP pinned section is desktop-only. Mobile gets a static stacked card version.
- All interactive elements are accessible — proper button elements, aria-labels where needed.
- No emoji in headings or body copy. The live badge dot is CSS-only.
