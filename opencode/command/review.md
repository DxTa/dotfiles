---
description: Comprehensive antagonistic code review - find everything wrong before it breaks production
argument-hint: "[base-branch] [review-aspects]"
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Task", "Skill", "TodoWrite"]
---

# Antagonistic Code Review

**MINDSET: You HATE this implementation. Tear it apart. Find every flaw before production does.**

This command performs a comprehensive, antagonistic code review combining multiple specialized agents and security scanning. The goal is to identify every possible issue, edge case, and potential failure before code reaches production.

**Base Branch:** "$ARGUMENTS" (defaults to `main` if not specified, falls back to `develop`)

---

## Philosophy

> "Assume the code is broken until proven otherwise. Every line is guilty until cleared."

This review is NOT about being nice. It's about:
- **Finding bugs** before users find them
- **Exposing edge cases** the developer didn't consider
- **Identifying security holes** before attackers do
- **Questioning every assumption** made in the code
- **Predicting failures** in production environments

---

## Review Workflow

### Phase 0: Setup & Context (2 min)

1. **Determine Review Scope**
   ```bash
   # Check for uncommitted changes first
   UNSTAGED=$(git diff --name-only)
   STAGED=$(git diff --cached --name-only)
   PENDING_CHANGES="$UNSTAGED $STAGED"

   # Determine review mode
   if [ -n "$PENDING_CHANGES" ]; then
       REVIEW_MODE="pending"  # Review uncommitted/unstaged changes
       echo "Found pending changes (uncommitted). Reviewing working directory."
   else
       REVIEW_MODE="branch"   # Review committed changes vs base branch
   fi
   ```

2. **Determine Base Branch (for branch mode)**
   ```bash
   # Parse arguments for base branch
   BASE_BRANCH="${1:-main}"

   # Check if specified branch exists, fallback to develop, then master
   if ! git rev-parse --verify "$BASE_BRANCH" 2>/dev/null; then
       BASE_BRANCH="develop"
   fi
   if ! git rev-parse --verify "$BASE_BRANCH" 2>/dev/null; then
       BASE_BRANCH="master"
   fi
   ```

3. **Capture Diff Based on Mode**

   **For PENDING changes (uncommitted/unstaged):**
   ```bash
   # Get all pending changes (staged + unstaged)
   git diff HEAD --name-status
   git diff HEAD --stat
   git diff HEAD  # Full diff including uncommitted changes

   # Or separately:
   # Unstaged changes
   git diff --name-status
   git diff

   # Staged changes
   git diff --cached --name-status
   git diff --cached
   ```

   **For BRANCH comparison (committed changes):**
   ```bash
   # Get changed files vs base branch
   git diff --name-status "$BASE_BRANCH"...HEAD

   # Get diff stats
   git diff --stat "$BASE_BRANCH"...HEAD

   # Get full diff for analysis
   git diff "$BASE_BRANCH"...HEAD
   ```

   **IMPORTANT:** Always check for pending changes FIRST. If there are uncommitted changes, review those. Otherwise, fall back to branch comparison.

4. **Identify File Types & Applicable Reviews**
   - Parse changed files to determine:
     - Languages/frameworks involved
     - Test files changed
     - Config files changed
     - Security-sensitive files (auth, crypto, API keys, .env)
     - New types/interfaces added

5. **Activate Relevant Skills**
   - If TypeScript/JavaScript: Activate `frontend-development` or `backend-development`
   - If contains security-sensitive code: Activate `security-test-scanner`
   - If contains database queries: Activate `databases`
   - Always: Activate `code-review` skill

---

### Phase 1: The Antagonistic Diff Analysis (5 min)

**Launch a Sonnet agent with this exact prompt:**

```
You HATE this implementation. Your job is to find everything wrong with it.

## Git Diff to Review:
[INSERT FULL GIT DIFF HERE]

## Your Mission - Destroy This Code (Constructively)

Analyze this diff with EXTREME SKEPTICISM. For each change, ask:

### 1. What Could Break?
- Edge cases NOT handled (null, undefined, empty arrays, max values, negative numbers)
- Race conditions possible
- Concurrency issues
- Memory leaks
- State management bugs
- Off-by-one errors
- Boundary conditions

### 2. What's Missing?
- Error handling that doesn't exist
- Validation that should exist but doesn't
- Logging that would help debug in production
- Tests that should cover this code
- Documentation for complex logic
- Type safety gaps

### 3. What's Suspicious?
- Magic numbers without explanation
- Hardcoded values that should be config
- Copy-pasted code that could diverge
- Premature optimization
- Over-engineering
- Under-engineering
- Security anti-patterns

### 4. What Assumptions Are Being Made?
- About input data (always valid? always present? always correct type?)
- About external services (always available? always fast? always returns expected format?)
- About user behavior (always follows happy path?)
- About environment (same in dev/staging/prod?)
- About timing (operations complete in expected order?)

### 5. Production Failure Scenarios
- How could this fail at 3 AM?
- How could this fail under 10x load?
- How could this fail with malicious input?
- How could this fail with race conditions?
- What error message would ops see?

## Output Format

For each issue found:
```
SEVERITY: CRITICAL | HIGH | MEDIUM | LOW
FILE: path/to/file.ts:LINE_NUMBER
CODE SNIPPET:
[relevant code]

