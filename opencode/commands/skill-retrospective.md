# 🔍 Skill Usage Retrospective

Analyze the usage and activation patterns of a specific skill over the past {{days}} days to identify adoption gaps, usage patterns, and improvement opportunities.

## Usage Examples

```bash
# Review sia-code skill usage (7 days)
/skill-retrospective skill=sia-code days=7

# Review memvid skill usage (30 days)
/skill-retrospective skill=memvid days=30

# Full skill audit (all skills, 30 days)
/skill-retrospective skill=all days=30 scope=full

# Quick check for specific skill
/skill-retrospective skill=chrome-devtools days=7 scope=quick
```

---

## Implementation Instructions

### Phase 1: Preparation & Setup (2 minutes)

**Parse Arguments:**
- `skill` = {{skill}} (REQUIRED - skill name or "all")
- `days` = {{days}} (default: 7 if not specified)
- `scope` = {{scope}} (default: "quick" if not specified)
- `output-dir` = {{output-dir}} (default: ~/.config/opencode/retrospectives/skill-retro-{timestamp}/)

**Validations:**
1. Check that skill exists in `~/.dotfiles/opencode/skill/` or `~/.config/opencode/skill/`
2. Check that `~/.config/opencode/plans/` exists and contains .md files
3. Validate `days` is one of: 7, 14, 30, 60
4. Validate `scope` is one of: quick, full
5. Create output directory if it doesn't exist

**Error Handling:**
- If skill not found: "❌ Skill '{{skill}}' not found in opencode/skill/. Available skills: [list]"
- If plans not found: "⚠️ No plan files found in ~/.config/opencode/plans/. Cannot analyze skill usage."
- If invalid days: "❌ Invalid days={{days}}. Valid options: 7, 14, 30, 60"
- If invalid scope: "❌ Invalid scope={{scope}}. Valid options: quick, full"

**Create TODO tracking:**
```
TodoWrite: Track skill retrospective analysis
- Phase 1: Preparation & Setup
- Phase 2: Data Extraction
- Phase 3: Usage Pattern Analysis
- Phase 4: AGENTS.md Comparison
- Phase 5: Report Generation
- Phase 6: Recommendations
```

---

### Phase 2: Data Extraction (3 minutes)

**Read skill file for expected usage patterns:**

```bash
# Load skill metadata
skill_file="$HOME/.dotfiles/opencode/skill/{{skill}}/SKILL.md"
if [ ! -f "$skill_file" ]; then
  skill_file="$HOME/.config/opencode/skill/{{skill}}/SKILL.md"
fi

# Extract description, triggers, and commands
cat "$skill_file"
```

**Extract skill mentions from plan files:**

```bash
# Calculate cutoff date
cutoff_date=$(date -d "{{days}} days ago" +%Y-%m-%d)
cutoff_epoch=$(date -d "$cutoff_date" +%s)

# Find plan files modified in date range
find ~/.config/opencode/plans -name "*.md" -type f | while read f; do
  mod_date=$(stat -c %Y "$f")
  if [ "$mod_date" -ge "$cutoff_epoch" ]; then
    echo "$f"
  fi
done

# Search for skill mentions (case-insensitive)
grep -rli "{{skill}}" ~/.config/opencode/plans/*.md 2>/dev/null

# Count mentions per file
for f in $(grep -rli "{{skill}}" ~/.config/opencode/plans/*.md 2>/dev/null); do
  count=$(grep -ci "{{skill}}" "$f")
  echo "$count: $f"
done | sort -rn
```

**Extract session mentions:**

```bash
# Find session storage files with skill mentions
find ~/.local/share/opencode/storage -name "*.json" -mtime -{{days}} -type f 2>/dev/null | \
  xargs grep -l "{{skill}}" 2>/dev/null | wc -l
```

**Save extraction results:**
- `{{output-dir}}/skill_info.json` - Skill metadata and expected patterns
- `{{output-dir}}/plan_mentions.json` - Plan file mentions with counts
- `{{output-dir}}/session_mentions.json` - Session message mentions

---

### Phase 3: Usage Pattern Analysis (5 minutes)

