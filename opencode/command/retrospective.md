---
>
> ⚠️ **TODO: INCOMPATIBLE WITH OPENCODE**
> 
> This command was designed for Claude CLI and references `~/.claude/history.jsonl`.
> OpenCode stores conversations differently in `~/.local/share/opencode/storage/`.
> 
> **Required changes to make this work:**
> - Rewrite to read from `~/.local/share/opencode/storage/session/` for session metadata
> - Parse messages from `~/.local/share/opencode/storage/message/` 
> - Parse parts from `~/.local/share/opencode/storage/part/`
> - Update Python extraction script accordingly
> - Update agent references: `~/.claude/agents/` → `~/.config/opencode/agent/`
> - Update doc references: `~/.claude/CLAUDE.md` → `~/.config/opencode/AGENTS.md`
>
> **Status:** Not functional until rewritten




# 🔍 Claude Code Retrospective Analysis

Analyze the last {{days}} days of Claude Code conversations to identify bottlenecks, tool utilization patterns, workflow insights, and improvement opportunities.

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

### Phase 1: Preparation & Setup (5 minutes)

**Parse Arguments:**
- `days` = {{days}} (default: 30 if not specified)
- `scope` = {{scope}} (default: "quick" if not specified)
- `validate` = {{validate}} (default: false if not specified)
- `output-dir` = {{output-dir}} (default: ~/.claude/retrospectives/retrospective-{current-timestamp}/)

**Validations:**
1. Check that `~/.claude/history.jsonl` exists and is readable
2. Validate `days` is one of: 7, 14, 30, 60, 90
3. Validate `scope` is one of: quick, full, tools-only, patterns-only
4. Create output directory if it doesn't exist
5. If `validate=true`, check that external LLM (Gemini 2.5 Pro) is available

**Error Handling:**
- If history.jsonl not found: "❌ Cannot find ~/.claude/history.jsonl. Please ensure history is enabled in Claude settings."
- If invalid days: "❌ Invalid days={{days}}. Valid options: 7, 14, 30, 60, 90"
- If invalid scope: "❌ Invalid scope={{scope}}. Valid options: quick, full, tools-only, patterns-only"
- If directory creation fails: "❌ Cannot create {{output-dir}}. Check write permissions."

**Create TODO tracking:**
```
TodoWrite: Track 8-phase retrospective analysis process
- Phase 1: Preparation & Setup
- Phase 2: Data Extraction
- Phase 3: Parallel Sub-Agent Analysis
- Phase 4: Report Generation
- Phase 5: CLAUDE.md Update Generation
- Phase 6: Memory Storage
- Phase 7: Validation (if requested)
- Phase 8: Output Summary
```

---

### Phase 2: Data Extraction (5 minutes)

**Extract Conversation History:**

1. Read `~/.claude/history.jsonl` (entire file)
2. Calculate timestamp cutoff: current_time - ({{days}} * 86400000) milliseconds
3. Filter conversations where timestamp >= cutoff
4. Extract metadata from filtered conversations:
   - Total conversation count
   - Unique projects (from "project" field)
   - Timestamp range (earliest to latest)
   - Command usage frequency (/clear, /help, etc.)
   - Tool mentions (chunkhound, graphiti, TodoWrite, external LLM)

**Generate Summary Statistics:**
```python
# Example statistics to extract
total_conversations = count of filtered entries
unique_projects = distinct project paths
date_range = "{earliest_date} to {latest_date}"
project_distribution = {project: count} sorted by count desc
tool_mentions = {
  "chunkhound": count of mentions,
  "graphiti": count of mentions,
  "TodoWrite": count of mentions,
  "external_llm": count of "gemini" or "copilot" or "codex"
}
```

**Save extraction results:**
- Save to `{{output-dir}}/summary.json`
- Save filtered conversations to `{{output-dir}}/recent_conversations.jsonl`

---

### Phase 3: Parallel Sub-Agent Analysis (15-20 minutes)

