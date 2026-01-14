# Context Engineering Platform

Sub-agents, ChunkHound MCP code indexing, Memvid memory, external LLM validation.

**Built-in Subagents:** Use `@general` for broad research and multi-step analysis, `@explore` for fast code searches and pattern matching. See https://opencode.ai/docs/agents/#built-in for details.

## FIRST ACTION: Detect Task Type

**New task patterns:** implement, build, create, fix, debug, refactor, design, migrate, setup, add, develop, "help me", "I want to", "how do I", "can you", "new feature", "fix bug"

**Skip patterns:** follow-ups, clarifications ("yes", "no", "use TypeScript"), acknowledgments ("ok", "thanks")

**If NEW TASK (not direct command):**
1. Output "TASK DETECTED - TIER [N]"
2. Run `@skill-suggests [task]` FIRST
3. Show and execute MASTER CHECKLIST

**Shortcut:** `/skills [task description]`

### Direct Command Exception
Skip ALL planning for trivial direct commands:
- Single explicit action: "run tests", "format file X", "show me Y"
- No code changes required
- Completes in <1 minute
- User explicitly says "just do X" or gives a direct imperative

**Examples:**
<examples>
  <example>"run npm test"</example>
  <example>"what's in package.json"</example>
  <example>"show git status"</example>
  <example>"format this file"</example>
</examples>

## TIER SYSTEM

LLM auto-detects tier based on task complexity:

| Tier | Scope | Key Requirements |
|------|-------|------------------|
| **T1** | <30 lines, 1 file | task_plan.md + TodoWrite MANDATORY. Memvid optional |
| **T2** | 30-100 lines, 2-5 files | All T1 + Memvid MANDATORY |
| **T3** | 100+ lines, architecture | All T2 + notes.md + External LLM MANDATORY |
| **T4** | Critical/Deployment | All T3 + rollback plan + Antagonistic QA NON-SKIPPABLE |

### Tier 1 Requirements
Follow **MASTER CHECKLIST** with these tier-specific requirements:
- Step 3 (`get-session-info`): Execute
- Step 4 (`task_plan.md`): MANDATORY (crash recovery)
- Step 5 (`notes.md`): Optional (for research/analysis)
- Step 6 (`TodoWrite`): MANDATORY
- Step 7 (exploration): Skip for simple tasks
- Step 14 (Memvid store): Optional (store if useful pattern)

**Lightweight path:** For <30 lines, 1 file, clear solution - skip skill-suggests, Memvid search, notes.md, exploration

### Tier 2 Requirements
Follow **MASTER CHECKLIST** with these tier-specific requirements:
- Step 1 (`@skill-suggests`): Execute
- Step 2 (Memvid search): MANDATORY (skip only if <30s, document why)
- Step 4 (`task_plan.md`): MANDATORY
- Step 5 (`notes.md`): Recommended (for research/analysis)
- Step 7 (exploration): ChunkHound if unfamiliar code
- Step 10 (Re-read plan): Before major decisions
- Step 11 (Self-reflection): Use @plan agent (recommended)
- Step 14 (Memvid store): MANDATORY

### Tier 3 Requirements
Follow **MASTER CHECKLIST** with these tier-specific requirements:
- All steps MANDATORY except where noted
- Step 2 (Memvid search): MANDATORY - execute BEFORE exploration
- Step 5 (`notes.md`): MANDATORY
- Step 7 (exploration): Parallel subagents MANDATORY before code changes
- Step 10 (Re-read plan): Before EVERY major decision
- Step 11 (Self-reflection): Use @plan agent (MANDATORY)
- Step 12 (External LLM): MANDATORY
- Step 14 (Memvid store): MANDATORY

### Tier 4 Additions
- External LLM validation NON-SKIPPABLE
- task_plan.md must include deployment checklist phase
- task_plan.md must include rollback plan in Decisions section
- Antagonistic QA before marking complete