**Analyze extraction results:**

1. **Quantitative metrics:**
   - Total mentions across all plan files
   - Mentions per plan file (distribution)
   - Mentions in session messages (actual commands executed)
   - Ratio: Documentation mentions vs Execution mentions

2. **Context categorization:**
   For each mention, categorize as:
   - **Development** (meta-usage): Developing the skill itself
   - **Documentation**: Reference or explanation
   - **Workflow**: Actual intended usage for code exploration/tasks

3. **Temporal patterns:**
   - Usage frequency over time
   - Correlation with task types (T1/T2/T3/T4)

**Generate usage statistics:**

```json
{
  "skill": "{{skill}}",
  "analysis_period": {
    "days": {{days}},
    "start_date": "{start}",
    "end_date": "{end}"
  },
  "mentions": {
    "total_plan_files": N,
    "total_mentions": M,
    "unique_plans_with_mentions": K,
    "session_executions": J
  },
  "context_breakdown": {
    "development_meta": N,
    "documentation_reference": M,
    "actual_workflow_usage": K
  },
  "adoption_rate": "X%"
}
```

---

### Phase 4: AGENTS.md Comparison (3 minutes)

**Load skill expectations from AGENTS.md:**

```bash
# Find all mentions of skill in AGENTS.md
grep -n "{{skill}}" ~/.config/opencode/AGENTS.md > {{output-dir}}/agents_md_mentions.txt

# Extract trigger patterns from skill file
# Expected patterns: "how does X work", "trace dependencies", etc.
```

**Compare actual vs expected:**

Create a table comparing AGENTS.md requirements with observed usage:

| Requirement | Expected (AGENTS.md) | Actual (observed) | Gap |
|-------------|---------------------|-------------------|-----|
| Trigger pattern 1 | "How does X work" | X times observed | Y |
| Trigger pattern 2 | "Trace dependencies" | X times observed | Y |
| Tier requirement | T2+: if unfamiliar | X times used | Y |
| Two-Strike Rule | Step 2 mandatory | X times used | Y |

**Calculate compliance score:**
```
Compliance = (Actual Workflow Usage / Total Mentions) * 100

If Compliance < 30%: LOW
If Compliance 30-70%: MEDIUM
If Compliance > 70%: HIGH
```

---

### Phase 5: Report Generation (2 minutes)

**Generate skill_retrospective_{{skill}}.md:**

```markdown
# Skill Usage Retrospective: {{skill}}

**Analysis Period:** {{days}} days ({start_date} to {end_date})
**Scope:** {{scope}}
**Generated:** {timestamp}

## Executive Summary

- **Total mentions:** N
- **Actual workflow usage:** M (X%)
- **AGENTS.md compliance:** LOW/MEDIUM/HIGH
- **Key gap:** [description]

## Usage Statistics

┌──────────────────────────────────────────────────┐
│ Metric                          │ Value          │
├─────────────────────────────────┼────────────────┤
│ Plan files with mentions        │ N              │
│ Total mentions                  │ M              │
│ Development/meta mentions       │ K (X%)         │
│ Actual workflow mentions        │ J (Y%)         │
│ Session command executions      │ I              │
│ Adoption rate                   │ Z%             │
└──────────────────────────────────────────────────┘

## Context Breakdown

| Context Type | Count | Percentage |
|--------------|-------|------------|
| Development (meta) | N | X% |
| Documentation/reference | M | Y% |
| Actual workflow usage | K | Z% |

## AGENTS.md Compliance

| Requirement | Expected | Actual | Status |
|-------------|----------|--------|--------|
| [requirement 1] | [expected] | [actual] | ✅/⚠️/❌ |
| [requirement 2] | [expected] | [actual] | ✅/⚠️/❌ |
| [requirement 3] | [expected] | [actual] | ✅/⚠️/❌ |

**Overall Compliance:** LOW/MEDIUM/HIGH

## Key Findings

1. **[Finding 1]**
   - Evidence: [cite specific plan files]
   - Impact: [description]

2. **[Finding 2]**
   - Evidence: [cite specific plan files]
   - Impact: [description]

3. **[Finding 3]**
   - Evidence: [cite specific plan files]
   - Impact: [description]

## Root Cause Analysis

**Why isn't {{skill}} being used as intended?**

1. [Cause 1]
2. [Cause 2]
3. [Cause 3]

## Recommendations

### Immediate Actions (Week 1)

1. **[Action 1]** - [description]
2. **[Action 2]** - [description]
3. **[Action 3]** - [description]

### AGENTS.md Updates

1. **[Update 1]** - [specific change needed]
   - Location: Line X
   - Rationale: [why]

2. **[Update 2]** - [specific change needed]
   - Location: Line Y
   - Rationale: [why]

### Process Improvements

1. [Process improvement 1]
2. [Process improvement 2]

## Files Analyzed

### Plan Files with Mentions
- [file 1] (N mentions)
- [file 2] (M mentions)
- ...

### Session Files
- [session 1]
- [session 2]
- ...

## Next Steps

1. User review this analysis
2. Implement approved recommendations
3. Test {{skill}} usage in next applicable task
4. Schedule follow-up retrospective in 30 days

---

**Note:** This retrospective was generated using `/skill-retrospective` command.
```

