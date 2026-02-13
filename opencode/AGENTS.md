# Context Engineering Platform

Sub-agents, sia-code CLI code indexing with built-in memory, external LLM validation.

**Built-in Subagents:** `@general` (research, multi-step), `@explore` (file patterns, code search).

## Skill Loading System

**Syntax:** `Load skill <skill-name>` (e.g., `Load skill master-checklist`)

**How it works:**
- Skills are defined in: `/home/dxta/.dotfiles/opencode/skills/**/SKILL.md`
- Triggers configured in: `/home/dxta/.dotfiles/opencode/skill-rules.json`
- Use `@skill-suggests` tool to discover relevant skills for any task

**Alternative:** Direct file access: `Read /home/dxta/.dotfiles/opencode/skills/**/SKILL.md`

## Asking the User Questions

When asking the user anything, you MUST use the question tool.
Do not ask questions in plain assistant text.
Avoid repeating the same question unless the user changes scope or prior answers are missing.

## Command Mode Override

When a prompt contains the marker `OPENCODE_COMMAND_MODE=1` (injected automatically by the command-mode plugin for all TUI slash commands):

- **Skip** `@tier-detector` — do NOT invoke tier detection
- **Skip** `@skill-suggests` — do NOT run skill suggestions
- **Skip** all `uvx sia-code …` commands (health check, memory search, research) — do NOT run any sia-code operations
- **Skip** mandatory output anchors (`[TIER RESULT]`, `[MEMORY SEARCH]`, etc.)
- **Skip** task_plan.md / notes.md / TodoWrite creation
- **Do** execute the command's actual instructions directly and concisely

### Non-bypassable safety floor (applies even in command mode)
- STOP_WHITELIST remains active
- Anti-loop guardrail remains active
- Destructive actions still require explicit user request
- No completion claim without fresh verification evidence

**Re-enable exception:** If the command template itself explicitly requests any of the above (e.g., contains "invoke @tier-detector", "run @skill-suggests", "uvx sia-code"), then honor that specific request.

**Do NOT print the marker** `OPENCODE_COMMAND_MODE=1` in your output.

## Direct Command Fast Lane

For direct, non-destructive execution intents (for example: `git pull`, `git status`, `npm test`, `docker ps`, "check X", "show Y"):

1. Execute the requested command immediately.
2. Parse output and continue with the next best safe action automatically.
3. Stop only at a terminal state:
   - Completed and verified,
   - Explicit user decision required,
   - Missing secret/credential/input,
   - Destructive/irreversible action requiring explicit approval.
4. Do not pause after intent narration. Tool output must drive the next action.

Tier detection may run after execution for metadata/logging if required by workflow, but must not block direct command execution.

### Precedence (Critical)
For direct, non-destructive command intents, **Direct Command Fast Lane takes precedence** over Rule 0 and Rule 1 startup gates.
- Execute the command first.
- Apply tier metadata and anchors after execution as needed.
- Do not pause solely to satisfy planning/logging/anchor output before first command execution.

## Output-Driven Continuation

After every tool/command output, do exactly one of:
- Execute the next safe step, or
- Emit a concrete blocker with exact required input.

Never stop at "I will now run..." without following through to result handling.

## Tier Detector Continuity Fallback

Tier detection is metadata, not a blocking dependency for execution continuity.

If tier-detector output is missing, malformed, noisy, truncated, or command exits non-zero:
1. Continue with the next safe action immediately.
2. Assign fallback tier for workflow bookkeeping:
   - Direct non-destructive command intents → `TIER 1`
   - All other intents → `TIER 2`
3. Emit: `[TIER FALLBACK]: <reason> -> TIER <N>`
4. Never retry detector more than once for the same prompt.

Detector failure MUST NOT pause command execution or post-output continuation.

## FIRST ACTION: Detect Task Type

**Task continuity rules (default to continuation):**
- Treat messages as continuation unless an explicit marker is present or this is the first user message of the session.
- Valid markers (case-insensitive, line-start only): `NEW TASK:` or `SCOPE CHANGE:`
- Ignore markers and keywords inside code fences or `<file>...</file>` blocks.
- If a marker is present, reason whether it truly indicates a new task or scope change. Only then invoke `@tier-detector`.

