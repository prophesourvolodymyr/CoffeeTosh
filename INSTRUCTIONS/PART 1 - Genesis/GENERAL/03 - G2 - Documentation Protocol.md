# INS-07-NEW: Setup Guide Generation Protocol

**System ID:** `INS-07-NEW`  
**Trigger:** User says "Create setup guide for [Service]" or "Generate guide for [API/Tool]" or "This feature needs a setup guide"  
**Input Requirement:** Feature context + external service/API documentation  
**Output Target:** `FEATURES/F[x]-[Name]/GUIDES/[Service]-Setup.md`

---

## 🎯 STRATEGIC INTENT (The "Why")

Some features require external services, APIs, or tools that need configuration. This protocol creates **step-by-step setup guides** so users can:

1. **Configure Services:** API keys, webhooks, OAuth setup
2. **Install Dependencies:** External tools, SDKs, packages
3. **Understand Integration:** How the service connects to our feature

**[Service]-Setup.md is:**
- Step-by-step instructions for a SPECIFIC service
- Includes screenshots/links where helpful
- Written for someone who's never used the service

**[Service]-Setup.md is NOT:**
- Feature documentation (that's F-Doc)
- Code documentation (that's in code comments)
- General tutorial (focused on OUR use case)

---

## 🔍 PHASE 1: RESEARCH SERVICE

**Cognitive Steps:**

1. **Identify What Needs Setup:**
   - What external service/API does this feature use?
   - What credentials/configuration are needed?

2. **Research Current Documentation:**
   - Use web search or MCP tools (like context7) to find official docs
   - Find the setup/quickstart guide
   - Identify required steps for our use case

3. **Identify Our Requirements:**
   - What specific endpoints/features do we need?
   - What permissions/scopes are required?
   - What environment variables need to be set?

---

## 🤖 PHASE 2: GUIDE GENERATION

**Role:** Technical Writer & Integration Specialist  
**Objective:** Create a clear, actionable setup guide.

**Content Requirements:**

1. **Prerequisites:** What user needs before starting
2. **Account Setup:** Creating accounts, getting access
3. **Configuration:** Step-by-step with screenshots/code
4. **Verification:** How to test the setup works
5. **Troubleshooting:** Common issues and fixes

---

## 📝 PHASE 3: FILE GENERATION

**Action:** Create `FEATURES/F[x]-[Name]/GUIDES/[Service]-Setup.md`

**Template:**

```markdown
# 🔧 [Service Name] Setup Guide

**For Feature:** F[x] - [Feature Name]
**Service:** [Service Name] ([Official URL])
**Last Updated:** [Date]

---

## 📋 Prerequisites

Before starting, ensure you have:
- [ ] [Prerequisite 1] (e.g., "A GitHub account")
- [ ] [Prerequisite 2] (e.g., "Node.js 18+ installed")
- [ ] [Prerequisite 3] (e.g., "Access to the project repository")

---

## 🚀 Step 1: Create Account / Access Service

1. Go to [Service URL]
2. Click "Sign Up" / "Get Started"
3. [Specific steps for account creation]

**Screenshot/Reference:** [Link or description]

---

## 🔑 Step 2: Get API Keys / Credentials

1. Navigate to [Settings/Dashboard/API section]
2. Click "[Create API Key]" or "[Generate Token]"
3. **Important:** Copy the key immediately - you won't see it again!

**Required Credentials:**
| Credential | Where to Find | Environment Variable |
|------------|---------------|---------------------|
| API Key | Settings → API | `SERVICE_API_KEY` |
| Secret | Settings → API | `SERVICE_SECRET` |
| Webhook URL | Our app provides this | `WEBHOOK_URL` |

---

## ⚙️ Step 3: Configure Service

### 3.1 [Configuration Task]
1. Go to [location in service]
2. Set [setting] to [value]
3. Save changes

### 3.2 [Another Configuration Task]
1. [Steps...]

**Configuration Values for Our Use Case:**
```
Setting A: [value]
Setting B: [value]
Webhook URL: https://your-app.com/api/webhook/[service]
```

---

## 🔌 Step 4: Connect to Our App

### Add Environment Variables

Create or update your `.env` file:
```env
# [Service Name] Configuration
SERVICE_API_KEY=your_api_key_here
SERVICE_SECRET=your_secret_here
SERVICE_WEBHOOK_SECRET=your_webhook_secret
```

### Verify Connection

Run the verification command:
```bash
npm run verify:[service]
# or
curl -X GET "https://api.service.com/verify" -H "Authorization: Bearer $SERVICE_API_KEY"
```

**Expected Output:**
```json
{
  "status": "connected",
  "account": "your-account"
}
```

---

## ✅ Step 5: Test Integration

1. [How to trigger a test]
2. [What to look for]
3. [How to know it's working]

**Test Checklist:**
- [ ] API key accepted (no auth errors)
- [ ] Webhook receives test event
- [ ] Data flows correctly to our feature

---

## 🔧 Troubleshooting

### Error: "Invalid API Key"
**Cause:** Key not set or incorrect
**Fix:** 
1. Verify `.env` has the correct key
2. Restart the application
3. Check key hasn't expired

### Error: "Webhook Verification Failed"
**Cause:** Webhook secret mismatch
**Fix:**
1. Regenerate webhook secret in [service dashboard]
2. Update `SERVICE_WEBHOOK_SECRET` in `.env`
3. Restart application

### Error: "[Common Error]"
**Cause:** [Reason]
**Fix:** [Steps]

---

## 📚 Additional Resources

- [Official Documentation](https://docs.service.com)
- [API Reference](https://api.service.com/docs)
- [Community Forum](https://community.service.com)

---

## 🔄 Maintenance Notes

**When to Update This Guide:**
- Service changes their API/dashboard
- New features require additional configuration
- Common issues discovered

**Last Verified Working:** [Date]
```

---

## 📂 FOLDER STRUCTURE

```
FEATURES/F[x]-[Name]/
├── F[x]-Doc.md
├── F[x]-Progress.md
├── F[x]-Research.md
├── GUIDES/
│   ├── Telegram-Setup.md
│   ├── Stripe-Setup.md
│   └── Firebase-Setup.md
└── UI/
```

---

## 🛑 EXECUTION CONSTRAINTS

<rules>
<rule id="1">**RESEARCH FIRST:** Use web search or MCP tools to get current, accurate information.</rule>
<rule id="2">**OUR USE CASE:** Focus on what WE need, not general tutorial.</rule>
<rule id="3">**ACTIONABLE:** Every step should be something user can DO.</rule>
<rule id="4">**VERIFICATION:** Include how to TEST that setup worked.</rule>
<rule id="5">**TROUBLESHOOTING:** Add common issues you discover or anticipate.</rule>
<rule id="6">**DATED:** Include "Last Updated" so users know if guide might be stale.</rule>
</rules>

---

## ✅ COMPLETION CRITERIA

- [ ] Guide created in `FEATURES/F[x]/GUIDES/[Service]-Setup.md`
- [ ] All prerequisites listed
- [ ] Step-by-step instructions complete
- [ ] Environment variables documented
- [ ] Verification steps included
- [ ] Troubleshooting section populated
- [ ] Links to official docs included
