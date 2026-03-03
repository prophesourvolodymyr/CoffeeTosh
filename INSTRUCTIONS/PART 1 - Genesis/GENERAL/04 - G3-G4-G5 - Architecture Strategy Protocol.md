# INS-02-NEW: Architecture Strategy Protocol

**System ID:** `INS-02-NEW`
**Trigger:** User says "Define Stack", "Setup Database", "Plan API", or "Run INS-02"
**Input Requirement:** `GENERAL/G0-Idea.md` (Vision)
**Output Target:** `GENERAL/G3-Data.md`, `GENERAL/G4-API.md`, `GENERAL/G5-Content.md`

---

## 🎯 STRATEGIC INTENT

This protocol defines the **Technical Backbone** of the new project.
Before writing feature logic, we must agree on *where data lives* and *how it moves*.

---

## 🏗️ PHASE 1: STACK DEFENSE

**Action:** Interview the user to determine the best tools for the job.

**Decision Matrix:**
1.  **Database (G3):** SQL (Postgres/Supabase) vs NoSQL (Mongo/Firebase) vs Local (SQLite).
    *   *Question:* "Does your data have strict relationships (Users have Orders) or is it loose documents?"
2.  **API Strategy (G4):** REST vs GraphQL vs Server Actions (Next.js) vs TRPC.
    *   *Question:* "Do you want a separate backend or a full-stack monolith?"
3.  **Content Strategy (G5):** CMS (Sanity/Strapi) vs Hardcoded vs Markdown.
    *   *Question:* "Who updates the content? Developers or Marketing team?"

**Output:** Create the necessary G-Files.

---

## 🧠 PHASE 2: G3 - DATA SCHEMA DEFINITION

**Action:** Create `GENERAL/G3-Data.md`.

**Content:**
- **ER Diagram (Mermaid):** High-level view of entities.
- **Models:**
    ```prisma
    model User {
      id        String   @id @default(uuid())
      email     String   @unique
      posts     Post[]
    }
    ```
- **Rules:** "All IDs must be UUIDs", "Soft delete only".

---

## 🔌 PHASE 3: G4 - API PATTERNS

**Action:** Create `GENERAL/G4-API.md`.

**Content:**
- **Standard Response Format:** `{ data: ..., error: ... }`
- **Auth Middleware:** "All `/api/protected/*` routes require JWT."
- **Pagination Strategy:** "Cursor-based for feeds, Offset for tables."

---

## 🛑 EXECUTION CONSTRAINTS
1.  **NO CODE YET:** Do not install packages. Just define the *Plan*.
2.  **Keep it Simple:** If the user is building a simple tool, suggest `SQLite` or `Local Storage`. Don't force Enterprise checks.
