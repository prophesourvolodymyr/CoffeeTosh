# INS-WEB-EVOLUTION-01: WebMain Content Audit Protocol

**System ID:** `INS-WEB-EVOLUTION-01`
**Trigger:** User says "Audit website", "Map existing pages", "Onboard this site", or "Run WebMain audit"
**Input Requirement:** Existing website codebase. G-files read if available.
**Output Target:** `NOTES/WebMain/` — per-page Audits, Style Audit, P-Docs, N1

---

## 🎯 STRATEGIC INTENT

This protocol **onboards an existing website** into the F-Cycle system. It forensically extracts what pages exist, what they say, and how they look — then packages that knowledge into P-Docs and N1 so the project can be managed going forward.

**This is NOT a redesign.** It documents what IS, not what should be.

**Folder structure produced:**
```
NOTES/WebMain/
├── ORIGINAL IDEA/
│   └── N1-WebMain.md
├── AUDIT/
│   ├── P1-[PageName]-Audit.md
│   ├── P2-[PageName]-Audit.md
│   ├── ...
│   ├── Style-Audit.md
│   └── WebMain-Audit-Summary.md
└── PAGES/
    ├── P1-[PageName]/
    │   ├── P-Doc-[PageName].md
    │   └── UI/                     ← Pre-UI mockups (HTML). Never goes to FEATURES/
    ├── P2-[PageName]/
    │   ├── P-Doc-[PageName].md
    │   └── UI/
    └── ...
```

---

## 📖 PHASE 1: READ CONTEXT

**Step 1: Check for G-files**
- If `GENERAL/G0 - Idea.md` exists → read it for project purpose and audience.
- If `GENERAL/G1 - Styles.md` exists → read it (skip Style Audit in Phase 4 — G1 already captures this).
- If neither exists → proceed with codebase only.

---

## 🔍 PHASE 2: PAGE DISCOVERY

**Action:** Scan the codebase for all pages/routes.

**Scan targets:**
- `pages/`, `app/`, `src/pages/`, `src/app/`
- Navigation components, header menus, router config files
- Sitemap files (`sitemap.xml`, `sitemap.ts`)
- Any MDX/markdown content directories

**Output per page found:**
```
P[n] — [PageName]: [route] — [file path]
```

**Output in chat:** List all discovered pages and ask:
> "Found [N] pages. Does this look complete? Any pages missing or should be excluded?"

**STOP.** Wait for user confirmation before proceeding.

---

## 📋 PHASE 3: PAGE AUDITS

**Trigger:** User confirms the page list.

**For each page, create:** `NOTES/WebMain/AUDIT/P[n]-[PageName]-Audit.md`

```markdown
# P[n] — [PageName] Audit

## Route
`/[route]`

## Page Type
[Landing / About / Pricing / Blog / Contact / Legal / Other]

## Sections Found
- [ ] [Section name]: [brief description of content]
- [ ] [Section name]: [brief description of content]

## Key Copy Extracted
[Most important headline or message on this page]

## Primary CTA
[What action the page drives]

## Issues Found
- [ ] [e.g., "Inconsistent button styles vs rest of site"]
- [ ] [e.g., "Missing meta description"]
- [ ] [e.g., "Mobile layout broken below 375px"]

## Questions
- [Anything unclear — should this page stay? be merged? be rewritten?]
```

---

## 🎨 PHASE 4: STYLE AUDIT

**Skip this phase if `GENERAL/G1 - Styles.md` already exists.**

**Create:** `NOTES/WebMain/AUDIT/Style-Audit.md`

```markdown
# WebMain Style Audit

## Colors Found
| Usage | Value | Token name (if any) |
|-------|-------|---------------------|
| Primary | #XXXXXX | |
| Background | #XXXXXX | |
| Text | #XXXXXX | |

## Typography Found
- Heading font: [name or fallback stack]
- Body font: [name or fallback stack]
- Sizes used: [list]

## Spacing Patterns
[e.g., "Most sections use 80px top/bottom padding. Cards use 24px."]

## Inconsistencies
- [ ] [e.g., "3 different shades of the primary color used"]
- [ ] [e.g., "Two different font families for body text"]

## Notes for G1
[What should be captured in G1 - Styles.md if it doesn't exist yet]
```

---

## 📊 PHASE 5: AUDIT SUMMARY

**Create:** `NOTES/WebMain/AUDIT/WebMain-Audit-Summary.md`

```markdown
# WebMain Audit Summary

## Pages Found
| # | Page | Route | Status |
|---|------|-------|--------|
| P1 | [Name] | / | ✅ Good / ⚠️ Issues / 🔴 Broken |

## Critical Issues
- [ ] [Issue requiring immediate decision]

## Questions for User
1. [Decision needed before P-Docs can be written]
2. ...

## Recommendation
[e.g., "7 pages found, all have content. 2 pages have mobile issues. Style is mostly consistent. Ready to create P-Docs."]
```

**Output in chat:** "Audit complete. Review `NOTES/WebMain/AUDIT/WebMain-Audit-Summary.md` and answer any questions. Say 'Audits approved' when ready."

**STOP.** Wait for user review and confirmation.

---

## 📄 PHASE 6: CREATE P-DOCS

**Trigger:** User approves audit summary.

**For each page, create:** `NOTES/WebMain/PAGES/P[n]-[PageName]/P-Doc-[PageName].md`

Also create `NOTES/WebMain/PAGES/P[n]-[PageName]/UI/` folder (empty — for future mockups).

```markdown
# P-Doc — [PageName] (P[n])

## Route
`/[route]`

## Purpose
[What this page exists to do]

## Sections
### [Section Name]
- **Content:** [Extracted/confirmed content for this section]
- **CTA:** [If applicable]
- **Notes:** [Design intent, issues to fix, special behavior]

### [Section Name]
...

## Global Shell
- Header: [Shared / Hidden / Transparent]
- Footer: [Shared / Custom / Hidden]

## Known Issues to Fix
- [ ] [Issue flagged in audit]
```

---

## 📝 PHASE 7: CREATE N1

**Create:** `NOTES/WebMain/ORIGINAL IDEA/N1-WebMain.md`

```markdown
# N1 — WebMain: [Project Name]

## What This Site Is
[Extracted purpose from audit + G0 if available]

## Audience
[Who this site is for]

## Tone / Vibe (Observed)
[What the current site communicates visually and tonally]

## Page Map
| # | Page | Route | Purpose |
|---|------|-------|---------|
| P1 | Home | / | ... |

## Issues to Address
[Top-level issues from audit summary]
```

---

## 🛑 EXECUTION CONSTRAINTS

1. **READ ONLY until Phase 6:** Do not create P-Docs before audit is approved.
2. **EXTRACT, DON'T FIX:** Document what exists. Fixes happen in execution (Part 2).
3. **UI STAYS IN NOTES:** HTML mockups in `UI/` folders are for review — never copied to `FEATURES/`.
4. **SKIP STYLE AUDIT IF G1 EXISTS:** Don't duplicate what G1 already captures.
5. **STOP GATES:** Confirm page list (Phase 2) and audit summary (Phase 5) before proceeding.
