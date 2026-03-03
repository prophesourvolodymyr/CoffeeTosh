# INS-03-AUDIT: Data & API Audit (Target: G3 + G4)

**System ID:** `INS-03-AUDIT`
**Trigger:** User says "Audit Database", "Audit API", "How does the data work?", or "Create G3/G4"
**Input Requirement:** An existing codebase with backend/data logic
**Output Target:** `GENERAL/G3 - Data.md` and/or `GENERAL/G4 - API.md`

---

## 🎯 STRATEGIC INTENT

This protocol answers: *"How does this project store and move data?"*

It scans for databases, schemas, API routes, and authentication. These are combined into one audit because Data and API are tightly coupled — but they produce **two separate G-Files**.

**Skip Rule:** If the project has NO database and NO API (e.g., a static site), skip this entirely.

---

## 🔍 PHASE 1: DATA SCAN (Read Only)

**Action:** Find all data-related files.

**Scan Targets - Database (G3):**
1. **ORM/Schema:** `schema.prisma`, `models.py`, `*.entity.ts`, SQL migrations
2. **Database Config:** `.env` DB URLs, `database.yml`, connection files
3. **Seeders/Migrations:** `prisma/migrations/`, `alembic/`, `knex/migrations/`

**Extract for G3:**
- **Database Type:** PostgreSQL / MySQL / MongoDB / SQLite / Supabase / Firebase
- **ORM:** Prisma / Drizzle / SQLAlchemy / Mongoose / None
- **Models Detected:** List all entities (User, Post, Order, etc.)
- **Relationships:** Foreign keys, many-to-many tables
- **Hosting:** Where is DB hosted? (Supabase, PlanetScale, local, unknown)

**Scan Targets - API (G4):**
1. **Routes:** `app/api/`, `routes/`, `controllers/`, `views.py`
2. **Auth:** JWT tokens, session config, OAuth providers
3. **Middleware:** Auth guards, rate limiting, CORS

**Extract for G4:**
- **API Pattern:** REST / GraphQL / tRPC / gRPC
- **Base URL:** `/api/v1`, `/api/`, etc.
- **Endpoints List:** Method + Path + Purpose
- **Auth Strategy:** JWT / Session / OAuth / API Keys / None
- **External APIs:** Third-party services called (Stripe, Twilio, etc.)

---

## 📋 PHASE 2: DRAFT & VERIFY (The Gate)

**Action:** Create `NOTES/AUDIT/G3-G4-Draft.md`

**Content:**
```markdown
# G3 + G4 DRAFT - Data & API (Pending Approval)
**Status:** 🟡 DRAFT - Awaiting User Verification

---

## G3: DATABASE

### Detected Database
- **Type:** [PostgreSQL / MongoDB / None]
- **ORM:** [Prisma / Drizzle / None]
- **Hosting:** [Supabase / Local / Unknown]

### Detected Models
| Model | Fields (Key Ones) | Relationships |
|-------|-------------------|---------------|
| User | id, email, name | Has many Posts |
| Post | id, title, userId | Belongs to User |

### Questions for User
1. [Is this the correct database?]
2. [Are there models I missed?]
3. [Where is this hosted in production?]

---

## G4: API

### Detected API Pattern
- **Type:** [REST / GraphQL / tRPC]
- **Auth:** [JWT / Session / None detected]

### Detected Endpoints
| Method | Path | Purpose (Inferred) |
|--------|------|-------------------|
| GET | `/api/users` | List users |
| POST | `/api/auth/login` | Login |

### External Services
- [Stripe] - Payment processing
- [SendGrid] - Email delivery

### Questions for User
1. [Is the auth strategy correct?]
2. [Any hidden/undocumented endpoints?]
3. [Which external services are active?]
```

**🛑 STOP.** Output: *"I have drafted G3 and G4. Please review `NOTES/AUDIT/G3-G4-Draft.md` and confirm or correct."*

---

## ✅ PHASE 3: RATIFICATION (Write the Law)

**Trigger:** User approves or corrects the draft.

**Action:**
- Create `GENERAL/G3 - Data.md` (if database exists)
- Create `GENERAL/G4 - API.md` (if API exists)
- Skip either if user confirms "No database" or "No API"

---

## 🛑 EXECUTION CONSTRAINTS
1. **G3 AND G4 ONLY.** Do not touch G0, G1, or G2.
2. **NEVER SKIP THE DRAFT.** Do not write directly to `GENERAL/`.
3. **USE GREB MCP.** Search for route patterns, schema definitions, auth middleware.
4. **SKIP IF N/A.** If no database detected, say so and skip G3. Same for G4.
