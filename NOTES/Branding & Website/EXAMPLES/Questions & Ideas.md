# 🔍 Branding & Website — Deep-Dive Questions & Ideas
**Generated:** 2026-03-05
**Status:** 🟡 Awaiting User Response
**Source:** N1.md + G1 Visual Law + CLI/App codebase analysis

---

## ✅ CONFIRMED UNDERSTANDING (What I Know for Certain)

Before questions, here's what I locked in from N1 + codebase:

- **App Tagline:** "Addicting your mac to stay alive"
- **Pages:** `index.html` (home), `download.html`, `docs.html`
- **Color Law:** Espresso Dark base (`#1A1310`), Warm Amber (`#D4923A`), White allowed as accent
- **SVG Assets:** `logo-animated.svg`, `logo-filled.svg`, `logo-outline.svg` confirmed in codebase
- **CLI Commands (real, from source):** `coffeetosh start [hours] [--mode keep-awake]`, `coffeetosh stop`, `coffeetosh status`, `coffeetosh preset set <mode> <duration>`, `coffeetosh add`, `coffeetosh install-cli`
- **Fonts:** SF Pro Rounded (`.heavy`/`.black`, design: `.rounded`) for headings — the "bubbly font"; System Monospaced for terminal — from direct onboarding source code
- **Libraries confirmed:** GSAP + ScrollTrigger (pinning), confetti library, Three.js (if hero background needed)
- **Section 2 Lock:** GSAP pinned scroll. Each of 3 feature points has a congrats button that user MUST click to unlock scroll to the next point. Terminal point (2) has a secondary "Docs" button alongside the congrats button.
- **Pricing Lock:** Slot machine animation counting UP from $0 toward $50/mo → FLIPS to FREE & Open Source reveal
- **Footer:** Coffee drip animation behind the footer content

---

## ❓ IMPLEMENTATION QUESTIONS

---

### 🦸 SECTION 1 — HERO

#### Q1: Hero Animation Direction & Trigger
**Current N1 State:** "Animation of a laptop closing and phones are connecting to it" — "big composition of text showing up"
**Unclear:** Does this animation play automatically on page load (timeline-based), or is it tied to scroll? And what exactly is the sequence order?

> My interpreted sequence (please confirm or correct):
> 1. Page loads → hero headline "Addicting your mac to stay alive" staggers in letter-by-letter or word-by-word
> 2. A 3D/illustrated laptop fades in — open, glowing screen
> 3. Laptop slowly closes (lid animation)
> 4. 2–3 phone outlines appear and connect via a line/beam to the closed laptop
> 5. Subheadline / CTA fades in below

**✏️ Your answer:**

---

#### Q2: The Laptops & Phones — Style
**Unclear:** Are these 3D objects (Three.js), 2D vector illustrations, or CSS/SVG shapes? And should the phones be specifically styled as iPhones, or generic?
**Unclear:** How many phones max? (I'm thinking 2–3 is readable)

**✏️ Your answer:**

---

#### Q3: Hero Background
**Unclear:** Is the hero background pure Espresso Dark (`#1A1310`) flat? Or does it have a subtle shader/noise/grain texture? N1 mentions WebGL+Three.js in the prompt format reference — should we use a subtle WebGL background on the hero?

**✏️ Your answer:**

---

#### Q4: Hero CTA Button
**Unclear:** N1 doesn't mention a CTA button in the hero section. Should there be:
- A) One big "Download" button below the hero text?
- B) Two buttons: "Download" + "View on GitHub"?
- C) No button — the hero is pure visual, the user scrolls naturally?

**✏️ Your answer:**

---

#### Q5: Hero Tagline vs Subtext
**Unclear:** Is "Addicting your mac to stay alive" the ONLY hero text, or is there a short 1-line subtitle below it (e.g., "The open-source sleep preventer for macOS")?

**✏️ Your answer:**

---

### ✨ SECTION 2 — FEATURES (GSAP Pinned Scroll)

#### Q6: Feature Point 1 — Dock Anatomy
**Current N1 State:** "Mouse goes, clicks it two times, cup goes from empty to filled (check our SVGs), then option+click reveals full menu"
**Unclear:** What does the "made up dock" look like? A realistic macOS dock with multiple fake app icons (Finder, Safari, etc.) + our Coffeetosh icon? Or just the Coffeetosh icon isolated on a mini dock?
**Unclear:** Does the dock float in the center of the viewport or sit at the bottom (like macOS)?

**✏️ Your answer:**

---

