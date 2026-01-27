---
description: Analyze and enhance a spec (from Jira or manual input) using memory-informed Socratic questioning
subtask: false
---

# Spec Analysis Command

Analyze and enhance the following spec using the **spec-analyzer** skill.

**Prerequisites:**
- If available, run `uvx sia-code memory search "[topic]"` FIRST to provide context from past decisions
- If Jira ticket ID is provided (e.g., PROJ-123), use mcp-atlassian to pull the ticket

**Process:**
1. Load spec-analyzer skill
2. Check if sia-code memory was searched (prompt if not done)
3. If Jira ticket ID: Pull via mcp-atlassian
4. If manual input: Accept user's description
5. Apply Socratic questioning to:
   - Identify gaps and ambiguities
   - Explore edge cases
   - Clarify acceptance criteria
   - Decompose into implementation phases
6. Present enhanced spec in sections
7. Store enhanced spec in notes.md

**Input:**
$ARGUMENTS

---

**Next Steps After Analysis:**
Once spec is approved:
1. Create task_plan.md with implementation phases
2. Continue with AGENTS.md MASTER CHECKLIST (get-session-info, TodoWrite, etc.)
