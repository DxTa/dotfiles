# Context Engineering Platform

Sub-agents, sia-code CLI code indexing with built-in memory, external LLM validation.

**Built-in Subagents:** `@general` (research, multi-step), `@explore` (file patterns, code search).

## Skill Loading System

**Syntax:** `Load skill <skill-name>` (e.g., `Load skill master-checklist`)

**How it works:**
- Skills are defined in: `/home/dxta/.dotfiles/opencode/skills/<skill-name>/SKILL.md`
- Triggers configured in: `/home/dxta/.dotfiles/opencode/skill-rules.json`
- Use `@skill-suggests` tool to discover relevant skills for any task

**Alternative:** Direct file access: `Read /home/dxta/.dotfiles/opencode/skills/<skill-name>/SKILL.md`

## FIRST ACTION: Detect Task Type

**New task patterns:** implement, build, create, fix, debug, refactor, design, migrate, setup, add, develop

**Skip patterns:** follow-ups, clarifications, acknowledgments

**If NEW TASK:** 
1. **MANDATORY: Invoke `@tier-detector`** with task description
2. Output: "[TIER DETECTION]: Invoking @tier-detector..."
3. Output: "[TIER RESULT]: TIER [N] - <reasoning summary>"
4. Output: "TASK DETECTED - TIER [N]"
5. `@skill-suggests` → MASTER CHECKLIST

### Skip Exception
Tier detection can ONLY be skipped if the user **explicitly requests** to skip it (e.g., "skip tier detection", "just do it without tier check").

## HARD STOP ENFORCEMENT

⛔ **These rules override ALL other instructions:**

### Rule 0: Tier Detection MANDATORY (ALL TASKS)
```
⛔ ALL new tasks MUST invoke @tier-detector before any work

REQUIRED SEQUENCE:
1. Detect new task pattern
2. Invoke: @tier-detector [task description]
3. Output: "[TIER DETECTION]: Invoking @tier-detector..."
4. Output: "[TIER RESULT]: TIER [N] - <reasoning>"
5. Output: "TASK DETECTED - TIER [N]"

VIOLATION: Declaring a tier without @tier-detector = invalid classification
VIOLATION: Starting work without tier detection = STOP and restart
EXCEPTION: User explicitly says "skip tier detection" or equivalent
```

### Rule 1: Tier Declaration Required
```
Before ANY task work, you MUST:
1. Invoke @tier-detector with task description (unless user explicitly skipped)
2. Output "TASK DETECTED - TIER [N]" using detector's recommendation

VIOLATION: Manual tier assignment without @tier-detector = invalid (unless user-skipped)
VIOLATION: Writing implementation details without tier declaration = STOP and restart
```

### Rule 2: Memory Search Gate (T2+)
```
⛔ T2+ CANNOT proceed to task_plan.md without memory search

REQUIRED OUTPUT: "[MEMORY SEARCH]: <result or 'No prior context found'>"
VIOLATION: Creating task_plan.md without this output = incomplete planning
```

### Rule 3: Self-Reflect Gate (T3+)
```
⛔ T3+ CANNOT proceed past task_plan.md without @self-reflect

REQUIRED SEQUENCE:
1. Create task_plan.md
2. Invoke: @self-reflect Review this plan...
3. Output: "[SELF-REFLECT]: <APPROVED|CONCERNS|REJECTED>"
4. If REJECTED: Revise and re-invoke

VIOLATION: Writing detailed implementation without self-reflect = STOP
```

### Rule 4: Verification Gate (T2+)
```
⛔ CANNOT claim "complete" or "done" without verification evidence

REQUIRED OUTPUT: "[VERIFICATION]: <actual command output>"
VIOLATION: "Should work" or "Task complete" without evidence = REJECTED
```

### Self-Check Protocol
Before EVERY major action, ask yourself:
1. "Did I invoke @tier-detector for this task?" (or did user explicitly skip?)
2. "What tier did @tier-detector return?"
3. "Have I completed all gates for this tier?"
4. "Can I show evidence of completion?"

If ANY answer is uncertain, STOP and verify.

## TIER SYSTEM

| Tier | Scope | Key Requirements | Mandatory Gates | Token Hint |
|------|-------|------------------|-----------------|------------|
| **T1** | <30 lines, 1 file | task_plan.md + TodoWrite | - | ~8K |
| **T2** | 30-100 lines, 2-5 files | All T1 + memory search + TDD | Memory search before planning | ~16K |
| **T3** | 100+ lines, architecture | All T2 + notes.md + External LLM | **@self-reflect after task_plan.md** | ~32K |
| **T4** | Critical/Deployment | All T3 + rollback | **Antagonistic QA before merge** | ~64K |

