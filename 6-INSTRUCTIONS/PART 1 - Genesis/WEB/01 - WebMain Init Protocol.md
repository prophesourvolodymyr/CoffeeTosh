# INS-WEB-GENESIS-01: WebMain Initialization Protocol

**System ID:** `INS-WEB-GENESIS-01`
**Trigger:** User says "Initialize WebMain", "Create website structure", "Setup pages", or "Start website project"
**Input Requirement:** G0 if exists. Otherwise raw idea from user or `NOTES/`.
**Output Target:** `NOTES/WebMain/` — N1, per-page Audits, P-Docs

---

## 🎯 STRATEGIC INTENT

This protocol initializes a **new website project** (marketing site, portfolio, landing pages, services site) from scratch. It organizes all pages under a single `WebMain` concept in `NOTES/` before any code is written.

**WebMain philosophy:**
- All public-facing pages (Home, About, Pricing, Contact, etc.) are ONE feature — `WebMain`
- Pages are NOT separate features — they are phases within WebMain
- P-Docs drive the content and layout of each page. No UIDR. No R1 logic.
- UI mockups live co-located with each page — never in `FEATURES/`

**Folder structure produced:**
```
NOTES/WebMain/
├── ORIGINAL IDEA/
│   └── N1-WebMain.md
├── AUDIT/
│   ├── P1-[PageName]-Audit.md
│   ├── P2-[PageName]-Audit.md
│   └── ...
└── PAGES/
    ├── P1-[PageName]/
    │   ├── P-Doc-[PageName].md
    │   └── UI/                     ← Pre-UI mockups (HTML). Never goes to FEATURES/
    │       └── [PageName]-Mockup.html
    ├── P2-[PageName]/
    │   ├── P-Doc-[PageName].md
    │   └── UI/
    └── ...
```

---

## 📖 PHASE 1: READ CONTEXT

**Step 1: Check for G0**
- If `GENERAL/G0 - Idea.md` exists → read it. Extract: project type, audience, core offering, tone/vibe.
- If G0 is missing → ask user: *"Give me a 2–3 sentence description of this website. What is it, who is it for, and what's the main goal?"*
- Also check `NOTES/` for any raw idea files the user may have already dropped.

**Step 2: Identify Project Type**
Based on the idea, classify into one of:
- **SaaS / App** → Home, Features, Pricing, About, Blog, Login, Sign Up, Contact
- **Portfolio / Personal** → Home, Work/Projects, About, Resume/CV, Contact
- **Services / Agency** → Home, Services, About, Portfolio, Testimonials, Contact
- **E-commerce** → Home, Products, About, FAQ, Contact, Cart
- **Marketing / Landing** → Home, Features, Pricing, FAQ, CTA, Contact
- **Other** → Ask user to describe page needs

---

## 🗺️ PHASE 2: PREDICT PAGE MAP

**Action:** Based on project type, output a predicted page list:

```
Predicted Pages for [Project Type]:
P1 — Home: [one-line purpose]
P2 — About: [one-line purpose]
P3 — [Page]: [one-line purpose]
...
```

**Output in chat:** Show the predicted list and ask:
> "Here's the predicted page map. Add, remove, or rename pages — then confirm."

**STOP.** Wait for user confirmation before proceeding.

---

## 🔍 PHASE 3: PAGE AUDITS

**Trigger:** User confirms the page list.

**For each confirmed page, create:** `NOTES/WebMain/AUDIT/P[n]-[PageName]-Audit.md`

```markdown
# P[n] — [PageName] Audit

## Purpose
What is the goal of this page? What should the user do or feel after seeing it?

## Sections (predicted)
- [ ] [Section name]: [what it contains]
- [ ] [Section name]: [what it contains]

## Key Message
The ONE thing this page must communicate.

## Primary CTA
What action do we want visitors to take?

## Tone / Mood
[e.g. "Confident and warm", "Technical and clean"]

## Questions for User
- [anything unclear that needs a decision before writing P-Doc]
```

**Output in chat:** "Page audits created in `NOTES/WebMain/AUDIT/`. Review each one and answer any questions. Say 'Audits approved' when ready."

**STOP.** Wait for user to review and confirm all page audits.

---

## 📝 PHASE 4: CREATE N1

**Trigger:** User approves audits.

**Create:** `NOTES/WebMain/ORIGINAL IDEA/N1-WebMain.md`

```markdown
# N1 — WebMain: [Project Name]

## Vision
[Pulled from G0 or user input]

## Audience
[Who this site is for]

## Tone / Vibe
[e.g. "Minimal, confident, dark mode, slightly technical"]

## Page Map
| # | Page | Purpose |
|---|------|---------|
| P1 | Home | ... |
| P2 | About | ... |
| ...| | |

## Global Decisions
- Navigation style: [Top nav / Sidebar / Hamburger]
- Footer: [Yes/No, content summary]
- Dark mode: [Yes/No/Both]
```

---

## 📄 PHASE 5: CREATE P-DOCS

**For each page, create:** `NOTES/WebMain/PAGES/P[n]-[PageName]/P-Doc-[PageName].md`

Also create `NOTES/WebMain/PAGES/P[n]-[PageName]/UI/` folder (empty — for future mockups).

```markdown
# P-Doc — [PageName] (P[n])

## Route
`/[route]`

## Purpose
[From audit]

## Sections
### [Section Name]
- **Content:** [What text/media goes here]
- **CTA:** [If applicable]
- **Notes:** [Design intent, tone, special behavior]

### [Section Name]
...

## Global Shell
- Header: [Shared / Hidden / Transparent]
- Footer: [Shared / Custom / Hidden]
```

**Output in chat:** "P-Docs created for all [N] pages. UI/ folders are ready for mockups. Say 'Generate mockup for P[n]' to create a pre-UI HTML for any page, or proceed to building."

---

## 🛑 EXECUTION CONSTRAINTS

1. **ONE WEBMAIN:** Never split pages into separate F[x] features. All pages = one WebMain.
2. **NOTES ONLY:** This protocol never touches `FEATURES/` or `src/`. All output is in `NOTES/WebMain/`.
3. **UI STAYS IN NOTES:** HTML mockups in `UI/` folders are for user review — never copied to `FEATURES/`.
4. **P-DOC IS LAW:** Once approved, the P-Doc drives page development. Do not deviate without updating it.
5. **STOP GATES:** Do not skip Phase 2 confirmation or Phase 3 audit approval.
