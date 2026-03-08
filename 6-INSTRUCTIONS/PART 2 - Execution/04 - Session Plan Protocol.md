# INS-03-EXEC: Session Plan Generation Protocol

**System ID:** `INS-03-EXEC`  
**Trigger:** User says "Create session plan for F[x]" or "I want to complete Phase [X-Y] today" or "Plan today's work on F[x]"  
**Input Requirement:** F[x]-Doc.md + F[x]-Progress.md + F[x]-Research.md (if exists)  
**Output Target:** `FEATURES/F[x]-[Name]/SESSIONS/[YYYY-MM-DD]-Session.md`

---

## 📁 SESSION FILE STRUCTURE

**Location:** Each feature has its own SESSIONS folder for historical tracking.

```
FEATURES/F[x]-[Feature_Name]/
├── F[x]-Doc.md
├── F[x]-Progress.md
├── F[x]-Research.md (if exists)
├── GUIDES/
├── UI/ (if exists)
└── SESSIONS/                    ← Session plans go here
    ├── 2026-01-24-Session.md    ← Today's session
    ├── 2026-01-23-Session.md    ← Yesterday's (optional keep)
    └── ...
```

**Filename Format:** `YYYY-MM-DD-Session.md` (e.g., `2026-01-24-Session.md`)

**Why date-based files:**
- Know exactly when work happened
- Multiple sessions on same day = add suffix: `2026-01-24-Session-2.md`
- Can keep history or delete old ones - your choice

---

## 🎯 STRATEGIC INTENT (The "Why")

Based on Dex's Context Engineering Research:
> *"I can read this plan and know what code changes will happen. Our plans include actual code snippets of what's going to change."*

This protocol creates a **detailed implementation plan** for a work session with:
- Exact file paths and line numbers
- Before/after code snippets
- Test commands per change

**SESSION-PLAN.md is:**
- Temporary (delete when session complete)
- Specific to TODAY's work
- Detailed enough that AI can execute without guessing

