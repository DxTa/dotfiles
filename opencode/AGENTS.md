# Context Engineering Platform

Sub-agents, sia-code CLI code indexing with built-in memory, external LLM validation.

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

| Tier | Scope | Key Requirements | Compression | Token Hint |
|------|-------|------------------|-------------|------------|
| **T1** | <30 lines, 1 file | task_plan.md + TodoWrite MANDATORY. sia-code memory optional | 5-10x | ~8K budget |
| **T2** | 30-100 lines, 2-5 files | All T1 + **Sia-code MANDATORY** (search + memory) | 2-5x | ~16K budget |
| **T3** | 100+ lines, architecture | All T2 + notes.md + External LLM | 1-2x | ~32K budget |
| **T4** | Critical/Deployment | All T3 + rollback plan + Antagonistic QA NON-SKIPPABLE | None | ~64K budget |

### Tier 1 Requirements
Follow **MASTER CHECKLIST** with these tier-specific requirements:
- Step 3 (`get-session-info`): Execute
- Step 4 (`task_plan.md`): MANDATORY (crash recovery)
- Step 5 (`notes.md`): Optional (for research/analysis)
- Step 6 (`TodoWrite`): MANDATORY
- Step 7 (exploration): Skip for simple tasks
- Step 14 (sia-code memory): Optional (store if useful pattern)

**Lightweight path:** For <30 lines, 1 file, clear solution - skip skill-suggests, sia-code memory search, notes.md, exploration

