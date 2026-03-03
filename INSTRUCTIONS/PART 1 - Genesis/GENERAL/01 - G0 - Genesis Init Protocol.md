# INS-00A: App & NOTES Initialization Protocol (The Project Consultant)

**System ID:** `INS-00A`
**Trigger:** User says "Initialize F0", "Create App Foundation", "Organize NOTES", or "Start new project"
**Input Requirement:** A vague or specific idea from the user.
**Output Target:** `GENERAL/` G-Files + Project Folder Structure.

---

## 🎯 STRATEGIC INTENT

This protocol converts a **Raw Idea** into a **Structured System**.
It does NOT just make folders. It acts as a **Senior Consultant**:
1.  **Ingests** the raw idea.
2.  **Audits** the idea (Challenge phase).
3.  **Codifies** the vision into `GENERAL/G0-Idea.md`.
4.  **Architects** the folder structure (NOTES/FEATURES/WORK).
5.  **Detects** necessary G-Extensions (Data, API).

> **⚠️ GM0 DELTA RULE:** If `GM/GM0-Brand.md` already exists, **G0 is a delta file — not a full spec.**
> Do NOT re-document audience, tone, voice, or brand mission in G0. Those live in GM0.
> G0 only captures: what THIS project does, its specific tech stack, its unique personas (if different from GM0), and project-specific goals.
> Ask the user ONLY about project-specific gaps — not brand-level questions already answered in GM0.

---

## 🕵️ PHASE 1: INGESTION & AUDIT (The Consult)

**Action:** Read user's input/notes and perform a gap analysis.

**Step 1: Read & Analyze**
- Read `NOTES/INITIAL IDEA.md` (if exists) or the Chat Input.
- Identify:
    - **Core Value:** What does this app do?
    - **Target Audience:** Who is it for?
    - **Tech Signals:** Database needed? API needed? Mobile/Web?

**Step 2: The Audit (STOP POINT)**
- **Create File:** `NOTES/INITIAL AUDIT.md`
- **Content:**
    - **Summary:** "I understand you want to build X."
    - **Gap Analysis:** "You haven't specified authentication." "Is this B2B or B2C?"
    - **Critical Questions:** Ask 3-5 high-impact questions to clarify the vision.
- **Action:** Output in chat: *"I have analyzed your idea. Please check `NOTES/INITIAL AUDIT.md` and answer the questions so I can build the G0 Source of Truth."*
- **Requrments** 20 Questioons & IDEAS in total

**STOP:** Do not proceed until user answers.

---

## 🧠 PHASE 2: THE G-CORE (Creation of Law)

**Trigger:** User provides answers to Audit.

**Action:** Consolidate inputs and CREATE the Source of Truth.

**Step 1: Create G0 - Idea.md (The Soul)**
- **Create Folder:** `GENERAL/`
- **Create File:** `GENERAL/G0 - Idea.md`
- **Content:**
    - **Project Name:** defined name.
    - **One-Liner:** The "Hook".
    - **Concept:** The refined summary from Phase 1.
    - **User Persona:** Defined audience.

**Step 2: Create ORIGINAL NOTES (Archive)**
- **Create File:** `NOTES/ORIGINAL IDEA.md`
- **Content:** The raw transcript/input for history.

**Status:** **STOP**. Ask user to approve `G0 - Idea.md`.


---

## 📂 PHASE 3: THE INFRASTRUCTURE (Notes)

**Trigger:** User approves `G0 - Idea.md`.

**Action:** Build the Folder Structure.

**Step 1: Archive Originals**
- Create `NOTES/zORIGINAL IDEA/`.
- Move `NOTES/INITIAL IDEA.md`, `NOTES/INITIAL AUDIT.md`, `NOTES/ORIGINAL IDEA.md` into it.

**Step 2: Verify & Activate Infrastructure**
- **Action:** Verify the standard repo structure exists (`FEATURES/`, `WORK/`, `NOTES/`, `JUNK/`).
- **Create:** `GENERAL/` (If missing). This folder must exist to hold the G-Files.
- **Ensure:** `JUNK/DEMOS/` and `JUNK/IMAGES/` exist.

