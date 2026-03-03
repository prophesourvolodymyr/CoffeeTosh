# INS-01-AUDIT: Design System Audit (Target: G1)

**System ID:** `INS-01-AUDIT`
**Trigger:** User says "Audit Styles", "What does this look like?", or "Create G1 from existing code"
**Input Requirement:** An existing codebase with visible UI
**Output Target:** `GENERAL/G1 - Styles.md`

---

## 🎯 STRATEGIC INTENT

This protocol answers ONE question: *"How does this project look?"*

It scans CSS, Tailwind configs, theme files, and component libraries to extract the **visual language** of the project. It does NOT restructure the code or fix anything. Pure forensic extraction.

---

## 🔍 PHASE 1: FORENSIC SCAN (Read Only)

**Action:** Find all style-related files.

**Scan Targets:**
1. **CSS/SCSS Files:** `*.css`, `*.scss`, `*.less`
2. **Tailwind Config:** `tailwind.config.*`
3. **Theme Files:** `theme.ts`, `colors.ts`, `tokens.json`
4. **Component Library:** Check for shadcn, MUI, Chakra, Ant Design in dependencies
5. **Global Styles:** `globals.css`, `app.css`, `index.css`

**Extract:**
- **Design Stack:** (Tailwind? CSS Modules? Styled Components? Inline?)
- **Color Palette:** Top 10 most-used hex/rgb values
- **Typography:** Font families, sizes, weights found
- **Component Style:** Rounded corners? Flat? Shadows? Glassmorphism?
- **Theme:** Dark mode? Light mode? Both?
- **Spacing System:** Consistent spacing scale or random values?

---

## 📋 PHASE 2: DRAFT & VERIFY (The Gate)

**Action:** Create `NOTES/AUDIT/G1-Draft.md`

**Content:**
```markdown
# G1 DRAFT - Design System (Pending Approval)
**Status:** 🟡 DRAFT - Awaiting User Verification

## Detected Design Stack
- **Framework:** [Tailwind / CSS Modules / etc.]
- **Component Library:** [shadcn / MUI / Custom / None]

## Detected Color Palette
| Name (Inferred) | Value | Usage |
|-----------------|-------|-------|
| Primary | #XXXX | Buttons, Links |
| Background | #XXXX | Page BG |
| Text | #XXXX | Body copy |
| Accent | #XXXX | Highlights |

## Detected Typography
- **Heading Font:** [Font Name]
- **Body Font:** [Font Name]
- **Sizes:** [Scale detected]

## Detected Component Patterns
- **Borders:** [Rounded / Sharp]
- **Shadows:** [Heavy / Light / None]
- **Spacing:** [Consistent / Inconsistent]

## Issues Found
- [e.g., "5 different shades of blue used inconsistently"]
- [e.g., "No dark mode despite toggle in UI"]

## Questions for User
1. [Which color palette do you want to keep?]
2. [Is the current font intentional?]
3. [Do you want to standardize spacing?]
```

**🛑 STOP.** Output: *"I have drafted G1. Please review `NOTES/AUDIT/G1-Draft.md` and confirm or correct."*

---

## 🖼️ PHASE 2B: HTML VISUAL AUDIT

**Trigger:** Immediately after creating `G1-Draft.md` in Phase 2. Created ALONGSIDE it — not instead of it.

**Rule:** Numbers in a markdown table don't communicate visual intent. For every visual property in the draft that has multiple detected variants or open questions, render them. HTML goes FIRST — confirmed answers populate the markdown draft.

**Action:** Create `NOTES/AUDIT/G1-Visual-Audit.html` alongside the draft markdown.

**Structure:**
- One `<section>` per visual conflict or open question from the draft
- Each option rendered as a live CSS component at real size
- No external dependencies — all CSS inline
- Dark mode toggle if dark mode tokens were detected
- **Each option is a clickable card.** Clicking marks it selected (accent border + checkmark). Selections persist via JS `localStorage`.
- A **"Copy Answers"** button at the top generates a plain-text summary of all selections the user can paste back into chat or the markdown draft.

**What goes in the HTML:**
- Color conflicts: all detected variants rendered on realistic surfaces (buttons, cards, text)
- Border radius conflicts: all detected values rendered on a button + a card
- Shadow conflicts: all variants rendered on the same card surface
- Typography conflicts: all detected font/size combos rendered at heading + body scale
- Component style issues: render the inconsistent variants side-by-side with ⚠️ label

**What stays in markdown only:**
- Spacing inconsistencies (numbers are fine in a table)
- Missing dark mode tokens (checklist item — not visual)
- Architecture issues ("No design tokens found — all values are hardcoded")

**After user answers:**
- Update `G1-Draft.md` questions section with confirmed decisions
- Proceed to Phase 3 (Ratification) with resolved draft

**STOP:** Present both file paths. Wait for user to review HTML first, then confirm draft.

---

## ✅ PHASE 3: RATIFICATION (Write the Law)

**Trigger:** User approves or corrects the draft.

**Action:** Create `GENERAL/G1 - Styles.md` using the approved content.

---

## 🛑 EXECUTION CONSTRAINTS
1. **ONE G-FILE ONLY.** Do not touch G0, G2, G3, or G4.
2. **NEVER SKIP THE DRAFT.** Do not write directly to `GENERAL/`.
3. **EXTRACT, DON'T FIX.** Document what EXISTS, not what should be.
4. **FLAG INCONSISTENCIES.** If styles conflict, list them as "Issues Found."
