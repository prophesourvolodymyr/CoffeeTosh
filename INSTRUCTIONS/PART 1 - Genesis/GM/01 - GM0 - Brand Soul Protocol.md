# INS-GM0: Brand Soul Protocol

**System ID:** `INS-GM0`
**Trigger:** User says "Create Brand Soul", "Initialize GM0", "Setup Brand Master", or "Create GM files"
**Input Requirement:** `NOTES/` (raw brand ideas) OR existing sub-project `GENERAL/G0` files
**Output Target:** `GM/GM0 - Brand.md`

---

## 🎯 STRATEGIC INTENT

This protocol creates the **Supreme Brand Law** — the single source of truth that all sub-projects (App, Website, Admin, etc.) inherit. It captures the brand's soul, audience, tone, and voice so that every sub-project AI session starts with a shared identity, not a blank slate.

**GM0 is NOT a product spec.** It documents the BRAND, not any single product.
- ❌ "The app has a dark mode toggle" → that goes in G0 of the App
- ✅ "The brand speaks in a warm, direct, no-BS tone" → that goes in GM0

**Conflict Rule:** GM0 > G0 for brand decisions. G0 > GM0 for product-specific decisions.

---

## 🕵️ PHASE 1: INGESTION & AUDIT

**Step 1: Read Sources (Priority Order)**
1. Read all files in `NOTES/` — extract brand signals
2. If sub-project G0 files exist, read them — extract consistent themes
3. Identify conflicts between sub-projects (e.g. App G0 says "playful", Website G0 says "corporate")

**Step 2: Create Audit File**
- **Create:** `NOTES/Brand/GM-Init-Audit.md`
- **Content — 20 questions across 4 categories:**

  **Identity (5 questions)**
  - What is the brand name?
  - What is the one-line brand promise?
  - What is the origin story / "why does this exist"?
  - What 3 adjectives describe this brand's personality?
  - What brands does this aspire to be like (and why)?

  **Audience (5 questions)**
  - Who is the primary audience? (demographics, psychographics)
  - What is their biggest pain point this brand solves?
  - How does the audience currently solve this problem?
  - What does success look like for the audience after using this brand?
  - Who is explicitly NOT the audience?

  **Tone & Voice (5 questions)**
  - How does the brand speak? (formal/casual, serious/playful, etc.)
  - What words/phrases does the brand NEVER use?
  - What words/phrases does the brand OWN?
  - How does the brand handle mistakes or negative situations?
  - Write one example sentence in the brand's voice.

  **Market Position (5 questions)**
  - Who are the top 3 competitors?
  - What makes this brand different from each competitor?
  - What is the brand's pricing position? (premium / mid / accessible)
  - What category does this brand want to OWN?
  - In 5 years, what does this brand want to be known for?

- **Output in chat:** "Audit created at `NOTES/Brand/GM-Init-Audit.md`. Please answer all 20 questions. I'll wait."

**STOP:** Do not proceed until user answers.

---

## 🧠 PHASE 2: GM0 CREATION

**Trigger:** User provides answers.

**Action:** Synthesize answers into `GM/GM0 - Brand.md`

### File Structure

```markdown
# GM0 — Brand Soul: [Brand Name]

## 🏷️ Identity
- **Brand Name:** 
- **One-Liner:** 
- **Origin Story:** 
- **Personality:** [3 adjectives]
- **Aspirational Brands:** [Brand X because Y]

## 👥 Audience
- **Primary Persona:** [Name, age range, situation]
- **Pain Point:** 
- **Current Solution:** 
- **Success Metric:** 
- **Anti-Persona:** [Who this is NOT for]

## 🗣️ Tone & Voice
- **Voice:** [e.g., warm, direct, no-BS]
- **Never Say:** [list]
- **Always Say:** [list]
- **Example Sentence:** "[...]"
- **Mistake Handling:** [how the brand responds]

## 🏆 Market Position
- **Category:** 
- **Differentiators:** 
  - vs [Competitor 1]: [...]
  - vs [Competitor 2]: [...]
- **Price Position:** [Premium / Mid / Accessible]
- **5-Year Goal:** 

## 📦 Sub-Projects
> See `GM/GM2 - Products.md` for the full product map.
- [App Name] — [one line]
- [Website Name] — [one line]
```

**Step 2: Output in chat:**
> "GM0 created. Brand soul is locked. Sub-projects will now inherit this as their base context. Next: run GM-01 to define the Visual DNA, or GM-02 to map your products."

---

## ✅ PHASE 3: VALIDATION

Before saving, verify:
- [ ] All 5 identity fields are filled
- [ ] Audience section has a named persona (not just "developers")
- [ ] Tone section has at least 3 "Never Say" and 3 "Always Say" entries
- [ ] Market position has at least 2 competitor differentiators
- [ ] File is under 300 lines (if longer, it's a spec, not a law — trim it)
