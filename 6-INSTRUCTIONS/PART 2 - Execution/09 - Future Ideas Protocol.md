# INS-P2-09: Future Ideas Protocol

**System ID:** `INS-P2-09`
**Trigger:** User says "Save future idea", "Log this for later", "Add to future ideas", "Park this idea", or "What are our future ideas?"
**Output Target:** `NOTES/zFUTURE IDEAS/` (created if missing)

---

## 🎯 STRATEGIC INTENT

This protocol captures ideas that are **out of scope** for the current feature or session — things worth keeping but not doing now. It prevents good ideas from getting lost in chat history.

**Two modes — user chooses:**

| Mode | File structure | Best for |
|------|---------------|----------|
| **A — Unified** | `NOTES/zFUTURE IDEAS/FUTURE-IDEAS.md` | Small projects, early stage |
| **B — Per-feature** | `NOTES/zFUTURE IDEAS/F[x]-[Name]-Ideas.md` | Larger projects with many features |

**If user hasn't specified a mode** → ask once:
> "Should I keep all ideas in one file (Mode A) or split by feature (Mode B)? I'll remember your choice."

Once mode is set, never ask again — just use it.

**When to write:**
- **Explicit:** User says any trigger phrase above
- **Passive:** At the end of a feature session, if the AI noticed requests that were intentionally skipped or deferred, log them automatically with a note: *(auto-captured — confirm or delete)*

---

## 🏗️ PHASE 1: SETUP

**Check:** Does `NOTES/zFUTURE IDEAS/` exist?
- No → create it
- Yes → proceed

**Check mode:**
- Mode A → ensure `NOTES/zFUTURE IDEAS/FUTURE-IDEAS.md` exists
- Mode B → ensure `NOTES/zFUTURE IDEAS/F[x]-[Name]-Ideas.md` exists for the relevant feature (create if missing)

---

## 📝 PHASE 2: WRITE THE IDEA

### Mode A — Append to `FUTURE-IDEAS.md`

```markdown
# 💡 Future Ideas

---

## [F[x] Name or "General"]

- **[Date]** — [One-line idea description]
  - *Context:* [What were we building when this came up?]
  - *Why deferred:* [Out of scope / too complex / needs more thought]

- **[Date]** — [Another idea]
  ...
```

### Mode B — Append to `F[x]-[Name]-Ideas.md`

```markdown
# 💡 Future Ideas — [F[x] Name]

---

- **[Date]** — [One-line idea description]
  - *Context:* [What were we building when this came up?]
  - *Why deferred:* [Out of scope / too complex / needs more thought]

- **[Date]** — [Another idea]
  ...
```

**Rules:**
- One bullet per idea — keep it short and actionable
- Always include context (what were we doing?) and why it was deferred
- Auto-captured ideas get tagged: *(auto — confirm or delete)*
- Never delete existing ideas — mark old ones as `~~struck through~~` if no longer relevant

---

## ✅ PHASE 3: CONFIRM

Output in chat:
> "Idea logged in `NOTES/zFUTURE IDEAS/[filename]`. [N] ideas total in this file."

---

## 👁️ READING IDEAS

**Trigger:** "Show future ideas" / "What ideas do we have?" / "Review future ideas"

- Mode A → read and display `FUTURE-IDEAS.md` grouped by feature section
- Mode B → ask "For which feature?" → display that file, or say "All" to display all files

---

## 🛑 EXECUTION CONSTRAINTS

1. **NOTES ONLY:** `zFUTURE IDEAS/` always lives in `NOTES/`. Never in `FEATURES/`, `GENERAL/`, or `WORK/`.
2. **APPEND ONLY:** Never overwrite or reorganize existing ideas without user instruction.
3. **ONE MODE:** Once mode is decided, stick to it for the project. Don't mix files.
4. **NO SCOPE CREEP:** Logging an idea does NOT mean it will be built. It is a parking lot, not a backlog.