**CRITICAL: Spawn all 4 agents IN PARALLEL using haiku model for speed**

Use this exact syntax:
```
Task(subagent_type="general-purpose", model="haiku", description="...", prompt="...")
```

Send a **single message** with **4 Task tool calls** to run them in parallel.

---

#### Agent 1: Workflow Tier Adherence Analysis

**Task Description:** "Analyze workflow tier adherence"

**Prompt:**
```
Analyze workflow tier adherence in Claude Code usage over the last {{days}} days.

Read and analyze: {{output-dir}}/recent_conversations.jsonl

**Analysis Focus:**
1. Task complexity distribution:
   - Tier 1 (simple, <30 lines): estimate %
   - Tier 2 (medium, 30-100 lines): estimate %
   - Tier 3 (complex, 100+ lines, architecture): estimate %
   - Tier 4 (critical, deployment): estimate %

2. Workflow adherence:
   - TodoWrite usage for multi-step tasks
   - Plan mode usage before complex changes
   - Self-reflection mentions

3. Comparison to targets:
   - Tier 1: 40-50%, Tier 2: 30-40%, Tier 3: 15-20%, Tier 4: 5-10%

**Output:**
Save detailed analysis to: {{output-dir}}/workflow_tier_adherence_analysis.md

Include:
- Tier distribution table (actual vs target)
- Adherence score (1-10) with justification
- Top 3 workflow bottlenecks
- Specific examples of good vs poor adherence
- Recommended improvements
```

---

#### Agent 2: Tool Utilization Analysis

**Task Description:** "Analyze tool utilization patterns"

**Prompt:**
```
Analyze tool utilization patterns in Claude Code usage over the last {{days}} days.

Read and analyze: {{output-dir}}/recent_conversations.jsonl

**Analysis Focus:**
1. Chunkhound/Code Expert usage:
   - How often mentioned or used?
   - "where is X" or "how does Y work" questions answered with chunkhound?
   - Used before code changes to unfamiliar areas?

2. Graphiti memory usage:
   - How often queried at task START?
   - How often updated at task END?
   - Preferences, procedures, facts stored appropriately?

3. Sub-agent utilization:
   - Which agents used (code-expert, qa-engineer, technical-writer)?
   - Used for Tier 3+ tasks as required?
   - Parallel execution when appropriate?

4. External LLM validation:
   - Gemini/Copilot/Codex usage frequency?
   - Used for Tier 3+ tasks as required?
   - Success rate and outcomes?

**Output:**
Save detailed analysis to: {{output-dir}}/tool_utilization_analysis.md

Include:
- Tool utilization scores (1-10) for each tool
- Usage frequency statistics vs targets
- Specific examples of effective vs ineffective usage
- Missing opportunities (where tools should have been used)
- Improvement recommendations
```

---

#### Agent 3: Bottleneck Identification Analysis

**Task Description:** "Identify bottlenecks and inefficiencies"

**Prompt:**
```
Identify bottlenecks, inefficiencies, and pain points in Claude Code usage over the last {{days}} days.

Read and analyze: {{output-dir}}/recent_conversations.jsonl

**Analysis Focus:**
1. Repeated patterns suggesting missing procedures:
   - Same questions asked multiple times?
   - Similar debugging workflows repeated?
   - Common troubleshooting steps not documented?

2. Error patterns and failures:
   - Mentions of: "error", "failed", "issue", "problem", "bug"
   - What types most common?
   - Same issues recurring across projects?

3. Efficiency gaps:
   - Long back-and-forth conversations?
   - Tasks that should be automated?
   - Parallel operations not used?

4. Context switching overhead:
   - How often are projects switched?
   - Context lost when switching?
   - Memory/documentation gaps causing re-discovery?

**Output:**
Save detailed analysis to: {{output-dir}}/bottlenecks_analysis.md

Include:
- Top 5 bottlenecks with severity scores (1-10)
- Repeated pain points and frequency
- Specific conversation examples
- Efficiency improvement opportunities
- Recommended process improvements
```

