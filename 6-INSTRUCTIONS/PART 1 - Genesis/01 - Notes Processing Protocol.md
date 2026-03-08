# INS-03-NEW: Notes Processing Protocol (N → Audit → R + UIDR)

**System ID:** `INS-01-NEW`
**Trigger:** User says "Process Notes for [Feature]", "Create R1", "Update R for [Feature]", or "Convert N to R"
**Input Requirement:** `NOTES/[Feature_Name]/ORIGINAL IDEA/N[x].md` must exist
**Output Target:** `NOTES/[Feature_Name]/EXAMPLES/Audit-R[x].md` → `NOTES/[Feature_Name]/RAW/R[x].md` + (optional) `NOTES/[Feature_Name]/UI/UIDR[x].md`

---

## 🎯 STRATEGIC INTENT

This is the **Refinery**. It takes raw user ideas (N[x]) and converts them into structured, actionable specifications (R[x]) that the Feature Construction protocol can consume.

**The Pipeline:**
```
N[x] (Raw Idea) → Classification → Audit → STOP → R[x] (Refined Spec) + UIDR[x] (UI Spec)
```

**Critical Rule:** This protocol NEVER writes R[x] directly. It ALWAYS creates an Audit first and waits for user approval.

---

## 🔗 Workflow Position

```
INS-00A/00B (Init) → Creates N1s
                ↓
        INS-03 (THIS) → Processes N[x] into R[x] + UIDR[x]
                ↓
        INS-04 (Clarification) → Optional deep-dive questions
                ↓
        INS-02A/02B (Feature Construction) → Builds FEATURES/ from R[x]
```

**Versioning Rule:** R[x] matches the N[x] version.
- N1 → R1 (first draft)
- N2 → R2 (user updated their idea)
- Each feature folder has its OWN R1, R2, R3... sequence

---

## 🏷️ PHASE 1: CLASSIFICATION (What Type of Feature?)

### 🔧 PRE-CHECK: Folder Structure Validation

**Action:** Verify the feature folder exists. If not, create it.

**Step 1: Check if `NOTES/[Feature_Name]/` exists**
- If folder exists → Proceed to Step 2
- If folder missing → Create structure:
  ```
  NOTES/[Feature_Name]/
    ├── ORIGINAL IDEA/
    ├── RAW/
    ├── UI/
    └── EXAMPLES/
  ```

**Step 2: Check if `N[x].md` exists in `ORIGINAL IDEA/`**
- If N1 exists → Proceed to Classification
- If missing → **STOP** and output: *"I created the folder structure for `[Feature_Name]`. Please create `NOTES/[Feature_Name]/ORIGINAL IDEA/N1-[Feature].md` with your feature idea, then re-run this protocol."*

---

### 📖 CLASSIFICATION (What Type of Feature?)

**Action:** Read `N[x]` and classify the feature.

**Read:**
1. `NOTES/[Feature_Name]/ORIGINAL IDEA/N[x].md`
2. `GENERAL/G0 - Idea.md` (for project context)
3. `NOTES/[Feature_Name]/EXAMPLES/` (for any existing references)
4. Previous R versions if they exist (for R2+)

**Classify Into One Of:**

| Type | Description | Outputs |
|------|-------------|---------|
| **Logic Feature** | Backend, API, Auth, Database logic | R[x] only |
| **UI Feature** | Dashboard, Settings, User-facing screens | R[x] + UIDR[x] |
| **Content Feature** | Landing page, Blog, Marketing | R[x] + UIDR[x] (Page-focused) |
| **Hybrid Feature** | Has both heavy logic AND UI | R[x] + UIDR[x] |

**Output:** State the classification in chat:
> "This is a **UI Feature** (Dashboard with data visualization). I will produce R[x] + UIDR[x]."

---

## 🕵️ PHASE 2: THE AUDIT (Draft → STOP → Approve)

