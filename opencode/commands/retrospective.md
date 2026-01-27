# 🔍 OpenCode Retrospective Analysis

Analyze the last {{days}} days of OpenCode sessions and plan files to identify bottlenecks, tool utilization patterns, workflow insights, and improvement opportunities.

## Usage Examples

```bash
# Weekly quick check (5 minutes, 2 documents)
/retrospective days=7 scope=quick

# Monthly full analysis (25 minutes, 13 documents) - RECOMMENDED
/retrospective days=30 scope=full

# Quarterly with validation (30 minutes)
/retrospective days=90 scope=full validate=true

# Tool utilization only
/retrospective days=30 scope=tools-only

# Custom output location
/retrospective days=30 scope=quick output-dir=~/Documents/retros/
```

---

## Implementation Instructions

### Phase 1: Preparation & Setup (3 minutes)

**Parse Arguments:**
- `days` = {{days}} (default: 30 if not specified)
- `scope` = {{scope}} (default: "quick" if not specified)
- `validate` = {{validate}} (default: false if not specified)
- `output-dir` = {{output-dir}} (default: ~/.config/opencode/retrospectives/retrospective-{current-timestamp}/)

**Validations:**
1. Check that `~/.local/share/opencode/storage/session/` exists and contains subdirectories
2. Check that `~/.config/opencode/plans/` exists and contains .md files
3. Validate `days` is one of: 7, 14, 30, 60, 90
4. Validate `scope` is one of: quick, full, tools-only, patterns-only
5. Create output directory if it doesn't exist
6. If `validate=true`, check that external LLM (Gemini 2.5 Pro) is available

**Error Handling:**
- If storage not found: "❌ Cannot find ~/.local/share/opencode/storage/. No OpenCode sessions found."
- If plans not found: "⚠️ No plan files found in ~/.config/opencode/plans/. Proceeding with session data only."
- If invalid days: "❌ Invalid days={{days}}. Valid options: 7, 14, 30, 60, 90"
- If invalid scope: "❌ Invalid scope={{scope}}. Valid options: quick, full, tools-only, patterns-only"
- If directory creation fails: "❌ Cannot create {{output-dir}}. Check write permissions."

**Create TODO tracking:**
```
TodoWrite: Track 8-phase retrospective analysis process
- Phase 1: Preparation & Setup
- Phase 2: Data Extraction (Parallel)
- Phase 3: Parallel Sub-Agent Analysis
- Phase 4: Report Generation
- Phase 5: AGENTS.md Update Generation
- Phase 6: Memory Storage (Memvid)
- Phase 7: Validation (if requested)
- Phase 8: Output Summary
```

---

### Phase 2: Data Extraction (5 minutes) - PARALLEL EXECUTION

**Run TWO extraction tasks IN PARALLEL:**

#### Task A: Session Data Extraction

```bash
# Calculate cutoff timestamp (days ago in milliseconds)
cutoff_ts=$(($(date +%s%3N) - ({{days}} * 86400000)))

# Extract session data
output_dir="{{output-dir}}"
mkdir -p "$output_dir"

# 1. List all projects
projects=$(ls ~/.local/share/opencode/storage/project/*.json 2>/dev/null)

# 2. For each project, find sessions within date range
sessions_data="[]"
for proj_file in $projects; do
  proj_id=$(basename "$proj_file" .json)
  proj_dir=$(jq -r '.worktree' "$proj_file")
  
  # Find sessions for this project
  session_dir="$HOME/.local/share/opencode/storage/session/$proj_id"
  if [ -d "$session_dir" ]; then
    for session_file in "$session_dir"/*.json; do
      created=$(jq -r '.time.created' "$session_file")
      if [ "$created" -ge "$cutoff_ts" ]; then
        # Extract session metadata
        session_data=$(jq -c '{
          id: .id,
          title: .title,
          directory: .directory,
          created: .time.created,
          updated: .time.updated,
          summary: .summary
        }' "$session_file")
        sessions_data=$(echo "$sessions_data" | jq --argjson s "$session_data" '. += [$s]')
      fi
    done
  fi
done

# 3. For each session, extract message metadata
for session_id in $(echo "$sessions_data" | jq -r '.[].id'); do
  msg_dir="$HOME/.local/share/opencode/storage/message/$session_id"
  if [ -d "$msg_dir" ]; then
    # Count messages by role and agent
    for msg_file in "$msg_dir"/*.json; do
      agent=$(jq -r '.agent // "unknown"' "$msg_file")
      model=$(jq -r '.model.modelID // "unknown"' "$msg_file")
      # Aggregate stats...
    done
  fi
done

# 4. Sample parts for tool mentions
tool_mentions='{
  "sia-code": 0,
  "memvid": 0,
  "TodoWrite": 0,
  "mcp_task": 0,
  "external_llm": 0
}'

# Save session extraction
echo "$sessions_data" > "$output_dir/recent_sessions.json"
```

