# 🏗️ PROJECT INIT CHECKER

**Purpose:** Initialize or validate the F-Cycle project structure. Detect missing files and create the proper organization hierarchy.

**When to Use:** Starting a new project OR auditing an existing project's structure compliance.

**What This Does NOT Do:** Does not create NOTES/, RAW/, or R[x] files (those come from INS-00/INS-01).

---

## 📋 F-CYCLE PROTOCOL PIPELINE (v3)

Execute protocols based on project phase:

```
BRAND MASTER — run ONCE before any sub-project (Part 1 - Genesis/GM/ or Part 1B - Evolution/GM/):
  GM0 (Brand Soul) → GM1 (Visual DNA) → GM2 (Product Map)

NEW PROJECT (Part 1 - Genesis/GENERAL/):
  G0 (Genesis Init) → G1 (Styles, delta if GM1 exists) → G2 (Architecture) → Process Notes → Build

EXISTING PROJECT (Part 1B - Evolution/GENERAL/):
  G0-G4 Audits (Vision → Design → Architecture → Data & API)

BUILDING (Part 2 - Execution):
  2 (Research) → 3 (Logic Spec) → 1A (Build) → 4 (Session Plan) → 5 (Cycles)

NOTE PROCESSING (Part 1 utility):
  1 (N[x] → Audit → R[x] + UIDR[x])

FEATURE SYNC (Part 2):
  6 (Updated Notes → Diff → Update F[x])

LEGACY RETROFIT (Part 2):
  7 (Map code → F[x] scaffold, P-Docs for website projects)
```

---

## 🎯 EXECUTION PROTOCOL

When the user says **"Initialize Project Structure"** or **"Check my project structure"**, execute this:

### PHASE 1: SCAN CURRENT STATE

Read the workspace and identify:

1. **Root-level folders present:**
   - [ ] `GM/` (optional — only for multi-repo brand setups)
   - [ ] `GENERAL/`
   - [ ] `INSTRUCTIONS/`
   - [ ] `NOTES/`
   - [ ] `FEATURES/`
   - [ ] `WORK/`
   - [ ] `JUNK/`

2. **Root-level files present:**
   - [ ] `AGENTS.md` (AI Bootloader)
   - [ ] `README.md` (with Project Structure section)

3. **GENERAL/ files present:**
   - [ ] `G0 - Idea.md` (Vision)
   - [ ] `G1 - Styles.md` (Design)
   - [ ] `G2 - System.md` (Architecture)

3. **WORK/ files present:**
   - [ ] `CYCLES.md`
   - [ ] `USER TODO & NOTES.md`

4. **Feature folders:**
   - Scan for `F[x]-[Name]/` folders
   - For each found, check:
     - [ ] `F[x]-Doc.md`
     - [ ] `F[x]-Progress.md`
     - [ ] `GUIDES/` folder

### PHASE 2: REPORT FINDINGS

Output a table like this:

```markdown
## 📊 Structure Audit Report

| Component | Status | Action Needed |
|-----------|--------|---------------|
| Root: INSTRUCTIONS/ | ✅ | - |
| Root: NOTES/ | ❌ | Create folder |
| Root: FEATURES/ | ✅ | - |
| Root: WORK/ | ⚠️ | Missing CYCLES.md |
| Root: JUNK/ | ❌ | Create folder |
| F1-[Feature Name]/F1-Doc.md | ✅ | - |
| F1-[Feature Name]/F1-Progress.md | ✅ | - |
| F1-[Feature Name]/GUIDES/ | ✅ | - |
| F2-[Feature Name]/F2-Doc.md | ✅ | - |
| F2-[Feature Name]/F2-Progress.md | ❌ | Create file |
| F2-[Feature Name]/GUIDES/ | ⚠️ | Folder exists but empty |
```

### PHASE 3: USER DECISION

Ask: **"Should I create the missing components? (yes/no)"**

- If **yes** → Proceed to Phase 4
- If **no** → End, provide list for manual creation

### PHASE 4: CREATE MISSING STRUCTURE

Execute in this order:

#### 4.1 Root Folders
Create any missing:
```
/INSTRUCTIONS/
/NOTES/
/FEATURES/
/WORK/
/JUNK/
```

#### 4.2 Root Files

If `README.md` missing or doesn't have structure section:
```markdown
# [Project Name]

**Description:** [Brief project description]

---

## 📁 Project Structure

```
FEATURES/                  # Product features
INSTRUCTIONS/              # F-Cycle protocol definitions
NOTES/                     # Research & raw concepts
WORK/                      # Work cycles & guides
JUNK/                      # Explanations & proposals
```

## 🚀 Features

| ID | Name | Status | Description |
|----|------|--------|-------------|
| - | - | 🔴 | - |

---

## 🛠️ Setup

[Setup instructions to be added]

## 📖 Usage

[Usage instructions to be added]
```

#### 4.3 WORK/ Files