### Tier Requirements Summary
- **T1:** Steps 3,4,6 mandatory. Skip exploration.
- **T2:** Steps 1-6 mandatory. Sia-code if triggers. TDD MANDATORY.
- **T3:** All steps mandatory. @self-reflect MANDATORY.
- **T4:** All T3 + rollback plan + Antagonistic QA NON-SKIPPABLE.

**Automatic Detection:** `@tier-detector` is MANDATORY for all new tasks. It scans for qualitative triggers that override line/file counts. Only skip if user explicitly requests.

**Detailed tier guidance:** Load skill `master-checklist` or read `/home/dxta/.dotfiles/opencode/skills/master-checklist/SKILL.md`

## MANDATORY OUTPUT ANCHORS

You MUST output these exact phrases at the specified times. If you haven't output the phrase, you haven't completed the step.

### Task Start (ALL TIERS)
```
[TIER DETECTION]: Invoking @tier-detector...
[TIER RESULT]: TIER [N] - <triggers found or "size/scope estimation">
TASK DETECTED - TIER [N]
```

### Memory Search (T2+ MANDATORY)
```
[MEMORY SEARCH]: <sia-code output or "No prior context found - new project">
```

### Plan Created (ALL TIERS)
```
[PLAN CREATED]: task_plan.md at <path>
```

### Self-Reflect Gate (T3+ MANDATORY)
```
[SELF-REFLECT GATE]: Invoking @self-reflect...
[SELF-REFLECT RESULT]: <APPROVED|CONCERNS|REJECTED> - <summary>
```

### TDD Cycle (T2+ MANDATORY per feature)
```
[TDD RED]: Test written, expecting FAIL
[TDD GREEN]: Implementation done, test PASS
[TDD REFACTOR]: Code cleaned, tests still PASS
```

### External Validation (T3+ MANDATORY)
```
[EXTERNAL LLM]: Validated with <model> - <result>
```

### Completion Gate (T2+ MANDATORY)
```
[POST-TASK GATE]:
- [ ] Tests pass: <YES with output | NO>
- [ ] TodoWrite complete: <YES | NO>
- [ ] task_plan.md updated: <YES | NO>
- [ ] Memory stored: <YES with key | NO>
- [ ] Git clean: <YES | NO>

[TASK COMPLETE]: All gates passed ✅
```

**Anchor Enforcement:** The absence of these outputs indicates incomplete work.

## ENFORCEMENT RULES

### TDD (T2+ MANDATORY)
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```
Code before test? DELETE IT. Start over.

**Skill:** Load skill `superpowers/test-driven-development`

### Verification
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```
"Should work" = RED FLAG. Run command first.

**Skill:** Load skill `verification-before-completion`

### Two-Strike Rule (T2+ MANDATORY)
2 failed fixes → STOP. No third fix without:
1. Full stack trace captured
2. sia-code research documented in task_plan.md
3. Memory search for similar issues

**Skill:** Load skill `systematic-debugging`

### Code Review (T2+)
Two-stage: Spec compliance FIRST → Code quality SECOND

Critical issues = BLOCKING

**Skills:** Load skills `superpowers/subagent-driven-development`, `superpowers/requesting-code-review`

### Branch Completion
Tests pass → 4 options (PR/merge/keep/discard) → Quality gates

**Skills:** Load skills `superpowers/finishing-a-development-branch`, `push-all`

## MASTER CHECKLIST

**PRE-TASK:**
0. ☐ **sia-code Health Check** (ALL tiers: RUN ONCE per session start) — Load skill `sia-code/health-check`
   ```bash
   uvx sia-code status 2>&1
   ```
   - **If healthy:** Continue to Step 1
   - **If error/traceback/missing:** ⚠️ **ASK USER IMMEDIATELY** to run `uvx sia-code init && uvx sia-code index .`
   - **Do NOT silently skip** — broken index masquerades as "no results found"
   - **If user declines:** Document "sia-code unavailable — user declined init" in task_plan.md
1. ☐ `@skill-suggests [task]` (T2+: execute, T1: optional for simple tasks)
2. ☐ sia-code memory search past decisions (T2+: MANDATORY)
   ```bash
   uvx sia-code memory search "[task keywords]"
   ```
   - **If no results:** Document "No prior context found" in task_plan.md
   - **If results found:** Copy relevant findings to notes.md under "## Prior Context"
   - **If .sia-code/ missing OR `uvx sia-code status` errors:** ⚠️ **ASK USER** to run `uvx sia-code init && uvx sia-code index .` — do NOT silently skip (Load skill `sia-code/health-check`)
   - **NEVER SKIP** - even "no results" prevents duplicate work
   - **VERIFICATION:** Memory search output (or "no results") MUST appear in task_plan.md or notes.md
