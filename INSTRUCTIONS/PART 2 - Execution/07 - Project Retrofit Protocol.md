# INS-P2-07: Project Retrofit Protocol

**System ID:** `INS-P2-07`
**Trigger:** User says "Retrofit this project", "Migrate to F-Cycle", "Bring existing code into system", or "Run Project Retrofit"
**Input Requirement:** Existing codebase. G-files must exist (`GENERAL/G0`, `G1`, `G2` minimum). Run `PART 1B - Evolution/` audits first if G-files are missing.
**Output Target:** `FEATURES/F[x]-[Name]/` containing migrated feature structure

---

## 🎯 STRATEGIC INTENT

This protocol takes ANY existing project that was built outside of F-Cycle and migrates it into the `FEATURES/` structure. It works for apps, APIs, websites, admin panels — any project type.

The goal is NOT to rewrite the code. The goal is to **impose structure** on existing code so the F-Cycle system can manage it going forward.

**Website Projects:** Use `P-Doc` files instead of `R1` logic docs for each page. A P-Doc captures content, layout intent, sections, and CTA — not logic. See the P-Doc template at the end of this protocol.

---

## 🕵️ PHASE 1: DISCOVERY

**Step 1: Read G-Files**
- Read `GENERAL/G0`, `G1`, `G2` (mandatory — run Part 1B audits first if missing)
- Read `GM/` files if they exist (brand context)

**Step 2: Map Existing Code**
Scan the existing codebase and produce a mental map of:
- **Entry points:** pages, routes, screens, API endpoints
- **Shared code:** components, utilities, hooks, middleware
- **Assets:** images, fonts, icons, static files
- **Config:** env files, build configs, CI/CD

**Step 3: Create Retrofit Audit**
- **Create:** `NOTES/[ProjectName]/Retrofit-Audit.md`
- **Content:**
  ```markdown
  ## Entry Points Found
  - [route/page/screen] → will become F[x] feature
  
  ## Shared Code Found
  - [component/utility] → will live in F1 or shared F[x]
  
  ## Assets Found
  - [path] → will move to F[x]/ASSETS/
  
  ## Issues Found
  - [ ] [code smell / tech debt to address]
  - [ ] [inconsistency with G1 styles]
  - [ ] [missing error handling]
  
  ## Proposed F[x] Assignment
  - F1: Design System (shared components, styles)
  - F[2]: [Feature Group A]
  - F[3]: [Feature Group B]
  ```
- **Output in chat:** "Discovery complete. Found [N] features to migrate. Proposed F[x] assignments in `Retrofit-Audit.md`. Approve the mapping?"

**STOP:** Wait for user approval of the F[x] mapping.

---

## 🏗️ PHASE 2: FEATURE CONTAINER SETUP

**Trigger:** User approves mapping.

**For each identified feature:**

**Step 1: Create F[x] folder**
```
FEATURES/F[x] - [Name]/
├── F[x]-Doc.md
├── F[x]-Progress.md
└── [subdirectories as needed]
```

**Step 2: Create F[x]-Doc.md**
Standard F-Doc structure, with an additional **Legacy Source** section:
```markdown
## 🗂️ Legacy Source
- **Original Location:** `[path to existing code]`
- **Migration Strategy:** [Move / Refactor / Rewrite]
- **Estimated Effort:** [Low / Medium / High]
```

**Step 3: Create F[x]-Progress.md**
Organise the retrofit work into phases:
```markdown
## ✅ Phase 1: Migration (Move Files)
- [ ] Move [file] to F[x]/
- [ ] Update imports

## 🔧 Phase 2: Refactor (Align to G-Files)
- [ ] Apply G1 design tokens to [component]
- [ ] Replace hardcoded colors with CSS variables

## 🧹 Phase 3: Cleanup (Remove Tech Debt)
- [ ] [Issue from audit]
```

---

## 📄 WEBSITE PROJECTS: P-DOC VARIANT

If this is a website/marketing project, each page gets a **P-Doc** instead of an R1 logic doc:

```markdown
# P-Doc: [Page Name]

## 📌 Purpose
[One sentence: what this page does for the visitor]

## 👤 Target Visitor
[Who lands here and what they want]

## 📐 Sections (top → bottom)
1. **[Section Name]:** [content description + copy direction]
2. **[Section Name]:** [...]

## 🎯 Primary CTA
- **Button:** [label]
- **Action:** [what happens]

## 📊 Success Metric
[How we know this page is working: conversion, time on page, etc.]

## ⚠️ Must-Haves
- [ ] [non-negotiable requirement]
```

Store P-Docs at: `FEATURES/F[x]-[Name]/PAGES/[PageName]/P-Doc-[PageName].md`

---

## ✅ PHASE 3: VALIDATION

Before closing the retrofit session:
- [ ] All legacy entry points have a corresponding F[x]
- [ ] Every F[x] has both an `-Doc.md` and `-Progress.md`
- [ ] Progress files have actionable, checkbox-based todos
- [ ] No orphaned code left unmapped
- [ ] Website projects: every page has a P-Doc

**Output in chat:**
> "Retrofit complete. [N] features scaffolded. [X] migration tasks, [Y] refactor tasks in Progress files. Recommended starting point: F[x]-[highest priority]."
