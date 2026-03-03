# INS-00-AUDIT: Project Vision Audit (Target: G0)

**System ID:** `INS-00-AUDIT`
**Trigger:** User says "Audit Vision", "What is this project?", or "Create G0 from existing code"
**Input Requirement:** An existing codebase
**Output Target:** `GENERAL/G0 - Idea.md`

---

## 🎯 STRATEGIC INTENT

This is the **first question** you ask about any existing project: *"What IS this thing?"*

This protocol focuses ONLY on understanding the project's identity. It does NOT touch styles, database, or architecture. One G-File. One Focus.

---

## 🔍 PHASE 1: DISCOVERY (Read Only)

**Action:** Scan for identity clues.

**Read These Files (in order):**
1. `README.md` (if exists)
2. `package.json` or `pyproject.toml` (name, description, dependencies)
3. Root folder name
4. Landing page / entry point (`index.html`, `app.tsx`, `main.py`)

**Extract:**
- **Project Name:** (from package.json or folder)
- **Core Purpose:** What does this app *do*? (Inferred from README + entry point)
- **User Persona:** Who uses this? (Inferred from UI text, marketing copy)
- **Type:** Web App / Mobile App / API / CLI / Library / Marketing Site

---

## 📋 PHASE 2: DRAFT & VERIFY (The Gate)

**Action:** Create `NOTES/AUDIT/G0-Draft.md`

**Content:**
```markdown
# G0 DRAFT - Project Vision (Pending Approval)
**Status:** 🟡 DRAFT - Awaiting User Verification

## Detected Identity
- **Project Name:** [Inferred]
- **Type:** [Web App / API / etc.]
- **Core Purpose:** [One paragraph summary]
- **User Persona:** [Who is this for?]

## Confidence Level
- Name: [HIGH/MEDIUM/LOW]
- Purpose: [HIGH/MEDIUM/LOW]
- Persona: [HIGH/MEDIUM/LOW]

## Questions for User
1. [Is this correct?]
2. [Any corrections?]
3. [What is the long-term vision?]
```

**🛑 STOP.** Output: *"I have drafted G0. Please review `NOTES/AUDIT/G0-Draft.md` and confirm or correct."*

---

## ✅ PHASE 3: RATIFICATION (Write the Law)

**Trigger:** User approves or corrects the draft.

**Action:** Create `GENERAL/G0 - Idea.md` using the approved content.

**Rule:** If user corrected anything, use THEIR words, not your inference.

---

## 🛑 EXECUTION CONSTRAINTS
1. **ONE G-FILE ONLY.** Do not touch G1, G2, G3, or G4.
2. **NEVER SKIP THE DRAFT.** Do not write directly to `GENERAL/`.
3. **LABEL CONFIDENCE.** Every inference must state HIGH/MEDIUM/LOW.
4. **USER WORDS WIN.** If user corrects your guess, their version is the truth.