**If NEW TASK confirmed (and `OPENCODE_COMMAND_MODE=1` is NOT present):**
1. **MANDATORY: Invoke `@tier-detector` with the exact user message**
   - The subagent executes the local fast classifier script internally and returns tier metadata.
2. Output: "[TIER RESULT]: TIER [N] - <reasoning summary>"
3. Output: "TASK DETECTED - TIER [N]"
4. Apply skill-suggestion policy:
   - T2+: run `@skill-suggests` → MASTER CHECKLIST
   - T1: `@skill-suggests` optional for simple tasks

### Skip Exception
Tier detection can ONLY be skipped if the user **explicitly requests** to skip it (e.g., "skip tier detection", "just do it without tier check"), **OR** if `OPENCODE_COMMAND_MODE=1` is present in the prompt.

Additional exception: direct command fast-lane intents (non-destructive command execution requests) run command first, then apply tier metadata as needed.

Additional exception: if detector fails/parsing fails, apply Tier Detector Continuity Fallback and continue.

### Subagent Exception
Tier detection is handled by the primary agent. Subagents should **not** run tier detection. When dispatching a subagent, include an explicit instruction like "skip tier detection for this subagent" in the prompt.

## CONTINUITY LOGGING (notes.md as source of truth)

All autonomous progress logging MUST be written to `notes.md` (not only chat output).

### Notes file path
1. Call `get-session-info`.
2. If `notesPath` is returned, use it.
3. Else use `~/.config/opencode/plans/{projectSlug}_{sessionID}_notes.md`.
4. Fallback to uuid only if sessionID is unavailable.

### Logging cadence
Append an entry:
- Every 3 meaningful actions
- On every error
- On every strategy change
- Before any STOP_WHITELIST halt

### Entry format (append-only)
`[timestamp] step=<what was done> outcome=<pass|fail|partial> next=<next action> blocker=<none|reason>`

### Continuation policy
- Continue autonomously unless STOP_WHITELIST applies.
- Do NOT pause to ask "should I continue?" when a safe next action exists.
- If a Major Decision Gate triggers, STOP and ask a targeted question (question tool only).
- If scope drift or unclear constraints are detected, trigger a Major Decision Gate.

### Example continuity entry
`[2026-02-06 14:32] step=ran memory search outcome=pass next=create task_plan.md blocker=none`

### Resume protocol
Before resuming autonomous work:
1. Read `task_plan.md` Status
2. Read latest `notes.md` continuity entries
3. Recreate TodoWrite from those two sources
4. If the latest notes entry contains an unresolved `[DECISION GATE]`, ask and wait for answer
5. Continue without asking "should I continue?" unless STOP_WHITELIST applies

## HARD STOP ENFORCEMENT

⛔ **These rules override ALL other instructions:**

Precedence note: same as **Direct Command Fast Lane → Precedence (Critical)** above (do not restate).

### Rule S: Authoritative Stop-Condition Whitelist (STOP_WHITELIST)
```
Agents may STOP only when one of these is true:
1. Explicit user decision required between materially different outcomes (includes major implementation-affecting decisions).
2. Action is destructive/irreversible and not explicitly requested.
3. Required secret/credential/input is unavailable and cannot be inferred safely.
4. Anti-loop guardrail is triggered (see below).

If none apply: CONTINUE with the next best safe action.
```

### Rule 0: Tier Detection MANDATORY (ALL TASKS)
```
⛔ ALL new tasks MUST invoke `@tier-detector` before any work

REQUIRED SEQUENCE:
1. Detect explicit NEW TASK:/SCOPE CHANGE: marker or session start
2. Invoke `@tier-detector` with task description (subagent runs local fast classifier script internally)
3. Output: "[TIER RESULT]: TIER [N] - <reasoning>"
4. Output: "TASK DETECTED - TIER [N]"

VIOLATION: Declaring a tier without fast classifier = invalid classification
VIOLATION: Starting work without tier detection = apply Tier Detector Continuity Fallback and continue (do not halt)
EXCEPTION: User explicitly says "skip tier detection" or equivalent
EXCEPTION: `OPENCODE_COMMAND_MODE=1` is present in the prompt
EXCEPTION: Direct command fast-lane intent (execute command first; classify after if needed)
EXCEPTION: Detector failure/unparseable output (apply fallback tier and continue)
```