#### Q7: Feature Point 1 — "Full Menu Shows Up" After Option+Click
**Unclear:** What exactly is "the whole menu"? Is it:
- A) Our actual Coffeetosh popover UI (with mode selector, duration picker) shown as a screenshot/mockup?
- B) A simplified representation of the menu?
- C) Should we mock it in real HTML/CSS as a live UI element?

**✏️ Your answer:**

---

#### Q8: Feature Point 1 — Congrats Button Text
**Current N1 State:** "For the beginning 2 it will be silly congratulate us text like (Cool :emoji) (that's nice :emoji)"
**Locked:** The confetti button for Point 1 has a silly text. What IS that text exactly?
**Options (pick one or suggest your own):**
- A) "Nice! 🎉" → bursts confetti, unlocks scroll
- B) "Cool right? 😎" → same
- C) "Ugh, fine. I like it. 👏"
- D) You tell me

**✏️ Your answer:**

---

#### Q9: Feature Point 2 — Terminal Visual Style
**Current N1 State:** "Show the terminal we have in our style code (style) black"
**Unclear:** Is there an existing terminal mockup style I should reference? Looking at the Onboarding (ProMaxOnboardingView.swift), I see a monospaced black panel. Should the web terminal match that exactly — black panel, white/amber text, monospaced font?

> Proposed commands to show (7 real ones from CLI source):
> ```
> coffeetosh install-cli
> coffeetosh start
> coffeetosh stop
> coffeetosh status
> coffeetosh start 8
> coffeetosh start 2 --mode keep-awake
> coffeetosh preset set headless 4
> ```

**Unclear:** Should each command be typed out with a typewriter effect as the GSAP animation progresses? Or are they all visible at once in the static terminal mockup?

**✏️ Your answer:**

---

#### Q10: Feature Point 2 — The "Docs" Button
**Current N1 State:** "there will be 2 buttons...the normal congratulation I have described, and like to Our Docs with the command"
**Locked:** Terminal point has a secondary button pointing to the Docs page.
**Unclear:** Button label — "See All Commands →"? "Open Docs →"? "Read the Docs 📖"?

**✏️ Your answer:**

---

#### Q11: Feature Point 2 — Congrats Button Text
Following the "silly" pattern from N1:
- A) "Okay that's actually sick 🖥️"
- B) "I can use my Mac more now 💀"
- C) You tell me

**✏️ Your answer:**

---

#### Q12: Feature Point 3 — Dashboard Visual
**Current N1 State:** "Cool dashboard — just animation of our dashboard (Analytics page only) — set random numbers & show sessions"
**Confirmed:** Analytics tab from DashboardView — Total Sessions, Total Hours, Mode split (Keep Awake vs Headless %)
**Unclear:** Is this a static screenshot/mockup of the dashboard with numbers counting up as animation? Or an actual HTML recreation of the dashboard UI with CSS animations?
**Unclear:** What's the confetti button text for Point 3? Does the "silly" rule still apply to Point 3, or only Points 1 & 2?

**✏️ Your answer:**

---

#### Q13: GSAP Section — Overall Background
**Unclear:** Does the entire Section 2 GSAP experience have the same Espresso Dark background? Or does the background visually shift/change for each of the 3 feature points (e.g., a subtle color wash or gradient shift per point)?

**✏️ Your answer:**

---

### 🎰 SECTION 3 — PRICING

#### Q14: Slot Machine Sequence
**Current N1 State:** "Price decreasing from 0 to 50/mon, and when it goes to maximum it becomes free"
**My interpretation (confirm/correct):**
1. Card appears with price counter: starts at `$0/mo`
2. Number animates UP like a slot machine: `$0 → $10 → $25 → $50/mo`
3. When it hits `$50`, the slot machine "breaks" — confetti, surprise, dramatic pause
4. The display FLIPS to `FREE` + "& Open Source" badge
5. Benefits of the free plan appear below

Is this the right interpretation? Or should it actually start at HIGH and spin DOWN to $0/FREE?

**✏️ Your answer:**

---

#### Q15: Pricing Card — Benefits List
**Unclear:** What are the listed benefits on the free plan card? Some ideas based on the app:
- ☕ Full Menu Bar UI
- 🖥️ Dual-Mode (Keep Awake + Headless SSH)
- 💻 Terminal CLI included
- 📊 Session Dashboard & Analytics  
- 🔓 Forever Free, Open Source (MIT)
- 🚀 macOS 13+ Ventura

Should I use these or do you want to write them yourself?

**✏️ Your answer:**

---

