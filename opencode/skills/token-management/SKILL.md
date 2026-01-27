---
name: token-management
description: Token budget awareness, compression strategies, and observation masking for optimal context usage
version: "1.0.0"
---

# Token Management & Compression Strategies

Comprehensive guide for managing token budget, applying tier-appropriate compression, and optimizing context window usage.

## Overview

**Context window is a public good** - every token competes with other information.

This skill provides:
- Token budget monitoring strategies
- Tier-aware compression ratios (T1: 5-10x, T2: 2-5x, T3+: minimal)
- Observation masking rules
- Semantic preservation guidelines (LLMLingua-2)
- Budget overflow protocols

---

## Token Budget Awareness (T2+)

### Built-in Monitoring

```bash
# Check current project stats
opencode stats --project ""

# Check last 7 days with model breakdown
opencode stats --days 7 --models 5

# Full breakdown
opencode stats --days 30 --models 10 --tools 10
```

### Budget Action Triggers

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

### Heuristic Triggers

| Event | Action |
|-------|--------|
| Phase boundary | Run `opencode stats`, summarize to task_plan.md |
| 3+ long tool outputs | Consider notes.md offload |
| Error investigation >2 attempts | Document state, check stats |
| Research accumulated | Transfer to notes.md |
| Before `/clear` | Run stats to log, then clear |

### Budget Overflow Protocol

When context fills up (75%+ usage):

1. **Run assessment:**
   ```bash
   opencode stats --project ""
   ```

2. **Offload research findings:**
   - Transfer to `notes.md`
   - Keep executive summary in context

3. **Summarize completed phases:**
   - Update `task_plan.md` with phase summaries
   - Archive detailed exploration notes

4. **Store key learnings:**
   ```bash
   uvx sia-code memory add-decision "..."
   ```

5. **If still overloaded:**
   - `/clear` and restore from `task_plan.md`
   - Re-establish context from plan + notes

---

## Observation Masking (Tier-Aware)

Long outputs waste tokens. Apply tier-appropriate masking (50%+ cost savings):

### Masking Rules by Tier

| Output Type | T1 (Simple) | T2 (Moderate) | T3+ (Complex) |
|-------------|-------------|---------------|---------------|
| File >100 lines | First 20 + last 10 + matches | Error context + 20 lines | Full structure |
| Command success | Exit code only | Exit code + key metrics | Exit code + full output |
| Command error | Full error + 3 lines | Full error + 5 lines | Full error section |
| Test results | Pass/fail counts | + first 3 failures | + all failures + stacks |
| API response | Schema only | Schema + sample | Full response |
| Build logs | Final 5 lines | Final 10 lines | Full error section |

### Semantic Preservation

**Always keep:**
- Function signatures
- Error lines
- Imports
- Class definitions

**Safe to compress:**
- Repeated patterns
- Verbose comments
- Whitespace

**Never discard:**
- The exact line referenced in errors

---

## Compression Strategy (Tier-Aware)

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

---

## Semantic Preservation Rules (LLMLingua-2)

### Core Principles

**Always keep:**
- Function signatures
- Imports
- Class definitions
- Error lines
- Variable declarations (in scope)

**Compress safely:**
- Repeated patterns
- Verbose comments
- Extensive whitespace
- Boilerplate code

**Never discard:**
- The exact line referenced in errors
- Function/class definitions in error stack
- Import statements causing issues

### Example: T1 Compression

**Original (100 lines):**
```python
# Long file with verbose comments
import os
import sys
import json

def process_data(data):
    """
    This function processes data by doing X, Y, and Z.
    It takes a data parameter and returns processed result.
    ... (50 lines of docstring) ...
    """
    # Implementation details...
    result = transform(data)
    return result

# ... 80 more lines ...
```

**T1 Compressed:**
```python
import os, sys, json
def process_data(data):
    result = transform(data)
    return result
# ... [80 lines compressed] ...
```

### Example: T3 Architecture Task

**Original:** Keep FULL

**Reasoning:** Architecture decisions require understanding full context, including:
- All class relationships
- Method signatures
- Inheritance hierarchies
- Complex logic flow

---

## Context Stability

### Keep Fixed

- AGENTS.md rules (this system prompt)
- Current task goal from task_plan.md
- Active phase objectives

### Summarize at Boundaries

- Completed phases (executive summary in task_plan.md)
- Exploration findings (detailed in notes.md)
- Research notes (transfer to notes.md or sia-code memory)

### Archive Aggressively

- Old tool outputs (>3 turns ago, unless actively referenced)
- Completed explorations
- Resolved error investigations

---

## Recovery Strategies

### Pre-Clear Protocol

Before running `/clear`:

1. **Document current state:**
   - Update task_plan.md with exact position
   - Log next 2 steps clearly
   - Store context-critical insights in sia-code memory

2. **Run stats:**
   ```bash
   opencode stats --project ""
   ```

3. **Archive findings:**
   - Transfer research to notes.md
   - Store learnings in sia-code memory

4. **Mark checkpoint in plan:**
   ```markdown
   ## Checkpoint: Before Clear
   - Position: [exact step]
   - Next: [next 2 steps]
   - Critical context: [key info]
   ```

### Post-Clear Recovery

After `/clear`:

1. **Read task_plan.md:**
   - Find "Checkpoint: Before Clear" or current position
   - Understand completed phases

2. **Restore TodoWrite:**
   - Initialize with remaining steps
   - Mark prior phases as completed

3. **Resume from position:**
   - Continue from exact step
   - Reference notes.md as needed

---

## Best Practices

### DO

✅ Monitor at phase boundaries (`opencode stats`)
✅ Offload research to notes.md early (not at 90%)
✅ Store learnings in sia-code memory (not in context)
✅ Match compression to tier (T1: heavy, T3: light)
✅ Keep errors at full fidelity (always)

### DON'T

❌ Wait until forced to /clear (proactive offloading)
❌ Apply same compression to all tiers (tier-aware)
❌ Compress error outputs (always full)
❌ Lose investigation progress (store first, then /clear)
❌ Forget to log stats before /clear (tracking)

---

## Quick Reference

### When to Check Stats

- ☐ Phase boundaries
- ☐ After 3+ long tool outputs
- ☐ Before /clear
- ☐ Error investigation >2 attempts

### Compression Ratios

- T1: 5-10x (aggressive)
- T2: 2-5x (moderate)
- T3: 1-2x (light)
- T4: None (full fidelity)
- Errors: FULL (always)

### Offload Targets

- Research findings → `notes.md`
- Key learnings → sia-code memory
- Completed phases → task_plan.md summary
- Old tool outputs → Archive (remove from context)

---

## Usage

Load this skill when:
- Context feels bloated (offload guidance)
- Approaching token limits (overflow protocol)
- Uncertain about compression level (tier matching)
- Before /clear (recovery protocols)
- Setting up new task (budget awareness)