---

### Phase 6: Recommendations (2 minutes)

**Based on analysis, generate specific recommendations:**

**If adoption < 30% (LOW):**
- Add explicit checkpoint to AGENTS.md
- Create reminder in task_plan.md template
- Simplify skill activation process
- Add more usage examples

**If adoption 30-70% (MEDIUM):**
- Strengthen tier requirements
- Add anti-pattern for skipping skill
- Improve documentation clarity

**If adoption > 70% (HIGH):**
- Document success patterns
- Consider making skill mandatory for more tiers
- Share learnings with team

**Output final summary:**

```
🎯 Skill Retrospective Complete: {{skill}}

📊 Summary:
- Period: {{days}} days ({start_date} to {end_date})
- Mentions: N total, M workflow usage (X%)
- Compliance: LOW/MEDIUM/HIGH

📁 Report: {{output-dir}}/skill_retrospective_{{skill}}.md

🔴 Key Gap: [description]

💡 Top Recommendations:
1. [recommendation 1]
2. [recommendation 2]
3. [recommendation 3]

🎯 Next Steps:
1. Review {{output-dir}}/skill_retrospective_{{skill}}.md
2. Implement Week 1 actions
3. Test {{skill}} in next applicable task
4. Schedule follow-up review

📅 Next Review: {current_date + 30 days}
```

---

## Success Criteria

- ✅ Skill file read and parsed
- ✅ Plan files searched for mentions
- ✅ Context categorization complete (development/documentation/workflow)
- ✅ AGENTS.md requirements extracted and compared
- ✅ Compliance score calculated
- ✅ Recommendations generated with specific actions
- ✅ Report saved to output directory

---

## Error Recovery

**If skill file not found:**
1. Check both `~/.dotfiles/opencode/skill/` and `~/.config/opencode/skill/`
2. List available skills
3. Suggest correct skill name or exit

**If no plan files in date range:**
1. Note in report: "No activity in analysis period"
2. Suggest longer date range
3. Generate minimal report with skill info only

**If AGENTS.md mentions not found:**
1. Note in report: "Skill not mentioned in AGENTS.md"
2. Recommend adding skill to AGENTS.md
3. Skip compliance comparison section

---

## Reference

**Skill locations:**
- `~/.dotfiles/opencode/skill/` - Version-controlled skills
- `~/.config/opencode/skill/` - Local-only skills

**Data sources:**
- `~/.config/opencode/plans/` - Task plans and notes
- `~/.local/share/opencode/storage/` - Session data
- `~/.config/opencode/AGENTS.md` - Workflow requirements

**Output:**
- `~/.config/opencode/retrospectives/skill-retro-{timestamp}/`

**Date range options:** 7, 14, 30, 60 days

**Scope options:**
- `quick` - Basic stats and recommendations
- `full` - Detailed analysis with all sections

---

**Command Version:** 1.0
**Created:** 2026-01-21
**Purpose:** Analyze skill usage patterns and improve adoption
