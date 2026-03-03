# INS-P1B-G1-HTML: Style Guide Retrofit Protocol

**System ID:** `INS-P1B-G1-HTML`
**Trigger:** User says "Create Style Guide from existing code", "Retrofit G1 HTML", or "Generate component showcase from existing styles"
**Input Requirement:** `GENERAL/G1 - Styles.md` (Mandatory). Existing codebase with CSS/Tailwind.
**Output Target:** `GENERAL/G1 - Styles.html`

---

## 🎯 STRATEGIC INTENT

This protocol is the **Evolution** version of `INS-P1-G1-HTML`. The project already has a G1 file (created by `INS-P1B-AUDIT`) and existing code. This protocol generates the visual HTML component showcase by READING the real code, not inventing it.

**Key Difference from P1 version:** This reads ACTUAL CSS/Tailwind/component files to extract real token values — it does not ask design questions. It reports what IS, not what SHOULD BE.

---

## 🕵️ PHASE 1: FORENSIC SCAN

**Step 1: Read G1 + Scan Code**
- Read `GENERAL/G1 - Styles.md`
- Scan for actual CSS variables in: `tailwind.config.*`, `globals.css`, `theme.css`, `tokens.css`, component files
- Extract real hex values, font names, radius values, shadow definitions

**Step 2: Conflict Detection**
- **Create:** `NOTES/General Styles/AUDIT/Style-Guide-Retrofit-Audit.md`
- **Flag:**
  - Tokens in G1 that don't match actual code values
  - Components used in code that are NOT in G1
  - Inconsistent values (e.g., 3 different button radii found in code)
- **Output in chat:** "Scan complete. Found [N] components, [X] conflicts between G1 spec and actual code. Review `Style-Guide-Retrofit-Audit.md` before I generate the HTML. Proceed?"

**STOP:** Wait for user confirmation.

---

## 🖼️ PHASE 1B: HTML CONFLICT VISUALIZER

**Trigger:** Immediately after creating `Style-Guide-Retrofit-Audit.md`. Created ALONGSIDE it — not instead of it.

**Rule:** Conflicts between G1 spec and actual code cannot be resolved by reading two number tables. Render both sides. HTML goes FIRST — user resolves conflicts visually, then markdown audit gets annotated with decisions.

**Action:** Create `NOTES/General Styles/AUDIT/Retrofit-Conflict-Audit.html` alongside the markdown.

**Structure:**
- One `<section>` per conflict found in the scan
- Each section shows: **G1 spec version** (left) vs **Actual code version** (right)
- Label each pair: `✅ Keep G1` / `✅ Keep Code` / `🛠 Define New`
- Only visual conflicts get an HTML section — logic/structure conflicts stay in markdown
- **Each option is a clickable card.** Clicking marks it selected (accent border + checkmark). Selections persist via JS `localStorage`.
- A **"Copy Answers"** button at the top generates a plain-text summary of all selections the user can paste back into chat or the markdown audit.

**Visual conflicts that get HTML sections:**
- Radius mismatch (G1 says 8px, code uses 12px → render both on a card)
- Shadow mismatch (G1 spec vs actual `box-shadow` found → render both)
- Color mismatch (G1 hex vs actual hex in code → render both as button + card surface)
- Font mismatch (G1 font vs font actually imported in code → render both at heading + body scale)
- Component variants in code not documented in G1 → render the undocumented variant

**What stays in markdown only:**
- Missing token declarations (code uses hardcoded values, no variables)
- Components in G1 not yet implemented in code (implementation gap — not a visual conflict)

**After user resolves conflicts:**
- Annotate `Style-Guide-Retrofit-Audit.md` with decisions
- Proceed to Phase 2 (Showcase Generation) using the winning values

**STOP:** Present both file paths. Wait for user to resolve HTML conflicts first.

---

## 🎨 PHASE 2: SHOWCASE GENERATION

**Trigger:** User approves audit.

**Action:** Generate `GENERAL/G1 - Styles.html`

**Rules:**
- Use ACTUAL values from code scan (not G1 spec values where conflicts exist — flag the conflict in an HTML comment)
- Single file, zero dependencies. All CSS inline.
- Render all components found in the codebase — not just what G1 lists
- For each component with inconsistent values in code, render ALL variants side by side with a red "⚠️ Inconsistency" label
- Dark mode toggle if dark mode tokens found

**Required sections** — same 15 as `INS-P1-G1-HTML`. If a component section is not found in the existing codebase, include a placeholder marked: `<!-- NOT FOUND IN CODEBASE — Define in G1 and implement in F1 -->`

---

## ✅ PHASE 3: VALIDATION

- [ ] HTML tokens match real code values (not invented)
- [ ] All inconsistencies are flagged with ⚠️ in the HTML
- [ ] Conflicts doc exists at `Style-Guide-Retrofit-Audit.md`
- [ ] No external CDN links

**Output in chat:**
> "Style Guide retrofit complete. `GENERAL/G1-Styles.html` reflects the ACTUAL state of your codebase. [X] inconsistencies flagged. Address them in G1 and F1 to align design system."
