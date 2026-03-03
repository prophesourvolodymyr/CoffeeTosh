# INS-02-AUDIT: System Architecture Audit (Target: G2)

**System ID:** `INS-02-AUDIT`
**Trigger:** User says "Audit Architecture", "How is this built?", or "Create G2 from existing code"
**Input Requirement:** An existing codebase
**Output Target:** `GENERAL/G2 - System.md`

---

## 🎯 STRATEGIC INTENT

This protocol answers ONE question: *"How is this project structured?"*

It maps the tech stack, folder organization, routing, and deployment setup. It does NOT analyze styles, data, or business logic.

---

## 🔍 PHASE 1: ARCHITECTURE SCAN (Read Only)

**Action:** Map the skeleton of the project.

**Scan Targets:**
1. **Package Manager:** `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`
2. **Framework Detection:** Check dependencies for Next.js, React, Vue, Django, Flask, Express, etc.
3. **Folder Structure:** List top-level and `src/` directories
4. **Routing:** `pages/`, `app/`, `routes/`, URL configs
5. **Config Files:** `next.config.*`, `vite.config.*`, `tsconfig.json`, `.env.example`
6. **Deployment:** `Dockerfile`, `vercel.json`, `netlify.toml`, CI/CD configs

**Extract:**
- **Tech Stack:** Framework + Language + Version
- **Project Type:** Monorepo? Single app? API-only?
- **Folder Map:** How code is organized (`src/components/`, `src/lib/`, etc.)
- **Site Map:** List of detected pages/routes
- **Build System:** (Vite? Webpack? Turbopack?)
- **Deployment Target:** (Vercel? Docker? AWS?)

---

## 📋 PHASE 2: DRAFT & VERIFY (The Gate)

**Action:** Create `NOTES/AUDIT/G2-Draft.md`

**Content:**
```markdown
# G2 DRAFT - System Architecture (Pending Approval)
**Status:** 🟡 DRAFT - Awaiting User Verification

## Detected Tech Stack
- **Framework:** [Next.js 14 / React / Vue 3 / etc.]
- **Language:** [TypeScript / JavaScript / Python]
- **Runtime:** [Node 20 / Python 3.11 / etc.]

## Folder Structure
```
src/
├── app/          → [Pages/Routing]
├── components/   → [UI Components]
├── lib/          → [Utilities]
├── styles/       → [CSS]
└── types/        → [TypeScript Definitions]
```

## Detected Routes/Pages
| Route | File | Purpose (Inferred) |
|-------|------|-------------------|
| `/` | `app/page.tsx` | Home page |
| `/about` | `app/about/page.tsx` | About page |

## Build & Deploy
- **Build Tool:** [Vite / Next / Webpack]
- **Deploy Target:** [Vercel / Docker / Unknown]
- **Environment:** [`.env.example` found? Y/N]

## Questions for User
1. [Is this the correct tech stack?]
2. [Are there routes I missed?]
3. [Where is this deployed?]
```

**🛑 STOP.** Output: *"I have drafted G2. Please review `NOTES/AUDIT/G2-Draft.md` and confirm or correct."*

---

## ✅ PHASE 3: RATIFICATION (Write the Law)

**Trigger:** User approves or corrects the draft.

**Action:** Create `GENERAL/G2 - System.md` using the approved content.

---

## 🛑 EXECUTION CONSTRAINTS
1. **ONE G-FILE ONLY.** Do not touch G0, G1, G3, or G4.
2. **NEVER SKIP THE DRAFT.** Do not write directly to `GENERAL/`.
3. **MAP, DON'T JUDGE.** Document what EXISTS. Save opinions for later.
4. **USE GREB MCP.** For large codebases, use `mcp_greb` to find routing patterns instead of reading every file.