#### Task B: Plan File Extraction (PARALLEL)

```bash
# Extract plan file data
plans_dir="$HOME/.config/opencode/plans"
output_dir="{{output-dir}}"

# Calculate cutoff date
cutoff_date=$(date -d "{{days}} days ago" +%Y-%m-%d)

# Find recent plan files by modification time
plans_data="[]"
for plan_file in "$plans_dir"/*_task_plan.md; do
  mod_date=$(stat -c %Y "$plan_file")
  cutoff_epoch=$(date -d "$cutoff_date" +%s)
  
  if [ "$mod_date" -ge "$cutoff_epoch" ]; then
    # Parse plan file metadata
    session=$(grep -m1 "^\*\*Session" "$plan_file" | sed 's/.*: //')
    project=$(grep -m1 "^\*\*Project" "$plan_file" | sed 's/.*: //')
    tier=$(grep -m1 "^\*\*Tier" "$plan_file" | sed 's/.*: //' | grep -oP 'T[1-4]')
    created=$(grep -m1 "^\*\*Created" "$plan_file" | sed 's/.*: //')
    
    # Count phase completion
    total_phases=$(grep -c "^### Phase" "$plan_file" || echo 0)
    completed_phases=$(grep -c "\[x\]" "$plan_file" || echo 0)
    pending_items=$(grep -c "\[ \]" "$plan_file" || echo 0)
    
    # Check for key sections
    has_errors=$(grep -q "## Errors Encountered" "$plan_file" && echo true || echo false)
    has_findings=$(grep -q "## Key Findings" "$plan_file" && echo true || echo false)
    has_decisions=$(grep -q "## Decisions" "$plan_file" && echo true || echo false)
    
    plan_data=$(jq -nc --arg f "$plan_file" --arg s "$session" --arg p "$project" \
      --arg t "$tier" --arg c "$created" --argjson tp "$total_phases" \
      --argjson cp "$completed_phases" --argjson pi "$pending_items" \
      --argjson he "$has_errors" --argjson hf "$has_findings" --argjson hd "$has_decisions" \
      '{file: $f, session: $s, project: $p, tier: $t, created: $c, 
        total_phases: $tp, completed_phases: $cp, pending_items: $pi,
        has_errors: $he, has_findings: $hf, has_decisions: $hd}')
    
    plans_data=$(echo "$plans_data" | jq --argjson p "$plan_data" '. += [$p]')
  fi
done

# Extract notes files similarly
for notes_file in "$plans_dir"/*_notes.md; do
  # Similar extraction for notes...
done

# Save plan extraction
echo "$plans_data" > "$output_dir/recent_plans.json"
```

**Generate Combined Summary Statistics:**

After both extractions complete, merge into `summary.json`:

```json
{
  "analysis_period": {
    "days": {{days}},
    "start_date": "{start}",
    "end_date": "{end}"
  },
  "sessions": {
    "total": N,
    "unique_projects": ["proj1", "proj2"],
    "agent_distribution": {
      "plan": N,
      "code": M,
      "ultrathink": K
    },
    "model_usage": {
      "claude-opus-4-5": N,
      "claude-sonnet-4-5": M
    }
  },
  "plans": {
    "total_task_plans": 55,
    "total_notes": 19,
    "tier_distribution": {
      "T1": N,
      "T2": M,
      "T3": K,
      "T4": J
    },
    "phase_completion_rate": "85%",
    "plans_with_errors": N,
    "plans_with_findings": M,
    "plans_with_decisions": K
  },
  "tool_mentions": {
    "sia-code": N,
    "memvid": M,
    "TodoWrite": K,
    "mcp_task": J,
    "external_llm": I
  }
}
```

**Save extraction results:**
- `{{output-dir}}/summary.json` - Combined statistics
- `{{output-dir}}/recent_sessions.json` - Session metadata
- `{{output-dir}}/recent_plans.json` - Plan file metadata

---

### Phase 3: Parallel Sub-Agent Analysis (15-20 minutes)

**CRITICAL: Spawn all 4 agents IN PARALLEL using `mcp_task` tool**

Send a **single message** with **4 Task tool calls** to run them in parallel.

---

#### Agent 1: Workflow Tier Adherence Analysis

**Task tool call:**
```
mcp_task(
  subagent_type="general",
  description="Analyze workflow tier adherence",
  prompt="..."
)
```

**Prompt:**
```
Analyze workflow tier adherence in OpenCode usage over the last {{days}} days.

Read and analyze BOTH files:
1. {{output-dir}}/recent_sessions.json - Session metadata
2. {{output-dir}}/recent_plans.json - Plan file metadata (CRITICAL for tier data)

**Analysis Focus:**

1. Task complexity distribution (from plan files):
   - Count tier field from task_plan.md files
   - Tier 1 (simple, <30 lines): count and %
   - Tier 2 (medium, 30-100 lines): count and %
   - Tier 3 (complex, 100+ lines, architecture): count and %
   - Tier 4 (critical, deployment): count and %
   - Compare to targets: T1: 40-50%, T2: 30-40%, T3: 15-20%, T4: 5-10%

2. Workflow adherence (from plan files):
   - Phase completion rate (count [x] vs [ ])
   - Plans with "Key Findings" sections
   - Plans with "Decisions" sections
   - Plans with "Errors Encountered" sections

3. Agent mode usage (from sessions):
   - Plan vs Code agent distribution
   - Ultrathink usage for complex tasks
   - Agent switches per session

4. TodoWrite integration:
   - Sessions with todo files in storage/todo/
   - Correlation with plan files

**Output:**
Save detailed analysis to: {{output-dir}}/workflow_tier_adherence_analysis.md

Include:
- Tier distribution table (actual vs target) - FROM PLAN FILES
- Phase completion metrics
- Adherence score (1-10) with justification
- Top 3 workflow bottlenecks
- Specific examples of good vs poor adherence (cite plan file names)
- Recommended improvements
```

---

#### Agent 2: Tool Utilization Analysis

**Prompt:**
```
Analyze tool utilization patterns in OpenCode usage over the last {{days}} days.

Read and analyze:
1. {{output-dir}}/recent_sessions.json - Session metadata
2. {{output-dir}}/recent_plans.json - Plan file metadata
3. {{output-dir}}/summary.json - Tool mention counts

**Analysis Focus:**

1. sia-code usage (replaced chunkhound):
   - Mentions in session parts
   - Used before unfamiliar code changes?
   - "uvx --with openai sia-code research" patterns

2. Memvid memory usage (replaced Graphiti):
   - "memvid find" at task START?
   - "memvid put" at task END?
   - Labels used: procedure, preference, fact

3. Sub-agent utilization:
   - mcp_task usage in sessions
   - Which subagent_types used?
   - Parallel execution (multiple Task calls)?

4. External LLM validation:
   - Gemini/Codex mentions
   - Used for T3+ tasks as required?

5. Plan file creation:
   - task_plan.md created for multi-step tasks?
   - notes.md created for research?

**Output:**
Save detailed analysis to: {{output-dir}}/tool_utilization_analysis.md

Include:
- Tool utilization scores (1-10) for each tool
- Usage frequency statistics vs AGENTS.md requirements
- Specific examples of effective vs ineffective usage
- Missing opportunities (where tools SHOULD have been used per tier)
- Improvement recommendations aligned with AGENTS.md
```