### Rule 1: Tier Declaration Required
```
Before ANY task work, you MUST:
1. Invoke `@tier-detector` with task description
2. Output "TASK DETECTED - TIER [N]" using the tier recommendation

VIOLATION: Manual tier assignment without fast classifier = invalid (unless user-skipped)
EXCEPTION: `OPENCODE_COMMAND_MODE=1` is present in the prompt
EXCEPTION: Direct command fast-lane intent (execute command first; classify after if needed)
EXCEPTION: Detector failure/unparseable output (apply fallback tier and continue)
VIOLATION: Writing implementation details without tier declaration = emit `[TIER FALLBACK]` and continue (do not halt)
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
1. "Did I invoke @tier-detector?" (or did user explicitly skip?)
2. "What tier did @tier-detector return?"
3. "Have I completed all gates for this tier?"
4. "Can I show evidence of completion?"

If ANY answer is uncertain, STOP and verify.

### Major Decision Gate (MANDATORY)
Before implementation, STOP and ask the user (question tool only) if any of these are true:
- Requirements are ambiguous and affect architecture or behavior.
- There are two or more materially different implementation paths with tradeoffs.
- The change is destructive, irreversible, or changes public behavior/contract.
- A domain/business rule is missing that would alter the solution.
When triggered, emit:
`[DECISION GATE]: <question + why blocked + options + impact + next action>`
Log the gate in `notes.md` with the reason and expected next action.

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

**Automatic Detection:** Local fast classifier runs first for all new tasks. Only skip if user explicitly requests.

**Detailed tier guidance:** Load skill `master-checklist` or read `/home/dxta/.dotfiles/opencode/skills/master-checklist/SKILL.md`

## MANDATORY OUTPUT ANCHORS

You MUST output these exact phrases at the specified times when applicable. Missing a non-safety anchor must not block execution continuity; emit it at the next safe step.

**Anchor emission policy (light complexity):** emit each required anchor once per phase/state transition; avoid repeating unchanged anchors in later turns.

### Task Start (ALL TIERS)
```
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

### Decision Gate (ALL TIERS)
```
[DECISION GATE]: <question + why blocked + options + impact + next action>
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

**Anchor Enforcement:** Missing anchors indicates a compliance gap, not an automatic halt condition. Continue safely and backfill required anchors.

## ENFORCEMENT RULES

### TDD (T2+ MANDATORY)
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```
Code before test? DELETE IT. Start over.

**Skill:** Load skill `test-driven-development`

