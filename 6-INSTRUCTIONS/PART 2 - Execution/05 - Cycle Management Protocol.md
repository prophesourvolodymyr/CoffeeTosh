# INS-04-EXEC: Cycle Management Protocol

**System ID:** `INS-04-EXEC` 
**Trigger:** User request to "Initialize Cycles," "Build Schedule," "Update Cycles," or "Plan Week." 
**Input Requirement:** READ ALL currently existing `FEATURES/F[x].../F[x]-Progress.md` files. 
**Output Target:** Create or Update `WORK/CYCLES.md`.
**Prerequisites:** At least one feature has been initialized via INS-02

---

### 🔗 Workflow Position

```
INS-02 (Feature Init) → INS-03 (Codebase Research) → INS-05 (This) → INS-04 (Session Plan) → Implementation
```

Cycle Management sits between feature planning and session execution:
- **Cycles** = Week/project-level groupings (5-15 tasks each)
- **Session Plans** (INS-04) = Individual session focus (5-10 tasks)

---

## 🎯 STRATEGIC INTENT (The "Why")

This protocol implements Dex's "context preservation" principle. We group tasks to keep the "Mental Context" loaded. Switching between Database and CSS costs energy. Cycles minimize this cost.

**Key Principles:**
- **Context Preservation:** Group related tasks to avoid AI "dumb zone" from context switching
- **Momentum:** Breaking massive features into achievable batches prevents decision paralysis
- **Linearity:** Convert complex, multi-threaded projects into simple, single-threaded execution lists
    

## 🤖 PHASE 1: THE SCHEDULING ENGINE (Analysis)

**Role:** Senior Project Manager. **Objective:** Convert a scattered list of "Todos" across multiple features into a linear, time-boxed execution plan based on the Strategic Intent.

**Cognitive Steps:**

1. **Global Scan:** Read every `F[x]-Progress.md` file in the `FEATURES/` directory.
    
2. **Status Check:** Ignore tasks marked as `[x]` (Done). Focus only on `[ ]` (Todo).
    
3. **Priority Assessment:** Check F[x]-Doc.md for feature priority (Critical/High/Medium/Low).
    
4. **Batching Logic:**
    
    - Group tasks into **Cycles** that contain 5-15 related tasks.
        
    - **Context Affinity (CRITICAL):** Prioritize grouping tasks from the _same_ feature (e.g., "F1 Phase 1 + F1 Phase 2") or same category (e.g., "All Workflow Tasks") to minimize context switching.
        
    - **Dependency Logic:** Ensure Phase 1 (Backend) is scheduled before Phase 2 (Frontend).
        

## 📝 PHASE 2: CYCLE GENERATION (The Output)

**Action:** Overwrite/Update `WORK/CYCLES.md`.

**Content Template:**

```
# 🚴 Project Cycles (Master Schedule)
**Batch Size:** 5-15 tasks per Cycle
**Status:** 🟢 Active

## ✅ COMPLETED ARCHIVE
* [x] **Cycle 0:** Initialization & Setup

## 🏃 ACTIVE CYCLE (Focus Here)
### 🔄 Cycle [X]: [Theme Name, e.g., "Telegram Bot Setup"]
**Total Tasks:** ~12 tasks
**Priority:** [High/Medium/Low]
**Goal:** [Brief goal description, e.g., "Get the bot accepting and sending messages"]
**Context:** [Why these tasks are grouped, e.g., "Focusing purely on bot-side logic"]

**Task Manifest:**
1.  **F[x] - [Feature Name]:**
    * [ ] Phase 1: [Task Name] (Ref: `FEATURES/F[x]-[Name]/F[x]-Progress.md`)
    * [ ] Phase 1: [Task Name]
2.  **F[y] - [Feature Name]:**
    * [ ] Phase 1: [Task Name]

---

## 🔮 UPCOMING QUEUE
### Cycle [X+1]: [Theme Name]
* **F[x]** Phase 2 (Frontend)
* **F[z]** Phase 1 (Database)

### Cycle [X+2]: [Theme Name]
* ...
```

## 🛑 EXECUTION CONSTRAINTS

1. **REALISM:** Do not overload a cycle. Better to have more cycles than one impossible cycle.
    
2. **LINKING:** Every task in `CYCLES.md` must correspond to a real task in an `F[x]-Progress.md` file.
    
3. **TOTALITY:** Ensure ALL open tasks from ALL features are accounted for in the "Upcoming Queue."