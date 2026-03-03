# INS-P1-G1-HTML: Project Style Guide Protocol

**System ID:** `INS-P1-G1-HTML`
**Trigger:** User says "Create Style Guide", "Generate Component HTML", "Make G1 HTML", or "Build component showcase"
**Input Requirement:** `GENERAL/G1 - Styles.md` (Mandatory). If `GM/GM1` exists, read it first.
**Output Target:** `GENERAL/G1 - Styles.html`

---

## 🎯 STRATEGIC INTENT

This protocol generates a **single self-contained HTML file** that visually renders every UI component defined in `G1-Styles.md`. It is the **living visual contract** for this project — every developer and AI session reads this file to understand what buttons, cards, inputs, and modals look like before writing a single line of feature code.

**Key Rules:**
- This file renders components ONLY. It is NOT a page mockup.
- If `GM1` exists, this file shows ONLY the project-specific OVERRIDES, then imports GM1 tokens as base. Never duplicate GM1 content.
- If no `GM1` exists, this file is the full source of truth for all visual tokens.

---

## 🕵️ PHASE 1: AUDIT

**Step 1: Read Sources**
- Read `GENERAL/G1 - Styles.md` (required)
- Read `GM/GM1-[Brand]-Styles.md` if it exists (brand base)
- Read any existing `NOTES/General Styles/` for context

**Step 2: Create Audit File**
- **Create:** `NOTES/General Styles/AUDIT/Style-Guide-Audit.md`
- **Content:**
  - List all components found in G1
  - Flag any missing states (hover, disabled, focus, error)
  - Flag any components referenced in features but not in G1
  - Note if GM1 override delta is applied
- **Output in chat:** "Audit complete. Found [N] components. [X] missing states. Check `NOTES/General Styles/AUDIT/Style-Guide-Audit.md`. Proceed?"

**STOP:** Wait for user confirmation.

---

## 🎨 PHASE 2: COMPONENT SHOWCASE GENERATION

**Trigger:** User approves audit.

**Action:** Generate `GENERAL/G1 - Styles.html`

### Required Component Sections

The HTML file MUST include ALL of the following in order:

```
1.  Design Tokens Panel     — color swatches, font specimens, spacing scale, radius scale
2.  Typography              — H1–H6, body, caption, code, label
3.  Buttons                 — Primary, Secondary, Ghost, Danger, Icon-only, Loading state, Disabled
4.  Inputs                  — Text, Email, Password, Search, Textarea, Disabled, Error state, Success state
5.  Select / Dropdown       — Default, Open state, Disabled
6.  Checkboxes & Radios     — Unchecked, Checked, Disabled
7.  Toggle / Switch         — Off, On, Disabled
8.  Badges & Tags           — All color variants, sizes
9.  Alerts / Banners        — Info, Success, Warning, Error
10. Cards                   — Default, Hover, With image, With action footer
11. Modals                  — Default layout, Confirm dialog variant
12. Navigation              — Navbar, Sidebar (collapsed + expanded), Breadcrumb, Tabs
13. Tables                  — Default, Striped, With actions
14. Loading States          — Spinner, Skeleton loader
15. Empty States            — Illustration placeholder + copy
16. Forms                   — Full login form, Full signup form (using the components above)
```

### HTML File Rules

- **Single file, zero dependencies.** All CSS is `<style>` inline. No external CDN.
- **Dark/Light toggle** button at the top if project supports both modes.
- **Token variables:** Use CSS custom properties (`--color-primary`, `--font-heading`, etc.) matching G1 names exactly.
- **Section headers** with `<!-- SECTION: Buttons -->` comments for easy navigation.
- Each component must show ALL its states side by side (not just the default).
- Use real copy, not `Lorem ipsum`. Base copy on `G0 - Idea.md` brand tone.

---

## ✅ PHASE 3: VALIDATION

**Step 1: Self-check**
Before saving, verify:
- [ ] All 15 component sections are present
- [ ] CSS variables match G1 token names exactly
- [ ] No external CDN links
- [ ] Dark mode toggle works (if applicable)
- [ ] File opens and renders correctly in a browser (no broken references)

**Step 2: Output**
- Save to `GENERAL/G1 - Styles.html`
- Output in chat: "Style Guide created at `GENERAL/G1 - Styles.html`. Open in browser to review all [N] components."