**Step 3: Create Feature Notes & N1 Files**
- Scan `zORIGINAL IDEA/ORIGINAL IDEA.md`.
- Break down the app into logical features.
- **For EACH Feature:**
    - Create `NOTES/[Feature Name]/`.
    - Create subfolders: `EXAMPLES/`, `RAW/`, `UI/`, `ORIGINAL IDEA/`.
    - **Create File:** `NOTES/[Feature Name]/ORIGINAL IDEA/N1 - [Feature Name].md`.
    - **N1 Content:**
        - **Overview:** Write a simple summary of the feature using the **User's Tone/Voice** (derive from `Original Idea`).
        - **User Input:** Create a section `### 📝 DETAILS FOR USER TO DEFINE` listing specific logic gaps, data fields, or flows that the user needs to write or clarify.

**Status:** **STOP**. Ask user to approve the folder structure.

---

## 🏗️ PHASE 4: THE CONFIGURATION (F0)

**Trigger:** User approves folders.

**Action:** Initialize F0.

**Step 1: Create F0 Folder**
- `FEATURES/F0 - App Config/`

**Step 2: Create F0-Doc.md**
- **Content:**
    - **Vision:** Link to `GENERAL/G0-Idea.md`.
    - **Tech Stack:** (React/Next, language, etc.)
    - **Environment:** (Dev/Prod setup).
    - **G-File Index:** List all created G-Files (`G0`, `G3`, `G4`, `G5`).

**Step 3: Create F0-Progress.md (Context Roadmap)**
- **Generate a Dynamic Roadmap** based on the features found in `NOTES/`.
- **Use this Structure:**

```markdown
# 📊 F0 - [Project Name] Context Roadmap
**Goal:** Detailed specification and structure before code execution.

---

## 🏗️ 1. Project Foundation & G-Files
*Setting the laws of the universe.*
- [ ] **Repo Setup:** Git, Dependencies, Environment Variables.
- [ ] **G1 (Styles):** Run `INS-13` → Create `GENERAL/G1-Styles.md`.
- [ ] **G3 (Data):** Define Schema → Create `GENERAL/G3-Data.md` (if DB needed).
- [ ] **G5 (WebMain):** (If Website) Create `GENERAL/G5-WebMain.md` (Sitemap/Strategy).

---

## 🔄 2. Feature Context Generation (The N1 → R1 Loop)
*AI has analyzed `NOTES/` and assigned specific workflows. Architecture First, Content Second.*

### 🔹 [Feature Name e.g. "User Auth"] (App Logic)
*Type: Functional/Logic*
- [ ] **Logic Spec (R1):** Run `INS-01` to define flows/restrictions.
- [ ] **UI Spec (UIDR):** Run `INS-07` (Docs) for screens.

### 🔹 [Feature Name e.g. "Marketing Landing"] (WebMain)
*Type: Static/Content*
- [ ] **Context:** Run `INS-00B` (WebMain Audit) to define pages/content.
- [ ] **UI:** Run `INS-08` (HTML Mockup) if structure is complex.

*(Repeat for all identified features)*

---

## 🔍 3. Final Verification (Pre-Flight)
- [ ] **Global Audit:** Run `INS-06` (Clarification) to catch cross-feature conflicts.
- [ ] **Final Review:** User approves all R1/UIDR documents.

---

## 🚀 4. Execution (Code Initialization)
*Only once Phase 3 is checked.*
- [ ] Run `INS-02` for [Feature Name]
- [ ] Run `INS-02B` for [WebMain Feature]
```

**Status:** **STOP**. Ask user to approve F0.

---

## ⚖️ PHASE 5: THE RATIFICATION (G0 - The Law)

**Trigger:** User approves F0 (and strictly after Phase 4).

**Action:** Establishing the Source of Truth.

**Step 1: Ingest Context**
- Read `NOTES/zORIGINAL IDEA/ORIGINAL IDEA.md`.
- Read any new notes user added in `NOTES/[Feature]/`.

**Step 2: Create `GENERAL/G0-Idea.md`**
- **Content:** The finalized, strict Vision & Scope.

**Step 3: Create G-Extensions**
- Detect & Create `GENERAL/G3-Data.md` (if needed).
- Detect & Create `GENERAL/G4-API.md` (if needed).

**Action:** Output: *"Project Initialized. G0 is set. Ready to code."*

---

## 🗣️ PHASE 6: THE VOICE (G6 - Optional)

**Trigger:** User asks to "Define Voice", "Set Tone", or explicitly runs Phase 6.

**Action:** Calibrate the Application's Voice & Microcopy.

**Step 1: The Interview (Tone Audit)**
- Ask the user specific questions to gather context:
    1.  **Persona:** "If the app was a person, who would it be? (e.g., A strict professor vs. a helpful friend)"
    2.  **Examples:** "How should the app say 'Success'? (e.g., 'Operation Complete' vs 'You did it! 🎉')"
    3.  **Terminology:** "Are they 'Users', 'Members', or 'Players'?"
    4.  **Banned Words:** "Any corporate jargon or words to avoid?"