---

#### Agent 3: Bottleneck Identification Analysis

**Prompt:**
```
Identify bottlenecks, inefficiencies, and pain points in OpenCode usage over the last {{days}} days.

Read and analyze:
1. {{output-dir}}/recent_sessions.json - Session metadata
2. {{output-dir}}/recent_plans.json - Plan file metadata

**Analysis Focus:**

1. Errors from plan files (HIGH VALUE):
   - Read "Errors Encountered" sections from task_plan.md files
   - Categorize error types
   - Recurring issues across projects?

2. Incomplete phases:
   - Plans with [ ] pending items
   - Abandoned plans (old modification date, incomplete phases)
   - Blocked workflows

3. Repeated patterns suggesting missing procedures:
   - Similar plan titles/goals repeated?
   - Same errors occurring multiple times?

4. Efficiency gaps:
   - Low phase completion rates
   - High pending item counts
   - Long time between created and updated

5. Context switching overhead:
   - Project variety in sessions
   - Session duration patterns
   - Plan creation vs session ratio

**Output:**
Save detailed analysis to: {{output-dir}}/bottlenecks_analysis.md

Include:
- Top 5 bottlenecks with severity scores (1-10)
- Error patterns from "Errors Encountered" sections (CITE FILES)
- Incomplete plan analysis
- Specific plan file examples
- Efficiency improvement opportunities
- Recommended process improvements
```

---

#### Agent 4: Success Pattern Identification

**Prompt:**
```
Identify successful patterns and best practices from OpenCode usage over the last {{days}} days.

Read and analyze:
1. {{output-dir}}/recent_sessions.json - Session metadata
2. {{output-dir}}/recent_plans.json - Plan file metadata

**Analysis Focus:**

1. Successful workflows from plan files (HIGH VALUE):
   - Plans with high phase completion (all [x])
   - Plans with "Key Findings" sections
   - Plans with documented "Decisions"

2. Best practices observed:
   - Proper tier selection
   - Good plan file structure
   - Effective notes.md usage
   - Complete phase tracking

3. Effective patterns:
   - Projects with multiple successful plans
   - Good agent mode selection (plan vs code)
   - Parallel execution usage

4. Knowledge capture:
   - Plans that documented learnings
   - Decisions with clear rationale
   - Reusable patterns identified

**Output:**
Save detailed analysis to: {{output-dir}}/success_patterns_analysis.md

Include:
- Top 5 success patterns with examples (CITE FILES)
- "Key Findings" that should become AGENTS.md rules
- "Decisions" that should become procedures
- Best practices that should be formalized
- Patterns worth promoting in AGENTS.md
```

---

### Phase 4: Report Generation (based on scope)

**Wait for all 4 sub-agents to complete before proceeding.**

**Read results from:**
- {{output-dir}}/workflow_tier_adherence_analysis.md
- {{output-dir}}/tool_utilization_analysis.md
- {{output-dir}}/bottlenecks_analysis.md
- {{output-dir}}/success_patterns_analysis.md

**Generate additional documents based on scope:**

