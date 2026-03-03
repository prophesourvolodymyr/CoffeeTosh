
**System ID:** `INS-03-NEW` 
**Trigger:** User request to "Initialize Idea" or "Create Documentation" for a specific Topic.
**Input Requirement:** User must provide the **Topic Name**. R[x] numbering is automatic.
**Output Target:** `NOTES/[Feature_Name]/RAW/R[x]-[Topic]-Documentation.md`
**Prerequisites:** NOTES folder structure exists (Created via INS-00A, 00B, 00C, or 11)

---

### 📌 R[x] Numbering Rule
**R[x] is version numbering PER feature folder:**
- Each `NOTES/[Feature_Name]/` folder has its OWN R1, R2, R3... sequence
- R1 = first draft, R2 = revision, R3 = another revision
- Example:
  - `NOTES/Homework/RAW/R1-...` (first draft)
  - `NOTES/Homework/RAW/R2-...` (revision)
  - `NOTES/Book Reading/RAW/R1-...` (first draft for different feature — separate sequence)

---

### 🔗 Workflow Position

```
INS-00[x] (Init) → INS-01 (This) → INS-02[x] (Feature Init)
```

After completing R1 documentation, the feature is ready for:
- **INS-02A (Standard):** Build logic-heavy feature.
- **INS-02B (Website):** Build page-heavy website feature.
- **INS-06:** If questions arise, run clarification protocol.

---

## 🤖 PHASE 1: THE SYNTHESIS ENGINE (Inputs)

**Role:** Senior Solutions Architect. **Objective:** Ingest the User's specific "Feature Idea" and merge it with "Chat Memory" to create a unified Research Artifact (R[x]) that will eventually become a Feature.

**You must actively analyze these three data streams:**

1. **The Target Topic:** The specific Feature ID (R[x]) and Name provided by the user (e.g., "R1 - Telegram Notification System").
    
2. **The Memory Stream:** Recall all recent Q&A, decisions we made regarding tech stack (React vs Vue, SQL vs NoSQL), and specific user preferences expressed in previous messages.
    
3. **The Reference Bank:** If the `NOTES/EXAMPLES/` folder has content, use it to align the architectural style.
    

## 🧠 PHASE 2: COGNITIVE PROCESSING (The "Thinking" Step)

_Do not output this section. Perform these steps internally before writing the document._

1. **Gap Analysis:** Identify what the user _forgot_ to mention about this specific topic. (e.g., "User asked for R1-Login but didn't specify the 2FA method. I will assume a standard TOTP flow based on context.")
    
2. **Conflict Resolution:** If the new idea contradicts a previous decision, prioritize the _new_ idea but note the conflict.
    
3. **Feasibility Check:** Assess if this specific R[x] feature requires specific libraries or external APIs.
    

## 📝 PHASE 3: OUTPUT GENERATION (The R-Document)

**Action:** Create (or overwrite) a file in the feature's `RAW/` folder:
- Path: `NOTES/[Feature_Name]/RAW/R[x]-[Topic]-Documentation.md`
- Check existing R files to determine next version number (R1, R2, R3...)

**Content Template:** Use the structure below strictly.

```
# 🧪 R[x] - [Topic] Research Documentation
**Date:** [Current Date]
**Status:** 🟡 Raw Research (Precursor to F[x])

## 1. 👁️ The Vision (R[x])
*A high-level synthesis of this specific feature. How does it function, and why does it exist?*

## 2. 🧠 Memory & Context Integration
*Crucial: List the specific decisions we made in chat that shape this feature.*
* **Decision:** [e.g., "For R1, we agreed to use n8n workflows."]
* **Constraint:** [e.g., "Must run on schedule."]

## 3. 🏭 Technical Architecture Strategy
*The proposed "How" for this specific feature.*
* **Core Logic:** [Brief explanation of the algorithm or flow]
* **Data Needs:** [What data does R[x] consume or produce?]
* **Key Libraries:** [Packages needed specifically for R[x]]

## 4. 🧩 The Component Breakdown
*Break this R[x] automation down into smaller logical parts (Sub-automations).*
* **Part A:** [Description]
* **Part B:** [Description]

## 5. ⚠️ Gap Analysis & Risks
*What is missing? What is hard?*
* [ ] **Unresolved Question:** [Ask the user about specific logic]
* [ ] **Technical Risk:** [e.g., "API Rate limits for this automation"]
```

## 🛑 EXECUTION CONSTRAINTS

1. **NO CODE:** Do not write implementation code in this file. This is for strategy only.
    
2. **SCOPE:** Focus ONLY on the requested Topic (R[x]). Do not summarize the entire project unless R[x] is "Project Overview".
    
3. Ensure taht it always gives an idea not tells that this is how it must be in the final automation.