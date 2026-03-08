# INS-05-NEW: Idea Incubation Protocol

**System ID:** `INS-05-NEW`
**Trigger:** User says "I have a vague idea", "Help me brainstorm", "I don't know where to start", or "Incubate this concept"
**Input Requirement:** User's loose thoughts, target audience, or raw constraints
**Output Target:** `NOTES/INITIAL IDEA.md`, `NOTES/INITIAL AUDIT.md`, `NOTES/ORIGINAL IDEA.md` (in root NOTES folder)

---

## 🎯 PROTOCOL PURPOSE

This protocol is for the **"Pre-Idea"** stage. It takes a vague spark—like a target audience or a problem statement—and incubates it into a concrete feature or app concept. It operates in the root `NOTES/` folder because the idea isn't solid enough for a feature folder yet.

**When to Use:**
- User has no clear UI or feature list.
- User only knows "I need specific things for this person with these interests."
- "Blind" starting point.

**When NOT to Use:**
- User already has a clear feature name (Use INS-11).
- User wants to start a full project immediately (Use INS-00A).

---

## 📝 PHASE 1: BRAIN DUMP (Input Capture)

**Action:** Interview the user and create `NOTES/INITIAL IDEA.md`.

1. **Ask clarifying questions** (if needed):
   - "Who is this for?"
   - "What is the one thing they MUST be able to do?"
   - "What are their specific interests or constraints?"

2. **Create File:** `NOTES/INITIAL IDEA.md`
   - Dump everything the user said.
   - Raw, unstructured, unedited.

**Template:**
```markdown
# INITIAL IDEA - Raw Input
**Date:** [YYYY-MM-DD]

## User Input
[Paste raw chat logs or user text here]

## constraints
- [Constraint 1]
- [Constraint 2]
```

---

## 🧠 PHASE 2: AUDIT & EXPANSION

**Action:** Analyze the raw input and create `NOTES/INITIAL AUDIT.md`.

**Cognitive Steps:**
1. **Analyze the User:** Based on the "Interests" or "Person" described.
2. **Brainstorm Features:** What naturally fits this person's needs?
3. **Identify Gaps:** What is missing to make this a functional app/feature?

**Create File:** `NOTES/INITIAL Audit.md`

**Template:**
```markdown
# INITIAL AUDIT - Analysis
**Source:** INITIAL IDEA.md

## 👤 User Persona Analysis
**Profile:** [Analyze the target user]
**Needs:** [What do they actually need?]
**Habits:** [Inferred habits]

## 💡 Potential Concepts
1. **Concept A:** [Description]
2. **Concept B:** [Description]
3. **Concept C:** [Description]

## 🔍 Missing Information
- [Question 1]
- [Question 2]
```

---

## 💎 PHASE 3: CONSOLIDATION (Refinement)

**Action:** Convert the winning concept into `NOTES/ORIGINAL IDEA.md`.

**Goal:** This file should look like the user wrote it. Simple, clear, ready for INS-11 or INS-00A.

**Cognitive Steps:**
1. **Select the Best Path:** Based on user feedback or logic.
2. **Rewrite in Simple Language:** Remove "AI jargon". Use "User Voice".

**Create File:** `NOTES/ORIGINAL IDEA.md`

**Template:**
```markdown
# N1 - [Generated Title]

**Date:** [YYYY-MM-DD]
**Status:** 💡 Incubated Idea

---

## The Idea
[Simple, clear description of the solution. 3-4 paragraphs.]

## Why This Matters
[Connection to the specific user interests/needs identified in Phase 1.]

## Who Benefits
[The specific persona identified.]
```

---

## 🚀 HANDOFF

Once `NOTES/ORIGINAL IDEA.md` exists:

1. **Tell User:** "Idea incubated. We have a solid concept in `ORIGINAL IDEA.md`. Ready to initialize?"
2. **Next Step:** Run **INS-00A** (App Init) or **INS-11** (Feature Init).
   - *Note: INS-00A will automatically move these incubator files into `NOTES/zORIGINAL IDEA/`.*

---

## 🛑 CONSTRAINTS

<rules>
<rule id="1">**NO SUBFOLDERS:** All 3 files must be in the root of `NOTES/`.</rule>
<rule id="2">**USER VOICE:** Phase 3 must sound natural, not "AI Generated".</rule>
<rule id="3">**DO NOT OVER-ENGINEER:** Keep the `INITIAL IDEA.md` raw.</rule>
</rules>