## MASTER CHECKLIST (All Tiers)

**PRE-TASK:**
1. ☐ `@skill-suggests [task]`
2. ☐ Memvid search (preferences, procedures, facts)
3. ☐ **Call `get-session-info` tool** → get sessionID and projectSlug
4. ☐ Create task_plan.md: `{projectSlug}_{sessionID}_task_plan.md` (MANDATORY all tiers)
5. ☐ Create notes.md: `{projectSlug}_{sessionID}_notes.md` (T1: optional, T2: recommended, T3+: mandatory)
6. ☐ TodoWrite: Initialize Phase 1 steps
7. ☐ **Exploration subagents** (T3+: MANDATORY before code changes, others: as needed):
   - **Task-based agent selection** (use decision tree below, not all agents)
   - `@general` for external research, multi-step analysis, documentation lookup
   - `@explore` for file pattern matching, code search, simple name lookup
   - `chunkhound_code_research` for architecture analysis, dependency mapping, unfamiliar code
   - Additional specialists based on domain:
      - @backend-specialist / @frontend-specialist (domain-specific)
      - @security-engineer (security implications)
      - @devops-engineer (infrastructure involved)
      - @qa-engineer (test strategy needed)
   - MUST complete exploration before any code changes
   - Re-run exploration if task scope changes

   **Agent Selection Decision Tree:**
   
   <decision-tree name="agent-selection">
     <case pattern="Find files matching pattern X">
       <agent>@explore</agent>
     </case>
     <case pattern="Search code for keyword Y">
       <agent>@explore</agent>
     </case>
     <case pattern="Where is feature Z defined?">
       <tool>chunkhound_code_research</tool>
     </case>
     <case pattern="How does X work?">
       <tool>chunkhound_code_research</tool>
       <note>architecture</note>
     </case>
     <case pattern="Trace dependencies of module Y">
       <tool>chunkhound_code_research</tool>
     </case>
     <case pattern="Unfamiliar codebase area">
       <tool>chunkhound_code_research</tool>
       <note>map first</note>
     </case>
     <case pattern="Research library/API/pattern">
       <agent>@general</agent>
       <note>external docs</note>
     </case>
     <case pattern="Complex multi-step analysis">
       <agent>@general</agent>
     </case>
   </decision-tree>

**DURING:**
8. ☐ TodoWrite: Update as steps complete
9. ☐ Sync task_plan.md Status after each TodoWrite change
10. ☐ Re-read task_plan.md before major decisions; confirm trimmed context is irrelevant to next 2 steps
11. ☐ Self-reflection (T1: mental check, T2: @plan agent recommended, T3+: @plan agent MANDATORY)
12. ☐ Log errors to task_plan.md

**POST-TASK:**
13. ☐ External LLM validation (T3+: MANDATORY, T4: NON-SKIPPABLE)
14. ☐ TodoWrite: Mark all completed
15. ☐ task_plan.md: Mark all phases [x]
16. ☐ Memvid: Store learnings (T1: optional, T2+: MANDATORY)
    - What new insight did we capture?
    - Should it become a curated hint in AGENTS.md?
17. ☐ Validation: run tests, verify changes

**Mark each item ✓ as you complete it.**

## Planning vs Implementation Phase

**Planning phase** (keywords: plan, design, approach, strategy, "how should"):
- Lighter reminder: "Include Memvid search and TodoWrite in your plan"

**Implementation phase** (keywords: implement, execute, proceed, make changes):
- Full checklist enforcement before any code changes

## CORE TOOLS

### MCP Reasoning Tools

Two complementary MCP servers for structured thinking:

#### code-reasoning vs shannon-thinking Decision Framework

```
Is this a problem with...
│
├─ Writing/debugging code, step-by-step reasoning?
│  └─ Use: code-reasoning ✅
│
├─ System design, architecture, or theoretical analysis?
│  └─ Use: shannon-thinking ✅
│
└─ Unclear? Ask: "Do I need to track uncertainty and assumptions?"
   ├─ Yes → shannon-thinking
   └─ No → code-reasoning
```

