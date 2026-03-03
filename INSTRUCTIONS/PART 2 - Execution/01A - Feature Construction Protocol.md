# INS-02A-EXEC: Feature Construction Protocol (Unified)

**System ID:** `INS-02A-EXEC`
**Trigger:** User says "Initialize Features", "Create Feature Sheet", "Migrate Legacy", or "Convert NOTES to FEATURES"
**Input Requirement:** `NOTES/` (Populated by Genesis R1 or Retrofit Audit)
**Output Target:** `FEATURES/F[x]-[Name]/`
**Prerequisites:** INS-11 (NOTES folders exist)

---

## 🎯 STRATEGIC INTENT

This protocol acts as the **Manufacturing Plant**. It takes raw materials (Ideas/Notes or Legacy Audits) from the `NOTES/` lab and builds the official production folders in `FEATURES/`.

**Capabilities:**
1.  **Greenfield Build:** Creates fresh scaffolding for new ideas.
2.  **Legacy Migration:** Creates scaffolding for refactoring/moving existing code.
3.  **Architecture Enforcement:** Splits Logic (`F-Doc`) from UI (`PAGES`).

> **📄 WEBSITE / MARKETING PROJECTS — P-DOC VARIANT:**
> If this project is a website or marketing site, each page uses a **P-Doc** instead of an R1 logic doc.
> A P-Doc captures: page purpose, target visitor, sections (top→bottom), primary CTA, and success metric.
> There is no logic spec for a page — content and layout IS the spec.
> P-Docs live at: `FEATURES/F[x]-[Name]/PAGES/[PageName]/P-Doc-[PageName].md`
> See `INSTRUCTIONS/PART 2 - Execution/7 - Project Retrofit Protocol.md` for the full P-Doc template.

---

## 🏗️ PHASE 1: THE PLANNING SHEET

**Trigger:** User says "Initialize Features" or "Migrate".

**Action:** Scan `NOTES/` and generate a plan.

**Step 1: Scan & Detect**
- List all folders in `NOTES/`.
- **Type Detection:**
    - If folder contains `RAW/R[x].md` -> **Type: New Build**.
    - If folder contains `Legacy Audit` or `Styles/` -> **Type: Migration**.

**Step 2: Generate Sheet**
Output the following markdown table to the user:

```markdown
# 🗂️ Feature Initialization Sheet
**Status:** ⏸️ Awaiting User Confirmation

## Reserved Components
- **F0:** App Documentation (Doc)
- **F1:** Design System (Style)

## Feature Queue

| ID | Feature Name | Type | Source | Pages |
|----|--------------|------|--------|-------|
| **F2** | [Name] | NEW | `NOTES/[Name]` | 0 |
| **F3** | [Name] | MIGRATE | `NOTES/[Name]` | 5 (Home, Login...) |

---
**Next Step:** Reply "Initialize All" or "Initialize F2 only".
```

**Hold:** Wait for user confirmation.

---

## 🏭 PHASE 2: THE FEATURE SHELL (Logic)

**Trigger:** User confirms list.
**Action:** Create the Feature Shell for each confirmed feature.

**Step 1: Create Main Folder**
- `FEATURES/F[x]-[FeatureName]/`

**Step 2: Create F[x]-Doc.md (The Logic Spec)**
- **Common Content:**
    - **Visual System:** "Adhere strictly to `GENERAL/G1-Styles.md`."
    - **Definition of Done:** 3-5 critical success criteria.
- **For New Build:**
    - Source: `NOTES/.../RAW/R[latest].md`.
    - Content: Technical Specs, Data Models, API Endpoints.
- **For Migration:**
    - Source: `NOTES/.../Legacy Audit` or `UIDR`.
    - Content: Refactor Goals, Legacy Source Path, Cleanup Strategy.

**Step 3: Create F[x]-Progress.md (The Tracker)**

