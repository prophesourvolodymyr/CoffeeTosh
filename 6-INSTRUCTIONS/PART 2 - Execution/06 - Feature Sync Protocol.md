# INS-05-EXEC: Feature Sync Protocol (Push Updates Into Features)

**System ID:** `INS-05-EXEC`
**Trigger:** User says "Sync Feature", "Update Feature from Notes", "Push R[x] into F[x]", or "Feature needs update"
**Input Requirement:** Updated `R[x]` or `UIDR[x]` in `NOTES/`, plus an existing `FEATURES/F[x]` folder
**Output Target:** Updated `F[x]-Doc.md`, `F[x]-Progress.md`, and optionally new `PAGES/`

---

## 🎯 STRATEGIC INTENT

Requirements evolve. When the user refines a Note into a new version (N2 → R2, or adds a UIDR where none existed), the existing Feature folder becomes **out of date**.

This protocol **diffs the old spec against the new** and surgically updates the Feature — without destroying existing progress or breaking completed work.

---

## ❓ PHASE 0: IDENTIFY THE SYNC TARGET

**Action:** When user triggers a sync, determine:

1. **Which Feature?** → `F[x]` — confirm the folder exists
2. **Which Note updated?** → `N[y]`, `R[y]`, or `UIDR[y]` — confirm the file exists
3. **What changed?** → New version (R2 vs R1), new UIDR, or content edit

**If ambiguous:** Ask the user to specify the feature number and the note file.

---

## 🔍 PHASE 1: THE DIFF

**Action:** Read both sources and compare.

### 1.1: Read Current F[x]-Doc.md
Extract:
- Current feature scope
- Listed requirements / specs
- Linked NOTES references
- Page/screen inventory (if any)

### 1.2: Read Updated R[x] / UIDR[x]
Extract:
- New requirements not in F-Doc
- Changed requirements (modified scope)
- Removed requirements (descoped)
- New screens/pages (if UIDR)
- New components (if UIDR)

### 1.3: Generate Diff Summary

```markdown
## 🔄 Feature Sync Diff: F[x] - [Name]
**Comparing:** F[x]-Doc (current) ↔ R[y] v[version] / UIDR[y]
**Date:** [Current Date]

### ➕ NEW (Not in F-Doc)
- [New requirement 1]
- [New requirement 2]
- [New screen: Settings Page]

### ✏️ CHANGED (Modified scope)
- [Requirement A: was "basic auth" → now "OAuth + MFA"]

### ➖ REMOVED (No longer in spec)
- [Requirement B: descoped by user]

### 🔲 UNCHANGED
- [Everything else — not touched]
```

---

## 📋 PHASE 2: THE SYNC PLAN (Draft → STOP)

**Action:** Present the sync plan to the user BEFORE making changes.

**Output:**

```markdown
## 📋 Sync Plan for F[x]

### F[x]-Doc.md Changes:
1. ADD section: [New Requirement]
2. UPDATE section: [Modified Requirement] — new scope: [...]
3. REMOVE reference: [Descoped item] → move to "Descoped" section (not deleted)
4. UPDATE linked Notes: R[y] v[version]

### F[x]-Progress.md Changes:
1. ADD new todos:
   - [ ] [New requirement 1]
   - [ ] [New requirement 2]
2. MARK as modified:
   - [ ] [Updated requirement] ← scope changed, re-verify
3. DESCOPED (will NOT be deleted, marked as struck):
   - ~~[Descoped requirement]~~

### PAGES/ Changes:
1. CREATE `P[n]-[NewPage]/` with Todos.md
2. UPDATE `P[existing]-Todos.md` with new tasks

### Approve? (y/n)
```

**🛑 STOP.** Wait for user approval.

---

## 🏗️ PHASE 3: EXECUTE THE SYNC

**Trigger:** User approves the sync plan.

### 3.1: Update F[x]-Doc.md
- **Add** new requirements under the appropriate section
- **Update** changed requirements with new scope
- **Move** descoped items to a `## Descoped` section (never delete)
- **Update** the Notes reference link to the new version
- **Add timestamp:** `Last Synced: [Date] from R[y] v[version]`

### 3.2: Update F[x]-Progress.md
- **Append** new todos as `- [ ]` checkboxes
- **Flag** modified todos with `⚠️ SCOPE CHANGED` marker
- **Strikethrough** descoped todos: `- ~~[descoped item]~~`
- **Do NOT touch** completed `- [x]` items unless they were descoped

### 3.3: Update PAGES/ (If UIDR Changes)
- **New screens** → Create `PAGES/P[n]-[PageName]/Todos.md`
- **Updated screens** → Append new tasks to existing `Todos.md`
- **Removed screens** → Move folder to `JUNK/` (never delete)

### 3.4: Version Stamp
Add to the top of `F[x]-Doc.md`:

```markdown
> **Sync Log:**
> - [Date]: Synced from R[y] v[version] — Added [X] requirements, modified [Y], descoped [Z]
```

---

## 🔁 MULTI-NOTE SYNC

If a Feature is built from multiple Notes (e.g., N1 for auth logic + N3 for auth UI):
1. Run the diff against EACH updated note separately
2. Combine all diffs into ONE sync plan
3. Present as a single approval gate
4. Execute as a single batch

---

## 🛑 EXECUTION CONSTRAINTS
1. **NEVER DELETE COMPLETED WORK.** If a `- [x]` task is descoped, add a strikethrough note but do not uncheck it.
2. **NEVER MODIFY CODE.** This protocol updates DOCUMENTATION only. Code changes happen via `INS-02A-EXEC` (Feature Construction).
3. **DRAFT FIRST.** The sync plan (Phase 2) must be approved before Phase 3 executes.
4. **ONE FEATURE AT A TIME.** Do not sync multiple features in parallel.
5. **PRESERVE PROGRESS.** The user's completed checkboxes are sacred. They represent real work done.
