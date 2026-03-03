# INS-GM2-AUDIT: Product Map Retrofit Protocol

**System ID:** `INS-GM2-AUDIT`
**Trigger:** User says "Map existing products", "Retrofit GM2", "Document existing sub-projects", or "Create product map from existing repos"
**Input Requirement:** Access to existing sub-project repos/folders. `GM/GM0 - Brand.md` recommended.
**Output Target:** `GM/GM2 - Products.md`

---

## 🎯 STRATEGIC INTENT

This is the **Evolution** version of `INS-GM2`. Multiple products already exist. This protocol MAPS them by reading what's actually there — folder structures, README files, G0 files, package.json, etc. — rather than designing from scratch.

---

## 🕵️ PHASE 1: DISCOVERY

**Step 1: Scan for Sub-Projects**
- Check sibling directories if accessible
- Read any README files that describe the ecosystem
- Read `GM/GM0 - Brand.md` if it exists for project references
- Ask user: "List all sub-project repos/folders you want mapped"

**Step 2: Per Sub-Project Extraction**
For each sub-project found, extract:
- Name and type (App / Website / API / Admin / Mobile)
- Purpose (from G0, README, or package.json description)
- Status (active, prototype, deprecated — infer from git activity or ask)
- Primary user (from G0 or infer from codebase)
- Key features (from FEATURES/ folder listing or README)
- External connections (API calls, shared auth, shared DB)

**Step 3: Create Audit**
- **Create:** `NOTES/Brand/GM2-Products-Retrofit-Audit.md`
- List all discovered sub-projects
- Flag: projects with no G0 (need `INS-00-AUDIT` run on them)
- Flag: projects whose purpose overlaps (potential boundary conflict)
- Flag: integrations that are undocumented
- **Output in chat:** "Found [N] sub-projects. [X] have no G0. [Y] have potential boundary overlaps. Review audit?"

**STOP:** User reviews and confirms/corrects the discovered list.

---

## 🗺️ PHASE 2: GM2 CREATION

**Trigger:** User confirms sub-project list.

**Action:** Generate `GM/GM2 - Products.md` using identical structure as `INS-GM2` Phase 2.

**Additional section for retrofit:** Add a **"Known Technical Debt"** subsection noting:
- Sub-projects with no G-files yet
- Sub-projects with no clear ownership boundary
- Integrations that are implicit (not documented anywhere)

---

## ✅ PHASE 3: VALIDATION

- [ ] Every active sub-project has an entry
- [ ] No sub-project purpose duplicates another (boundary rules filled in)
- [ ] Integration Map has entries for ALL known connections
- [ ] Known Technical Debt section helps prioritize what to fix next

**Output in chat:**
> "GM2 Product Map retrofit complete. [N] sub-projects mapped. Recommended next actions: [list projects needing G0 audit, list boundary conflicts to resolve]."