---

#### Agent 4: Success Pattern Identification

**Task Description:** "Identify success patterns"

**Prompt:**
```
Identify successful patterns and best practices from Claude Code usage over the last {{days}} days.

Read and analyze: {{output-dir}}/recent_conversations.jsonl

**Analysis Focus:**
1. Successful workflows:
   - What conversations led to successful outcomes?
   - Positive indicators: "done", "completed", "working", "success", "fixed"

2. Effective tool combinations:
   - Tools used together effectively
   - Successful parallel agent usage
   - Good memory + code exploration use

3. Good practices observed:
   - Proper tier selection
   - Effective validation and review
   - Good documentation habits
   - Efficient context management

4. User satisfaction indicators:
   - Positive acknowledgments
   - Tasks completed without excessive iteration
   - Clean, efficient conversation flows

**Output:**
Save detailed analysis to: {{output-dir}}/success_patterns_analysis.md

Include:
- Top 5 success patterns with examples
- Effective tool usage combinations
- Best practices that should be formalized
- User preferences that emerged
- Patterns worth promoting in CLAUDE.md
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
   - Bottleneck severity table
   - Success patterns checklist
   - Next steps checklist

#### If scope="full" (13 documents):
All of "quick" scope PLUS:

3. **synthesis_report.md** - Comprehensive synthesis
   - Convergent findings across all 4 agents
   - Critical issues with evidence
   - Secondary bottlenecks
   - Success patterns worth reinforcing
   - Proposed CLAUDE.md updates (detailed)

4. **remediation_plan.md** - 4-week implementation plan
   - Week 1: Quick wins (2 hours, recovery 2-3 hrs/week)
   - Week 2: Medium changes (4 hours, recovery +2 hrs/week)
   - Week 3: Structural changes (8 hours, recovery +1-2 hrs/week)
   - Week 4: Validation & adjustment

5. **implementation_checklist.md** - Actionable tracking
   - Phase 1-4 checklists
   - Weekly metric tracking template
   - Success criteria definitions

6. **visual_summary.txt** - ASCII charts and graphs
   - Tool utilization bar charts
   - Tier distribution pie chart
   - Bottleneck timeline
   - Project distribution graph

7. **ANALYSIS_COMPLETE.txt** - Completion report
   - Analysis metadata (date, conversations, confidence)
   - Deliverables created
   - Key findings summary
   - FAQ section

8. **INDEX.md** - Navigation guide
   - Reading path recommendations
   - Document descriptions
   - Quick links to sections

9. **README.md** - Context and usage
   - What this analysis covers
   - How to use the documents
   - Next steps after review

10-13. **Agent-specific reports** (already created in Phase 3)

#### If scope="tools-only" (2 documents):
1. tool_utilization_analysis.md (from Agent 2)
2. quick_reference.txt (tools section only)

#### If scope="patterns-only" (3 documents):
1. workflow_tier_adherence_analysis.md (from Agent 1)
2. success_patterns_analysis.md (from Agent 4)
3. quick_reference.txt (patterns section only)

---

### Phase 5: CLAUDE.md Update Generation

**Based on all analysis findings, generate specific CLAUDE.md update recommendations.**

Create: `{{output-dir}}/CLAUDE_MD_UPDATES.md`

**Structure:**
```markdown
# CLAUDE.md Updates - Based on {{days}}-Day Retrospective

## Overview
- Analysis period: {date_range}
- Conversations analyzed: {total_conversations}
- Critical issues found: {count}
- Expected productivity recovery: {hours}/week

## Proposed Updates

### Update 1: [Title] (INSERT/REPLACE at line X)
**WHY:** {evidence from analysis}
**Current:** {current CLAUDE.md text or "none"}
**Proposed:**
```markdown
{new text to add/replace}
```

### Update 2: [Title] (INSERT/REPLACE at line Y)
...

