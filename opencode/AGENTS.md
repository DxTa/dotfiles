# Context Engineering Platform

Sub-agents, sia-code CLI code indexing with built-in memory, external LLM validation.

**Built-in Subagents:** `@general` (research, multi-step), `@explore` (file patterns, code search).

## FIRST ACTION: Detect Task Type

**New task patterns:** implement, build, create, fix, debug, refactor, design, migrate, setup, add, develop

**Skip patterns:** follow-ups, clarifications, acknowledgments

**If NEW TASK:** Output "TASK DETECTED - TIER [N]" → `@skill-suggests` → MASTER CHECKLIST

### Direct Command Exception
Skip planning for: single explicit action, no code changes, <1 minute, "just do X"

## TIER SYSTEM

| Tier | Scope | Key Requirements | Token Hint |
|------|-------|------------------|------------|
| **T1** | <30 lines, 1 file | task_plan.md + TodoWrite MANDATORY | ~8K |
| **T2** | 30-100 lines, 2-5 files | All T1 + Sia-code MANDATORY | ~16K |
| **T3** | 100+ lines, architecture | All T2 + notes.md + External LLM | ~32K |
| **T4** | Critical/Deployment | All T3 + rollback + Antagonistic QA | ~64K |

### Tier Requirements Summary
- **T1:** Steps 3,4,6 mandatory. Skip exploration.
- **T2:** Steps 1-6 mandatory. Sia-code if triggers. TDD MANDATORY.
- **T3:** All steps mandatory. @self-reflect MANDATORY.
- **T4:** All T3 + rollback plan + Antagonistic QA NON-SKIPPABLE.

**Detailed tier guidance:** Load skill: `skills/master-checklist`

## ENFORCEMENT RULES

### TDD (T2+ MANDATORY)
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```
Code before test? DELETE IT. Start over.

**Skill:** Load `superpowers/test-driven-development`

### Verification
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```
"Should work" = RED FLAG. Run command first.

**Skill:** Load `superpowers/verification-before-completion`

### Two-Strike Rule (T2+ MANDATORY)
2 failed fixes → STOP. No third fix without:
1. Full stack trace captured
2. sia-code research documented in task_plan.md
3. Memory search for similar issues

**Skill:** Load `superpowers/systematic-debugging`

### Code Review (T2+)
Two-stage: Spec compliance FIRST → Code quality SECOND

Critical issues = BLOCKING

**Skills:** Load `superpowers/subagent-driven-development`, `superpowers/requesting-code-review`

### Branch Completion
Tests pass → 4 options (PR/merge/keep/discard) → Quality gates

**Skills:** Load `superpowers/finishing-a-development-branch`, `push-all`

## MASTER CHECKLIST

**PRE-TASK:**
1. ☐ `@skill-suggests [task]` (T2+: execute, T1: optional for simple tasks)
2. ☐ sia-code memory search past decisions (T2+: MANDATORY, recovery if fails: run `uvx sia-code init && uvx sia-code index .`)
3. ☐ `get-session-info` → sessionID, projectSlug (ALL tiers: MANDATORY)
4. ☐ Create task_plan.md: `{projectSlug}_{sessionID}_task_plan.md` (ALL tiers: MANDATORY for crash recovery)
5. ☐ Create notes.md: `{projectSlug}_{sessionID}_notes.md` (T1: optional, T2: recommended, T3+: mandatory)
6. ☐ TodoWrite: Initialize Phase 1 (ALL tiers: MANDATORY)
7. ☐ Exploration (T2+: if triggers hit, T3+: MANDATORY before code changes)
   - **7a.** Sia-Code: Check triggers (unfamiliar code? cross-file? "how X works"? post Two-Strike?) → `uvx sia-code embed start` (if hybrid search) → `uvx sia-code research` → Document in task_plan.md
   - **7b.** Subagent Selection: Use decision tree - Load skill: `skills/agent-selection`

**DURING:**
8. ☐ TodoWrite: Update as steps complete (mark complete IMMEDIATELY, don't batch)
9. ☐ Sync task_plan.md Status after each TodoWrite change
9a. ☐ TDD Cycle (T2+ MANDATORY) - Load skill: `superpowers/test-driven-development`
    - RED: Write failing test first → Verify RED → GREEN: Minimal code to pass → Verify GREEN → REFACTOR → COMMIT
10. ☐ Re-read task_plan.md before major decisions (T3+: before EVERY major decision)
11. ☐ Self-reflection (T1: mental check, T2: @self-reflect recommended, T3+: @self-reflect MANDATORY)
    - **AUTO-TRIGGER:** After task_plan.md (T3+), before first code change (T3+), after Two-Strike, before claiming complete (T2+)
12. ☐ Log errors to task_plan.md

**POST-TASK:**
13. ☐ External LLM validation (T3+: MANDATORY, T4: NON-SKIPPABLE)
14. ☐ TodoWrite: Mark all completed
15. ☐ task_plan.md: Mark all phases [x]
16. ☐ sia-code memory: Store learnings (T2+: MANDATORY - search first, update if exists, use category prefix: Procedure/Fact/Pattern/Fix/Preference)
17. ☐ @code-simplifier (T2+: recommended before final testing)
17a. ☐ Two-Stage Review (T2+) - Load skills: `superpowers/subagent-driven-development` (spec) then `superpowers/requesting-code-review` (code)
18. ☐ Validation: run tests, verify changes (Load skill: `superpowers/verification-before-completion`)
18a. ☐ Branch Completion - Load skill: `superpowers/finishing-a-development-branch` + `push-all`

**Full checklist details:** Load skill: `skills/master-checklist`

## AGENT SELECTION

| Need | Agent/Tool |
|------|------------|
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
| TDD implementation (T2+) | `@general` + `superpowers/test-driven-development` |
| Task complete, before review | `@general` + `superpowers/subagent-driven-development` |
| 2+ failed fixes | `@general` + `superpowers/systematic-debugging` |
| Branch complete | `@general` + `superpowers/finishing-a-development-branch` |

**Full decision tree:** Load skill: `skills/agent-selection`

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
If `.sia-code/` missing: `uvx sia-code init && uvx sia-code index .`

### MCP Reasoning
- **code-reasoning:** Debugging, algorithms, step-by-step
- **shannon-thinking:** Architecture, tradeoffs, uncertainty

**Skill:** Load `skills/reasoning-tools`

### TodoWrite + Plan Sync
- Task start → Create task_plan.md → TodoWrite Phase 1
- TodoWrite update → Update task_plan.md Status
- Before /clear → Ensure task_plan.md current
- Session resume → Read task_plan.md → Restore TodoWrite

**Skill:** Load `@planning-with-files`

### Token Budget
Monitor at phase boundaries: `opencode stats --project ""`

Offload research to notes.md.

**Skill:** Load `skills/token-management`

## SELF-REFLECTION TRIGGERS

- After creating task_plan.md (T2+: recommended, T3+: MANDATORY)
- Before first code change (T3+: MANDATORY)
- After Two-Strike triggered
- Before claiming "task complete" (T2+: verification gate)

**Invocation:** `@self-reflect Review this plan for edge cases, production risks, and missing considerations`

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

**Full anti-patterns with rationale:** Load skill: `skills/anti-patterns`