**SESSION-PLAN.md is NOT:**
- Permanent documentation (that's F-Doc)
- Task tracking (that's F-Progress)
- Codebase understanding (that's F-Research)

---

## 🔍 PHASE 1: SCOPE IDENTIFICATION

**Cognitive Steps:**

1. **Load Context (The "Context Triangle"):**
   - **Local Context:** Read `F[x]-Doc.md` (what we're building) & `F[x]-Progress.md` (status).
   - **Global Visuals (If UI Task):** Read `GENERAL/G1-Styles.md` (The Law).
   - **Global Config (If Core Task):** Read `GENERAL/G0-Idea.md` (Vision) & `GENERAL/G2-System.md` (Architecture).
   - **Research:** Read `F[x]-Research.md` (how codebase works) - if exists.

2. **Identify Session Scope:**
   - Which phases does user want to complete?
   - How many tasks/todos in those phases?
   - Estimate: Is this realistic for one session?

3. **Warn if Too Large:**
   - If scope > 10 substantial tasks, suggest splitting
   - "This is a lot of tasks. Want to reduce scope or split into multiple sessions?"

---

## 🤖 PHASE 2: DETAILED PLAN GENERATION

**Role:** Senior Implementation Architect  
**Objective:** Convert vague todos into exact code changes.

**For Each Task in Scope:**

1. **Identify Target File(s):**
   - Which file needs to change?
   - What line numbers?
   - Or: What new file to create?

2. **Document Current State:** (for modifications)
   - Copy exact current code snippet
   - Note the pattern/structure

3. **Specify Change:**
   - Write the exact new code
   - Or describe the change precisely

4. **Add Test Command:**
   - How to verify this change works?
   - Unit test? Manual test? Build command?

---

## 📝 PHASE 3: PLAN FILE GENERATION

**Action:** Create `FEATURES/F[x]-[Name]/SESSIONS/[YYYY-MM-DD]-Session.md`

1. Create SESSIONS folder if it doesn't exist
2. Use today's date for filename
3. If file already exists for today, add suffix: `-2`, `-3`, etc.

**Template:**

```markdown
# 📋 Session Plan: F[x] - [Feature Name]

**Date:** [YYYY-MM-DD]
**Scope:** Phase [X] to Phase [Y] (or specific tasks)
**Total Tasks:** [X] changes
**Priority:** [High/Medium/Low]
**Status:** 🟡 In Progress

---

## 🎯 Session Goal

Complete the following from F[x]-Progress.md:
- [ ] [Task 1 from Progress]
- [ ] [Task 2 from Progress]
- [ ] [Task 3 from Progress]

---

## 📝 Detailed Changes

### Change 1: [Task Name]

**Target:** `src/path/to/file.ts` (Lines 45-60)

**Current Code:**
```typescript
export function existingFunction() {
  // current implementation
  return oldValue;
}
```

**Change To:**
```typescript
export function existingFunction(newParam: string) {
  // new implementation with newParam
  return newValue;
}
```

**Why:** [Brief explanation of why this change]

**Test:** 
```bash
npm test -- existingFunction
# or: Build and verify [specific behavior]
```

---

### Change 2: [Task Name]

**Target:** Create NEW file `src/path/newFile.ts`

**Content:**
```typescript
// New file content
export function newFunction() {
  // implementation
}
```

**Why:** [Brief explanation]

**Test:**
```bash
npm test -- newFunction
```

---

### Change 3: [Task Name]

**Target:** `src/path/another.ts` (Line 120)

**Add After Line 120:**
```typescript
// New code to insert
import { newFunction } from './newFile';
```

**Why:** [Connect the new function to existing code]

**Test:**
```bash
npm run build
```

---

## 📊 Execution Order

1. **First:** Change 2 (create new file - no dependencies)
2. **Then:** Change 1 (modify existing - depends on nothing)
3. **Finally:** Change 3 (connect them - depends on 1 & 2)

---

## ⚠️ Watch Out For

- [Any gotchas from F-Research]
- [Edge cases to handle]
- [Related code that might break]

---

## ✅ Completion Checklist

After all changes:
- [ ] All tests pass
- [ ] Build succeeds
- [ ] Feature works as expected
- [ ] Update F[x]-Progress.md (mark tasks complete)
- [ ] Mark this session 🟢 Complete (or delete file)
```

---

## 🛑 EXECUTION CONSTRAINTS

<rules>
<rule id="1">**SPECIFICITY:** Every change must have exact file path. No vague "update the auth code."</rule>
<rule id="2">**CODE SNIPPETS:** Include actual code, not descriptions of code.</rule>
<rule id="3">**TESTABILITY:** Every change must have a way to verify it works.</rule>
<rule id="4">**ORDERING:** Changes must be in dependency order (create before import).</rule>
<rule id="5">**DATE-BASED:** Filename uses today's date: `YYYY-MM-DD-Session.md`</rule>
<rule id="6">**SCOPE LIMIT:** Keep sessions focused - 5-10 substantial tasks maximum.</rule>
</rules>

---

## 🔄 LIFECYCLE

| Event | Action |
|-------|--------|
| User requests session plan | CREATE `SESSIONS/[date]-Session.md` |
| During implementation | AI follows the plan step by step |
| Task completed | Check off in plan |
| Session complete | Mark status 🟢 Complete (keep or delete) |
| Next session | CREATE new `SESSIONS/[new-date]-Session.md` |

**Optional:** Keep old session files for history, or delete them after marking Progress.md complete.

---

## 💡 AGENT MODE GUIDANCE

When AI is in agent/autonomous mode:

1. **Work through plan sequentially** - Don't skip around
2. **Verify after each change** - Run the test command
3. **Mark completed IMMEDIATELY** - After finishing a task, open F[x]-Progress.md and change `- [ ]` to `- [x]` for that specific task
4. **Stop on blockers** - If something unexpected, pause and ask
5. **Complete the plan** - Don't stop at 25% unless blocked

**CRITICAL - Progress Tracking:**
- After EVERY completed task, mark it `[x]` in Progress.md
- Don't wait until the end of session - mark as you go
- This helps user see real-time progress

**Context Management:**
- If context feels heavy (50+ messages), suggest fresh session
- Write progress to F-Progress before ending
- New session = new SESSION-PLAN.md