## Implementation Checklist
- [ ] Phase 1: Critical fixes (Week 1)
- [ ] Phase 2: Tool enablement (Week 2)
- [ ] Phase 3: Pattern reinforcement (Week 3)
- [ ] Phase 4: Metrics & tracking (Week 4)

## Expected Outcomes
- Tool utilization improvements
- Bottleneck reductions
- Productivity recovery timeline
```

**Generate 5-10 specific updates addressing:**
1. Tool underutilization (make MANDATORY if <20% usage)
2. Workflow tier misclassification
3. Missing procedures (Two-Strike Debugging, Focus Blocks, etc.)
4. Success patterns to formalize
5. Bottleneck mitigation strategies

---

### Phase 6: Memory Storage (MANDATORY for scope="full")

**Store findings in Graphiti memory.**

**As PROCEDURES (entity="Procedure"):**
```python
mcp__graphiti-memory__add_memory(
  name="Monthly Retrospective Procedure - {current_date}",
  episode_body="[Full retrospective process documentation]",
  source="text",
  source_description="monthly retrospective procedure",
  group_id="default"
)
```

Store:
- Retrospective analysis process (this command's methodology)
- New debugging workflows discovered
- Testing procedures from findings
- Deployment checklists from patterns

**As PREFERENCES (entity="Preference"):**
```python
mcp__graphiti-memory__add_memory(
  name="Coding Patterns - {current_date} Retrospective",
  episode_body="[Observed coding patterns and best practices]",
  source="text",
  source_description="retrospective preferences",
  group_id="default"
)
```

Store:
- Coding patterns observed
- Testing approaches preferred
- Documentation standards found
- Tool usage best practices identified

**As FACTS (regular episodes):**
```python
mcp__graphiti-memory__add_memory(
  name="{Current_date} Retrospective Critical Findings",
  episode_body="[Detailed bottleneck metrics and tool utilization stats]",
  source="text",
  source_description="retrospective analysis facts",
  group_id="default"
)
```

Store:
- Bottleneck details with metrics
- Tool utilization: current % vs target %
- Architecture decisions/patterns observed
- Common pitfalls and gotchas discovered

**For scope="quick", "tools-only", "patterns-only":**
Store only key findings (1-2 memory entries instead of full set).

---

### Phase 7: External Validation (if validate=true)

**Run external LLM validation using Gemini 2.5 Pro.**

```bash
/usr/bin/zsh -c "source ~/.zshrc && gemini -m gemini-2.5-pro -p 'Adopt an antagonistic QA mindset. Review this retrospective analysis:

## Analysis Summary:
- {{total_conversations}} conversations analyzed over {{days}} days
- Tool underutilization: Graphiti {X}%, Chunkhound {Y}%, TodoWrite {Z}%
- Estimated productivity loss: {N} hours/week
- Proposed recovery: {M} hours/week within 4 weeks

## Key Findings:
[Paste top 3-4 critical issues from synthesis]

## Proposed Solutions:
[Paste top 3-4 CLAUDE.md updates]

Validate with skepticism:
1. Are findings supported by sufficient evidence?
2. Are severity scores justified or inflated?
3. Are time savings realistic or optimistic?
4. Could MANDATORY tools create new bottlenecks?
5. Is 4-week timeline achievable?
6. What assumptions could be wrong?
7. Are there simpler solutions overlooked?
8. What could break if changes applied?

Be brutally honest about gaps and weaknesses.'"
```

**Timeout:** 2 minutes. If timeout, note in output: "⚠️ Gemini validation timed out. Proceed with manual review."

**Save results:**
- If successful: Save to `{{output-dir}}/validation_report.md`
- If timeout/error: Note in SUMMARY.md that validation was skipped

---

### Phase 8: Output Summary & Completion

**Update TodoWrite to mark phases complete.**

**Generate completion report:**

```
🎯 Retrospective Analysis Complete!

