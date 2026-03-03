# INS-GM2: Product Map Protocol

**System ID:** `INS-GM2`
**Trigger:** User says "Create Product Map", "Initialize GM2", "Map sub-projects", or "Document brand products"
**Input Requirement:** `GM/GM0 - Brand.md` (Mandatory)
**Output Target:** `GM/GM2 - Products.md`

---

## 🎯 STRATEGIC INTENT

This protocol maps every sub-project (repo) that belongs to the brand into one reference document. It answers: *"What does this brand ship, and how do the pieces relate?"*

This file is used by every sub-project AI session to understand its place in the larger ecosystem — preventing the App AI from duplicating what the Website already handles, for example.

---

## 🕵️ PHASE 1: AUDIT

**Step 1: Read Sources**
- Read `GM/GM0 - Brand.md` for the full brand picture
- Scan local filesystem for sibling repos/folders if accessible
- Ask user to list all current and planned sub-projects

**Step 2: Create Audit File**
- **Create:** `NOTES/Brand/GM2-Products-Audit.md`
- **Questions:**
  1. List all sub-projects that currently exist (name + one line of purpose)
  2. List all sub-projects planned for the future
  3. Which sub-project is the PRIMARY product? (the one that generates the most value)
  4. Which sub-projects share users? Which have separate audiences?
  5. How do sub-projects connect? (shared API, shared auth, separate, etc.)
  6. Is there a shared component library / design system repo?
  7. Who is the primary user of EACH sub-project?

- **Output in chat:** "Product audit ready. Answer these 7 questions and I'll build the map."

**STOP:** Wait for user answers.

---

## 🗺️ PHASE 2: GM2 CREATION

**Trigger:** User provides answers.

**Action:** Generate `GM/GM2 - Products.md`

### File Structure

```markdown
# GM2 — Product Map: [Brand Name]

## 🗺️ Ecosystem Overview
> [1-2 sentence description of how all products fit together]

## 📦 Sub-Projects

### [Project Name] — [Type: App / Website / API / Admin / Mobile]
- **Repo/Folder:** `[path or repo name]`
- **Purpose:** [one clear sentence]
- **Primary User:** [persona from GM0]
- **G-Files:** `GENERAL/G0`, `G1`, `G2` (link if exists)
- **Status:** 🟢 Active / 🟡 In Development / 🔵 Planned / ⚫ Deprecated
- **Key Features:** [bullet list, max 5]
- **Connects to:** [which other sub-projects it talks to]

### [Next Project...]

## 🔌 Integration Map
> How sub-projects connect to each other:

| From | To | Method | Notes |
|------|----|--------|-------|
| App | API | REST | Auth required |
| Website | App | Link | SSO handoff |

## 🚫 Boundary Rules
> What each sub-project does NOT own (prevents duplication):
- **App** does NOT own: marketing copy, SEO pages
- **Website** does NOT own: user data, app logic
- **[Project]** does NOT own: [...]

## 📅 Roadmap Signals
> High-level planned additions (not feature specs — those live in F-Docs):
- [Project]: [planned direction]
```

---

## ✅ PHASE 3: VALIDATION

- [ ] Every currently existing sub-project has an entry
- [ ] Every entry has a Status indicator
- [ ] Integration Map has at least one row if sub-projects interact
- [ ] Boundary Rules section prevents at least one obvious duplication
- [ ] File is under 150 lines — if longer, the individual projects are too detailed (move to their G0s)

**Output in chat:**
> "GM2 Product Map created. All [N] sub-projects are mapped. Reference this from any sub-project session to understand the full product ecosystem."
