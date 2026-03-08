 # 🚀 F-CYCLE QUICK REFERENCE v2

**Copy-paste prompts for common operations.**

---

## 🤔 WHICH PROTOCOL DO I NEED?

### Part 1 — Genesis (New Project from Scratch)

**GENERAL/ — Creates G files:**
| # | Protocol | Trigger Phrase |
|---|----------|----------------|
| 1 | G0 Genesis Init | "Initialize project for [App Name]" |
| 2 | G1 Design Definition | "Create G1 styles for this project" |
| 3 | G2 Documentation | "Create G2 system doc for this project" |
| 4 | G3-G4-G5 Architecture | "Create G2 system for this project" |
| 5 | G1-HTML Style Guide | "Create component style guide" |

**GM/ — Creates Brand Master files (run ONCE per brand, before sub-projects):**
| # | Protocol | Trigger Phrase |
|---|----------|----------------|
| GM0 | Brand Soul | "Create brand master" / "Initialize GM0" |
| GM1 | Visual DNA | "Create brand design system" / "Initialize GM1" |
| GM2 | Product Map | "Map brand products" / "Initialize GM2" |

**Utility:**
| # | Protocol | Trigger Phrase |
|---|----------|----------------|
| 1 | Notes Processing | "Process notes for [Feature]" |
| 2 | Idea Incubation | "Explore this idea: [concept]" |
| 3 | Clarification | "Ask questions about [Feature]" |
| 4 | HTML Visual Mockup | "Create mockup for [Feature]" |

### Part 1B — Evolution (Existing Project → Create G/GM files)

**GENERAL/ — Extracts G files from existing code:**
| # | Protocol | Trigger Phrase |
|---|----------|----------------|
| 1 | G0 Vision Audit | "Audit project vision" / "Create G0 from codebase" |
| 2 | G1 Design Audit | "Audit design system" / "Create G1 from codebase" |
| 3 | G2 Architecture Audit | "Audit system architecture" / "Create G2 from codebase" |
| 4 | G3-G4 Data & API Audit | "Audit data and APIs" |
| 5 | G1-HTML Style Guide Retrofit | "Generate component showcase from existing styles" |

**GM/ — Extracts Brand Master from existing sub-projects:**
| # | Protocol | Trigger Phrase |
|---|----------|----------------|
| GM0 | Brand Soul Retrofit | "Extract brand soul from existing projects" |
| GM1 | Visual DNA Retrofit | "Build brand design system from existing styles" |
| GM2 | Product Map Retrofit | "Map existing sub-projects" |

### Part 2 — Execution (G files exist → Build features)
| # | Protocol | Trigger Phrase |
|---|----------|----------------|
| 1A | Feature Construction | "Build F[x]" / "Code [Feature]" |
| 2 | Codebase Research | "Research codebase for [Feature]" |
| 3 | Logic Specification | "Write pseudocode for [Feature]" |
| 4 | Session Plan | "Plan session for F[x]" |
| 5 | Cycle Management | "Update cycles" |
| 6 | Feature Sync | "Sync F[x] with updated notes" |
| 7 | Project Retrofit | "Retrofit this project into F-Cycle" |

---

## 🎯 COMMON SCENARIOS

**Brand new brand with multiple sub-projects:**
```
Init to this project → GM0 (Brand Soul) → GM1 (Visual DNA) → GM2 (Product Map)
→ then per sub-project: P1/G0 → P1/G1 (delta) → P1/G2 → Build
```

**Brand new single-project app (no brand layer):**
```
Init to this project → P1/G0 (Genesis) → P1/G1 (Styles) → P1/G2 (Arch) → Process Notes → Build
```

**Existing app, first time using F-Cycle:**
```
Init to this project → P1B/G0-G4 (Audits) → Process Notes → Build
```

**Existing brand with multiple repos, no GM yet:**
```
Init to this project → P1B/GM0 Retrofit → P1B/GM1 Retrofit → P1B/GM2 Retrofit
→ then trim each sub-project G0/G1 to delta-only
```

**Add feature to existing project:**
```
Process Notes → P2/1A (Build Feature)
```

**Continue from yesterday:**
```
Init to this project → "Plan session for F[x]" → Code
```

**Feature spec changed:**
```
Update NOTES R[x] → P2/6 (Feature Sync) → Continue coding
```

**Website/marketing site:**
```
Init to this project → P1/G0 → P1/G1 → P2/7 (Project Retrofit with P-Docs)
```

---

## 📋 THE PIPELINE

```
Brand Setup:  GM0 → GM1 → GM2           (once per brand, shared across all sub-projects)
New Project:  P1/G0 → G1(delta) → G2   (per sub-project, inherits GM)
Ideas:        N[x] → P1/1 (Process) → R[x] + UIDR[x]
Build:        P2/1A (Construct) → FEATURES/F[x]
Research:     P2/2 (Codebase) → P2/4 (Session Plan)
Audit:        P1B/G0-G4 (Scan → Draft → Approve → Write)
Sync:         P2/6 (Diff → Plan → Update F[x])
Retrofit:     P2/7 (Map legacy code → F[x] scaffold + P-Docs)
```

---

## 🏁 SESSION START

```
Init to this project
```
AI reads GENERAL/, reports Context Status, waits for command.

---

## 📝 DOCUMENTATION PROMPTS

### Process Raw Notes into Specs
```
Process notes for [Feature Name]
```

### Create Feature from Spec
```
Build F[x] from R[x] for [Feature Name]
```

---

## 🔍 RESEARCH PROMPTS

### Codebase Research (Permanent, per feature)
```
Research codebase for F[x] - [Feature Name]
```

### Session Plan (Temporary, per session)
```
Plan session for F[x] - I want to complete [specific tasks]
```

---

## 📅 PLANNING PROMPTS

### Update Work Cycles
```
Update cycles
```

### Sync Feature After Notes Update
```
Sync F[x] with updated R[x]
```

---

## 🎨 UI PROMPTS

### Create Visual Mockup
```
Create mockup for [Feature Name]
```

### Explore an Idea
```
Explore this idea: [concept description]
```

---

## 🔧 AUDIT PROMPTS (Existing Projects)

### Full Project Audit
```
Audit project vision
Audit design system
Audit system architecture
Audit data and APIs
Audit features
```

### Single G-File Audit
```
Audit [vision/design/architecture/data] for this project
```

---

## 💡 TIPS

1. **Always start sessions with:** `Init to this project`
2. **One feature per session** — don't mix F1 and F2 context
3. **Draft → Approve pattern** — AI creates drafts, you review, then it writes
4. **G-Files are law** — if F-Doc contradicts G0, G0 wins
5. **Mark progress immediately** — `- [ ]` → `- [x]` as tasks complete