#### If scope="quick" (2 documents):
1. **SUMMARY.md** - Executive summary
   - The Paradox (what's working vs broken)
   - Critical Issues (top 3-4)
   - Bottom Line (productivity loss and recovery potential)
   - Immediate next steps (Week 1 actions)

2. **quick_reference.txt** - 1-page visual summary
   - Tool utilization scores (ASCII bar charts)
   - Tier distribution from plan files
   - Bottleneck severity table
   - Success patterns checklist
   - Next steps checklist

#### If scope="full" (13 documents):
All of "quick" scope PLUS:

3. **synthesis_report.md** - Comprehensive synthesis
4. **remediation_plan.md** - 4-week implementation plan
5. **implementation_checklist.md** - Actionable tracking
6. **visual_summary.txt** - ASCII charts and graphs
7. **ANALYSIS_COMPLETE.txt** - Completion report
8. **INDEX.md** - Navigation guide
9. **README.md** - Context and usage
10-13. **Agent-specific reports** (already created in Phase 3)

#### If scope="tools-only" (2 documents):
1. tool_utilization_analysis.md (from Agent 2)
2. quick_reference.txt (tools section only)

#### If scope="patterns-only" (3 documents):
1. workflow_tier_adherence_analysis.md (from Agent 1)
2. success_patterns_analysis.md (from Agent 4)
3. quick_reference.txt (patterns section only)

---

### Phase 5: AGENTS.md Update Generation

**Based on all analysis findings, generate specific AGENTS.md update recommendations.**

Create: `{{output-dir}}/AGENTS_MD_UPDATES.md`

**Structure:**
```markdown
# AGENTS.md Updates - Based on {{days}}-Day Retrospective

## Overview
- Analysis period: {date_range}
- Sessions analyzed: {total_sessions}
- Plan files analyzed: {total_plans}
- Critical issues found: {count}
- Expected productivity recovery: {hours}/week

## Proposed Updates

### Update 1: [Title] (INSERT/REPLACE at line X)
**WHY:** {evidence from analysis - cite plan files}
**Current:** {current AGENTS.md text or "none"}
**Proposed:**
```markdown
{new text to add/replace}
```

## Implementation Checklist
- [ ] Phase 1: Critical fixes (Week 1)
- [ ] Phase 2: Tool enablement (Week 2)
- [ ] Phase 3: Pattern reinforcement (Week 3)
- [ ] Phase 4: Metrics & tracking (Week 4)
```

---

### Phase 6: Memory Storage (Memvid)

**Store findings using Memvid (replaces Graphiti).**

```bash
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh

# Store as PROCEDURE
echo '{"title":"Monthly Retrospective - {{date}}","label":"procedure","text":"Retrospective analysis process: 1) Extract sessions from storage/, 2) Extract plans from plans/, 3) Run 4 parallel agents, 4) Generate reports, 5) Update AGENTS.md, 6) Store to Memvid"}' | \
  memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large

# Store as PREFERENCE (from success patterns)
echo '{"title":"Coding Patterns - {{date}} Retrospective","label":"preference","text":"[Top patterns from success_patterns_analysis.md]"}' | \
  memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large

# Store as FACT (metrics and bottlenecks)
echo '{"title":"Retrospective Findings - {{date}}","label":"fact","text":"Sessions: N, Plans: M, Tier distribution: T1=X%, T2=Y%, T3=Z%, T4=W%. Top bottleneck: [from bottlenecks_analysis.md]. Tool utilization: sia-code=X/10, memvid=Y/10"}' | \
  memvid put ~/.config/opencode/memory.mv2 --embedding -m openai-large
```

**For scope="quick", "tools-only", "patterns-only":**
Store only key findings (1 memory entry with summary).

---

### Phase 7: External Validation (if validate=true)

**Run external LLM validation using Gemini 2.5 Pro.**

```bash
source ~/.zshrc && gemini -m gemini-2.5-pro -p 'Adopt an antagonistic QA mindset. Review this retrospective analysis:

## Analysis Summary:
- Sessions analyzed: {N} over {{days}} days
- Plan files analyzed: {M}
- Tier distribution: T1={X}%, T2={Y}%, T3={Z}%, T4={W}%
- Tool utilization scores: sia-code={A}/10, memvid={B}/10, TodoWrite={C}/10

## Key Findings:
[Top 3-4 critical issues from synthesis]

## Proposed Solutions:
[Top 3-4 AGENTS.md updates]

Validate with skepticism:
1. Are findings supported by sufficient evidence?
2. Are tier percentages realistic given plan file count?
3. Are tool scores justified?
4. What assumptions could be wrong?
5. Are there simpler solutions overlooked?

Be brutally honest about gaps.'
```

**Timeout:** 2 minutes

---

### Phase 8: Output Summary & Completion

**Generate completion report:**

```
🎯 OpenCode Retrospective Analysis Complete!

📊 Analysis Summary:
- Period: {date_range}
- Sessions analyzed: {total_sessions}
- Plan files analyzed: {total_plans} (task_plans: {N}, notes: {M})
- Projects: {unique_project_count}
- Scope: {{scope}}

📁 Documents Generated: {document_count}
Location: {{output-dir}}/

📈 Tier Distribution (from plan files):
- T1: {N}% (target: 40-50%)
- T2: {M}% (target: 30-40%)
- T3: {K}% (target: 15-20%)
- T4: {J}% (target: 5-10%)

🔧 Tool Utilization Scores:
- sia-code: {X}/10
- Memvid: {Y}/10
- TodoWrite: {Z}/10
- Sub-agents: {W}/10

🔴 Critical Issues Found: {count}
1. {issue_1} (from plan: {file})
2. {issue_2} (from plan: {file})

🧠 Memory Updated (Memvid):
- {count} entries stored

🎯 Immediate Next Steps:
1. Read {{output-dir}}/SUMMARY.md (5 min)
2. Review AGENTS_MD_UPDATES.md (10 min)
3. Implement Week 1 changes (2 hours)
4. Schedule next retrospective

📅 Next Retrospective: {current_date + 30 days}
```

---

## Success Criteria

- ✅ Both data sources extracted (sessions + plans)
- ✅ 4 sub-agents completed in parallel
- ✅ Tier distribution from plan files
- ✅ AGENTS.md updates cite specific plan files
- ✅ Memvid memory updated
- ✅ No errors or timeouts

---

## Error Recovery

**If Phase 2 (extraction) fails:**
1. Check which data source completed
2. Continue with available data
3. Note in SUMMARY.md which source was incomplete

**If Phase 3 (sub-agents) times out:**
1. Check which agents completed successfully
2. Generate reports from available data
3. Note in SUMMARY.md which analyses are incomplete
4. Recommend re-running with smaller `days` value

**If memory storage fails:**
1. Note in SUMMARY.md that memory update failed
2. Continue with document generation
3. Provide manual memory storage instructions

**If validation fails:**
1. Note timeout in output summary
2. Continue with document generation
3. Recommend manual validation of AGENTS_MD_UPDATES.md

---

## Monthly Usage Recommendations

**Recommended Schedule:**
- **Monthly full analysis:** First Monday of each month
- **Weekly quick check:** Every Monday morning
- **Quarterly deep dive:** First Monday of Jan/Apr/Jul/Oct

**Monthly workflow:**
1. Run `/retrospective days=30 scope=full`
2. Review SUMMARY.md and quick_reference.txt (10 min)
3. Apply Week 1 of remediation_plan.md (2 hours)
4. Track metrics weekly
5. Run next retrospective in 30 days
6. Compare month-over-month improvement

---

## Reference Documentation

**Data Sources:**
- `~/.local/share/opencode/storage/` - Session/message/part data
- `~/.config/opencode/plans/` - Task plans and notes

**Output Location:**
- `~/.config/opencode/retrospectives/retrospective-{timestamp}/`

**Configuration:**
- `~/.config/opencode/AGENTS.md` - Will receive update recommendations
- `~/.config/opencode/memory.mv2` - Memvid memory storage

**Agent Definitions:**
- `~/.config/opencode/agent/project-manager.md`
- `~/.config/opencode/agent/qa-engineer.md`
- `~/.config/opencode/agent/technical-writer.md`

**Skills:**
- `@memvid` - Memory storage patterns
- `@planning-with-files` - Plan file format

---

**Command Version:** 2.0
**Created:** 2026-01-16
**Rewritten for:** OpenCode (from Claude CLI)