#### Q16: Pricing — GitHub CTA
**Unclear:** After the free reveal, is there a "Star us on GitHub ⭐" or "Get it Free →" button on the pricing card?

**✏️ Your answer:**

---

### 📥 SECTION 4 — DOWNLOAD (HOMEPAGE SECTION)

#### Q17: Homebrew Command
**Unclear:** What is the exact brew installcommand?
- A) `brew install coffeetosh`
- B) `brew install --cask coffeetosh`
- C) Something else (tap + install)?

**✏️ Your answer:**

---

#### Q18: Download Button — Apple Direct
**Unclear:** Does the direct .dmg/.zip download link exist yet, or is it a placeholder? GitHub Releases link?

**✏️ Your answer:**

---

#### Q19: System Requirements
**Confirmed from R1:** macOS 13 Ventura minimum. Should this be displayed alongside the download buttons?

**✏️ Your answer:**

---

### 🧭 NAVIGATION BAR

#### Q20: Nav Links
**Unclear:** Which links appear in the nav?
- A) Home / Download / Docs
- B) Home / Download / Docs / GitHub
- C) Something else?

**✏️ Your answer:**

---

#### Q21: Nav Logo Text
**Current N1 State:** "Logo must be taken from the animated SVG from our codebase, and text will be in our bold bubbly font as on onboarding"
**Confirmed:** `logo-animated.svg` in navbar + "Coffeetosh" text in SF Pro Rounded Black.
**Unclear:** Should the logo animation in the nav loop infinitely or only play once on page load?

**✏️ Your answer:**

---

#### Q22: Nav CTA Button
**Unclear:** Should the nav have a right-side CTA button like "Download" or "Get for Mac"? Many Mac app sites do this.

**✏️ Your answer:**

---

### 🦶 FOOTER

#### Q23: Coffee Drip — Animation Style
**Current N1 State:** "On the background of the footer there will be a coffee: coffee drip"
**Unclear:** Is the coffee drip:
- A) A CSS/SVG animated path of coffee dripping down from the TOP of the footer container?
- B) A looping animation of a coffee drop falling from a spout?
- C) A Three.js / canvas-based particle drip effect?
- D) A subtle repeating CSS keyframe animation (drip goes down, fades, loops)?

**My proposal:** CSS-animated SVG path of a coffee drip line running across the top edge of the footer, dripping down. Clean, matches the brand, low-overhead. Confirm?

**✏️ Your answer:**

---

#### Q24: Footer Links
**Unclear:** What page links appear in the footer?
Proposal: Home · Download · Docs · GitHub
Any social links (Twitter/X)? Any copyright year?

**✏️ Your answer:**

---

### 📄 STANDALONE PAGES

#### Q25: Docs Page — Command Format
**Current N1 State:** "Terminal style of our website to copy and commands"
**Confirmed:** Docs page uses same black terminal aesthetic with copy buttons.
**Unclear:** Should the Docs page show ONLY commands, or also explanations of each command with flags and example outputs?
> Example layout:
> ```
> coffeetosh start [hours] [--mode keep-awake]
> # Starts a session. Default: Headless mode, 8 hours.
> ```
> With a `[Copy]` button on each block.

**✏️ Your answer:**

---

#### Q26: Download Page — Difference from Section 4
**Current N1 State:** "Downloads page will be similar to section 4"
**Unclear:** Is the standalone `/download.html` **identical** to Section 4 of the homepage? Or does it have more detail (installation instructions, changelog, system reqs)?

**✏️ Your answer:**

---

## 💡 AMBITIOUS IDEAS (Nothing Is Impossible)

---

### Idea 1: Floating Coffee Steam in Hero
**Vision:** Instead of flat background, WebGL particle system renders slow-rising coffee steam from the bottom of the hero — dark, moody, atmospheric. The steam rises behind the laptop/phone illustration.
**User Benefit:** Instantly sets the "coffee" mood without being heavy-handed.
**Technical Approach:** Three.js `ParticleSystem` or GLSL vertex shader with upward drift + opacity falloff. ~200 particles max.
**Complexity:** Medium

---

### Idea 2: "Live Status" Badge in Hero
**Vision:** A small badge in the hero that says "☕ Coffeetosh is running" with a blinking amber dot — like a simulated "live" indicator showing the app actively doing its job.
**User Benefit:** Immediately makes the product feel real and active to a new visitor.
**Technical Approach:** Pure CSS animation — pulsing dot with `animation: pulse` on the amber color. No JS needed.
**Complexity:** Low

---

