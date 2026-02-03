---
name: master-checklist
description: Detailed guidance for each MASTER CHECKLIST step with tier-specific requirements
version: "1.0.0"
---

# MASTER CHECKLIST Detailed Guidance

Comprehensive step-by-step guidance for all 18+ checklist steps with tier-specific requirements and best practices.

## Overview

The MASTER CHECKLIST is the core workflow for all tasks. This skill provides:
- Detailed guidance for each step
- Tier-specific variations (T1, T2, T3, T4)
- Self-reflection checkpoints (AUTO-TRIGGER)
- Common pitfalls and how to avoid them

---

## PRE-TASK Steps

### Step 1: `@skill-suggests [task]`

**Purpose:** Get AI-suggested skills relevant to the task

**Execution:**
```
@skill-suggests implement authentication middleware
```

**Tier Requirements:**
- T1: Optional (skip for simple tasks)
- T2+: Execute
- T3+: MANDATORY

**Skip Conditions:**
- Direct commands ("run tests", "format file X")
- Follow-up clarifications
- <30 lines, 1 file, clear solution (T1 lightweight path)

---

### Step 2: sia-code memory search

**Purpose:** Search past decisions and patterns before starting

**Execution:**
```bash
uvx sia-code memory search "authentication"
uvx sia-code memory search "[task topic]"
```

**Tier Requirements:**
- T1: Optional (store if useful pattern)
- T2+: MANDATORY (skip only if <30s, document why)
- T3+: MANDATORY - execute BEFORE exploration

**Recovery if it fails:**
If memory search fails because `.sia-code/` is missing or broken:
⚠️ **ASK USER** to run `uvx sia-code init && uvx sia-code index .`
Do NOT silently skip — Load skill `sia-code/health-check` for full troubleshooting.
Then retry the memory search.

**What to look for:**
- Past decisions on similar features
- Known patterns or gotchas
- Related architecture decisions
- Configuration requirements

---

### Step 3: Call `get-session-info` tool

**Purpose:** Get sessionID and projectSlug for plan file naming

**Execution:**
```
Use the get-session-info MCP tool
```

**Tier Requirements:**
- T1: Execute
- T2+: Execute
- ALL tiers: MANDATORY

**Output:**
- `sessionID`: e.g., `ses_40459c3afffeRfpLuTnCCYdKyS`
- `projectSlug`: e.g., `dxta`

---

### Step 4: Create task_plan.md

**Purpose:** Persistent planning file for crash recovery and session continuity

**File Path:**
```
~/.config/opencode/plans/{projectSlug}_{sessionID}_task_plan.md
```

**Tier Requirements:**
- ALL tiers: MANDATORY (crash recovery)

**Template Structure:**
```markdown
# Task Plan: [Task Name]

**Session:** {sessionID}
**Date:** YYYY-MM-DD
**Tier:** [T1/T2/T3/T4]

## Goal
[Clear, measurable objective]

## Status
- [x] Phase 1: Planning
- [ ] Phase 2: Implementation
- [ ] Phase 3: Testing
- [ ] Phase 4: Review

## Decisions
1. [Key decision with rationale]

## Errors Encountered
[Log errors here]

## Next Steps
[Current position in task]
```

---

### Step 5: Create notes.md

**Purpose:** Offload research findings without polluting working memory

**File Path:**
```
~/.config/opencode/plans/{projectSlug}_{sessionID}_notes.md
```

**Tier Requirements:**
- T1: Optional (for research/analysis)
- T2: Recommended (for research/analysis)
- T3+: MANDATORY

**Use Cases:**
- API documentation summaries
- Architecture research findings
- Library usage patterns
- External resource notes

---

### Step 6: TodoWrite: Initialize Phase 1

**Purpose:** Create TUI-visible task list for live progress tracking

**Execution:**
```
Use TodoWrite MCP tool to create initial phase steps
```

**Tier Requirements:**
- ALL tiers: MANDATORY

