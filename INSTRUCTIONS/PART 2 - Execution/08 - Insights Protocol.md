# INS-P2-08: Codebase Insights Protocol

**System ID:** `INS-P2-08`
**Trigger:** User says "Extract insights", "What did we learn?", "Document insights", or "Save AI learnings"
**Input Requirement:** Active codebase. `FEATURES/F1` must exist — this protocol is only useful once real implementation has begun.
**Output Target:** `WORK/INSIGHTS.md` (created or updated)

---

## 🎯 STRATEGIC INTENT

This protocol captures **hard-won knowledge** about the codebase — patterns discovered, mistakes made, gotchas found, and conventions established — so the next AI session (or a new AI entirely) starts with an advantage instead of repeating the same mistakes.

**When to use:**
- End of a feature or session
- Before switching AI tools or AI chat windows
- When a non-obvious pattern or constraint is discovered
- When something took significantly longer than expected due to a codebase quirk

**This is NOT:**
- A task list (that's `CYCLES.md`)
- A design decision log (that's `G0/G1/G2`)
- A feature doc (that's `F[x]-Doc`)

**User Commands:**
| Command | What it does |
|---------|-------------|
| `"Extract insights"` | Full protocol — scan + write to INSIGHTS.md |
| `"What did we learn?"` | Same as above |
| `"Give me 3 insights"` | Quick extract — outputs in chat only, does NOT write to file |
| `"Update insights"` | Appends a new session block to existing INSIGHTS.md |
| `"Show insights"` | Reads and displays current INSIGHTS.md content, no changes |

---

## 🧠 PHASE 1: INSIGHT EXTRACTION

Scan the current codebase and active session context. Extract exactly **3–5 insights** in these categories:

**Category A — Codebase Patterns (How this code works)**
- Non-obvious architectural decisions
- Custom conventions that differ from framework defaults
- Files/folders that are deceptively important

**Category B — Gotchas & Landmines (What to avoid)**
- Things that break silently
- Dependencies with unexpected behavior
- Patterns that look correct but are wrong in this codebase

**Category C — Established Conventions (What to follow)**
- Naming patterns the team uses
- State management approach
- How errors are handled
- How styles are applied (utility-first? CSS modules?)

---

## 📝 PHASE 2: WRITE TO INSIGHTS.MD

**Action:** Create or append to `WORK/INSIGHTS.md`

### File Format

```markdown
# 🧠 CODEBASE INSIGHTS

> Last updated: [Date]
> These are hard-won learnings about this codebase. Read before starting any new feature.

---

## Session: [Feature Name or Date]

### ✅ Patterns (Follow These)
- **[Pattern name]:** [What it is and why it matters]

### ⚠️ Gotchas (Avoid These)
- **[Issue name]:** [What goes wrong and how to avoid it]

### 📐 Conventions (This Codebase Specific)
- **[Convention]:** [The rule and where it applies]

---
```

**Rules:**
- Each insight must be **one sentence max** — actionable, not narrative
- If `INSIGHTS.md` already exists, **append** a new session block — never overwrite
- Max 5 insights per session. Quality over quantity.
- If there is genuinely nothing non-obvious to capture, output: *"No new insights — patterns are straightforward. INSIGHTS.md not updated."*

---

## ✅ PHASE 3: CONFIRM

Output in chat:
> "Insights saved to `WORK/INSIGHTS.md`. [N] insights captured for this session. Next AI session should read this file before touching the codebase."

---

## 🛑 EXECUTION CONSTRAINTS

1. **F1 GATE:** If F1 doesn't exist, do not run this protocol.
2. **NO OPINIONS:** Only document facts about the codebase, not aesthetic preferences.
3. **APPEND ONLY:** Never delete existing insights — they represent prior work.
4. **3–5 LIMIT:** Do not dump everything. Pick the most impactful learnings only.
