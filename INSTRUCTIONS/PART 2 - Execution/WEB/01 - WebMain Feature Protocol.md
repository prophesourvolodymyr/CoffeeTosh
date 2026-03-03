# INS-WEB-EXEC-01: WebMain Feature Protocol

**System ID:** `INS-WEB-EXEC-01`
**Trigger:** User says "Build WebMain", "Convert WebMain to feature", "Initialize WebMain feature", or "Run WebMain build"
**Input Requirement:** `NOTES/WebMain/` with N1 + at least one P-Doc. Run Part 1 Genesis or Part 1B Evolution WEB protocols first if missing.
**Output Target:** `FEATURES/F[x]-WebMain/`

---

## 🎯 STRATEGIC INTENT

This protocol converts the `NOTES/WebMain/` research into a production-ready `FEATURES/F[x]-WebMain/` structure. Pages become phases. P-Docs become task lists.

**This protocol works for both:**
- New websites initialized via `PART 1 - Genesis/WEB/`
- Existing sites onboarded via `PART 1B - Evolution/WEB/`

The source is always `NOTES/WebMain/`. The output is always `FEATURES/F[x]-WebMain/`.

**Folder structure produced:**
```
FEATURES/F[x]-WebMain/
├── F[x]-Doc.md
├── F[x]-Progress.md
└── PAGES/
    ├── P1-[PageName]/
    │   └── P[n]-[PageName]-Todo.md
    ├── P2-[PageName]/
    │   └── P[n]-[PageName]-Todo.md
    └── ...
```

> ⚠️ UI/ folders from `NOTES/WebMain/PAGES/` are NEVER copied here. They stay in NOTES.

---

## ✅ PHASE 1: VERIFY PREREQUISITES

**Check the following — STOP if any are missing:**

- [ ] `NOTES/WebMain/ORIGINAL IDEA/N1-WebMain.md` exists
- [ ] At least one `NOTES/WebMain/PAGES/P[n]-*/P-Doc-*.md` exists
- [ ] F[x] slot is available in `FEATURES/`

If N1 or P-Docs are missing → output:
> "WebMain notes are incomplete. Run `PART 1 - Genesis/WEB/01 - WebMain Init Protocol` (new project) or `PART 1B - Evolution/WEB/01 - WebMain Content Audit` (existing project) first."

**STOP.**

---

## 🏗️ PHASE 2: ASSIGN F-NUMBER & CREATE STRUCTURE

**Step 1:** Scan `FEATURES/` to find the next available F number.

**Step 2:** Create folder structure:
```
FEATURES/F[x]-WebMain/
└── PAGES/
    ├── P1-[PageName]/
    ├── P2-[PageName]/
    └── ...  (one folder per P-Doc found in NOTES/WebMain/PAGES/)
```

---

## 📋 PHASE 3: CREATE F-DOC

**Create:** `FEATURES/F[x]-WebMain/F[x]-Doc.md`

```markdown
# F[x]-Doc — WebMain

## Vision
[Copy from N1-WebMain.md]

## Audience
[From N1]

## Tone / Vibe
[From N1]

## Global Shell
- **Navigation:** [Top nav / Sidebar / Hamburger — from N1 or P-Docs]
- **Header:** [Behavior — sticky / transparent / standard]
- **Footer:** [Content summary]
- **Dark mode:** [Yes / No / Both]

## Visual System
- Inherits from: `GENERAL/G1-Styles.md` (if exists)
- Component library: [Tailwind / shadcn / CSS Modules / other]

## Page Map
| # | Page | Route | P-Doc |
|---|------|-------|-------|
| P1 | [Name] | / | `NOTES/WebMain/PAGES/P1-.../P-Doc-....md` |
| P2 | [Name] | /[route] | `NOTES/WebMain/PAGES/P2-.../P-Doc-....md` |

## Source Notes
`NOTES/WebMain/` — all research, audits, and P-Docs live here.
```

---

## ✅ PHASE 4: CONVERT P-DOCS → P-TODOS

**For each `NOTES/WebMain/PAGES/P[n]-[PageName]/P-Doc-[PageName].md`:**

Create: `FEATURES/F[x]-WebMain/PAGES/P[n]-[PageName]/P[n]-[PageName]-Todo.md`

```markdown
# P[n]-Todo — [PageName]

> Source: `NOTES/WebMain/PAGES/P[n]-[PageName]/P-Doc-[PageName].md`

## Route
`/[route]`

## Tasks

### [Section Name]
- [ ] Build [section] layout
- [ ] Add [content/copy] from P-Doc
- [ ] Wire up CTA → [target]
- [ ] Verify responsive behavior

### [Section Name]
- [ ] ...

## Known Issues (from audit)
- [ ] [Issue flagged during audit phase]
```

---

## 📊 PHASE 5: CREATE F-PROGRESS.MD

**Create:** `FEATURES/F[x]-WebMain/F[x]-Progress.md`

Pages = phases, ordered by build priority (usually: shell/layout first, then page by page).

```markdown
# F[x]-Progress — WebMain

## 🏗️ Phase 0: Global Shell
- [ ] Implement Header component
- [ ] Implement Footer component
- [ ] Set up routing structure
- [ ] Configure global styles / theme

## 📄 Phase 1: [P1 PageName]
- [ ] [From P1-Todo.md — copy top-level tasks]

## 📄 Phase 2: [P2 PageName]
- [ ] [From P2-Todo.md]

## 📄 Phase [n]: [Pn PageName]
- [ ] ...

## 🛡️ Final Phase: QA & Launch Prep
- [ ] Cross-browser check
- [ ] Mobile responsiveness audit
- [ ] SEO metadata (title, description, og:image per page)
- [ ] Performance check (images optimized, no render-blocking)
```

---

## 🛑 EXECUTION CONSTRAINTS

1. **NOTES ARE READ-ONLY:** This protocol reads from `NOTES/WebMain/` but never modifies it.
2. **NO UI/ IN FEATURES:** HTML mockup files from `NOTES/WebMain/PAGES/*/UI/` are never copied to `FEATURES/`.
3. **P-DOC IS LAW:** If content in P-Todo contradicts P-Doc, stop and flag it. P-Doc wins.
4. **GLOBAL SHELL FIRST:** Phase 0 (Header/Footer/Routing) must always be the first build phase.
5. **ONE WEBMAIN:** Never create multiple WebMain features. All public pages belong to F[x]-WebMain.