**Best Practices:**
- Break into specific, actionable items
- One task in_progress at a time
- Mark complete IMMEDIATELY after finishing (don't batch)
- Keep synced with task_plan.md Status section

---

### Step 7: Exploration

**Purpose:** Understand codebase architecture before code changes

**Tier Requirements:**
- T1: Skip for simple tasks
- T2+: If triggers hit (unfamiliar code, cross-file, "how does X work", post Two-Strike)
- T3+: MANDATORY before code changes

#### Step 7a: Sia-Code Check

**Trigger Check:**
- Unfamiliar codebase area (haven't worked in past 30 days)?
- Cross-file changes (Integration Changes pattern)?
- Task involves "how does X work" or "trace dependencies"?
- After Two-Strike Rule triggered?

**If YES:**

1. **Ensure embed daemon running (MANDATORY for hybrid search):**
   ```bash
   uvx sia-code embed status
   # If not running:
   uvx sia-code embed start
   ```
   Skip if using lexical-only search (`--regex`)

2. **Check index health:**
   ```bash
   uvx sia-code status
   ```
   Shows 🟢 Healthy / 🟡 Degraded / 🔴 Critical

3. **Run architectural research:**
   ```bash
   uvx sia-code research "how does authentication flow work" --hops 3
   ```

4. **Document in task_plan.md:**
   - **T2:** Optional: "Sia-code findings: [summary]" OR "Sia-code skipped: [reason]"
   - **T3+:** MANDATORY: Must document findings or skip reason

**If NO:**
Document in task_plan.md ("Familiar codebase: [reason]") for T3+ tasks

#### Step 7b: Subagent Selection

**Use decision tree, not all agents**

Load skill: `skills/agent-selection` for full decision tree

**Core Agents:**
- `@general` for external research, multi-step analysis, documentation lookup
- `@explore` for file pattern matching, code search, simple name lookup

**Additional specialists based on domain:**
- @backend-specialist / @frontend-specialist (domain-specific)
- @security-engineer (security implications)
- @devops-engineer (infrastructure involved)
- @qa-engineer (test strategy needed)

**MUST complete exploration before any code changes**
**Re-run exploration if task scope changes**

---

## DURING Steps

### Step 8: TodoWrite: Update as steps complete

**Purpose:** Keep TUI task list current

**Tier Requirements:**
- ALL tiers: Execute

**Best Practices:**
- Mark complete IMMEDIATELY after finishing each step
- Don't batch completions
- Only ONE task in_progress at a time

---

### Step 9: Sync task_plan.md Status

**Purpose:** Keep persistent plan synced with TodoWrite

**Tier Requirements:**
- ALL tiers: Execute after each TodoWrite change

**Sync Protocol:**
| Event | Action |
|-------|--------|
| TodoWrite update | Update task_plan.md Status section |
| Error occurs | Log to task_plan.md "Errors Encountered" |
| Phase complete | Mark task_plan.md [x] → Reset TodoWrite |

---

### Step 9a: TDD Cycle (T2+ MANDATORY)

**Purpose:** Ensure test-first development

**Tier Requirements:**
- T1: Optional (but encouraged)
- T2+: **MANDATORY** - Code before test? DELETE IT. Start over.

**Iron Law:**
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

**RED-GREEN-REFACTOR Cycle:**
- [ ] **RED:** Write ONE failing test
- [ ] **Verify RED:** Watch it fail (correct reason - "feature missing" not typo)
- [ ] **GREEN:** Write MINIMAL code to pass
- [ ] **Verify GREEN:** All tests pass (no regressions)
- [ ] **REFACTOR:** Clean up (stay green)
- [ ] **COMMIT:** Atomic commit per behavior

**Load skill:** `superpowers/test-driven-development` for full guidance

---

### Step 10: Re-read task_plan.md before major decisions

**Purpose:** Prevent context amnesia and goal drift

**Tier Requirements:**
- T1: Before major decisions
- T2: Before major decisions
- T3+: Before EVERY major decision

**What qualifies as "major decision":**
- Choosing implementation approach
- Refactoring existing code
- Adding new dependencies
- Changing architecture

**Action:** Confirm trimmed context is irrelevant to next 2 steps

---

### Step 11: Self-reflection

**Purpose:** Validate approach, identify risks, find simpler alternatives

**Tier Requirements:**
- T1: Quick mental check (skip agent)
- T2: Use `@self-reflect` (recommended)
- T3+: Use `@self-reflect` (MANDATORY)
- T4: Use `@self-reflect` (NON-SKIPPABLE)

**Self-Reflection Checkpoints (AUTO-TRIGGER):**
- [ ] After creating task_plan.md (T2+: recommended, T3+: run @self-reflect)
- [ ] Before first code change (T3+: MANDATORY @self-reflect on approach)
- [ ] After Two-Strike Rule triggered (run @self-reflect for root cause)
- [ ] Before claiming "task complete" (T2+: @self-reflect verification gate)

**Invocation:**
```
@self-reflect Review this plan for edge cases, production risks, and missing considerations
```

**What @self-reflect validates:**
- Edge cases and error scenarios
- Production risks and scalability concerns
- Missing considerations and requirements gaps
- Simpler alternative approaches
- Unstated assumptions that need verification

**Validation approach:** Antagonistic QA mindset from a Senior Technical Lead perspective - **assume broken until proven.**

---

### Step 12: Log errors to task_plan.md

**Purpose:** Track investigation progress for crash recovery

**Tier Requirements:**
- ALL tiers: Execute

**Format:**
```markdown
## Errors Encountered

### Error 1: TypeError at line 42
- **When:** 2026-01-27 14:30
- **What:** Cannot read property 'foo' of undefined
- **Fix Attempted:** Added null check
- **Result:** Still failing
```

---

## POST-TASK Steps

### Step 13: External LLM validation

**Purpose:** Get second opinion on approach and implementation

**Tier Requirements:**
- T1/T2: Skip
- T3+: MANDATORY
- T4: NON-SKIPPABLE

**How:** Use external LLM (ChatGPT, Claude web) to review:
- Architecture decisions
- Security implications
- Edge cases
- Performance concerns

---

### Step 14: TodoWrite: Mark all completed

**Purpose:** Clean up TUI task list

**Tier Requirements:**
- ALL tiers: Execute

---

### Step 15: task_plan.md: Mark all phases [x]

**Purpose:** Update persistent plan to show completion

**Tier Requirements:**
- ALL tiers: Execute

---

### Step 16: sia-code memory: Store learnings

**Purpose:** Preserve knowledge for future tasks

**Tier Requirements:**
- T1: Optional (store if useful pattern)
- T2+: MANDATORY

**What new insight did we capture?**

**Search for related memories first:**
```bash
uvx sia-code memory search "[topic]"
```
If it fails, see Step 2 recovery.

**If exists:** Update with "Updated [date]: [new insight]"
**If new:** Use appropriate category prefix

**Categories:**
- `Procedure:` Step-by-step how-to instructions
- `Fact:` Verified assertion about the codebase
- `Pattern:` Reusable approach with conditions for use
- `Fix:` Root cause → solution mapping
- `Preference:` User or project-specific choice

**Store as decision** (Load skill `sia-code/decision-trace` for structured format):
```bash
uvx sia-code memory add-decision "[Category]: [Decision]. Context: [trigger]. Reasoning: [why]. Outcome: [result]."
```
**Examples:**
```bash
uvx sia-code memory add-decision "Procedure: How to debug X. Context: recurring issue in module Y. Reasoning: stack trace pointed to Z. Outcome: documented for future sessions."
uvx sia-code memory add-decision "Fact: Module Y requires Z. Context: discovered during feature implementation. Reasoning: missing config caused silent failure. Outcome: added to setup checklist."
```
- ❌ **NEVER** store bare outcomes: `"Fix: Added retry logic"`
- ✅ **ALWAYS** include Context + Reasoning to preserve decision history

---

### Step 17: @code-simplifier

**Purpose:** Clean up code for clarity and maintainability

**Tier Requirements:**
- T1: Optional
- T2+: Recommended (before final testing)

**Invocation:**
```
@code-simplifier Review and simplify [files]
```

---

### Step 17a: Two-Stage Review (T2+)

**Purpose:** Systematic code review: spec compliance FIRST, then code quality

**Tier Requirements:**
- T1: Skip
- T2+: Execute

**STAGE 1: Spec Compliance**
Dispatch `@general` with `superpowers/subagent-driven-development` spec-reviewer

**Loop until ✅:**
- [ ] Run spec review
- [ ] Fix issues
- [ ] Re-dispatch spec review
- [ ] Repeat until ✅ Spec compliant

**STAGE 2: Code Quality** (only after Stage 1 passes)
Dispatch `@general` with `superpowers/requesting-code-review`

**Loop until ✅:**
- [ ] Run code review
- [ ] Fix issues (Critical = BLOCKING)
- [ ] Re-dispatch code review
- [ ] Repeat until ✅ Quality approved

---

### Step 18: Validation: run tests, verify changes

**Purpose:** Evidence-based completion verification

**Tier Requirements:**
- ALL tiers: Execute

**Load skill:** `superpowers/verification-before-completion`

**Iron Law:**
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

**Before ANY claim of success:**
1. IDENTIFY: What command proves this claim?
2. RUN: Execute the command (fresh, complete)
3. READ: Full output, check exit code
4. VERIFY: Does output confirm claim?
5. ONLY THEN: Make the claim

**Red Flags:** "should work", "probably", "seems to"

---

### Step 18a: Branch Completion

**Purpose:** Systematically finish development branch with quality gates

**Tier Requirements:**
- ALL tiers: Execute when branch work complete

**Load skill:** `superpowers/finishing-a-development-branch`

**Workflow:**
- [ ] Tests pass (verification gate)
- [ ] Choose option (PR/merge/keep/discard)
- [ ] For PR/merge: Load `push-all` skill for quality gates
- [ ] Execute choice

**Options:**
1. **Create PR:** `push-all` → `gh pr create`
2. **Merge locally:** `push-all` → checkout main → merge
3. **Keep as-is:** No action
4. **Discard:** Require "discard" confirmation

---

## Tier-Specific Summary

### T1 Requirements
**MANDATORY steps:** 3, 4, 6
**Skip:** Step 1 (skill-suggests), Step 2 (memory search), Step 7 (exploration)
**Optional:** Step 14 (sia-code memory)

### T2 Requirements
**MANDATORY steps:** 1-6, 8-12, 14-18
**Step 7:** If triggers hit (unfamiliar, cross-file, "how does X work", post Two-Strike)
**Step 9a (TDD):** MANDATORY
**Step 11 (@self-reflect):** Recommended
**Step 14 (sia-code memory):** MANDATORY

### T3 Requirements
**ALL steps MANDATORY** except where noted
**Step 5 (notes.md):** MANDATORY
**Step 7 (exploration):** Sia-code + parallel subagents MANDATORY before code changes
**Step 10 (Re-read plan):** Before EVERY major decision
**Step 11 (@self-reflect):** MANDATORY
**Step 12 (External LLM):** MANDATORY
**Step 14 (sia-code memory):** MANDATORY

### T4 Additions
- All T3 requirements
- External LLM validation NON-SKIPPABLE
- task_plan.md must include deployment checklist phase
- task_plan.md must include rollback plan in Decisions section
- Antagonistic QA before marking complete

---

## Common Pitfalls

| Pitfall | Detection | Fix |
|---------|-----------|-----|
| Skipping task_plan.md | No persistent plan exists | Create immediately (Step 4) |
| TodoWrite without plan | TUI has todos but no plan file | Create plan, sync Status |
| Forgetting sia-code memory | Task complete, no memory stored | Run Step 16 before marking done |
| Code before test (T2+) | Writing implementation before test | DELETE code, write test first |
| No self-reflection (T3+) | About to code without @self-reflect | Stop, run @self-reflect first |
| Claiming complete without verification | Using "should work" language | Run Step 18 verification |

---

## Usage

Load this skill when:
- Starting a new task (review full checklist)
- Uncertain about a specific step (find step number)
- Debugging why a step failed (read detailed guidance)
- Explaining workflow to others (comprehensive reference)
