# INS-GM0-AUDIT: Brand Soul Retrofit Protocol

**System ID:** `INS-GM0-AUDIT`
**Trigger:** User says "Extract Brand Soul", "Retrofit GM0", "Create GM0 from existing projects", or "Build brand master from existing G files"
**Input Requirement:** Existing sub-project `GENERAL/G0` files OR existing codebase + NOTES
**Output Target:** `GM/GM0 - Brand.md`

---

## 🎯 STRATEGIC INTENT

This is the **Evolution** version of `INS-GM0`. The brand already exists — products are live or in development — but the GM layer was never formalized. This protocol EXTRACTS the brand soul from what's already been built and written down, rather than inventing it from scratch.

**Key Principle:** Trust the code and the notes over opinions. What the team has been building IS the brand, even if it was never written down as such.

---

## 🕵️ PHASE 1: FORENSIC BRAND EXTRACTION

**Step 1: Read All Available Sources**
Priority order:
1. All sub-project `GENERAL/G0-Idea.md` files across repos/folders
2. `NOTES/` files in each sub-project — especially `ORIGINAL IDEA.md`, `INITIAL IDEA.md`
3. Existing marketing copy (website hero text, About pages, README files)
4. App store descriptions, pitch decks if accessible

**Step 2: Extract Brand Signals**
For each source, extract:
- Recurring words/phrases (brand vocabulary signals)
- Audience descriptions
- Problem statements
- Mission/vision statements
- Tone of voice samples (how copy is written)

**Step 3: Conflict Detection**
- **Create:** `NOTES/Brand/GM0-Retrofit-Audit.md`
- **Flag:**
  - Contradictions between sub-projects (e.g., App G0 says "enterprise", Website copy says "indie developers")
  - Missing brand elements (no tone definition, no competitor context)
  - Drift signals (sub-projects feel visually/tonally disconnected)
- **Output in chat:** "Brand extraction complete. Found [N] brand signals across [X] sub-projects. [Y] conflicts detected. Review `GM0-Retrofit-Audit.md`. I'll ask only the gaps — no need to repeat what's already documented."

**STOP:** Present ONLY the unanswered questions from the audit. Do not ask questions that are clearly answered in existing files.

---

## 🧠 PHASE 2: GM0 CREATION

**Trigger:** User fills in the gaps.

**Action:** Synthesize extracted signals + user answers into `GM/GM0 - Brand.md`

Use **identical file structure** as `INS-GM0` Phase 2. The only difference is the data comes from extraction, not a blank interview.

**Important:** Where conflicts were found between sub-projects, include a `⚠️ Conflict Resolved:` note in GM0 explaining the decision made.

---

## ✅ PHASE 3: VALIDATION

- [ ] All fields filled — no "TBD" entries
- [ ] At least one `⚠️ Conflict Resolved` note if conflicts were found
- [ ] File under 300 lines
- [ ] Existing sub-project G0 files are NOT made redundant — GM0 is the parent, G0s become deltas

**Output in chat:**
> "GM0 Brand Soul extracted and formalized. [N] sub-project G0 files should now be updated to delta-only format — they no longer need to repeat audience, tone, or mission. Run `INS-00-AUDIT` on each sub-project to trim their G0s."