**Action:** Create `NOTES/[Feature_Name]/EXAMPLES/Audit-R[x].md`

**Cognitive Steps (Internal):**
1. **Gap Analysis:** What did the user forget to mention?
2. **Conflict Check:** Does this contradict previous R versions or G-Files?
3. **Feasibility Check:** Does this need external APIs, specific libraries, or complex infrastructure?
4. **Scope Check:** Is the user asking for one feature or accidentally describing three?

**Audit Document Template:**

```markdown
# 🔍 Audit for R[x] - [Feature Name]
**Date:** [Current Date]
**Source:** N[x] - [Feature Name]
**Classification:** [Logic / UI / Content / Hybrid]
**Status:** 🟡 Awaiting User Review

---

## ❓ Questions
*Please answer the following to clarify your requirements:*

### Q1: [Specific question about unclear/missing information]
**Your Response:**
- 

### Q2: [Specific question about technical details]
**Your Response:**
- 

### Q3: [Specific question about user flow or behavior]
**Your Response:**Nx
- 

> **Note:** The questions amount is based on teh tipt, if it discusse more - mless questions, is less more quetsions, the same iwth idea, feel free to add more questions here or update the ones above based on our discussion.

---

## 💡 Ideas & Suggestions
*Optional enhancements not in your original request:*

1. **[Idea Title]:** [Description of enhancement]
   - **Complexity:** [Low/Medium/High]
   - **Approve?** [ ] Yes / [ ] No
   - **Your Response:** 
     - 

2. **[Idea Title]:** [Description of enhancement]
   - **Complexity:** [Low/Medium/High]
   - **Approve?** [ ] Yes / [ ] No
   - **Your Response:** 
     - 

---

## ⚠️ Problems
*(Only include this section if issues detected)*

- **Problem:** [Description of conflict, technical limitation, or blocker]
  - **Suggested Solution:** [How to resolve it]

---

## 📝 Other Notes
*Anything else you want to add? Additional context, changes, or clarifications:*

**Your Response:**
- 

---

**Next Step:** Once you've filled in your responses, say "Approved" to proceed to R[x] generation.
```

**🛑 STOP.** Output: *"I have created the Audit for R[x] in `NOTES/[Feature]/EXAMPLES/Audit-R[x].md`. Please review and fill in your responses to the Questions section and the Other Notes field at the bottom. Say 'Approved' when ready."*

---

## 📝 PHASE 3: R[x] GENERATION (The Refined Spec)

**Trigger:** User approves the Audit (with or without corrections).

**Action:** Create `NOTES/[Feature_Name]/RAW/R[x]-[Feature]-Documentation.md`

**Critical Writing Rule:** This feature likely contains MULTIPLE sub-systems (e.g. Contradiction Flag, Timeline, Relationships are all part of F1). Each sub-system gets its OWN dedicated section. Do NOT collapse them into generic bullets. Every detail from every Audit answer must appear somewhere in this document. If the Audit has 9 questions, the R[x] must reflect all 9.

**Content Template:**