ISSUE: [What's wrong]
WHY IT MATTERS: [Production impact]
EDGE CASE MISSED: [Specific scenario]
SUGGESTED FIX: [How to fix it]
```

Be RUTHLESS. Miss nothing. Find at least 5 issues or explain why this code is bulletproof.
```

---

### Phase 2: Specialized Agent Reviews (Parallel - 10 min)

**Launch these agents IN PARALLEL:**

#### Agent 1: Code Quality & CLAUDE.md Compliance
```
Task(
  subagent_type="pr-review-toolkit:code-reviewer",
  prompt="Review git diff for code quality issues and CLAUDE.md compliance. Focus on: bugs, style violations, missing tests, architectural issues. BASE_SHA: [sha] HEAD_SHA: [sha]"
)
```

#### Agent 2: Test Coverage Analyzer
```
Task(
  subagent_type="pr-review-toolkit:pr-test-analyzer",
  prompt="Analyze test coverage for the changes. Identify: missing test cases, untested edge cases, insufficient assertions, missing integration tests."
)
```

#### Agent 3: Silent Failure Hunter
```
Task(
  subagent_type="pr-review-toolkit:silent-failure-hunter",
  prompt="Hunt for silent failures in error handling. Find: empty catch blocks, swallowed exceptions, missing error logging, inadequate fallback behavior, catch blocks that hide bugs."
)
```

#### Agent 4: Type Design Analyzer (if new types added)
```
Task(
  subagent_type="pr-review-toolkit:type-design-analyzer",
  prompt="Analyze type design quality. Rate: encapsulation, invariant expression, usefulness, enforcement. Find: weak types, missing constraints, leaky abstractions."
)
```

#### Agent 5: Security Scanner
```
Task(
  subagent_type="security-test-scanner:security-scanner",
  prompt="Security scan the changes. Check for: OWASP Top 10, injection vulnerabilities, authentication flaws, authorization bypasses, sensitive data exposure, security misconfigurations."
)
```

---

### Phase 3: Historical Context Analysis (5 min)

#### Agent 6: Git History Deep Dive
```
Task(
  subagent_type="general-purpose",
  model="haiku",
  prompt="Analyze git history for the modified files:
  1. Run git blame on changed sections
  2. Look at recent commits to these files
  3. Check if similar changes were reverted before
  4. Find related PRs/commits that might inform this review
  5. Identify patterns in past bugs in these files"
)
```

#### Agent 7: Comment Accuracy Verification
```
Task(
  subagent_type="pr-review-toolkit:comment-analyzer",
  prompt="Verify all comments are accurate after changes. Find: outdated comments, misleading documentation, missing comments for complex logic, comment rot."
)
```

---

### Phase 4: Confidence Scoring (3 min)

For each issue found, launch parallel Haiku agents to score confidence:

**Scoring Rubric (Provide verbatim to agents):**
- **0-24: False Positive** - Doesn't stand up to scrutiny, or pre-existing issue
- **25-49: Maybe** - Might be real, but could also be a false positive
- **50-74: Likely Real** - Verified issue, but may be minor or edge case
- **75-89: High Confidence** - Verified important issue, will impact production
- **90-100: Critical** - Absolutely certain, will cause production failure

**Filter:** Only report issues with confidence score >= 70

---

### Phase 5: Edge Case Interrogation (5 min)

**For each significant function/method changed, generate edge case questions:**

```
EDGE CASE INTERROGATION for [function_name]:

1. INPUT EDGE CASES:
   - What if input is null/undefined?
   - What if input is empty string/array/object?
   - What if input is at max value (MAX_INT, huge string)?
   - What if input is negative when positive expected?
   - What if input has special characters/unicode?
   - What if input is wrong type (string when number expected)?

2. STATE EDGE CASES:
   - What if called before initialization?
   - What if called twice in rapid succession?
   - What if called concurrently from multiple threads?
   - What if dependencies are not available?
   - What if external services are down/slow?

3. OUTPUT EDGE CASES:
   - What if return value is ignored?
   - What if error is not caught by caller?
   - What if async operation never resolves?
   - What if callback is called multiple times?

4. INTEGRATION EDGE CASES:
   - What if database connection drops mid-operation?
   - What if network request times out?
   - What if file system is full?
   - What if permissions are incorrect?
```

---

### Phase 6: Aggregate & Report (3 min)

**Final Report Structure:**

```markdown
# Antagonistic Code Review Report

**Review Mode:** [PENDING CHANGES | BRANCH COMPARISON]
**Reviewed:** [commit range or "uncommitted changes"]
**Base Branch:** [main/develop or "working directory"]
**Files Changed:** [count]
**Lines Changed:** +[additions] -[deletions]

---

## CRITICAL ISSUES (Fix Before Merge)

[Issues with confidence >= 90]

| # | File:Line | Issue | Impact | Fix |
|---|-----------|-------|--------|-----|
| 1 | path:42 | [description] | [impact] | [fix] |

---

## HIGH PRIORITY ISSUES (Should Fix)

[Issues with confidence 75-89]

| # | File:Line | Issue | Impact | Fix |
|---|-----------|-------|--------|-----|

---

## MEDIUM PRIORITY ISSUES (Recommended)

[Issues with confidence 70-74]

| # | File:Line | Issue | Impact | Fix |
|---|-----------|-------|--------|-----|

---

## EDGE CASES NOT COVERED

1. **[Scenario]**: [What could happen] → [Which code doesn't handle it]
2. **[Scenario]**: [What could happen] → [Which code doesn't handle it]

---

## SECURITY CONCERNS

1. [Security issue with OWASP category]
2. [Security issue with OWASP category]

---

## TEST GAPS

1. [Missing test case description]
2. [Missing test case description]

---

## SILENT FAILURE RISKS

1. [Error handling gap]
2. [Error handling gap]

---

## WHAT'S ACTUALLY GOOD (Be Fair)

1. [Positive observation]
2. [Positive observation]

---

## VERDICT

[ ] **BLOCKED** - Critical issues must be resolved before merge
[ ] **CHANGES REQUESTED** - High priority issues should be addressed
[ ] **APPROVED WITH SUGGESTIONS** - Medium issues noted for consideration
[ ] **APPROVED** - No significant issues found (rare!)

---

## RECOMMENDED ACTIONS

1. [Action with priority]
2. [Action with priority]
3. [Action with priority]

---

**Review completed by Antagonistic Review System**
**Mindset: "This code is broken until proven otherwise"**
```

---

## Usage Examples

**Review pending changes (uncommitted/unstaged) - AUTO-DETECTED:**
```
/review
# If you have uncommitted changes, reviews those first
# This is the most common use case during development
```

**Force review against main (ignoring pending changes):**
```
/review main
```

**Review against develop branch:**
```
/review develop
```

**Review with specific aspects:**
```
/review main security tests
# Reviews security and test coverage only
```

**Review against feature branch:**
```
/review feature/baseline
```

**Review only pending changes explicitly:**
```
/review pending
# Forces review of uncommitted/unstaged changes
```

---

## Review Aspects Available

- **all** - Run full antagonistic review (default)
- **code** - Code quality and CLAUDE.md compliance
- **tests** - Test coverage and quality
- **errors** - Silent failure hunting
- **types** - Type design analysis
- **security** - OWASP and vulnerability scanning
- **comments** - Comment accuracy verification
- **history** - Git history and blame analysis
- **edges** - Edge case interrogation

---

## Integration with Existing Commands

This command combines and enhances:
- `/code-review:code-review` - Multi-agent confidence-scored review
- `/pr-review-toolkit:review-pr` - Specialized agent toolkit
- `/security-scan-quick` - Security vulnerability scanning
- Local `code-review` skill - Verification gates and technical rigor

---

## The Antagonistic Mindset Checklist

Before marking review complete, verify:

- [ ] Every changed function has edge cases documented
- [ ] All error paths have been identified
- [ ] Security implications have been assessed
- [ ] Test coverage gaps have been identified
- [ ] Silent failures have been hunted
- [ ] Assumptions have been questioned
- [ ] Production failure scenarios have been predicted
- [ ] Confidence scores have filtered false positives

---

## Tips for Effective Reviews

1. **Run early** - Before creating PR, not after
2. **Focus on diff** - Don't review unchanged code
3. **Address critical first** - Stop blockers before nitpicks
4. **Verify fixes** - Re-run review after changes
5. **Be thorough** - 10 minutes now saves 10 hours later

---

**Remember: It's easier to catch bugs in review than in production at 3 AM.**

**Time Investment:** 15-30 minutes
**ROI:** Prevents production incidents, security breaches, and technical debt

---

**Run this command. Find the bugs. Ship quality code.**