**Step 2: Create `GENERAL/G6-Voice.md`**
- **Content:**
    - **# G6 - Voice, Tone & Microcopy**
    - **The Persona:** Voice description (Friendly/Strict/Professional).
    - **Grammar & Formatting:** (Capitalization rules, emoji usage).
    - **Terminology Dictionary:** (Allowed vs Banned terms).
    - **Microcopy Patterns:**
        - **Success:** [Example]
        - **Error:** [Example]
        - **Empty State:** [Example]

**Action:** Output: *"Voice calibrated. G6 created. I will now speak in this tone."*

---
- `FEATURES/F0 - App Config/`

**Step 2: Create F0-Doc.md**
- **Content:**
    - **Vision:** Link to `GENERAL/G0-Idea.md`.
    - **Tech Stack:** (React/Next, language, etc.)
    - **Environment:** (Dev/Prod setup).
    - **G-File Index:** List all created G-Files (`G0`, `G3`, `G4`).

**Step 3: Create F0-Progress.md**
- **Structure:**
    - `[ ] Initialize Repo`
    - `[ ] Setup Environment Variables`
    - `[ ] Install Dependencies`
    - `[ ] Define G3 (Database Schema)`
    - `[ ] Define G1 (Design System) via INS-13`

---

## 🛑 EXECUTION CONSTRAINTS
1.  **G0 IS KING:** Do not create F0 until G0 is written and approved.
2.  **AUDIT FIRST:** Never skip the Audit Phase. We don't build vague ideas.
3.  **NO F1 YET:** Do NOT create F1. That is for `INS-13`.
│   ├── UI/
│   │   ├── UIDR-[Feature_Name].md  ← UI documentation (if feature has UI)
│   │   ├── UIR1-[Feature_Name].html  ← HTML mockup (created via INS-08)
│   │   └── IMAGES/  ← Screenshots, mockups, references
│   └── EXAMPLES/
│       └── (empty for now - examples added during development)
```

**N1 File Content:**
Extract and copy relevant sections from raw notes that pertain to this feature. Keep user's original writing style and voice. This is the "seed" that will grow into R1.

**UI Folder (For Features with UI):**
If a feature has significant user interface:
- Create `UI/UIDR-[Feature_Name].md` - UI documentation spec
- Create `UI/IMAGES/` folder for screenshots/mockups
- HTML mockup `UIR1-[Feature_Name].html` created later via INS-08

---

## 📝 PHASE 3: F0 DOCUMENTATION GENERATION

**Action:** Create `01-FEATURES/F0-[App_Name]/F0-Doc.md`

**Content Template:**

```markdown
# 📱 F0 - [App Name] Foundation
**Created:** [Date]
**Status:** 🟢 Living Document (Updates as features evolve)
**Purpose:** Master app vision and architecture overview

---

## 🎯 App Vision

[User's original idea written in their natural voice - don't make it corporate or formal. Keep the passion and personality from the raw notes.]

**Core Philosophy:**
[What makes this app unique? What problem does it solve? Why build this?]

