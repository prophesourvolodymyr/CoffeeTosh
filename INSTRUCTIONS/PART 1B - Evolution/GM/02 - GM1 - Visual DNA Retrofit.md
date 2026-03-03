# INS-GM1-AUDIT: Visual DNA Retrofit Protocol

**System ID:** `INS-GM1-AUDIT`
**Trigger:** User says "Extract Visual DNA", "Retrofit GM1", "Build brand design system from existing projects", or "Create GM1 from existing styles"
**Input Requirement:** Existing sub-project `GENERAL/G1` files AND/OR CSS/Tailwind config files
**Output Target:** `GM/GM1 - [BrandName] - Styles.md` + `GM/GM1 - [BrandName] - Styles.html`

---

## 🎯 STRATEGIC INTENT

This is the **Evolution** version of `INS-GM1`. Real projects exist. Styles have been built. This protocol forensically extracts the common visual DNA shared across sub-projects and elevates it to the GM layer, creating a brand design system from what's already been built — not what's theoretically ideal.

**Goal:** Find the intersection. What colors, fonts, and patterns appear across ALL sub-projects? That intersection IS the brand visual DNA.

---

## 🕵️ PHASE 1: FORENSIC VISUAL EXTRACTION

**Step 1: Read All Style Sources**
For each sub-project, read (in order):
1. `GENERAL/G1 - Styles.md`
2. `tailwind.config.*`, `tailwind.config.js/ts`
3. `globals.css`, `theme.css`, `variables.css`, `tokens.css`
4. Any component library config files

**Step 2: Extract & Compare**
Build a comparison table:

| Token | Sub-Project A | Sub-Project B | Sub-Project C | Consensus? |
|-------|--------------|--------------|--------------|------------|
| Primary Color | #0055FF | #0050FA | #0055FF | ✅ #0055FF |
| Heading Font | Inter | Inter | Poppins | ⚠️ Conflict |
| Border Radius | 8px | 8px | 12px | ⚠️ Conflict |

**Step 3: Conflict Report**
- **Create:** `NOTES/Brand/GM1-Visual-Retrofit-Audit.md`
- List all conflicts with recommendation for each
- Flag tokens that ONLY exist in one project (project-specific, stays in G1)
- Flag tokens shared by ALL projects (brand-level, goes into GM1)
- **Output in chat:** "Visual extraction complete. Found [N] shared tokens, [X] conflicts. Review audit. I'll ask for decisions on conflicts only."

**STOP:** Present only conflict-resolution questions to user.

---

## 🖼️ PHASE 1B: HTML CONFLICT VISUALIZER (Brand Token Conflicts)

**Trigger:** Immediately after creating `GM1-Visual-Retrofit-Audit.md`. Created ALONGSIDE it — not instead of it.

**Rule:** A table showing `Inter` vs `Poppins` means nothing until you see them rendered at H1 scale with real brand copy. Conflicting brand tokens must be resolved visually — not by reading names. HTML goes FIRST — confirmed decisions populate the markdown audit.

**Action:** Create `NOTES/Brand/GM1-Visual-Retrofit-Conflict.html` alongside the markdown.

**Structure:**
- One `<section>` per conflicting token across sub-projects
- Each section shows all competing values rendered on a realistic surface side-by-side
- Renders using real brand copy from GM0 (not Lorem Ipsum)
- Dark mode toggle at top if any sub-project uses dark mode
- **Each option is a clickable card.** Clicking marks it selected (accent border + checkmark). Selections persist via JS `localStorage`.
- A **"Copy Answers"** button at the top generates a plain-text summary of all selections the user can paste back into chat or the markdown audit file.

**What gets an HTML section (visual conflicts only):**
- Primary color conflict: render each candidate as button + card header + link text
- Font conflict: render each font at H1 + H3 + body scale with real brand copy
- Border radius conflict: render all candidate values on a button + a card
- Shadow conflict: render all variants on the same card surface at same elevation
- Any token where two sub-projects disagree and the difference is perceivable visually

**What stays in markdown only:**
- Tokens that only appear in one sub-project (project-specific, stays in G1 — no conflict to render)
- Spacing scale conflicts (numbers in a table are fine)
- Logo rule conflicts (verbal decision)

**After user resolves conflicts:**
- Annotate `GM1-Visual-Retrofit-Audit.md` with confirmed brand-level decisions
- Proceed to Phase 2 (GM1 Creation) with all conflicts resolved

**STOP:** Present both file paths. Wait for user to resolve HTML conflicts first.

---

## 🎨 PHASE 2: GM1 CREATION

**Trigger:** User resolves conflicts.

**Action:** Generate both output files using identical structure as `INS-GM1` Phase 2 and Phase 3.

**Key rule for the `.md`:** Only include tokens that appear in 2+ sub-projects OR that the user explicitly promotes to brand level. Project-specific tokens stay in their respective G1 files.

**Key rule for the `.html`:** Show ONLY the brand-level tokens (colors, typography, spacing, radius). Do NOT include project-specific components — those belong in each project's `G1-Styles.html`.

---

## ✅ PHASE 3: VALIDATION

- [ ] Every token in GM1 is justified (appears in 2+ projects OR explicitly chosen)
- [ ] Conflicts from audit are resolved — no unresolved items
- [ ] HTML uses exact token names from the `.md`
- [ ] Sub-project G1 files are now delta-only (any token repeated in both G1 and GM1 should be removed from G1)

**Output in chat:**
> "GM1 Visual DNA retrofit complete. [N] tokens elevated to brand level. [X] tokens remain project-specific in their G1 files. Sub-project G1 files should now only contain overrides — run `INS-P1B-G1-HTML` on each project to regenerate their component showcases against the new brand base."
