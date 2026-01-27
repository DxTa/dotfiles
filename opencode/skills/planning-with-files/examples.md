# Examples: Planning with Files + TodoWrite

## Example 1: Tier 2 Feature (Recommended Pattern)

**Task:** "Add email validation to signup form"

### Step 1: Create task_plan.md
```markdown
# Task Plan: Email Validation for Signup

## Goal
Add robust email validation to signup form with helpful error messages.

## Phases
- [ ] Phase 1: Research current validation (CURRENT)
- [ ] Phase 2: Implement validation logic
- [ ] Phase 3: Add error UI
- [ ] Phase 4: Test edge cases

## Status
**Currently in Phase 1** - Investigating existing form code
**TodoWrite sync:** Starting research
```

### Step 2: Initialize TodoWrite
```
TodoWrite:
- [in_progress] Read current form implementation
- [pending] Check existing validation utils
- [pending] Document findings
```

### Step 3: After Each TodoWrite Update
```markdown
## Status
**Currently in Phase 1** - Found form at src/components/SignupForm.tsx
**TodoWrite sync:** Completed form read, checking validation utils
```

### Step 4: Phase Boundary
```markdown
## Phases
- [x] Phase 1: Research current validation ✓
- [ ] Phase 2: Implement validation logic (CURRENT)
...

## Status
**Currently in Phase 2** - Creating email regex validator
**TodoWrite sync:** Starting implementation
```

---

## Example 2: Tier 3 with Full 3-File Pattern

**Task:** "Implement OAuth2 authentication with Google"

### Files Created:
1. `~/.config/opencode/plans/myapp_abc123_task_plan.md`
2. `~/.config/opencode/plans/myapp_abc123_notes.md`

### task_plan.md
```markdown
# Task Plan: Google OAuth2 Implementation

## Goal
Add Google OAuth2 login alongside existing email/password auth.

## Phases
- [x] Phase 1: Research OAuth2 flow and Google setup
- [x] Phase 2: Backend: token handling
- [ ] Phase 3: Frontend: login button + callback (CURRENT)
- [ ] Phase 4: Integration test
- [ ] Phase 5: Documentation

## Decisions Made
- Using passport-google-oauth20 (well-maintained, TypeScript support)
- Storing refresh tokens in DB, not sessions
- Callback route: /auth/google/callback

## Errors Encountered
- [2026-01-03 14:30] CORS error on callback
  → Fixed: Added Google domain to allowed origins
- [2026-01-03 15:00] Token refresh failing silently
  → Root cause: Missing error handler in refresh middleware

## Learnings for Graphiti
- [Procedure]: OAuth debug - check CORS before token logic
- [Preference]: Use passport.js for social auth in Express
- [Fact]: Google OAuth requires verified domain for production

## Status
**Currently in Phase 3** - Implementing React login button
**TodoWrite sync:** Completed button component, working on callback handler
```

### notes.md
```markdown
# Notes: Google OAuth2 Research

## Official Documentation
- URL: https://developers.google.com/identity/protocols/oauth2
- Key points:
  - Authorization code flow for web apps
  - Refresh tokens require offline access scope
  - Token expiry: 1 hour (access), 6 months (refresh)

## Library Comparison
| Library | Stars | TypeScript | Last Update |
|---------|-------|------------|-------------|
| passport-google-oauth20 | 1.2k | Yes | 2 weeks |
| google-auth-library | 800 | Yes | 1 week |

## Decision: passport-google-oauth20
Reason: Better Express integration, familiar passport pattern

## Security Considerations
- State parameter prevents CSRF
- PKCE recommended for mobile
- Store tokens encrypted
```

---

## Example 3: Recovery After Context Reset

**Before reset:**
```markdown
## Status
**Currently in Phase 2** - Implementing JWT validation
**TodoWrite sync:** Completed middleware creation, adding token verify
```

**TodoWrite (lost on reset):**
```
- [x] Create auth middleware file
- [x] Add JWT validation logic
- [in_progress] Connect to user service  ← LOST
- [pending] Add error handling
```

**After reset - Recovery:**
```
1. Read task_plan.md
2. See: "Phase 2", "adding token verify"
3. Restore TodoWrite:
   - [x] Create auth middleware file
   - [x] Add JWT validation logic
   - [in_progress] Connect to user service
   - [pending] Add error handling
4. Continue exactly where left off
```

---

## Example 4: Error Logging Pattern

**Bad (hidden):**
```
Action: API call
Error: 401 Unauthorized
Action: API call (retry)
Action: API call (retry again)
Success!
```

**Good (logged):**
```
Action: API call
Error: 401 Unauthorized

# Update task_plan.md:
## Errors Encountered
- [14:32] 401 on /api/users - token expired
  → Added token refresh before retry
  → Learning: Always check token expiry before API calls

Action: Refresh token
Action: API call
Success!
```