**Target User:**
[Who is this for? What's their pain point?]

---

## 🏗️ App Architecture Overview

[High-level explanation of how the app is structured - NO mention of specific features by name]

**Platform:** [iOS / Android / Web / All]

**Tech Stack:**
- Frontend: [Framework]
- Backend: [Services]
- Database: [Solution]
- Integrations: [APIs/Services]

**Core Concepts:**
[Explain fundamental concepts that span multiple features]
- Concept 1: [Explanation]
- Concept 2: [Explanation]
- Concept 3: [Explanation]

*Example: "The app uses a point-based system where all user activities contribute to visualization. Users create custom workflows for different life areas. Everything syncs across devices in real-time."*

---

## 🎨 Design Principles

**Visual Style:** [Dark/Light/Customizable? Minimal/Rich?]

**Interaction Patterns:** [Gesture-based? Button-heavy? Voice?]

**Information Architecture:** [How is content organized? Navigation structure?]

---

## 🔄 Development Philosophy

**Feature Priority:** [What matters most? Speed? Flexibility? Simplicity?]

**Technical Debt Policy:** [Move fast and refactor? or Build it right first time?]

**User Feedback Loop:** [How do we validate features?]

---

## 📊 Current Status

**Total Features Identified:** [X]
**Features in Progress:** [Y]
**Features Completed:** [Z]

**Phase Breakdown:**
- Phase 1 (Complex): [X] features
- Phase 2 (Medium): [Y] features  
- Phase 3 (Simple): [Z] features

---

## 🔗 Feature Index

*This section lists all identified features but does NOT explain them. Feature details live in their individual F[x] docs.*

**Phase 1 Features:**
- [Feature Name] → `NOTES/[Feature_Name]/`
- [Feature Name] → `NOTES/[Feature_Name]/`

**Phase 2 Features:**
- [Feature Name] → `NOTES/[Feature_Name]/`

**Phase 3 Features:**
- [Feature Name] → `NOTES/[Feature_Name]/`

---

## ⚙️ Maintenance Notes

**Last Updated:** [Date]
**Update Trigger:** When any feature initialization (INS-03) changes app architecture or introduces new concepts, F0 must be updated to reflect current reality.
```

---

## 📋 PHASE 4: MASTER PROGRESS TRACKER

**Action:** Create `01-FEATURES/F0-[App_Name]/F0-Progress.md`

**Content Template:**

```markdown
# 📊 F0 - [App Name] Master Progress Tracker
**Status:** 🟡 In Progress
**Total Features:** [X]

---

## 📈 Progress Overview

**Completion Stats:**
- Complete Notes: [X] / [Total]
- Discussions Complete: [X] / [Total]
- R1s Created: [X] / [Total]
- F[x] Initialized: [X] / [Total]

---

## 🏗️ Phase 1: Complex Features (Explain First)

### [Feature Name]
**Folder:** `NOTES/[Feature_Name]/`
**Complexity:** High
**Initialization:**
- [ ] Complete notes in `ORIGINAL IDEA/N1-[Feature_Name].md`
- [ ] Complete R1 - Pre raw feature (INS-01)
- [ ] Make F[x] of that feature (INS-02)

### [Feature Name]
**Folder:** `NOTES/[Feature_Name]/`
**Complexity:** High
**Initialization:**
- [ ] Complete notes in `ORIGINAL IDEA/N1-[Feature_Name].md`
- [ ] Complete R1 - Pre raw feature (INS-01)
- [ ] Make F[x] of that feature (INS-02)

---

## 🎨 Phase 2: Medium Features

### [Feature Name]
**Folder:** `NOTES/[Feature_Name]/`
**Complexity:** Medium
**Initialization:**
- [ ] Complete notes in `ORIGINAL IDEA/N1-[Feature_Name].md`
- [ ] Complete R1 - Pre raw feature (INS-01)
- [ ] Make F[x] of that feature (INS-02)

---

## 🚀 Phase 3: Simple Features

### [Feature Name]
**Folder:** `NOTES/[Feature_Name]/`
**Complexity:** Low
**Initialization:**
- [ ] Complete notes in `ORIGINAL IDEA/N1-[Feature_Name].md`
- [ ] Complete R1 - Pre raw feature (INS-01)
- [ ] Make F[x] of that feature (INS-02)

---

## 🔍 Final App Clarification Phase

**Trigger:** After all features have completed R1 documentation.

### Whole App Review
- [ ] Perform INS-06 Version 1 (Full app questions & ideas for ALL features)
- [ ] User responds to questions in `NOTES/FINAL INIT APP QUESTIONS & IDEAS.md`
- [ ] Update all R1s based on clarifications
- [ ] Create new feature folders if clarification reveals missing features

---

## ✅ Completed Features

*Features move here after all 4 initialization steps are complete.*

### [Feature Name] ✓
**Folder:** `NOTES/[Feature_Name]/` → `FEATURES/F[x]-[Feature_Name]/`
**Completed:** [Date]
- [x] Complete notes
- [x] Complete R1
- [x] Make F[x]

---

## 📝 Notes

- Checkboxes can be marked by user OR AI (user decides workflow)
- Features ordered by explanation complexity within phases (randomized within same tier)
- New features added during clarification (INS-09) get appended to appropriate phase
- This file is the single source of truth for app initialization progress
```

---

## 🛑 EXECUTION CONSTRAINTS

1. **NO AUTOMATIC TRIGGER:** User must explicitly request F0 initialization. This is a deliberate, manual process.

2. **WORKSPACE FOLDER CREATION:** ALWAYS create these folders during F0 initialization:
   - `04-WORK/CYCLES.md` - Work session planning
   - `04-WORK/USER TODO & NOTES.md` - Personal task tracking
   - `04-WORK/PAGE-REGISTRY.md` - Global page tracker (sequential P1, P2, P3...)
   - `03-NOTES/FUTURE IDEAS/` - Ideas for future features
   - `05-JUNK/IMAGES/` - UI reference images with README.md
   - `05-JUNK/DEMOS/` - Demo files and experiments
    
3. **FEATURE FOLDER DISCOVERY:** Scan ALL folders in `NOTES/` - every identified feature gets the folder structure treatment.
    
4. **N1 PREFIX STANDARD:** First idea document in `ORIGINAL IDEA/` folder MUST be named `N1-[Feature_Name].md` (enables future N2, N3 iterations).

5. **UIDR FOR UI FEATURES:** Features with significant UI should have:
   - `UI/UIDR-[Feature_Name].md` - UI documentation with layout diagrams and interaction flows
   - `UI/IMAGES/` - Reference images for that feature's UI
   - Later: `UI/UIR1-[Feature_Name].html` - HTML mockup (generated via INS-08)
    
6. **NO FEATURE MENTIONS IN F0-DOC:** F0 documentation explains app architecture and philosophy WITHOUT naming specific features. Features listed in index section only.
    
7. **COMPLEXITY-BASED PHASES:** Order features by explanation difficulty (hardest first), NOT by technical dependencies or implementation order.
    
8. **RANDOMIZATION WITHIN TIERS:** Features with same complexity level should be randomized to prevent unconscious bias in ordering.
    
9. **LIVING DOCUMENT:** F0-Doc must be updated whenever any feature initialization (INS-02) changes the app's conceptual architecture.
    
10. **USER VOICE PRESERVATION:** F0-Doc should reflect user's writing style from raw notes - keep it authentic, not corporate.
    
11. **CHECKBOX FLEXIBILITY:** Progress checkboxes can be marked by user OR AI - workflow is user's choice.
    
12. **PHASE GRANULARITY:** Each feature gets exactly 3 initialization todos - no more, no less. This creates consistent progress tracking. The 4th step (INS-06 Version 1) happens once for the entire app after all R1s are complete.

---

## 🔄 F0 Update Triggers

F0-Doc must be updated when:
- New feature concept introduced through INS-06 clarification
- Existing feature changes core app architecture (e.g., new database paradigm)
- App philosophy or design principles evolve
- Tech stack changes (new framework, different backend)
- Integration strategy shifts (API changes)

**Update Process:**
1. Identify what changed in feature documentation
2. Update relevant F0-Doc sections (Architecture, Core Concepts, Tech Stack)
3. Do NOT add feature names - keep F0 feature-agnostic
4. Update "Last Updated" timestamp in F0-Doc

---

## 📐 Example F0 Structure

**Example App:** "Personal Productivity Suite"

**Folders Created:**
```
NOTES/
├── Task Management/
│   ├── ORIGINAL IDEA/N1-Task_Management.md
│   ├── RAW/ (empty until R1 created)
│   ├── UI/ (for UI-heavy features)
│   │   ├── UIDR-Task_Management.md (UI documentation)
│   │   ├── UIR1-Task_Management.html (HTML mockup, later)
│   │   └── IMAGES/ (reference screenshots)
│   └── EXAMPLES/ (empty)
├── Calendar Integration/
│   ├── ORIGINAL IDEA/N1-Calendar_Integration.md
│   ├── RAW/ (empty)
│   ├── UI/
│   └── EXAMPLES/ (empty)
├── Analytics Dashboard/
│   ├── ORIGINAL IDEA/N1-Analytics_Dashboard.md
│   ├── RAW/ (empty)
│   ├── UI/
│   └── EXAMPLES/ (empty)

FEATURES/
├── F0-Personal_Productivity_Suite/
│   ├── F0-Doc.md (App vision, architecture, philosophy)
│   └── F0-Progress.md (Master tracker with 3 features × 4 todos = 12 checkboxes)
```

**Phase Assignment:**
- Phase 1 (High): Analytics Dashboard (complex data visualization + aggregation)
- Phase 2 (Medium): Calendar Integration (standard API integration)
- Phase 3 (Low): Task Management (straightforward CRUD operations)

---

## 🎓 Protocol Philosophy

F0 represents **intentional project initialization**. Unlike ad-hoc feature addition, F0 forces you to:
- Think holistically about your app BEFORE diving into features
- Structure knowledge for future discoverability
- Track progress systematically across all features
- Maintain architectural coherence as project grows

**F0 is your project's foundation - treat it as sacred.**