```markdown
# 🧪 R[x] - [Feature Name] Research Documentation
**Date:** [Current Date]
**Status:** 🟡 Raw Research (Precursor to F[x])
**Classification:** [Logic / UI / Content / Hybrid]
**Source:** N[x] + Audit Feedback

---

## 1. 👁️ The Vision
*What does this feature do and why does it exist? What pain does it solve?*
[High-level synthesis from N[x] + user's audit answers. 3-5 sentences max. Focus on the user's words.]

---

## 2. 🧠 Locked Decisions
*These are confirmed by the user in the Audit. They are law. Do not re-question them in R[x].*

| Decision | Value | Source |
|---|---|---|
| [Decision name] | [The answer] | Q[x] |
| [Decision name] | [The answer] | Q[x] |

---

## 3. 🏗️ Sub-System Breakdown
*This feature contains [N] sub-systems. Each is documented fully below.*

### Sub-System 1: [Name]
**What it does:** [One sentence]
**Trigger / Entry point:** [How does the user or AI activate this?]
**Manual flow:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**AI flow:**
- [How AI proposes/creates/modifies this sub-system]
- [Ask-first rule: does AI auto-act or always confirm?]

**Data Schema (customData):**
```json
{
  "type": "[element_type]",
  "field1": "[value or description]",
  "field2": "[value or description]"
}
```

**Visual output:** [What appears on the canvas when this is triggered]
**Status lifecycle (if applicable):** [e.g. unresolved → investigating → resolved]
**What it replaces:** [The old manual way, number of steps saved]

---

### Sub-System 2: [Name]
[Repeat same structure as Sub-System 1]

---

### Sub-System N: [Name]
[Repeat same structure]

---

## 4. 🤖 AI Behavior Master Table
*All AI-driven actions for this feature in one place. Always confirm which are ask-first vs. autonomous.*

| Action | Trigger | Ask First? | What AI Does |
|---|---|---|---|
| [Action name] | [When it fires] | Yes / No | [Description] |
| [Action name] | [When it fires] | Yes / No | [Description] |

---

## 5. 📐 JSON Visibility Map
*Every piece of data this feature writes to the .excalidraw file. This is what the AI reads.*

| Element Type | customData field | Meaning |
|---|---|---|
| [e.g. arrow] | `type: "contradicts"` | [What it means] |
| [e.g. anchor] | `timeline[]` | [What it stores] |

---

## 6. 🔗 Cross-Feature Dependencies
*Other features this one depends on or affects.*

| Dependency | Feature | Why |
|---|---|---|
| [e.g. ElementOverlayManager] | F1 / F3 | [Reason] |
| [e.g. Evidence Tagging presets] | F3 | [Reason] |

---

## 7. 🧠 Skills File Registry
*Skills files to be created later in PROGRESS.md. Listed here so nothing is forgotten.*

| Skill File | Capability it gives AI | When invoked |
|---|---|---|
| `skill-[name].md` | [What AI can do] | [Condition] |

---

## 8. ⚠️ Risks & Open Questions
*Unresolved technical risks, blockers, or questions not answered in the Audit.*

- [ ] [Risk or open question]
- [ ] [Risk or open question]
```

---

## 🎨 PHASE 4: UIDR GENERATION (If UI/Content/Hybrid)

**Skip this phase if Classification = "Logic Feature".**

**Action:** Create `NOTES/[Feature_Name]/UI/UIDR[x]-[Feature].md`

**Critical Writing Rule:** This is a canvas-based plugin, not a web app with routes. Do NOT use web app language (routes, pages, screens). Use: **Panels**, **Overlays**, **Toolbars**, **Popups**, **Canvas Elements**. Every sub-system from R[x] that has a visual component gets its own UIDR section. Every badge color, every CSS class, every pixel-level detail confirmed in the Audit must appear here.

**Content Template:**

```markdown
# 🎨 UIDR[x] - [Feature Name] UI Design Reference
**Date:** [Current Date]
**Status:** 🟡 Design Spec (Precursor to F[x] Pages)
**Source:** R[x] + G1-Styles (if exists)
**CSS Prefix:** All new classes use `.exaliconnect-` prefix
**Naming:** All new TS files use `ExaliconnectXxx.ts` naming

---

## 1. 🎨 Visual Token Registry
*All colors, sizes, and style values used in this feature. Single source of truth.*

| Token | Value | Used In |
|---|---|---|
| `--ec-color-[name]` | `#XXXXXX` | [Component] |
| `--ec-color-[name]` | `#XXXXXX` | [Component] |

---

## 2. 🗂️ Canvas Panels
*Floating or docked UI panels rendered on the canvas (not Obsidian sidebar).*