3. ☐ `get-session-info` → sessionID, projectSlug (ALL tiers: MANDATORY)
4. ☐ Create task_plan.md: `{projectSlug}_{sessionID}_task_plan.md` (ALL tiers: MANDATORY for crash recovery)
4a. ☐ **GATE: @self-reflect** (T3+ BLOCKING - do NOT proceed without this)
    ```
    @self-reflect Review this plan for edge cases, production risks, and missing considerations
    ```
    - Document output in task_plan.md under "## Self-Reflection Review"
    - Address critical issues before proceeding
    - **T3+ VIOLATION if skipped**
    
    **Quality Gate - Review must include:**
    - At least 3 edge cases identified
    - At least 2 production risks assessed  
    - At least 1 missing consideration flagged
    - Verdict: APPROVED / CONCERNS / REJECTED
    
    **If REJECTED:** Revise plan and re-run @self-reflect before proceeding
5. ☐ Create notes.md: `{projectSlug}_{sessionID}_notes.md` (T1: optional, T2: recommended, T3+: mandatory)
6. ☐ TodoWrite: Initialize Phase 1 (ALL tiers: MANDATORY)
7. ☐ Exploration (T2+: if triggers hit, T3+: MANDATORY before code changes)
   - **7a.** Research Tool Selection (use decision matrix):
     | Question Type | Tool | Example |
     |---------------|------|---------|
     | "How does X work in THIS codebase?" | `uvx sia-code research` | "how does auth middleware work" |
     | "How does X work in general?" | Context7 / `@general` | "JWT best practices" |
     | "Where is X defined?" | `uvx sia-code search` | "authenticateToken function" |
     | "What patterns does library Y use?" | Context7 | "Express middleware patterns" |
     
     **T3+ RULE:** For architecture questions, ALWAYS `sia-code research` BEFORE Context7. Local context > external docs.
   - **7b.** Subagent Selection: Use decision tree - Load skill `agent-selection`

