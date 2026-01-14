---
name: planning-with-files
description: Manus-style persistent markdown planning integrated with TodoWrite. Creates task_plan.md for persistence and goal tracking while using TodoWrite for live TUI visibility. Use for Tier 2+ tasks, multi-step projects, or when tracking/recovery is needed.
---

# Planning with Files + TodoWrite Integration

Work like Manus: Use persistent markdown files as your "working memory on disk" while leveraging TodoWrite for live session tracking.

## Quick Reference

| Tool | Purpose | Persistence | TUI Visible |
|------|---------|-------------|-------------|
| **TodoWrite** | Live step tracking | Session only | Yes |
| **task_plan.md** | Phases, goals, errors, learnings | Permanent | No |
| **notes.md** | Research findings | Permanent | No |

## File Locations

```
~/.config/opencode/plans/
├── {project}_{uuid}_task_plan.md    # Main plan
├── {project}_{uuid}_notes.md        # Research (Tier 3+)
└── archive/                          # Auto-archived after 30 days
```

## UUID Generation

**Every new task MUST have a unique session ID (UUID).**

Generate a short UUID at task start:
```bash
uuidgen | cut -c1-8
```

Example: `e7f3a281`

**Never use:**
- Descriptive names (e.g., `notifications_fix`)
- Dates (e.g., `20260104`)
- Mixed formats

**Always use:**
- 8-character UUID from `uuidgen`

## Tier Adaptation

| Tier | task_plan.md | notes.md | TodoWrite | Re-read |
|------|--------------|----------|-----------|---------|
| T1 | Optional | Skip | If 3+ steps | Skip |
| T2 | Recommended | If research | Mandatory | Before major decisions |
| T3+ | **Mandatory** | **Mandatory** | Mandatory | Before EVERY decision |

## Sync Protocol (Critical)

**After every TodoWrite update:**
1. Update task_plan.md Status section with current position
2. Log any errors to "Errors Encountered" section

**At phase boundaries:**
1. Mark phase [x] in task_plan.md
2. Update Status to next phase
3. Reset TodoWrite with next phase's steps

**Before /clear or session end:**
1. Ensure task_plan.md Status reflects exact position
2. Note any in-progress items

**On session resume:**
1. Read task_plan.md
2. Identify current phase from Status
3. TodoWrite: Recreate items for current phase

## task_plan.md Template

```markdown
# Task Plan: [Brief Description]

## Goal
[One sentence describing to end state]

## Phases
- [ ] Phase 1: Plan and setup
- [ ] Phase 2: Research/gather information
- [ ] Phase 3: Execute/build
- [ ] Phase 4: Review and deliver

## Key Questions
1. [Question to answer]

## Decisions Made
- [Decision]: [Rationale]

## Errors Encountered
- [Timestamp] [Error]: [Resolution]

## Learnings for Graphiti
- [Procedure/Preference/Fact]: [Learning to store after task]

## Status
**Currently in Phase X** - [What I'm doing now]
**TodoWrite sync:** [Last synced step]
```

## notes.md Template (Tier 3+)

```markdown
# Notes: [Task Brief]

## Research Findings

### Source 1: [Name]
- URL: [link]
- Key points:
  - [Finding]

### Source 2: [Name]
...

## Synthesized Insights
- [Category]: [Insight]

## Open Questions
- [Question still to resolve]
```

## Critical Rules

### 1. Dual-Layer Tracking
- TodoWrite = live visibility (TUI)
- task_plan.md = persistence + recovery

### 2. Sync After Every TodoWrite Update
Keep task_plan.md Status current. This enables recovery after context reset.

### 3. Re-read Before Decisions (Tier 2+)
Read task_plan.md before major decisions to bring goals into attention window.

### 4. Log All Errors
Every error goes in task_plan.md. TodoWrite doesn't track error history.

### 5. Bridge to Graphiti
At task end, extract learnings from task_plan.md to store in Graphiti memory.

## Recovery Scenario

```
Context reset or /clear happens...

1. Read task_plan.md
   → Status: "Currently in Phase 2 - Implementing auth middleware"
   → TodoWrite sync: "Completed JWT validation, working on user service"

2. Restore TodoWrite:
   - [x] Create auth middleware file
   - [x] Add JWT validation logic
   - [in_progress] Connect to user service
   - [pending] Add error handling

3. Continue from exact position
```

## Why This Works

| Problem | TodoWrite Alone | With task_plan.md |
|---------|-----------------|-------------------|
| Context reset | **Lost** | Recoverable |
| 50+ tool calls | Goal drift | Re-read refreshes goals |
| Error patterns | Not tracked | Logged for learning |
| Cross-session | Must restart | Resume exactly |
| Graphiti sync | Manual | "Learnings" section |