### Panel: [Name]
- **Type:** Floating / Docked / Collapsible
- **Position:** [Where on canvas — e.g. top-left corner, pinned to frame edge]
- **Trigger:** [What opens it — button, right-click, auto]
- **Contents:**
  - [Item 1 — e.g. list of frames with names]
  - [Item 2 — e.g. collapse/expand toggle per row]
  - [Item 3 — e.g. filter dropdown]
- **Empty state:** [What shows when there's nothing to display]
- **CSS class:** `.exaliconnect-panel-[name]`

---

## 3. 🔲 Canvas Overlays
*React overlays rendered on top of Excalidraw elements (borders, highlights, badges).*

### Overlay: [Name]
- **Applied to:** [Which element type — e.g. any element, only arrows, only text]
- **Visual:** [Exact description — e.g. 2px dashed red border, gold background fill at 30% opacity]
- **Color:** `[hex value]`
- **CSS class:** `.exaliconnect-overlay-[name]`
- **Badge (if any):** [Symbol, position — e.g. `✕` top-right corner, 16px circle]
- **Badge color states:**
  | State | Color | Badge |
  |---|---|---|
  | [state] | `#XXXXXX` | `[symbol]` |

---

## 4. 💬 Popups & Forms
*Lightweight input popups that appear on user action (not full modals).*

### Popup: [Name]
- **Trigger:** [e.g. right-click → "Mark as Contradicting", stroke finished]
- **Position:** [e.g. at cursor, at element center, at stroke tip]
- **Fields:**
  - `[Field name]` — [type: text input / dropdown / toggle] — [required/optional]
  - `[Field name]` — [type] — [required/optional]
- **Actions:** [Confirm button label] / [Cancel / Escape dismisses]
- **On confirm:** [What happens — data written, overlay applied, etc.]
- **CSS class:** `.exaliconnect-popup-[name]`

---

## 5. 🏹 Canvas Elements Generated by Plugin
*Excalidraw elements the plugin creates programmatically (arrows, anchors, text nodes).*

### Element: [Name]
- **Excalidraw type:** `arrow` / `text` / `rectangle` / `freedraw` / custom
- **Style:**
  - Color: `[hex]`
  - Stroke: solid / dashed
  - Roughness: [0–3]
  - Arrowheads: none / start / end / both
  - Fill: [none / color / opacity]
- **Position logic:** [e.g. midpoint of source and target, offset 20px below element]
- **Editable by user?** Yes / No
- **customData written:** `{ type: "...", ... }`

---

## 6. 🖱️ Context Menu Additions
*New items added to right-click menus on the canvas.*

| Menu Item | Appears When | Action |
|---|---|---|
| "[Label]" | [Condition — e.g. 2+ elements selected] | [What it triggers] |
| "[Label]" | [Condition] | [What it triggers] |

---

## 7. 🔄 Interaction States
*For every interactive component: what does it look like in each state.*

| Component | Default | Hover | Active | Disabled |
|---|---|---|---|---|
| [Component] | [Description] | [Description] | [Description] | [Description] |

---

## 8. 📐 Layout & Style Rules
- **Style Reference:** Adhere to `GENERAL/G1-Styles.md`
- **Canvas context only:** No Obsidian sidebar components unless explicitly approved
- **Animation:** [Describe any transitions — e.g. overlay fades in 150ms]
- **Z-index:** Overlays sit above canvas elements but below Obsidian's native modals
- **Accessibility:** All interactive elements must have `aria-label`
```

---

## 🛑 EXECUTION CONSTRAINTS

1. **NEVER SKIP THE AUDIT.** Phase 2 is mandatory. No direct N→R conversion.
2. **NO CODE.** R[x] and UIDR[x] are strategy documents, not implementation.
3. **SCOPE CONTROL.** If N[x] describes multiple features, split them and process ONE at a time.
4. **VERSION AWARENESS.** If R1 already exists and you're creating R2, note what CHANGED from R1.
5. **USER WORDS WIN.** If the user corrected something in the Audit, their version is the truth.
