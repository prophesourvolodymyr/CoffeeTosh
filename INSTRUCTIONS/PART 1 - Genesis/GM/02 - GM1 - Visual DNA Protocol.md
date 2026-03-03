# INS-GM1: Visual DNA Protocol

**System ID:** `INS-GM1`
**Trigger:** User says "Create Visual DNA", "Initialize GM1", "Setup Brand Styles", or "Make brand design system"
**Input Requirement:** `GM/GM0 - Brand.md` (Mandatory). Sub-project `GENERAL/G1` files if they exist.
**Output Target:** `GM/GM1 - [BrandName] - Styles.md` + `GM/GM1 - [BrandName] - Styles.html`

---

## 🎯 STRATEGIC INTENT

This protocol defines the **Master Visual Language** of the brand. It is the parent design system that all sub-projects inherit. Sub-project `G1` files are OVERRIDE ONLY — they never repeat what is defined here.

**What GM1 owns:**
- Master color palette (all brand colors + semantic mappings)
- Typography system (font families, scale, weights)
- Spacing & layout grid
- Border radius scale
- Shadow system
- Motion/animation principles
- Logo usage rules

**What GM1 does NOT own:**
- Component-level implementation (that's G1 + F1 per project)
- Feature-specific UI patterns

---

## 🕵️ PHASE 1: AUDIT

**Step 1: Read Sources**
- Read `GM/GM0 - Brand.md` for personality + aspirational brand references
- Read any existing sub-project `G1` files to extract common patterns
- Check `NOTES/` for any visual references, moodboards, or hex codes the user has dropped

**Step 2: Create Audit File**
- **Create:** `NOTES/Brand/GM1-Visual-Audit.md`
- **Content — Visual Questions:**

  **Color (required)**
  - What is the primary brand color? (hex or description)
  - What is the secondary/accent color?
  - Dark mode support? (yes/no)
  - Any colors that are OFF-LIMITS?

  **Typography (required)**
  - Preferred font for headings? (or "AI choose based on brand personality")
  - Preferred font for body text?
  - Any font that MUST NOT be used?

  **Style Direction (required)**
  - Pick ONE: Minimal / Bold / Playful / Elegant / Technical / Brutalist / Glassmorphism / Other
  - Border radius preference: Sharp (0px) / Subtle (4px) / Rounded (8px) / Pill (full)
  - Shadow style: None / Subtle / Strong / Colored

  **References (optional)**
  - Share 1–3 websites/apps whose visual style you admire
  - Share any logo files or brand assets if available

- **Output in chat:** "Visual audit ready at `NOTES/Brand/GM1-Visual-Audit.md`. Answer the required questions. Optional references help a lot."

**STOP:** Wait for user answers.

---

## 🖼️ PHASE 1B: HTML VISUAL AUDIT (Brand Token Rendering)

**Trigger:** Immediately after creating `GM1-Visual-Audit.md`. Created ALONGSIDE it — not instead of it.

**Rule:** Token decisions (radius, shadow depth, color feel, typography rendering) cannot be made by reading hex values and numbers. Render the options. HTML goes FIRST — markdown gets filled with confirmed answers from it.

**Action:** Create `NOTES/Brand/GM1-Visual-Audit.html` alongside the markdown.

**Structure:**
- One `<section>` per visual question that has competing options
- Renders all candidate values as live swatches/specimens side-by-side
- No external dependencies — all CSS inline
- Dark mode toggle at top if brand supports dark mode

**What goes in the HTML (brand token visual questions):**
- Primary color candidates: rendered as buttons, links, and highlighted text — not just hex swatches
- Typography pairings: heading + body rendered at real scale with real brand copy (from GM0)
- Border radius scale: `0px / 4px / 8px / 12px / 9999px` — rendered on a button and a card
- Shadow depth options: none / subtle / medium / strong — rendered on a card surface
- Dark vs light vs both: rendered as a split-screen surface comparison

**What stays in markdown only:**
- Logo rules, clear space, forbidden uses
- Font licensing notes
- Off-limits colors (verbal constraint — not visual)

**After user answers the HTML audit:**
- Populate `GM1-Visual-Audit.md` answers section with confirmed token values
- Proceed to Phase 2 (Styles.md Creation) with locked decisions

**STOP:** Present both file paths. Wait for user to review HTML first, then confirm markdown.

---

## 🎨 PHASE 2: STYLES.MD CREATION

**Trigger:** User answers audit questions.

**Action:** Generate `GM/GM1 - [BrandName] - Styles.md`

### File Structure

```markdown
# GM1 — Visual DNA: [Brand Name]

> **INHERITANCE RULE:** All sub-project G1 files inherit this file.
> Sub-project G1 ONLY documents overrides and project-specific additions.

## 🎨 Color Palette

### Brand Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `--color-primary` | #XXXXXX | Main CTAs, links, highlights |
| `--color-primary-hover` | #XXXXXX | Hover state of primary |
| `--color-secondary` | #XXXXXX | Supporting accents |
| `--color-secondary-hover` | #XXXXXX | |

### Semantic Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `--color-success` | #XXXXXX | Confirmations, success states |
| `--color-warning` | #XXXXXX | Warnings, alerts |
| `--color-error` | #XXXXXX | Errors, destructive actions |
| `--color-info` | #XXXXXX | Informational |

### Neutrals
| Token | Hex | Usage |
|-------|-----|-------|
| `--color-bg` | #XXXXXX | Page background |
| `--color-surface` | #XXXXXX | Card/panel background |
| `--color-border` | #XXXXXX | Dividers, input borders |
| `--color-text-primary` | #XXXXXX | Body text |
| `--color-text-secondary` | #XXXXXX | Muted text, labels |
| `--color-text-disabled` | #XXXXXX | Disabled states |

### Dark Mode (if applicable)
> Override tokens for dark mode. Only list tokens that change.

## ✏️ Typography

### Font Families
- **Heading:** [Font Name] — [Google Fonts / System / Custom]
- **Body:** [Font Name]
- **Mono:** [Font Name] (for code, technical values)

### Type Scale
| Token | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `--text-xs` | 12px | 400 | 1.4 | Labels, captions |
| `--text-sm` | 14px | 400 | 1.5 | Secondary body |
| `--text-base` | 16px | 400 | 1.6 | Primary body |
| `--text-lg` | 18px | 500 | 1.5 | Lead text |
| `--text-xl` | 20px | 600 | 1.4 | H4 |
| `--text-2xl` | 24px | 600 | 1.3 | H3 |
| `--text-3xl` | 30px | 700 | 1.2 | H2 |
| `--text-4xl` | 36px | 700 | 1.1 | H1 |
| `--text-5xl` | 48px | 800 | 1.0 | Hero |

## 📐 Spacing Scale
| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Micro gaps |
| `--space-2` | 8px | Tight spacing |
| `--space-3` | 12px | |
| `--space-4` | 16px | Default padding |
| `--space-5` | 24px | Section spacing |
| `--space-6` | 32px | |
| `--space-8` | 48px | Large sections |
| `--space-10` | 64px | Hero/page sections |

## 🔲 Border Radius
| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | Xpx | Subtle (inputs, small cards) |
| `--radius-md` | Xpx | Default (buttons, cards) |
| `--radius-lg` | Xpx | Large cards, modals |
| `--radius-full` | 9999px | Pills, avatars |

## 🌑 Shadows
| Token | Value | Usage |
|-------|-------|-------|
| `--shadow-sm` | ... | Subtle lift |
| `--shadow-md` | ... | Cards, dropdowns |
| `--shadow-lg` | ... | Modals, popovers |

## 🎬 Motion
- **Duration:** Fast: 150ms / Default: 250ms / Slow: 400ms
- **Easing:** `ease-out` for entrances, `ease-in` for exits
- **Principle:** [e.g., "Subtle and purposeful. Never animate for decoration."]

## 🖼️ Logo Rules
- Minimum size: [X]px
- Clear space: [X]px on all sides
- Approved backgrounds: [list]
- Forbidden: [stretching / color changes / etc.]
```

---

## 🖥️ PHASE 3: STYLES.HTML CREATION

**Action:** Generate `GM/GM1 - [BrandName] - Styles.html`

This is the **Brand Design System Showcase** — a single self-contained HTML file rendering:

1. **Token Panel** — all color swatches, type specimens, spacing visual scale, radius examples
2. **Typography Showcase** — all heading levels + body + mono
3. **Color System** — all tokens as labeled swatches, dark/light toggle if applicable
4. **Spacing & Radius Reference** — visual grid

**Rules:**
- Single file, zero dependencies. All CSS inline via `<style>`.
- CSS variables MUST exactly match the token names defined in the `.md`
- Use real brand copy from GM0 for all text specimens (not Lorem ipsum)
- Dark mode toggle at top if dark mode is defined in GM1
- This file renders TOKENS only — not full components (components are in project-level G1-Styles.html)

---

## ✅ PHASE 4: VALIDATION

Before saving both files, verify:
- [ ] All color tokens have hex values (no "TBD")
- [ ] Typography has both heading and body fonts named
- [ ] HTML file CSS variables match `.md` token names exactly
- [ ] No external CDN links in HTML
- [ ] GM1 is under 200 lines in `.md` — if longer, extract to separate files

**Output in chat:**
> "GM1 Visual DNA created. `GM/GM1-[Brand]-Styles.md` is the token law. `GM/GM1-[Brand]-Styles.html` is the visual proof. Sub-project G1 files will inherit from this and only document overrides."