📊 Analysis Summary:
- Period: {date_range}
- Conversations analyzed: {total_conversations}
- Projects: {unique_project_count}
- Scope: {{scope}}

📁 Documents Generated: {document_count}
Location: {{output-dir}}/

✅ Key Deliverables:
{if scope=quick}
- SUMMARY.md - Executive summary
- quick_reference.txt - 1-page visual summary

{if scope=full}
- SUMMARY.md - Executive summary
- synthesis_report.md - Comprehensive analysis (22 KB)
- CLAUDE_MD_UPDATES.md - Specific update recommendations (23 KB)
- remediation_plan.md - 4-week action plan
- implementation_checklist.md - Weekly tracking
- + 8 additional analysis documents

{if scope=tools-only}
- tool_utilization_analysis.md - Tool usage deep dive
- quick_reference.txt - Tool metrics summary

{if scope=patterns-only}
- workflow_tier_adherence_analysis.md - Tier analysis
- success_patterns_analysis.md - Best practices
- quick_reference.txt - Pattern summary

🔴 Critical Issues Found: {count}
1. {issue_1_title} (severity: {X}/10)
2. {issue_2_title} (severity: {Y}/10)
3. {issue_3_title} (severity: {Z}/10)

💰 Bottom Line:
- Productivity loss: {N} hours/week
- Recovery potential: {M} hours/week (within 4 weeks)
- ROI: 2-3 days payback

🧠 Memory Updated:
- {count} procedures stored
- {count} preferences stored
- {count} facts stored

{if validate=true and validation succeeded}
✅ External validation: PASSED (Gemini 2.5 Pro)

{if validate=true and validation failed}
⚠️ External validation: TIMEOUT or FAILED
Recommendation: Manual review of findings

🎯 Immediate Next Steps:
1. Read {{output-dir}}/SUMMARY.md (5-10 min)
2. Review {{output-dir}}/quick_reference.txt (2 min)
3. Check {{output-dir}}/CLAUDE_MD_UPDATES.md (10 min)
4. Implement Week 1 from remediation_plan.md (2 hours)
5. Set up weekly metric tracking
6. Schedule next retrospective in 30 days

📅 Next Retrospective: {current_date + 30 days}

🚀 Start now. Your future productivity depends on taking action today.
```

**Final checklist:**
- [ ] All {{document_count}} documents created
- [ ] Findings stored in Graphiti memory (if scope=full)
- [ ] CLAUDE.md updates generated
- [ ] Validation completed (if requested)
- [ ] Output summary displayed
- [ ] TodoWrite marked all phases complete

---

## Success Criteria

After running this command, verify:
- ✅ {{output-dir}}/ directory exists with all documents
- ✅ SUMMARY.md contains executive summary with critical issues
- ✅ CLAUDE_MD_UPDATES.md has specific line-by-line recommendations
- ✅ quick_reference.txt provides 1-page visual overview
- ✅ Graphiti memory updated with procedures, preferences, facts (if scope=full)
- ✅ No errors or timeouts in execution
- ✅ Next steps clearly documented

---

## Error Recovery

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
3. Recommend manual validation of CLAUDE_MD_UPDATES.md

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

**This command replaces:** Manual retrospective process in `/tmp/claude_retrospective/`

**Related files:**
- `~/.claude/CLAUDE.md` - Will receive update recommendations
- `~/.claude/history.jsonl` - Data source
- `/tmp/claude_retrospective/` - Example output from manual retrospective

**Agent specifications:**
- `~/.claude/agents/project-manager.md` - Coordination agent
- `~/.claude/agents/code-expert.md` - Code analysis agent
- `~/.claude/agents/qa-engineer.md` - Testing analysis agent
- `~/.claude/agents/technical-writer.md` - Documentation analysis agent

**Graphiti cursor rules:**
- `/home/daniel/dev/mcp/graphiti/mcp_server/cursor_rules.md` - Memory best practices

---

**Command Version:** 1.0
**Created:** 2025-11-19
**Next Update:** After first production run and feedback