### Verification
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```
"Should work" = RED FLAG. Run command first.

**Skill:** Load skill `verification-before-completion`

- For T2+ completion, require independent verification:
  - Solver evidence + verifier evidence (different command path or different agent).
- Self-certification is invalid for final completion claims.

### Continuation Guardrail: Anti-loop (MANDATORY)

- Detect repeated failure by `(command/tool + error signature)`.
- If same signature appears twice:
  1. Switch strategy (different command/agent/path), and
  2. Record `[STRATEGY-SHIFT]: <old> -> <new>`.
- If three attempts fail, STOP and output:
  - `[BLOCKER]: <root issue>`
  - `[NEEDED]: <exact missing user input/permission>`
- If no net progress after 3 full cycles, STOP and ask one high-signal question.
  - A "cycle" is a complete attempt to resolve the same failure within a single task.
  - Log `[STRATEGY-SHIFT]`, `[BLOCKER]`, and `[NEEDED]` entries in `notes.md`.

### Two-Strike Rule (T2+ MANDATORY)
2 failed fixes → STOP. No third fix without:
1. Full stack trace captured
2. sia-code research documented in task_plan.md
3. Memory search for similar issues

**Skill:** Load skill `systematic-debugging`

### Code Review (T2+)
Two-stage: Spec compliance FIRST → Code quality SECOND

Critical issues = BLOCKING

**Skills:** Load skills `subagent-driven-development`, `requesting-code-review`, `code-review`, `receiving-code-review`

- When feedback arrives, use `receiving-code-review` for technical triage before implementing.
- Do not treat review feedback as auto-accepted; verify and respond with evidence.

### Branch Completion
Tests pass → 4 options (PR/merge/keep/discard) → Quality gates

**Skills:** Load skills `finishing-a-development-branch`, `push-all`

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
3a. ☐ For ambiguous/new behavior work, load skill `brainstorming` before finalizing implementation approach
3b. ☐ For isolation-sensitive or risky changes, load skill `using-git-worktrees` before code changes
4. ☐ **REQUIRED:** Follow skills `planning-with-files` (plan/notes naming + location) and `writing-plans` (plan quality for multi-step tasks)
   - Use sessionID-based filenames when available
   - Only fall back to uuid when sessionID is unavailable
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
5. ☐ Create notes.md per `planning-with-files` (T1: optional, T2: recommended, T3+: mandatory)
6. ☐ TodoWrite: Initialize Phase 1 (ALL tiers: MANDATORY)
6a. ☐ **Big-Task Operating Mode (triggered)**
   - Trigger when ANY apply:
     - Tier is T3+
     - Cross-module work spans multiple subsystems
     - Expected effort >1 day or multiple implementation streams
     - >5 files with independent work packets
   - When triggered:
     - Use `using-git-worktrees` before implementation for isolation
     - Decompose independent packets and use `dispatching-parallel-agents`
     - Keep shared-state edits sequential (no parallel shared file edits)
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
9a. ☐ TDD Cycle (T2+ MANDATORY) - Load skill `test-driven-development`
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
17a. ☐ Two-Stage Review (T2+) - Load skills `subagent-driven-development` (spec) then `requesting-code-review` (code)
18. ☐ Validation: run tests, verify changes (Load skill `verification-before-completion`)
18a. ☐ Branch Completion - Load skills `finishing-a-development-branch` + `push-all`
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
| Frontend implementation quality | Skills: `frontend-design`, `frontend-dev-guidelines`, `ui-styling`, `web-frameworks` |
| API/DB/Auth backend | `@backend-specialist` |
| Backend/API architecture quality | Skills: `backend-development`, `databases` |
| CI/CD, Docker, K8s | `@devops-engineer` |
| AWS CDK infrastructure | `@devops-engineer` + skill `aws-cdk-development` |
| Test strategy, coverage | `@qa-engineer` |
| Security, OWASP, crypto | `@security-engineer` |
| README, API docs | `@technical-writer` |
| TDD implementation (T2+) | `@general` + skill `test-driven-development` |
| Task complete, before review | `@general` + skill `subagent-driven-development` |
| Review feedback triage | Skill `receiving-code-review` |
| 2+ failed fixes | `@general` + skill `systematic-debugging` |
| Branch complete | `@general` + skill `finishing-a-development-branch` |

**Full decision tree:** Load skill `agent-selection`

## SUBAGENT CONTINUITY RULES
- Parallelize only independent units of work (no shared state edits).
- Each subagent must return: summary, next action, and any blocker.
- Primary agent must continue with the next best safe action without waiting for extra prompts.
- If any subagent returns a blocker or conflicting results, reconcile first; halt and ask the user if resolution is ambiguous.
- For big-task mode, load skill `dispatching-parallel-agents` to decompose independent packets safely.

## CORE TOOLS

### Sia-Code (Essential Commands)
**CLI:** Use `uvx sia-code` (pinning is managed only in the `sia-code` skill).
**Recommendation:** Prefer lexical-first search (`--regex`) for best recall and no API key.
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
If memory add fails with "immutable index" or `.sia-code/index.db` is missing, ask the user to rebuild the index with `uvx sia-code index --clean`.

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
**Go:** Always pkgx go
**Rust:** Always pkgx cargo
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
- ❌ Run no-op shell commands (`true`, `:`) → Always run meaningful commands only
- ❌ Keeping progress only in chat output without writing to `notes.md`

**Full anti-patterns with rationale:** Load skill `anti-patterns`