**Quick Reference:**

| Scenario | code-reasoning | shannon-thinking |
|----------|----------------|------------------|
| **Debugging a specific bug** | ✅ Better | ❌ |
| **Step-by-step algorithm design** | ✅ Better | ⚪ OK |
| **System architecture decisions** | ⚪ OK | ✅ Better |
| **Evaluating tradeoffs with unknowns** | ❌ | ✅ Better |
| **Root cause analysis (complex)** | ⚪ OK | ✅ Better |
| **Quick problem decomposition** | ✅ Better | ❌ Overkill |
| **Formal proof/validation needed** | ❌ | ✅ Better |
| **Tracking dependencies between decisions** | ❌ | ✅ Better |

**code-reasoning** - Best for iterative, exploratory thinking:
- Debugging code
- Algorithm design
- Refactoring decisions
- Feature implementation
- Quick exploration with branching

**shannon-thinking** - Best for structured, rigorous analysis:
- Architecture decisions
- System design with constraints
- Root cause analysis with unknowns
- Decisions requiring uncertainty quantification (0-1 confidence)
- Validation combining theory + experiments
- **5 stages:** Problem Definition → Constraints → Model → Proof/Validation → Implementation

**Practical Examples:**

| Task | Tool | Why |
|------|------|-----|
| "Fix React component not rendering" | code-reasoning | Iterative debugging |
| "Design rate limiting for API" | shannon-thinking | Constraints + model needed |
| "Implement binary search" | code-reasoning | Step-by-step algorithm |
| "Why is database slow under load?" | shannon-thinking | Root cause with unknowns |
| "Should we migrate REST to GraphQL?" | shannon-thinking | Formal tradeoff evaluation |

**Integration Strategy:** Use both in same session:
1. **shannon-thinking** for high-level design (problem definition, constraints, model)
2. **code-reasoning** for implementation (step-by-step coding, debugging)
3. **shannon-thinking** for validation (verify implementation meets model)

### ChunkHound Code Research

**When to use `chunkhound_code_research`:**
- Before implementing features - find existing patterns to reuse
- During debugging - map complete flows to find actual failure point
- Refactoring prep - understand all dependencies before making changes
- Code archaeology - learn unfamiliar systems quickly

**When to use direct search instead:**
- Quick symbol lookups → `chunkhound_search_regex`
- Known file/function → `chunkhound_search_semantic`
- Architectural questions → `chunkhound_code_research`

### Memvid Memory
**Skill:** Load `@memvid` for detailed commands and patterns.

**Setup (one-time):**
```bash
export OPENAI_API_KEY=sk-your-key-here  # Already in .mcp-credentials.json
memvid create ~/.config/opencode/memory.mv2
```

**AT START (hybrid search):**
```bash
# Search for relevant context (uses text-embedding-3-large)
memvid find ~/.config/opencode/memory.mv2 --query "[task]" --mode sem --top-k 10 -m openai-large

# Check entity state if specific entity known
memvid state ~/.config/opencode/memory.mv2 "[EntityName]"
```

**AT END - Store only genuinely new outcomes:**
```bash
# Store new learning with label
echo '{"title":"[Topic]","label":"procedure","text":"[Description of workflow]"}' | memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large

# Or for quick facts
echo "Key insight about [topic]" | memvid put ~/.config/opencode/memory.mv2 --label fact --embedding -m openai-large
```

- Skip if behavior matched documentation/expectation
- Store if solution differed from initial approach
- Store if debugging revealed non-obvious cause
- **Labels:** procedure (workflow) | preference (pattern) | fact (gotcha)

**Embedding Model:** text-embedding-3-large (3072 dimensions) via `-m openai-large`