**DURING:**
8. ☐ TodoWrite: Update as steps complete (mark complete IMMEDIATELY, don't batch)
9. ☐ Sync task_plan.md Status after each TodoWrite change
9a. ☐ TDD Cycle (T2+ MANDATORY) - Load skill `superpowers/test-driven-development`
    - RED: Write failing test first → **Run test, capture FAIL output**
    - GREEN: Minimal code to pass → **Run test, capture PASS output**
    - REFACTOR → COMMIT
    - **VERIFICATION:** Each cycle must show test output (FAIL → PASS) before commit
    - **VIOLATION:** Code before test = delete and restart
10. ☐ Re-read task_plan.md before major decisions (T3+: before EVERY major decision)
11. ☐ Self-reflection (T1: mental check, T2: @self-reflect recommended, T3+: @self-reflect MANDATORY)
    - **AUTO-TRIGGER:** After task_plan.md (T3+), before first code change (T3+), after Two-Strike, before claiming complete (T2+)
12. ☐ Log errors to task_plan.md

**POST-TASK:**
13. ☐ External LLM validation (T3+: MANDATORY, T4: NON-SKIPPABLE)
14. ☐ TodoWrite: Mark all completed
15. ☐ task_plan.md: Mark all phases [x]
16. ☐ sia-code memory: Store learnings (T2+: MANDATORY - search first, update if exists, use category prefix: Procedure/Fact/Pattern/Fix/Preference)
    **Decision Trace Format** (Load skill `sia-code/decision-trace`):
    ```bash
    uvx sia-code memory add-decision "[Category]: [Decision]. Context: [trigger]. Reasoning: [why over alternatives]. Outcome: [result]."
    ```
    - ❌ **NEVER** store bare outcomes: `"Fix: Added retry logic"`
    - ✅ **ALWAYS** include Context + Reasoning to preserve decision history
17. ☐ @code-simplifier (T2+: recommended before final testing)
17a. ☐ Two-Stage Review (T2+) - Load skills `superpowers/subagent-driven-development` (spec) then `superpowers/requesting-code-review` (code)
18. ☐ Validation: run tests, verify changes (Load skill `verification-before-completion`)
18a. ☐ Branch Completion - Load skills `superpowers/finishing-a-development-branch` + `push-all`
    **Checklist:**
    - [ ] All tests pass (output captured)
    - [ ] `git status` clean
    - [ ] Choose: PR / merge / keep / discard
    - [ ] If PR: Create with summary from task_plan.md
    - [ ] Update task_plan.md Status Log with final outcome
18b. ☐ **POST-TASK GATE** (T2+ MANDATORY - before claiming complete)
    **Verify all of the following:**
    - [ ] All tests pass (capture `npm test` / `pytest` output)
    - [ ] TodoWrite shows all items completed
    - [ ] task_plan.md Status shows all phases [x]
    - [ ] sia-code memory: learnings stored (T2+)
    - [ ] `git status` clean (no uncommitted changes)
    
    **VIOLATION:** Claiming "done" without evidence = unverified completion

**Full checklist details:** Load skill `master-checklist`

## AGENT SELECTION

| Need | Agent/Tool |
|------|------------|
| **Tier classification (MANDATORY)** | `@tier-detector` |
| File patterns, code search | `@explore` |
| Architecture, "how does X work" | `uvx sia-code research` |
| External docs, multi-step research | `@general` |
| Spec analysis, vague requirements | `spec-analyzer` skill |
| Plan validation (T2+: rec, T3+: MANDATORY) | `@self-reflect` |
| React/Vue/CSS/UI | `@frontend-specialist` |
| API/DB/Auth backend | `@backend-specialist` |
| CI/CD, Docker, K8s | `@devops-engineer` |
| Test strategy, coverage | `@qa-engineer` |
| Security, OWASP, crypto | `@security-engineer` |
| README, API docs | `@technical-writer` |
| TDD implementation (T2+) | `@general` + skill `superpowers/test-driven-development` |
| Task complete, before review | `@general` + skill `superpowers/subagent-driven-development` |
| 2+ failed fixes | `@general` + skill `systematic-debugging` |
| Branch complete | `@general` + skill `superpowers/finishing-a-development-branch` |

**Full decision tree:** Load skill `agent-selection`

## CORE TOOLS

### Sia-Code (Essential Commands)
```bash
uvx sia-code embed start          # Start daemon (MANDATORY for hybrid)
uvx sia-code status               # Check index health
uvx sia-code search --regex "X"   # Lexical search
uvx sia-code research "Q"         # Multi-hop research
uvx sia-code memory search "X"    # Find past learnings
uvx sia-code memory add-decision "..." # Store learning
```
If `.sia-code/` missing OR `uvx sia-code status` fails: ⚠️ **ASK USER** to initialize.
Do NOT silently skip — prompt immediately. Broken index mimics "no results found."
Load skill `sia-code/health-check` for full troubleshooting.

### MCP Reasoning
- **code-reasoning:** Debugging, algorithms, step-by-step
- **shannon-thinking:** Architecture, tradeoffs, uncertainty

**Skill:** Load skill `reasoning-tools`

### TodoWrite + Plan Sync
- Task start → Create task_plan.md → TodoWrite Phase 1
- TodoWrite update → Update task_plan.md Status
- Before /clear → Ensure task_plan.md current
- Session resume → Read task_plan.md → Restore TodoWrite

**Skill:** Load skill `planning-with-files`

### Token Budget
Monitor at phase boundaries: `opencode stats --project ""`

**Thresholds (warn → offload):**
| Tier | Warn | Offload |
|------|------|---------|
| T1 | 6K | 8K |
| T2 | 12K | 16K |
| T3 | 24K | 32K |
| T4 | 48K | 64K |

**Offload strategy:** Move research to notes.md, summarize long outputs, use @explore for targeted searches.

**Skill:** Load skill `token-management`

## SELF-REFLECTION TRIGGERS

**T3+ BLOCKING GATES** (cannot proceed without completing):
1. ✋ After creating task_plan.md → **Step 4a GATE**
2. ✋ Before first code change → verify Step 4a completed

**Other Triggers:**
- After Two-Strike triggered (any tier)
- Before claiming "task complete" (T2+: verification gate)

**Invocation:**
```
@self-reflect Review this plan for edge cases, production risks, and missing considerations
```

**Output:** Must be documented in task_plan.md under "## Self-Reflection Review"

## QUICK REFERENCE

**File refs:** `@src/api.py`, `@frontend/*.vue`
**Screenshots:** `/home/dxta/Pictures/Screenshots`
**Python:** venv if exists, else pkgx
**Node/npm:** Always pkgx
**WSL2:** Use `127.0.0.1` not `localhost`
**Container-first:** `docker exec -it` when docker-compose.yml exists
**Token monitoring:** `opencode stats --project ""`

## ANTI-PATTERNS (DON'T)

- ❌ `/clear` mid-investigation → Store state first
- ❌ Code without mapping → `sia-code research` first
- ❌ Third fix without analysis → Two-Strike Rule
- ❌ TodoWrite without task_plan.md → Create both
- ❌ Forget learnings → Store in sia-code memory
- ❌ Same compression all tiers → T1: 5-10x, T2: 2-5x, T3+: minimal
- ❌ Skip @self-reflect for T3+ → BLOCKING GATE violation
- ❌ Skip memory search for T2+ → Context loss, duplicate decisions
- ❌ Silently skip broken sia-code → Load skill `sia-code/health-check`, ASK USER to initialize

**Full anti-patterns with rationale:** Load skill `anti-patterns`