**Rules:**
- No paragraphs. Only checkboxes `- [ ]`.
- Start with USER TODOS (config, setup, manual tasks).
- Break down implementation into codebase-specific steps.
- Organized by logical phases, not just "Backend" and "Frontend".

**Template Structure:**

```markdown
# 📊 F[x] - [Feature Name] Progress Tracker
**Status:** 🟡 In Progress
**Last Updated:** [Date]
**Source:** R[x] + UIDR[x] (if UI)

---

## 🧑 USER TODOS (Manual Setup Required)
*Tasks the user must complete before development can proceed.*

- [ ] **Environment Setup:** [e.g., Install package X, configure API keys]
- [ ] **External Services:** [e.g., Create database, set up OAuth provider]
- [ ] **Access/Credentials:** [e.g., Get API token from service Y]
- [ ] **Decision Needed:** [e.g., Choose between approach A or B for feature Z]

---

## 📋 PHASE 1: Foundation & Architecture
*Core structure and setup before feature logic.*

### 1.1 Data Layer
- [ ] Define data models/types in `[path/to/types.ts]`
- [ ] Create database schema/migrations in `[path/to/migrations]` (if applicable)
- [ ] Set up data validation schemas (Zod/Yup) in `[path/to/schemas]`
- [ ] Create mock data for development in `[path/to/mocks]`

### 1.2 API/Service Layer
- [ ] Create API routes in `[path/to/api]`
- [ ] Implement service functions in `[path/to/services]`
- [ ] Add error handling utilities in `[path/to/errors]`
- [ ] Write API tests in `[path/to/tests]`

### 1.3 Core Logic
- [ ] Implement main feature logic in `[path/to/feature-logic.ts]`
- [ ] Add utility functions in `[path/to/utils]`
- [ ] Create helper hooks (if React) in `[path/to/hooks]`
- [ ] Add state management (if needed) in `[path/to/store]`

---

## 🎨 PHASE 2: UI Implementation (Pages & Components)
*Frontend screens and user-facing elements.*

### 2.1 Shared Components
- [ ] Create reusable components in `[path/to/components]`:
  - [ ] `[ComponentA].tsx` - [Brief description]
  - [ ] `[ComponentB].tsx` - [Brief description]
- [ ] Style components using G1 Design System tokens
- [ ] Add component tests

### 2.2 Pages (See PAGES/ for detailed P[n]-Todos)
- [ ] **P1 - [Page Name]:** Main screen - `[file path]`
- [ ] **P2 - [Page Name]:** Settings screen - `[file path]`
- [ ] **P3 - [Page Name]:** Detail view - `[file path]`

### 2.3 Navigation & Routing
- [ ] Add routes to `[path/to/routes]`
- [ ] Update navigation menu in `[path/to/nav]`
- [ ] Add breadcrumbs/page titles

---

## 🔗 PHASE 3: Integration & Data Flow
*Connect all the pieces.*

### 3.1 Data Fetching
- [ ] Set up API client/hooks in `[path/to/api-client]`
- [ ] Implement data fetching for each page
- [ ] Add loading states
- [ ] Add error states
- [ ] Add empty states

### 3.2 State Management
- [ ] Connect global state (if applicable)
- [ ] Implement local state for pages
- [ ] Add form state management
- [ ] Handle data mutations (create/update/delete)

### 3.3 External Services
- [ ] Integrate [External API/Service name]
- [ ] Add authentication/authorization logic
- [ ] Implement webhooks (if applicable)

---

## ✅ PHASE 4: Polish & Quality
*Make it production-ready.*

### 4.1 User Experience
- [ ] Add animations/transitions
- [ ] Implement responsive design (mobile/tablet)
- [ ] Add keyboard shortcuts (if applicable)
- [ ] Improve accessibility (ARIA labels, focus management)

### 4.2 Error Handling & Edge Cases
- [ ] Add try-catch blocks in critical paths
- [ ] Handle network failures gracefully
- [ ] Add validation feedback for forms
- [ ] Test edge cases (empty data, max limits, etc.)

### 4.3 Performance
- [ ] Optimize re-renders (React.memo, useMemo)
- [ ] Add pagination/infinite scroll (if needed)
- [ ] Lazy load components/pages
- [ ] Optimize images/assets

### 4.4 Testing
- [ ] Write unit tests for core logic
- [ ] Write integration tests for API
- [ ] Write E2E tests for critical flows
- [ ] Manual QA testing

---

## 📚 PHASE 5: Documentation & Cleanup
*Final touches.*

- [ ] Update README with feature documentation
- [ ] Add inline code comments for complex logic
- [ ] Create user guide in `FEATURES/F[x]/GUIDES/` (if needed)
- [ ] Remove console.logs and debug code
- [ ] Update changelog/release notes

---

## 🎯 Definition of Done
- [ ] All phases completed
- [ ] No console errors
- [ ] Works on mobile/tablet/desktop
- [ ] Passes all tests
- [ ] User can [core feature action] successfully
```

