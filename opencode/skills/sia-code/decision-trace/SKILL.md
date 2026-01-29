---
name: sia-code/decision-trace
description: Structured decision trace format for sia-code memory. Captures reasoning context (WHY decisions were made), not just outcomes (WHAT happened). Inspired by context graph architecture. Use when storing learnings, adding decisions, or reviewing memory format.
license: MIT
compatibility: opencode
version: 1.0.0
---

# Decision Trace Format

Structured format for sia-code memory entries that captures **reasoning context** — not just outcomes. This ensures future sessions can understand WHY decisions were made, not just WHAT was decided.

## The Problem

Flat memory entries store outcomes without reasoning:

```
❌ "Fix: Added retry logic to API calls"
❌ "Fact: Use PostgreSQL for user data"
❌ "Pattern: All forms use react-hook-form"
```

When a similar situation arises in a future session, the agent sees WHAT was decided but not:
- **What triggered** the decision
- **What alternatives** were considered and rejected
- **Why this choice** was made over others
- **What the outcome** was (did it work? any caveats?)

Each case is treated as new — even when the organization has already resolved it.

## Structured Trace Format

Every memory entry should follow this structure:

```
[Category]: [Decision]. Context: [what triggered this]. Reasoning: [why chosen over alternatives]. Outcome: [result or impact].
```

### Category Prefixes

| Category | Use For | Example Trigger |
|----------|---------|-----------------|
| **Procedure:** | Recurring how-to steps | "How do we deploy X?" |
| **Fact:** | Codebase constraints, dependencies | "Module X requires Y" |
| **Pattern:** | Reusable architectural approaches | "How should we structure Z?" |
| **Fix:** | Bug root causes + solutions | "Why did X break?" |
| **Preference:** | User/team conventions | "Which library for Y?" |

## Examples

### ❌ Bad: Outcome-Only

```bash
uvx sia-code memory add-decision "Fix: Added retry logic to API calls"
uvx sia-code memory add-decision "Fact: Use PostgreSQL for user data"
uvx sia-code memory add-decision "Pattern: All forms use react-hook-form"
```

### ✅ Good: Full Decision Trace

```bash
uvx sia-code memory add-decision "Fix: Added retry with exponential backoff for external API calls. Context: Flaky CI tests failing 20% of runs due to third-party rate limiting. Reasoning: Fixed delay caused thundering herd effect; jitter alternative considered but simpler backoff sufficient at current scale (~100 req/min). Outcome: CI pass rate improved from 80% to 99%."
```

```bash
uvx sia-code memory add-decision "Fact: User data stored in PostgreSQL, not MongoDB. Context: Initial architecture decision during project setup. Reasoning: Relational integrity needed for user-account-subscription relationships; MongoDB considered for flexibility but schema stability prioritized. Outcome: Working well, no migration planned."
```

```bash
uvx sia-code memory add-decision "Pattern: All forms use react-hook-form + zod validation. Context: Standardized after JIRA-789 inconsistency audit. Reasoning: Formik considered but hook-based API cleaner with our component architecture; zod chosen over yup for TypeScript-first inference. Outcome: 40% reduction in form-related bugs since adoption."
```

```bash
uvx sia-code memory add-decision "Procedure: Deploy to staging via GitHub Actions. Context: Migrated from manual deploys after JIRA-456 production incident. Reasoning: Jenkins considered but GitHub Actions native to our workflow; ArgoCD considered but overkill for current scale. Outcome: Deploy time reduced from 45min manual to 8min automated."
```

```bash
uvx sia-code memory add-decision "Preference: Use kebab-case for all file names, PascalCase for components. Context: User expressed preference in session abc123. Reasoning: Consistency with existing codebase convention; prevents case-sensitivity issues on Linux vs macOS. Outcome: Adopted project-wide."
```

## Enrichment Checklist

When storing a learning, try to capture:

- [ ] **What triggered this?** (bug, feature request, review feedback, user preference)
- [ ] **What alternatives were considered?** (at least 1 rejected alternative)
- [ ] **Why this choice over alternatives?** (the key reasoning)
- [ ] **What was the outcome?** (metrics, qualitative result, or "pending")
- [ ] **What did @self-reflect flag?** (if applicable — edge cases, risks)
- [ ] **What prior memories were relevant?** (link to related decisions)

Not every entry needs all fields — but **Context + Reasoning** are the minimum enrichment over bare outcomes.

## When to Use This Format

| Trigger | Action |
|---------|--------|
| **Step 16** of Master Checklist (POST-TASK) | Store task learnings with full trace |
| **After Two-Strike resolution** | Store root cause + reasoning for the fix |
| **After discovering a codebase fact** | Store with context of how/why discovered |
| **After user expresses preference** | Store with session context |
| **After @self-reflect identifies important insight** | Store the insight with review context |
| **Before `/clear`** | Store critical context that would otherwise be lost |

## Updating Existing Memories

When a topic already has a memory entry:

```bash
# 1. Search first
uvx sia-code memory search "[topic]"

# 2. If found, update with temporal context
uvx sia-code memory add-decision "Pattern: [Updated 2026-01-29] All forms use react-hook-form + zod. Context: Original decision from JIRA-789. Updated: Added server-side validation requirement after security audit JIRA-1023. Reasoning: Client-only validation insufficient for API-direct access. Outcome: Zero form-injection incidents since update."
```

**Key:** Prefix updates with `[Updated YYYY-MM-DD]` to maintain temporal context.

## Integration with AGENTS.md

This skill is referenced in:
- **Step 16** of Master Checklist (store learnings with structured format)
- **Anti-patterns** #8 (Knowledge Loss) and #11 (Memory Stagnation)
- **Token management** (memory offload format)

**Load this skill:** `Load skill sia-code/decision-trace`

**Full sia-code reference:** `Load skill sia-code`

**Background reading:** See `context-graph-reference.md` in this directory