### TodoWrite + Plan Sync
**Context stability:** Keep AGENTS.md rules and task goal fixed; summarize completed phases only at boundaries.

**First Action:** Call `get-session-info` tool to get `sessionID` and `projectSlug`
**Files (ALL tiers):**
- `~/.config/opencode/plans/{projectSlug}_{sessionID}_task_plan.md`
- `~/.config/opencode/plans/{projectSlug}_{sessionID}_notes.md`

**Archive:** `plans/archive/` (auto-archived after 30 days)
**Skill:** Load `@planning-with-files` for detailed instructions

**Sync Protocol (All Tiers):**
| Event | Action |
|-------|--------|
| Task start | Create task_plan.md → TodoWrite with Phase 1 |
| TodoWrite update | Update task_plan.md Status section |
| Error occurs | Log to task_plan.md "Errors Encountered" |
| Phase complete | Mark task_plan.md [x] → Reset TodoWrite |
| Before /clear | Ensure task_plan.md Status is current |
| Session resume | Read task_plan.md → Restore TodoWrite |

### Recovery After /clear
1. Read task_plan.md → Find current phase/position
2. Restore TodoWrite with remaining steps
3. Continue from exact position

### Plan Caching Warning
Plans may cache old versions. Use fresh prompt (don't reference old plan) to refresh perspectives.

### Sub-Agents (Tier 3+)
| Agent | Use Case |
|-------|----------|
| @general | Broad research, multi-step analysis, uncertain searches |
| @explore | Fast codebase exploration, file patterns, code search |
| @qa-engineer | Test suites, coverage review |
| @technical-writer | READMEs, API docs, root cause docs |
| @senior-fullstack-developer | Architecture, performance, large refactors |
| @backend-specialist | Backend domain tasks |
| @frontend-specialist | Frontend domain tasks |
| @devops-engineer | Infrastructure, CI/CD |
| @security-engineer | Security, auth |

**Note:** For architecture analysis, dependency mapping, and unfamiliar code exploration, use `chunkhound_code_research` tool directly instead of a subagent.

### Self-Reflection & External Validation
**Self-Reflection:**
- T1: Quick mental check
- T2: Use @plan agent (recommended)
- T3+: Use @plan agent (MANDATORY)

**External LLM (Codex or equivalent):**
- T2: Optional
- T3+: MANDATORY
- T4: NON-SKIPPABLE

**Validation approach:** Antagonistic QA mindset - validate edge cases, production risks, missing considerations, simpler approaches, wrong assumptions. **Assume broken until proven.**

**Codex Execution Command:**
```bash
~/.local/bin/codex -c model=gpt-5.1-codex exec --skip-git-repo-check "Adopt antagonistic QA mindset. Review this plan: validate edge cases, production risks, missing considerations, simpler approaches, wrong assumptions. Assume broken until proven." < ~/.config/opencode/plans/{planfile}.md
```

**Usage:** Pass the task_plan.md path via stdin redirection.

## RULES

### Two-Strike Rule (MANDATORY Tier 2+)
**2 failed fixes → STOP.** No third fix without:
1. CAPTURE: Full stack trace, console (chrome-devtools for frontend), environment
2. CHUNKHOUND: Use `chunkhound_code_research` to analyze root cause
3. MEMVID: Search similar past issues
4. EXTERNAL LLM (T3+): Validate approach
5. STORE: Root cause, fix, prevention in Memvid

**Anti-patterns:** Trial-and-error console.log, CSS without DevTools, random fixes

### Observation Masking

Long outputs waste tokens. Apply simple masking (50%+ cost savings):

| Output Type | Keep |
|-------------|------|
| File >100 lines | First 20 + last 10 + search matches |
| Command success | Exit code + key metrics |
| Command error | Full error + 5 lines context |
| Test results | Pass/fail counts + first failure |

### Frontend Debugging (MANDATORY Tier 2+)
Use `@chrome-devtools` for: UI/styling, JS errors, network, DOM, performance
**Triggers:** "screenshot", "debug error", "why does X show", network issues
**Process:** Capture console → DevTools inspection → Network traces → Validate fixes

### Integration Changes (Cross-File)
1. **MAP:** `chunkhound_code_research` → ALL affected locations
2. **PLAN:** TodoWrite with files + integration test
3. **TEST:** Create integration test FIRST
4. **IMPLEMENT:** Make changes with test running
5. **VALIDATE:** Tests pass, no cascading errors, store pattern

## ANTI-PATTERNS

<anti-patterns>
  <pattern name="premature-clear">
    <wrong>/clear mid-investigation</wrong>
    <right>Store state in Memvid first</right>
    <rationale>Loses all context and investigation progress, forcing restart from scratch</rationale>
  </pattern>
  
  <pattern name="unmapped-features">
    <wrong>Add features without mapping</wrong>
    <right>chunkhound_code_research → integration test</right>
    <rationale>Changes cascade unexpectedly without understanding full impact surface</rationale>
  </pattern>
  
  <pattern name="visual-only-debugging">
    <wrong>Screenshot-only debugging</wrong>
    <right>Full logs + chrome-devtools</right>
    <rationale>Visual symptoms don't reveal root cause; need console errors and network traces</rationale>
  </pattern>
  
  <pattern name="repeated-failing-fixes">
    <wrong>Third fix without analysis</wrong>
    <right>Two-Strike → STOP → analyze</right>
    <rationale>Random attempts waste time; systematic root cause analysis required after 2 failures</rationale>
  </pattern>
  
  <pattern name="unsynchronized-planning">
    <wrong>TodoWrite without task_plan.md</wrong>
    <right>Create both, keep synced</right>
    <rationale>TUI todos are ephemeral; task_plan.md provides crash recovery and session continuity</rationale>
  </pattern>
  
  <pattern name="context-amnesia">
    <wrong>Forget goals after tool calls</wrong>
    <right>Re-read task_plan.md</right>
    <rationale>Long tool outputs cause goal drift; task_plan.md anchors focus</rationale>
  </pattern>
  
  <pattern name="knowledge-loss">
    <wrong>Lose learnings at task end</wrong>
    <right>Transfer to Memvid</right>
    <rationale>Patterns discovered should be available for future tasks via memory retrieval</rationale>
  </pattern>
  
  <pattern name="context-pollution">
    <wrong>Stuff research in context</wrong>
    <right>Store in notes.md</right>
    <rationale>Large research dumps dilute focus; notes.md preserves findings without polluting working memory</rationale>
  </pattern>
</anti-patterns>

## QUICK REFERENCE

**File refs:** Always use `@` syntax: `@src/api.py`, `@frontend/*.vue`
**Screenshots:** `/home/dxta/Pictures/Screenshots`
**UI changes:** Validate with before/after screenshots
**Python:** venv if exists, else pkgx
**Node/npm:** Always pkgx
**WSL2:** Use `127.0.0.1` not `localhost`
**Container-first:** Use `docker exec -it` when docker-compose.yml exists
**Context7:** Use `@context7` for library docs
**Code index:** `repomix-output.xml` for AI navigation
**Project docs:** Read AGENTS.md, CLAUDE.md first

## EFFICIENCY

### Parallel Execution Groups

**Group 1 (Task Start - run together):**
- `@skill-suggests`
- Memvid search (preferences, procedures, facts)
- `get-session-info`

**Sequential after Group 1:**
- `task_plan.md` (requires sessionID from get-session-info)

**Conditional exploration:**
- Use agent selection decision tree (see step 7 in MASTER CHECKLIST)
- NOT always parallel - depends on task type

### Other Efficiency Patterns
- **Batch operations:** TodoWrite updates, memory storage, file reads
- **Cache decisions:** Store patterns in Memvid, reuse from memory