If `CYCLES.md` missing:
```markdown
# 🔄 WORK CYCLES

## Current Cycle: [Not Started]

| Cycle | Date | Duration | Feature/Task | Status |
|-------|------|----------|--------------|--------|
| C1 | TBD | 5h | - | 🔴 Planned |

---

## Cycle Log

_Add completed cycles here_
```

If `USER TODO & NOTES.md` missing:
```markdown
# 📝 USER TODO & NOTES

**Last Updated:** [Date]

---

## 📋 Personal TODO

- [ ] [Task]
- [ ] [Task]

---

## 📝 Notes

[General project notes go here]
```

#### 4.4 Feature Folders

For each incomplete `F[x]` folder:

**If Doc file missing:**
```markdown
# F[x] - [Name] Specification

**Version:** 1.0  
**Status:** 🟡 Draft  
**Created:** [Date]

---

## 1. 🎯 Purpose

[To be defined]

---

## 2. 🏗️ Architecture

[To be defined]

---

## 3. 🔄 Core Logic Flow

[To be defined]

---

## 4. 📊 Data Structures

[To be defined]

---

## 5. 🔐 Required Credentials

[To be defined]

---

## 6. 📁 File Map

| File | Purpose | Status |
|------|---------|--------|
| - | - | 🔴 |

---

## 7. ✅ Definition of Done

- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

**If Progress file missing:**
```markdown
# F[x] - [Name] Progress Tracker

**Last Updated:** [Date]  
**Status:** 🔴 Not Started

---

## 🔧 User Manual Tasks (Complete Before Development)

> These require human action and cannot be automated.

- [ ] Task 1: [Specific manual task]
- [ ] Task 2: [Specific manual task]
- [ ] Task 3: [Specific manual task]

---

## 📋 Phase 1: [Phase Name, e.g., "Core Setup"]

**Goal:** [What this phase accomplishes]

**Tasks:**
- [ ] Setup: [Specific task description]
- [ ] Setup: [Specific task description]
- [ ] Configuration: [Specific task description]
- [ ] Testing: [Specific task description]

---

## 📋 Phase 2: [Phase Name, e.g., "Integration Layer"]

**Goal:** [What this phase accomplishes]

**Tasks:**
- [ ] Integration: [Specific task description]
- [ ] Integration: [Specific task description]
- [ ] Error handling: [Specific task description]
- [ ] Testing: [Specific task description]

---

## 📋 Phase 3: [Phase Name, e.g., "Polish & Testing"]

**Goal:** [What this phase accomplishes]

**Tasks:**
- [ ] Refinement: [Specific task description]
- [ ] Edge cases: [Specific task description]
- [ ] End-to-end testing: [Specific task description]
- [ ] Documentation: [Specific task description]

---

## 📌 Questions to Resolve

| # | Question | Answer |
|---|----------|--------|
| 1 | [Question] | TBD |

---

## 📊 Progress Summary

**Phase 1:** 0/[X] tasks complete  
**Phase 2:** 0/[X] tasks complete  
**Phase 3:** 0/[X] tasks complete  
**Overall:** 🔴 Not Started
```

**If GUIDES/ folder missing or empty:**
```
Create folder: /FEATURES/F[x]-[Name]/GUIDES/
Add placeholder: /FEATURES/F[x]-[Name]/GUIDES/README.md with:
"# Setup Guides

This folder contains step-by-step human setup guides for:
- API credentials
- Platform configuration
- External service connections

Guides will be added during INS-09 execution."
```

### PHASE 5: FINAL REPORT

Output:
```markdown
## ✅ Initialization Complete

### Created:
- [List of files/folders created]

### Already Present:
- [List of existing files]

### Next Steps:
1. If starting new project → Execute INS-00 to initialize app structure
2. If continuing existing → Review Doc files and proceed to coding
3. Use INS-05 to generate work cycles
```

---

## 🎯 EXAMPLE EXECUTION

**User says:** "Initialize Project Structure"

**You respond:**
1. Scan workspace
2. Show audit table
3. Ask permission to create
4. Create missing components
5. Report completion

---

## 🛡️ VALIDATION RULES

Before creating files, verify:

1. **Naming Convention:** Files must follow `A[x]-` or `F[x]-` prefix
2. **No Duplicates:** Don't overwrite existing files
3. **Hierarchy Respect:** GUIDES/ always inside the automation/feature folder
4. **Minimal Content:** Create placeholder structure only, not full specs

---

## 🚫 WHAT NOT TO DO

- ❌ Do NOT create NOTES/ subfolders (A[x], F[x], RAW, ORIG)
- ❌ Do NOT generate R[x] documentation files
- ❌ Do NOT write actual code or implementations
- ❌ Do NOT create example/sample data
- ❌ Do NOT overwrite existing Doc or Progress files

---

## 🔄 INTEGRATION WITH OTHER PROTOCOLS

- **After this:** User can run Part 1/00A (Genesis) or Part 2/00-05 (Audits) or start coding
- **Before coding:** G-Files + Doc and Progress must exist (this protocol ensures they do)
- **Codebase Research:** Use Part 3/00 to identify relevant files before implementation
- **Session Planning:** Use Part 3/03 before coding sessions to plan focus