**Customization Rules:**
- **For Logic-Only Features:** Remove Phase 2 (UI), expand Phase 1.
- **For UI-Heavy Features:** Expand Phase 2, add more pages.
- **For Migration Features:** Replace Phase 1 with migration-specific tasks (move files, refactor imports, update types).
- **Codebase Paths:** Replace ALL `[path/to/...]` placeholders with ACTUAL file paths from the project structure.

**Step 4: Handle Research**
- If `NOTES/.../Research.md` exists -> **Move** to `FEATURES/F[x]/F[x]-Research.md`.

---

## 📄 PHASE 3: THE PAGE BUILD (The P-System)

**Action:** Build the `PAGES/` sub-structure.

**Step 1: Detect Pages in NOTES**
- Scan `NOTES/[Feature]/UI/PAGES/`.
- **Manual Add:** If `NOTES/` contains a separate file listing pages (e.g. `PAGES_LIST.md`), read it.

**Step 2: Assign Local Numbers**
- Sort pages (alphabetical or by logical flow).
- Assign `P1`, `P2`, `P3`... specific to **this feature**.

**Step 3: Create Page Folders**
For each page (e.g., "Dashboard"):
1.  **Create Folder:** `FEATURES/F[x]/PAGES/P1-Dashboard/`
2.  **Create P1-Doc.md (Specs):**
    - Specific UI layout for *this page*, special behaviors, route.
3.  **Create P1-Todos.md (Action Plan):**
    - **For New Build:**
        - `## Layout`: Make Shell, Grid.
        - `## Components`: Make Chart, Make Table.
        - `## Logic`: Connect Data.
    - **For Migration:**
        - `## Migrate`: Move content from `[LegacyPath]`.
        - `## Refactor`: Update imports, fix types.
        - `## Style`: Implement F1 Design System.
4.  **Copy Assets:**
    - If `P-Mockup.html` exists in NOTES -> Copy to `P1-Mockup.html`.

**Step 4: Move UI Mockups**
- **Check:** Does `NOTES/[Feature]/UI/UIR[x]-[Feature]-Mockup.html` exist?
- **Action:** 
    1. Create `FEATURES/F[x]/UI/` folder (if doesn't exist)
    2. **Move** (not copy) `UIR[x]-[Feature]-Mockup.html` from NOTES to FEATURES
    3. **Rename** to `UI1-[Feature]-Mockup.html`
- **Purpose:** Keep the mockup with the feature implementation, not in research notes.

**Step 5: Update Registry**
- Run **INS-12** (Registry Sync) immediately after creating pages to update `WORK/PAGE-REGISTRY.md`.

---

## 🛑 EXECUTION CONSTRAINTS

1.  **NO GLOBAL P-NUMBERS:** P1 in F2 is different from P1 in F3.
2.  **NO UIDR:** UI specs belong in `F[x]-Doc` (General) or `P[n]-Doc` (Specific).
3.  **CLEAN PROGRESS:** `F[x]-Progress.md` must extract top-level tracking items.

---
