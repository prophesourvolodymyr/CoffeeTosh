# ⌨️ PROMPT SHORTCUTS REFERENCE

**Trigger:** `Option + V` → then press key

---

## 🔢 PROTOCOLS (1-9, -, =)

| Key | Protocol | Prompt |
|-----|----------|--------|
| `1` | P1/00A Genesis Init | Initialize project for this workspace |
| `2` | P1/03 Notes Processing | Process notes for: |
| `3` | P3/02A Feature Construction | Build feature from R[x] for: |
| `4` | P3/00 Codebase Research | Research codebase for: |
| `5` | P3/03 Session Plan | Plan session for: (Specify tasks) |
| `6` | P3/04 Cycle Management | Update cycles with current progress |
| `7` | P1/04 Clarification | Ask clarification questions for: |
| `8` | P1/06 Visual Mockup | Create visual mockup for: |
| `9` | P2/00-05 Audits | Audit [vision/design/architecture/data/features] |
| `-` | P1/07 Documentation | Create setup guide for: |
| `=` | P3/05 Feature Sync | Sync F[x] with updated notes |

---

## ⚡ QUICK ACTIONS

| Key | Name | Prompt |
|-----|------|--------|
| `0` | Read Agent | Read the AGENTS.md file and understand the project rules and structure before proceeding |
| `c` | Commit & Push | Stage all changes, generate a descriptive commit message based on what changed (be specific in first words), commit without co-author, and push to origin main |
| `q` | Quick Question | Quick question: |
| `w` | What's Current | Read WORK/CYCLES.md and the current feature's Progress.md file, then tell me exactly what we are working on right now, what's completed, and what's the next task |
| `s` | Start Session | Let's start implementing. Read the current feature's Progress.md, identify the next uncompleted task, and begin working on it. Ask me if anything is unclear before coding. |

---

## 🛠️ CODE ACTIONS

| Key | Name | Prompt |
|-----|------|--------|
| `f` | Fix Error | Fix this error. Read the error message, understand the context, and provide a working solution: |
| `r` | Refactor | Refactor this code to be cleaner, more readable, and follow best practices. Explain what you changed. |
| `t` | Write Tests | Write comprehensive tests for this code. Include edge cases and explain test coverage. |
| `d` | Document | Add clear documentation and comments to this code. Explain what each part does. |
| `e` | Explain | Explain this code in detail. What does it do, how does it work, and why is it written this way? |

---

## 📁 PROJECT NAVIGATION

| Key | Name | Prompt |
|-----|------|--------|
| `p` | Project Structure | Show me the current project structure and explain the purpose of each main folder |
| `l` | List Files | List all files in this folder with a brief description of each |
| `m` | Read README | Read the README.md file and summarize the project |

---

## 🎨 UI/FRONTEND

| Key | Name | Prompt |
|-----|------|--------|
| `i` | Improve UI | Improve the UI of this component. Make it more visually appealing, accessible, and user-friendly. |
| `h` | HTML Preview | Create an HTML preview/mockup of this UI design |
| `u` | UI Feedback | Review this UI and give me specific feedback on: layout, colors, typography, spacing, and accessibility |

---

## 📋 FULL PROMPT TEXTS

### `0` - Read Agent
```
Read the AGENTS.md file and understand the project rules and structure before proceeding. Follow the F-Cycle Protocol guidelines.
```

### `c` - Commit & Push
```
Stage all changes with git add -A, then analyze what files changed and generate a descriptive commit message. The message should be specific - start with the most important change (e.g., "Add user auth", "Fix navbar bug", "Update INS-02 protocol"). Do NOT add co-author. Commit and push to origin main. Show me the command you'll run before executing.
```

### `q` - Quick Question
```
Quick question: 
```

### `w` - What's Current
```
Read WORK/CYCLES.md and find the current active feature. Then read that feature's Progress.md file (in FEATURES/F[x]-[Name]/). Tell me:
1. What feature we're working on
2. What phase we're in
3. What tasks are completed (checked)
4. What's the NEXT uncompleted task
5. Any blockers or notes
```

### `s` - Start Session
```
Let's start implementing. 
1. Read WORK/CYCLES.md to identify current feature
2. Read that feature's F[x]-Progress.md
3. Find the next uncompleted task (first unchecked item)
4. Read F[x]-Doc.md for context if needed
5. Begin working on that specific task
6. If anything is unclear, ask me BEFORE writing code
```

### `f` - Fix Error
```
Fix this error. 
1. Read the full error message and stack trace
2. Identify the root cause
3. Check the relevant files
4. Provide a working solution with explanation
5. Make sure the fix doesn't break other things

Error: 
```

### `r` - Refactor
```
Refactor this code to be cleaner and more maintainable:
1. Improve readability (clear names, structure)
2. Remove duplication
3. Follow language best practices
4. Keep the same functionality
5. Explain each change you made
```

---

## 🔮 SUGGESTED ADDITIONS

| Key | Name | Description |
|-----|------|-------------|
| `b` | Bug Report | Describe this bug, how to reproduce it, and suggest potential causes |
| `a` | Add Feature | I want to add a new feature: [describe]. What files need to change? |
| `v` | Review Code | Review this code for bugs, security issues, and improvements |
| `n` | New File | Create a new file for: [purpose]. Follow project conventions. |
| `x` | Delete Safely | I want to delete this. Check if anything depends on it first. |
| `g` | Git Status | Show git status, recent commits, and any uncommitted changes |
| `z` | Undo | Undo the last change and explain what was reverted |

---

## ⚙️ SETUP

These shortcuts are configured in `~/.hammerspoon/init.lua`

**Trigger:** Hold `Option`, press `V`, release, then press the key.

**Edit prompts:** Modify the Hammerspoon config and reload.