### Idea 3: Terminal Section Has Real Typing Animation
**Vision:** In Section 2's terminal point, each command types out letter-by-letter as the user "watches" the GSAP scroll — making it feel like someone is actually using the tool live.
**User Benefit:** More engaging than static text. Creates the "oh this is actually real" moment.
**Technical Approach:** GSAP `TextPlugin` + `gsap.timeline()` stagger. Each command types out when its position is entered.
**Complexity:** Low (GSAP native)

---

### Idea 4: Ambient Coffee Cup SVG in Section Dividers
**Vision:** Between major sections, a subtle centered coffee cup SVG divider with a single steam wisp, rather than a hard `<hr>`. Keeps the coffee theme woven through the entire page.
**User Benefit:** Consistent brand storytelling between sections.
**Technical Approach:** Inline SVG with CSS animation on the steam path.
**Complexity:** Low

---

### Idea 5: macOS-style Window Chrome in Dashboard Demo
**Vision:** In Section 2's dashboard demo, wrap the dashboard mockup in a realistic macOS window frame (traffic lights: red/yellow/green dots, title bar, subtle shadow). Makes the mockup feel like you're genuinely looking at the running app.
**User Benefit:** Immediate recognition — "oh this is an actual Mac app."
**Technical Approach:** `div` with CSS-crafted macOS window styling.
**Complexity:** Low

---

### Idea 6: GitHub Stars Counter in Footer
**Vision:** Live GitHub star count pulled from the GitHub API displayed near the footer logo. "⭐ 1,200 people use Coffeetosh" — if the count is low, show "Be the first to star us ⭐"
**User Benefit:** Social proof. Open source apps live and die by stars.
**Technical Approach:** Fetch from `https://api.github.com/repos/[owner]/coffeetosh` on page load. Display with a number counter animation.
**Complexity:** Low (simple fetch)
**Note:** Only use repo's confirmed GitHub URL — confirm this first.

---

### Idea 7: "Brew Copy" Interactive Terminal Block in Nav
**Vision:** A persistent floating mini terminal snippet that appears on scroll past the Hero: `brew install coffeetosh` with a one-click copy button. Like a persistent CTA that follows the user.
**User Benefit:** Reduces friction — user can install at any point without scrolling to Download section.
**Technical Approach:** Fixed-position mini card, appears with GSAP `fromTo` after hero exits viewport.
**Complexity:** Low

---

## 🔗 FEATURE EXTENSION IDEAS

**New Components to Consider:**
- [ ] **GitHub Badge component:** "Open Source · MIT License" badge on the pricing card
- [ ] **OG/Social Meta tags:** Custom Open Graph image (animated logo on dark bg) for link preview when shared on Twitter/Slack
- [ ] **Mobile Responsive Fallback:** GSAP pinned scroll may not work well on mobile — consider a simplified card-stack fallback for screens < 768px
- [ ] **README Banner:** The user mentioned "good banner & explanation in README" — a separate GitHub social preview image (`1280x640`) featuring the hero text and logo

---

## 🎨 OPEN TYOGRAPHY DECISION

### Web Font Candidates (to match the "two fonts" from G1 + onboarding)

Since SF Pro isn't available on the web, equivalent choices:

| Role | Native App (SwiftUI) | Web Equivalent Options |
|---|---|---|
| **Bubbly/Bold Headings** | SF Pro Rounded Black | Nunito ExtraBold, Baloo 2 ExtraBold, Fredoka One |
| **Body / Secondary** | SF Pro Regular | Inter, Plus Jakarta Sans |
| **Terminal / Code** | SF Mono / Monospaced | JetBrains Mono, IBM Plex Mono, Fira Code |

**Unclear:** Do you have a preference for the bubbly heading font? Or should I pick the closest to the onboarding feel?

**✏️ Your answer:**

---

## ✅ USER ACTION REQUIRED

Please review and respond to the questions above. You can:
- Answer inline (add your answers after `**✏️ Your answer:**`)
- Or reply in chat with just the Q number + answer (e.g., "Q1: Timeline auto-plays on load, Q4: Two buttons...")

Once answered, I will:
1. ✍️ Use your answers to write the **single-shot website prompt** (referencing GSAP, Three.js, all sections)
2. 📋 Create `FEATURES/F[x] - Website/F[x]-Doc.md` with the full website spec
3. ✅ Create `FEATURES/F[x] - Website/F[x]-Progress.md` with **checkbox for every section, page, and animation**

The prompt will be structured exactly like your N1 example format — 3 roles, library references, and every section instruction clearly written for a single-shot AI build.
