# INS-00-EXEC: Codebase Research Protocol

**System ID:** `INS-00-EXEC`
**Trigger:** User says "Research codebase for [Feature]", "Analyze Feasibility", or "How would this work?"
**Input Requirement:** `NOTES/` (Idea/Spec) + Existing Codebase
**Output Target:** `NOTES/[Feature]/Research.md` OR `FEATURES/F[x]/F[x]-Research.md`

---

## 🎯 STRATEGIC INTENT

This protocol bridges the gap between **Idea** and **Reality**. It answers: "How does this actually fit into the current system?"

**Dual Mode Strategy:**
1.  **Educational Mode (Brainstorming):** When working in `NOTES/`, the goal is to **Teach** the user. Explain *how* the logic flows, *why* certain files are chosen, and *what* patterns are being used.
2.  **Production Mode (Execution):** When working in `FEATURES/`, the goal is **Precision**. List exact file paths, line numbers, and strict integration points for the coder.

---

## 🔍 PHASE 1: MODE DETECTION

**Action:** Check the current context of the feature.

1.  **If folder is `NOTES/[FeatureName]/`:**
    - **Mode:** Educational / Feasibility.
    - **Goal:** Validate the idea and explain the architectural approach.
    - **Output:** `NOTES/[FeatureName]/Research.md`.

2.  **If folder is `FEATURES/F[x]/`:**
    - **Mode:** Production / Integration.
    - **Goal:** Map the exact surgery points.
    - **Output:** `FEATURES/F[x]/F[x]-Research.md`.

---

## 🤖 PHASE 2: THE RESEARCH SCAN

**Trigger:** "Analyze how to build [Feature]"

**Execution Steps:**
1.  **Semantic Search:** Search for related keywords from the N1/R1 specs (e.g., "Auth", "Payment", "User Model").
2.  **Pattern Matching:** Find existing features that do similar things (e.g., "See how `F2-Login` handles state").
3.  **Dependency Check:** Identify required libraries or missing G-Files.

---

## 📝 PHASE 3: OUTPUT GENERATION

### Option A: Educational Research (`NOTES/Research.md`)
*Use this format when the user is still shaping the idea.*

```markdown
# 🧠 Logic Flow & Feasibility: [Feature Name]

## 1. How It Works (The "Mental Model")
*Explain clearly to the user how this data flows through the system.*
> "When the user clicks [X], the data travels from the `Frontend Component` -> `API Route` -> `Database`. We use the [Pattern Name] pattern here."

## 2. Key Files Involved
*Don't just list paths—explain their role.*
- **[src/auth_handler.ts](src/auth_handler.ts):** This guards the door. We need to modify it to let our new user type in.
- **[src/database_schema.sql](src/database_schema.sql):** The blueprint. We'll add a new column here.

## 3. Recommended Strategy
*Guide the user on the best approach.*
- "I recommend Extension Strategy A because it keeps the code clean..."
```

### Option B: Production Research (`FEATURES/F[x]-Research.md`)
*Use this format when the feature is initialized and ready to code.*

```markdown
# 🔬 Technical Integration Map: F[x] - [Name]

## 1. Integration Points
- **Hook 1:** `src/app.ts` (Line 45) - Add middleware import.
- **Hook 2:** `src/routes.ts` (Line 102) - Add `/feature` route.

## 2. New Dependencies
- `package.json`: Add `axios` (v1.0.0).

## 3. Data Schema Changes
```sql
ALTER TABLE users ADD COLUMN ...
```

## 4. Risks & Conflicts
- Watch out for `GlobalErrorHandler` in `src/utils.ts`.
```

---

## 💡 AI GUIDANCE

When writing the **Educational Research**, imagine you are a Senior Architect onboarding a Junior Dev (the User).
- Use analogies.
- Explain *why* a file is important.
- Make the "Invisible Logic" visible.

When writing **Production Research**, be a Surgical Robot.
- Exact paths.
- Exact lines.
- No fluff.

---