### Tier 2 Requirements
Follow **MASTER CHECKLIST** with these tier-specific requirements:
- Step 1 (`@skill-suggests`): Execute
- Step 2 (sia-code memory search): MANDATORY (skip only if <30s, document why)
- Step 4 (`task_plan.md`): MANDATORY
- Step 5 (`notes.md`): Recommended (for research/analysis)
- Step 7 (exploration): **Sia-code recommended if ANY trigger:**
  - Unfamiliar codebase area (haven't worked in past 30 days)
  - Cross-file changes (Integration Changes pattern)
  - After Two-Strike Rule triggered
  - Task involves "how does X work" or "trace dependencies"
- Step 10 (Re-read plan): Before major decisions
- Step 11 (Self-reflection): Use @plan agent (recommended)
- Step 14 (sia-code memory): MANDATORY

### Tier 3 Requirements
Follow **MASTER CHECKLIST** with these tier-specific requirements:
- All steps MANDATORY except where noted
- Step 2 (sia-code memory search): MANDATORY - execute BEFORE exploration
- Step 5 (`notes.md`): MANDATORY
- Step 7 (exploration): **Sia-code + parallel subagents MANDATORY** before code changes
- Step 10 (Re-read plan): Before EVERY major decision
- Step 11 (Self-reflection): Use @plan agent (MANDATORY)
- Step 12 (External LLM): MANDATORY
- Step 14 (sia-code memory): MANDATORY

### Tier 4 Additions
- External LLM validation NON-SKIPPABLE
- task_plan.md must include deployment checklist phase
- task_plan.md must include rollback plan in Decisions section
- Antagonistic QA before marking complete

## MASTER CHECKLIST (All Tiers)

**PRE-TASK:**
1. ☐ `@skill-suggests [task]`
2. ☐ sia-code memory search (past decisions, patterns)
3. ☐ **Call `get-session-info` tool** → get sessionID and projectSlug
4. ☐ Create task_plan.md: `{projectSlug}_{sessionID}_task_plan.md` (MANDATORY all tiers)
5. ☐ Create notes.md: `{projectSlug}_{sessionID}_notes.md` (T1: optional, T2: recommended, T3+: mandatory)
6. ☐ TodoWrite: Initialize Phase 1 steps
7. ☐ **Exploration** (T3+: MANDATORY before code changes, T2+: if triggers hit):
   
   **7a. ☐ Sia-Code Check (T2+: recommended if triggers, T3+: MANDATORY):**
   - ☐ Trigger check: Unfamiliar code? Cross-file changes? "How does X work"? Post Two-Strike?
   - ☐ **EMBED DAEMON (MANDATORY for hybrid search):** Run `uvx sia-code embed status`
     - If not running: `uvx sia-code embed start`
     - Skip if using lexical-only search (`--regex`)
   - ☐ If YES: Run `uvx sia-code status` (check index health)
   - ☐ If YES: Run `uvx sia-code research "[architectural question]"` 
   - ☐ Document in task_plan.md:
     - **T2:** Optional: "Sia-code findings: [summary]" OR "Sia-code skipped: [reason]"
     - **T3+:** MANDATORY: Must document findings or skip reason
   
   **7b. ☐ Subagent Selection (use decision tree, not all agents):**
   - `@general` for external research, multi-step analysis, documentation lookup
   - `@explore` for file pattern matching, code search, simple name lookup
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
       <cli>uvx sia-code research</cli>
     </case>
     <case pattern="How does X work?">
       <cli>uvx sia-code research</cli>
       <note>architecture</note>
     </case>
     <case pattern="Trace dependencies of module Y">
       <cli>uvx sia-code research</cli>
     </case>
     <case pattern="Unfamiliar codebase area">
       <cli>uvx sia-code research</cli>
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
16. ☐ sia-code memory: Store learnings (T1: optional, T2+: MANDATORY)
    - What new insight did we capture?
    - Search for related memories: `uvx sia-code memory search "[topic]"`
    - If exists: Update with "Updated [date]: [new insight]"
    - If new: Use appropriate category prefix (Procedure/Fact/Pattern/Fix)
    - Store as decision: `uvx sia-code memory add-decision "..."`
17. ☐ @code-simplifier: Run on modified code (T2+: recommended, before final testing)
18. ☐ Validation: run tests, verify changes

**Mark each item ✓ as you complete it.**

## Planning vs Implementation Phase

**Planning phase** (keywords: plan, design, approach, strategy, "how should"):
- Lighter reminder: "Include sia-code memory search and TodoWrite in your plan"

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

### Sia-Code Research & Memory

**Setup (first use per project):**
```bash
# Start embed daemon (reuses if already running)
uvx sia-code embed start

# Initialize and index
uvx sia-code init && uvx sia-code index .
```

**Embed daemon status:** Run `uvx sia-code embed status` to check if daemon is active.

**Search code (lexical-first, 89.9% Recall@5):**
```bash
uvx sia-code search --regex "pattern"  # Lexical (RECOMMENDED)
uvx sia-code search "query"            # Hybrid (requires OPENAI_API_KEY)
```

**Research architecture:**
```bash
uvx sia-code research "how does X work?" --hops 3
```

**Memory - Search past learnings:**
```bash
uvx sia-code memory search "authentication"
```

**Memory - Store new learning:**
```bash
uvx sia-code memory add-decision "Procedure: How to debug X"
uvx sia-code memory add-decision "Fact: Module Y requires Z"
```

**Memory - View timeline:**
```bash
uvx sia-code memory list --type timeline
uvx sia-code memory list --type decision
```

**Memory Evolution Protocol (T2+):**

<protocol name="memory-evolution">
  <description>Guidelines for maintaining and evolving sia-code memory</description>
  
  <rule name="update-vs-create">
    <when>Same topic, new insight discovered</when>
    <action>Update existing with context noting what changed</action>
    <format>
      uvx sia-code memory add-decision \
        "Updated [YYYY-MM-DD]: [new insight]. Previous: [old insight]."
    </format>
  </rule>
  
  <rule name="link-related">
    <when>Discovery relates to existing memory</when>
    <action>Reference related topics in the decision text</action>
    <format>
      uvx sia-code memory add-decision \
        "[Learning]. Related: [topic1], [topic2]."
    </format>
  </rule>
  
  <rule name="contradictory-findings">
    <when>New finding contradicts existing memory</when>
    <action>Keep both, add context explaining conditions when each applies</action>
    <format>
      uvx sia-code memory add-decision \
        "Context-dependent: [condition1] → [behavior1]; [condition2] → [behavior2]."
    </format>
  </rule>
  
  <categories>
    <category prefix="Procedure:">Step-by-step how-to instructions</category>
    <category prefix="Fact:">Verified assertion about the codebase</category>
    <category prefix="Pattern:">Reusable approach with conditions for use</category>
    <category prefix="Fix:">Root cause → solution mapping</category>
    <category prefix="Preference:">User or project-specific choice</category>
  </categories>
</protocol>

**Memory Quality Checklist:**
- [ ] Includes context (why this was learned)
- [ ] Uses appropriate category prefix
- [ ] References related topics if applicable
- [ ] Specific enough to be actionable
- [ ] Avoids duplicating existing memory

**Check index health:**
```bash
uvx sia-code status  # Shows 🟢 Healthy / 🟡 Degraded / 🔴 Critical
```
Update index if `Health Status: Degraded` or `Critical`.

**Embed daemon (MANDATORY for hybrid search):**
```bash
uvx sia-code embed start   # Start or reuse existing daemon
uvx sia-code embed status  # Check if running
uvx sia-code embed stop    # Stop daemon (optional, auto-stops after 1hr idle)
```
> ⚠️ **HYBRID SEARCH REQUIRES DAEMON:** Before using `uvx sia-code search "query"` (without `--regex`), ensure the embed daemon is running. Lexical search (`--regex`) works without daemon.

**Skill:** Load `@sia-code` for detailed commands and workflows.

> ⚠️ **SIA-CODE CHECK:** Is this codebase unfamiliar or are you modifying cross-file integrations?
> - **FIRST:** Ensure embed daemon is running: `uvx sia-code embed start`
> - If YES and `.sia-code/` exists: Run `uvx sia-code status` first
> - If YES and `.sia-code/` doesn't exist: Run `uvx sia-code init && uvx sia-code index .`
> - If NO: Document in task_plan.md ("Familiar codebase: [reason]") for T3+ tasks

### Token Budget Awareness (T2+)

**Context window is a public good** - every token competes with other information.

**Built-in Monitoring:**
```bash
# Check current project stats
opencode stats --project ""

# Check last 7 days with model breakdown
opencode stats --days 7 --models 5

# Full breakdown
opencode stats --days 30 --models 10 --tools 10
```

<decision-tree name="budget-action-triggers">
  <case condition="phase_boundary_reached">
    <action>Run `opencode stats --project ""` to assess usage</action>
  </case>
  <case condition="long_outputs >= 3">
    <action>Consider offloading findings to notes.md</action>
  </case>
  <case condition="error_investigation > 2_attempts">
    <action>Document state, run stats, assess if /clear needed</action>
  </case>
  <case condition="before_clear">
    <action>Run stats to log usage, then proceed with /clear</action>
  </case>
</decision-tree>

**Heuristic Triggers:**
| Event | Action |
|-------|--------|
| Phase boundary | Run `opencode stats`, summarize to task_plan.md |
| 3+ long tool outputs | Consider notes.md offload |
| Error investigation >2 attempts | Document state, check stats |
| Research accumulated | Transfer to notes.md |
| Before `/clear` | Run stats to log, then clear |

**Budget Overflow Protocol:**
1. Run `opencode stats --project ""` to assess current usage
2. Offload research findings to notes.md
3. Summarize completed phases in task_plan.md
4. Store key learnings in sia-code memory
5. If still overloaded: `/clear` and restore from task_plan.md

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
| @code-simplifier | Code cleanup, simplification before testing/PR |
| @qa-engineer | Test suites, coverage review |
| @technical-writer | READMEs, API docs, root cause docs |
| @senior-fullstack-developer | Architecture, performance, large refactors |
| @backend-specialist | Backend domain tasks |
| @frontend-specialist | Frontend domain tasks |
| @devops-engineer | Infrastructure, CI/CD |
| @security-engineer | Security, auth |

**Note:** For architecture analysis, dependency mapping, and unfamiliar code exploration, use `uvx sia-code research` directly instead of a subagent.

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

<rule name="two-strike" tier="2+" blocking="true">
  <trigger>2 failed fixes → STOP. No third fix without completing ALL steps:</trigger>
  <steps>
    <step>CAPTURE: Full stack trace, console (chrome-devtools for frontend), environment</step>
    <step required="non-skippable">
      SIA-CODE: 
      - Run: `uvx sia-code research "trace error flow from [component]" --hops 3`
      - Document: Add findings summary to task_plan.md "Two-Strike Analysis" section
    </step>
    <step>SIA-CODE MEMORY: Search similar past issues (`uvx sia-code memory search "..."`)</step>
    <step tier="3+">EXTERNAL LLM: Validate approach</step>
    <step>STORE: Root cause as decision (`uvx sia-code memory add-decision "..."`)</step>
  </steps>
  <verification>Cannot proceed to third fix attempt until sia-code findings documented in task_plan.md.</verification>
  <anti-patterns>Trial-and-error console.log, CSS without DevTools, random fixes</anti-patterns>
</rule>

### Observation Masking (Tier-Aware)

Long outputs waste tokens. Apply tier-appropriate masking (50%+ cost savings):

| Output Type | T1 (Simple) | T2 (Moderate) | T3+ (Complex) |
|-------------|-------------|---------------|---------------|
| File >100 lines | First 20 + last 10 + matches | Error context + 20 lines | Full structure |
| Command success | Exit code only | Exit code + key metrics | Exit code + full output |
| Command error | Full error + 3 lines | Full error + 5 lines | Full error section |
| Test results | Pass/fail counts | + first 3 failures | + all failures + stacks |
| API response | Schema only | Schema + sample | Full response |
| Build logs | Final 5 lines | Final 10 lines | Full error section |

**Semantic Preservation:** Always keep function signatures, error lines, imports.

### Compression Strategy (Tier-Aware)

<decision-tree name="compression-strategy">
  <description>Select compression ratio based on output type and task tier</description>
  
  <case condition="output.type == 'error'">
    <action>Keep FULL - errors need complete context</action>
    <rationale>Error diagnosis requires full stack traces and surrounding code</rationale>
  </case>
  
  <case condition="output.type != 'error'">
    <branch on="task.tier">
      <case value="T1">
        <action>5-10x compression</action>
        <rules>
          <rule>Files: First 20 + last 10 + search matches</rule>
          <rule>Commands: Exit code only</rule>
          <rule>Tests: Pass/fail counts only</rule>
        </rules>
      </case>
      <case value="T2">
        <action>2-5x compression</action>
        <rules>
          <rule>Files: Error context + 20 lines around</rule>
          <rule>Commands: Exit code + key metrics</rule>
          <rule>Tests: Pass/fail + first 3 failures</rule>
        </rules>
      </case>
      <case value="T3">
        <action>1-2x compression (semantic preservation)</action>
        <rules>
          <rule>Files: Full structure, compress comments only</rule>
          <rule>Architecture: Full file required</rule>
          <rule>Tests: Full failure details + stack traces</rule>
        </rules>
      </case>
      <case value="T4">
        <action>No compression (full fidelity)</action>
        <rationale>Critical/deployment tasks need complete context</rationale>
      </case>
    </branch>
  </case>
</decision-tree>

**Semantic Preservation Rules (LLMLingua-2):**
- **Always keep:** Function signatures, imports, class definitions, error lines
- **Safe to compress:** Repeated patterns, verbose comments, whitespace
- **Never discard:** The exact line referenced in errors

### Frontend Debugging (MANDATORY Tier 2+)
Use `@chrome-devtools` for: UI/styling, JS errors, network, DOM, performance
**Triggers:** "screenshot", "debug error", "why does X show", network issues
**Process:** Capture console → DevTools inspection → Network traces → Validate fixes

### Integration Changes (Cross-File)
1. **MAP:** `uvx sia-code research` → ALL affected locations
2. **PLAN:** TodoWrite with files + integration test
3. **TEST:** Create integration test FIRST
4. **IMPLEMENT:** Make changes with test running
5. **VALIDATE:** Tests pass, no cascading errors, store pattern

## ANTI-PATTERNS

<anti-patterns>
  <pattern name="premature-clear">
    <wrong>/clear mid-investigation</wrong>
    <right>Store state in sia-code memory first</right>
    <rationale>Loses all context and investigation progress, forcing restart from scratch</rationale>
  </pattern>
  
  <pattern name="unmapped-features">
    <wrong>Add features without mapping</wrong>
    <right>uvx sia-code research → integration test</right>
    <rationale>Changes cascade unexpectedly without understanding full impact surface</rationale>
  </pattern>
  
  <pattern name="skipped-sia-code">
    <wrong>Start coding unfamiliar codebase without sia-code research</wrong>
    <right>sia-code research → understand architecture → then code</right>
    <rationale>Blind coding leads to integration bugs, missed patterns, and duplicated logic</rationale>
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
    <right>Transfer to sia-code memory</right>
    <rationale>Store as decision: uvx sia-code memory add-decision "..."</rationale>
  </pattern>
  
  <pattern name="context-pollution">
    <wrong>Stuff research in context</wrong>
    <right>Store in notes.md</right>
    <rationale>Large research dumps dilute focus; notes.md preserves findings without polluting working memory</rationale>
  </pattern>
  
  <pattern name="blind-truncation">
    <wrong>Apply same compression regardless of task tier</wrong>
    <right>Match compression ratio to tier (T1: 5-10x, T2: 2-5x, T3+: minimal)</right>
    <rationale>Architecture tasks need full context; simple edits can compress heavily</rationale>
  </pattern>
  
  <pattern name="memory-stagnation">
    <wrong>Create new memories without checking for existing related ones</wrong>
    <right>Search memory first, update existing with context if same topic</right>
    <rationale>Duplicate memories fragment knowledge; evolved memories maintain coherence</rationale>
  </pattern>
  
  <pattern name="budget-blindness">
    <wrong>Ignore context usage until auto-compact or /clear forced</wrong>
    <right>Monitor budget proactively, offload at 75%, prepare for /clear at 90%</right>
    <rationale>Proactive offloading preserves continuity; reactive clearing loses context</rationale>
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
**Sia-code:** `uvx sia-code status` (check health), `uvx sia-code search --regex "X"` (search), `uvx sia-code research "Q"` (explore)
**Sia-code embed:** `uvx sia-code embed start` (start daemon), `uvx sia-code embed status` (check), MANDATORY for hybrid search
**Sia-code memory:** `uvx sia-code memory search "X"` (find past), `uvx sia-code memory add-decision "..."` (store)
**Token monitoring:** `opencode stats --project ""` (built-in usage/cost stats)

## EFFICIENCY

### Parallel Execution Groups

**Group 1 (Task Start - run together):**
- `@skill-suggests`
- sia-code memory search (`uvx sia-code memory search "[task]"`)
- `get-session-info`

**Sequential after Group 1:**
- `task_plan.md` (requires sessionID from get-session-info)

**Conditional exploration:**
- Use agent selection decision tree (see step 7 in MASTER CHECKLIST)
- NOT always parallel - depends on task type

### Other Efficiency Patterns
- **Batch operations:** TodoWrite updates, memory storage, file reads
- **Cache decisions:** Store patterns in sia-code memory, reuse from memory
