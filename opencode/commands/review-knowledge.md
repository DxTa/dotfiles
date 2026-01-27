---

> 
> TODO: INCOMPATIBLE WITH OPENCODE
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




# 📚 Review Knowledge Command

Review the current conversation to identify knowledge worth saving to your Obsidian PKM vault.

## Usage

```bash
# Current session only (default)
/review-knowledge

# Past 5 days
/review-knowledge days=5

# Past week
/review-knowledge days=7

# Past 2 weeks
/review-knowledge days=14

# Past month (max 90 days)
/review-knowledge days=30
```

---

## Implementation Instructions

### Phase 1: Conversation Analysis

**Parse Arguments:**
- `days` = {{days}} (default: null = current session only)
- If `days` provided: Validate it's a positive integer <= 90
- Calculate timestamp cutoff: current_time - (days * 86400000) milliseconds

**Auto-detect project from current working directory** (extract folder name for tagging).

**Determine conversation source:**
- If `days` parameter provided: Review historical conversations
- If no `days` parameter: Review current session (default)

**For historical conversations (days={n}):**
1. Read `~/.claude/history.jsonl` (entire file)
2. Filter conversations by timestamp >= cutoff
3. For each filtered entry:
   - Sanitize project path: replace `/` with `--`, prefix with `-`
   - Example: `/home/dxta/dev/brose` → `-home-dxta--dev--brose`
   - Locate conversation file: `~/.claude/projects/{sanitized}/agent-*.jsonl`
   - Read and extract all user/assistant message content
4. Aggregate all message content for analysis (group by conversation date)

**For current session (no days parameter):**
- Scan in-memory conversation (existing behavior)

**Scan the conversation(s) for knowledge in these categories:**

1. **Patterns** - Reusable code patterns, architectural patterns, design patterns
2. **Decisions** - Why something was done a certain way (architectural, technical)
3. **Workflows** - Debugging steps, deployment processes, troubleshooting that worked
4. **Techniques** - Tool combinations, shortcuts, efficient approaches discovered
5. **Gotchas** - Pitfalls, things that failed, common mistakes to avoid
6. **Configurations** - Settings, environment variables, configs that matter

**For each potential learning, extract:**
- Title (concise, searchable - 5-10 words)
- Type (pattern | decision | workflow | technique | gotcha | config)
- Content (detailed explanation with context)
- Tags (relevant technologies, concepts, project names)
- Source context (what prompted this learning)

**Skip items that are:**
- Trivial or obvious
- Project-specific with no reusable value
- Already captured in previous sessions
- Simple facts without insight

**Run Python extraction script in parallel:**
```bash
# Generate session ID for output coordination
session_id=$(uuidgen | cut -d'-' -f1)
output_dir="/tmp/review-knowledge-${session_id}"
mkdir -p "${output_dir}"

# Run Stage 1 extraction (Python script with parallel processing)
python3 ~/.claude/scripts/extract_knowledge.py {{days|3}} > "${output_dir}/extraction_summary.txt"

# Check extraction results
if [ ! -f "/tmp/knowledge_extraction.json" ]; then
    echo "❌ Extraction failed - no items found"
    exit 1
fi

# Count total items extracted
total_items=$(jq 'length' /tmp/knowledge_extraction.json)
echo "✓ Extracted ${total_items} raw knowledge items"
```

---

### Phase 2: Parallel Sub-Agent Knowledge Extraction

**CRITICAL: Spawn all 6 agents IN PARALLEL using haiku model for speed**

**In a SINGLE message, use Task tool 6 times:**

```typescript
// Agent 1: Pattern Extraction
Task(
  subagent_type="general-purpose",
  model="haiku",
  description="Extract code patterns",
  prompt=`You are a knowledge extraction specialist for CODE PATTERNS and ARCHITECTURAL PATTERNS.

Read the extracted knowledge from: /tmp/knowledge_extraction.json

Extract reusable CODE PATTERNS and ARCHITECTURAL PATTERNS.

**Quality Criteria (score 0-100):**
- Reusability (30pts): Would this be useful 6 months from now in ANY project?
- Clarity (25pts): Is it self-contained without context?
- Completeness (25pts): Are all details included?
- Non-trivial (20pts): Is this more than obvious?

**Skip:**
- Generic warm-ups ("I'll explore", "Ready to help")
- Tool errors (<tool_use_error>)
- System reminders (<system-reminder>)
- Project-specific only (brose, metsa, etc.)
- Duplicates

**Output Format:**
```json
[
  {
    "title": "Concise title (5-10 words)",
    "summary": "2-3 sentence explanation",
    "content": "Relevant details (3-6 sentences)",
    "tags": ["technology", "context"],
    "confidence": 85
  }
]
```

Save to: /tmp/review-knowledge-${session_id}/patterns.json

Only extract items with confidence >= 50.`
`
)

// Agent 2: Decision Extraction
Task(
  subagent_type="general-purpose",
  model="haiku",
  description="Extract technical decisions",
  prompt=`You are a knowledge extraction specialist for TECHNICAL and ARCHITECTURAL DECISIONS.

Read the extracted knowledge from: /tmp/knowledge_extraction.json

Extract DECISIONS with rationale:
- Technology choices
- Framework/library selections
- Trade-offs considered
- Alternatives evaluated

**Same quality criteria and output format as Pattern Agent.**

Save to: /tmp/review-knowledge-${session_id}/decisions.json`
`
)

// Agent 3: Workflow Extraction
Task(
  subagent_type="general-purpose",
  model="haiku",
  description="Extract workflows",
  prompt=`You are a knowledge extraction specialist for WORKFLOWS and PROCESSES.

Read the extracted knowledge from: /tmp/knowledge_extraction.json

Extract WORKFLOWS:
- Debugging steps
- Troubleshooting processes
- Deployment procedures
- Setup processes

**Focus on actionable step-by-step processes that worked.**

**Same quality criteria and output format as Pattern Agent.**

Save to: /tmp/review-knowledge-${session_id}/workflows.json
`
)

// Agent 4: Technique Extraction
Task(
  subagent_type="general-purpose",
  model="haiku",
  description="Extract techniques",
  prompt=`You are a knowledge extraction specialist for TECHNIQUES and EFFICIENT APPROACHES.

Read the extracted knowledge from: /tmp/knowledge_extraction.json

Extract TECHNIQUES:
- Tool combinations
- Keyboard shortcuts
- CLI tricks
- Efficient workflows
- Productivity tips

**Same quality criteria and output format as Pattern Agent.**

Save to: /tmp/review-knowledge-${session_id}/techniques.json
`
)

// Agent 5: Gotcha Extraction (HIGH PRIORITY - Most valuable!)
Task(
  subagent_type="general-purpose",
  model="haiku",
  description="Extract gotchas and bugs",
  prompt=`You are a knowledge extraction specialist for GOTCHAS, BUGS, and LESSONS LEARNED.

Read the extracted knowledge from: /tmp/knowledge_extraction.json

Extract GOTCHAS (highest priority):
- Bugs and their root causes
- Common mistakes to avoid
- Configuration pitfalls
- Version incompatibilities
- Platform-specific issues
- Solutions that worked

**Focus on actionable lessons learned - what went wrong and how it was fixed.**

**Same quality criteria and output format as Pattern Agent.**

Save to: /tmp/review-knowledge-${session_id}/gotchas.json
`
)

// Agent 6: Configuration Extraction
Task(
  subagent_type="general-purpose",
  model="haiku",
  description="Extract configurations",
  prompt=`You are a knowledge extraction specialist for CONFIGURATION insights.

Read the extracted knowledge from: /tmp/knowledge_extraction.json

Extract CONFIGURATION knowledge:
- Environment variables
- Build settings
- Feature flags
- Deployment options
- Tool configurations

**Same quality criteria and output format as Pattern Agent.**

Save to: /tmp/review-knowledge-${session_id}/configs.json
`
)
```

**Wait for all 6 agents to complete before proceeding.**

**After agents complete, aggregate results:**
```bash
# Combine all agent outputs
combined_items="[]"
for category in patterns decisions workflows techniques gotchas configs; do
    file="/tmp/review-knowledge-${session_id}/${category}.json"
    if [ -f "$file" ]; then
        combined_items=$(jq -s '.[]' "$file")
    fi
done

# Save combined items
echo "$combined_items" | jq '.' > /tmp/review-knowledge-${session_id}/combined_extraction.json

# Report summary
total_extracted=$(jq 'length' /tmp/review-knowledge-${session_id}/combined_extraction.json)
echo "✓ Sub-agents extracted ${total_extracted} items"
```

---

### Phase 3: Quality Validation

**Spawn Opus validation agent:**

```typescript
Task(
  subagent_type="general-purpose",
  model="opus",
  description="Validate and filter knowledge quality",
  prompt=`You are a KNOWLEDGE QUALITY VALIDATOR.

Read all extracted knowledge items from: /tmp/review-knowledge-${session_id}/combined_extraction.json

**Your Task:**

1. **Remove trivial items:**
   - Generic warm-ups ("I'll explore", "Ready to help")
   - Tool errors or system reminders
   - Obvious statements
   - Items less than 150 characters

2. **Deduplicate:** Merge similar or duplicate items

3. **Score each item 0-100 on:**
   - Reusability (30pts): Would this be useful 6 months from now?
   - Clarity (25pts): Is it clear without additional context?
   - Completeness (25pts): Are all necessary details included?
   - Non-trivial (20pts): Is this more than obvious information?

4. **Filter to items scoring >= 70**

**Output Format:**
\`\`\`json
{
  "items": [
    {
      "title": "...",
      "summary": "...",
      "content": "...",
      "tags": [...],
      "quality_score": 85,
      "category": "pattern|decision|workflow|technique|gotcha|configuration"
    }
  ],
  "validation_summary": {
    "original_count": N,
    "validated_count": M,
    "filtered_count": N-M,
    "retention_rate": X%
  }
}
\`\`\`

Save to: /tmp/review-knowledge-${session_id}/validated_knowledge.json

**Focus on QUALITY over QUANTITY. Better to have 10 excellent items than 50 mediocre ones.**
`
)
```

**Wait for validation to complete before Phase 4.**

---

### Phase 4: Present Findings

**Format findings as a numbered list:**

```
📚 Knowledge Review - {count} items found

## 1. [Title] (type: {type})
**Tags:** #{tag1}, #{tag2}
**Summary:** {2-3 sentence summary}

---

## 2. [Title] (type: {type})
...
```

**After presenting, use AskUserQuestion to ask:**

Question: "Which items would you like to capture?"
Options:
- "All items" - Capture everything
- "Select by number" - Enter specific numbers (e.g., 1, 3, 5)
- "Skip" - Don't capture anything

---

### Phase 5: Note Organization & Structure

**Automatically organize captured items by type into separate notes:**

**Note Types and Categories:**
1. **Patterns** → `Knowledge/Patterns/{date}.md`
2. **Decisions** → `Knowledge/Decisions/{date}.md`
3. **Workflows** → `Knowledge/Workflows/{date}.md`
4. **Techniques** → `Knowledge/Techniques/{date}.md`
5. **Gotchas** → `Knowledge/Gotchas/{date}.md`
6. **Configurations** → `Knowledge/Configurations/{date}.md`

**Tagging Strategy:**
- **Always include:** `#knowledge` + `#{type}` (e.g., `#pattern`, `#workflow`)
- **If project-related:** `#project/{project-name}` (e.g., `#project/brose`, `#project/claude-config`)
- **Technology tags:** `#{technology}` (e.g., `#react`, `#python`, `#typescript`, `#docker`)
- **Context tags:** `#{context}` (e.g., `#debugging`, `#deployment`, `#architecture`)

**Tag Examples:**
- Pattern in Brose project: `#knowledge #pattern #project/brose #react #frontend`
- Decision about database: `#knowledge #decision #project/myapp #postgresql #architecture`
- Workflow for debugging: `#knowledge #workflow #debugging #chrome-devtools`
- Gotcha about WSL2: `#knowledge #gotcha #wsl2 #networking`

**Note Template per Type:**
```markdown
# {Type} - {date}

## {Title}

**Tags:** {auto-generated tags above}
**Time:** {HH:MM} (for historical: **Date:** {conversation_date})
**Source:** {project path or "current session"}

{content}

---

```

---

### Phase 6: Capture to Obsidian

**Organization Strategy: Create separate notes by knowledge type**

**For current session (no days parameter):**
1. Get today's date in YYYY-MM-DD format
2. Group captured items by type (pattern, decision, workflow, technique, gotcha, configuration)
3. For each type with items:
   - Check if `Knowledge/{Type}/{date}.md` exists
   - If exists: use `mcp__obsidian__update_note` to append
   - If not exists: use `mcp__obsidian__create_note` with note template
4. Also create/update `Daily Notes/{date}.md` with summary/links to knowledge notes

**For historical conversations (days parameter provided):**

**Historical Date Handling:**
- Extract conversation timestamp from each history.jsonl entry
- Convert timestamp to YYYY-MM-DD format
- Group knowledge items by (date, type) tuple
- For each (date, type) combination:
  1. Check if `Knowledge/{Type}/{date}.md` exists
  2. Use `mcp__obsidian__read_note` to check existence
  3. Use `mcp__obsidian__update_note` or `create_note` accordingly
  4. Append with conversation date context

**Note Template Format:**
```markdown
# {Type} - {date}

## {Title}

**Tags:** #knowledge #{type} #project/{project} #{technology} #{context}
**Time:** {HH:MM}
**Source:** {project path}
**(for historical:** **Date:** {conversation_date}, **Captured:** {capture_date} **)**

{content}

---

```

**Daily Note Summary Format (links to knowledge notes):**
```markdown
## Learnings from Claude Code

**Date:** {date}
**Items captured:** {count}

### By Type:
- [Patterns]({link}) ({n} items)
- [Decisions]({link}) ({m} items)
- [Workflows]({link}) ({k} items)
- [Techniques]({link}) ({j} items)
- [Gotchas]({link}) ({i} items)
- [Configurations]({link}) ({h} items)

---
```

**Obsidian MCP Tools:**
- `mcp__obsidian__read_note` - Check if daily note exists
- `mcp__obsidian__update_note` - Append to existing note with edits parameter
- `mcp__obsidian__create_note` - Create new daily note if needed

**Example create_note usage (for new knowledge type note):**
```python
mcp__obsidian__create_note(
    path="Knowledge/Patterns/2025-12-30.md",
    content="# Patterns - 2025-12-30\n\n## React State Persistence Pattern\n\n**Tags:** #knowledge #pattern #project/brose #react #frontend\n**Time:** 14:32\n**Source:** /home/dxta/dev/brose\n\nUse Zustand persist middleware with localStorage for...\n\n---\n\n## Next pattern...\n"
)
```

**Example update_note usage (appending to existing knowledge note):**
```python
mcp__obsidian__update_note(
    path="Knowledge/Workflows/2025-12-30.md",
    edits=[{
        "mode": "insert",
        "heading": "Workflows",
        "position": "append",
        "content": "## Two-Strike Debugging Workflow\n\n**Tags:** #knowledge #workflow #debugging\n**Time:** 15:45\n**Source:** /home/dxta/.claude\n\nAfter 2 failed attempts: STOP, analyze with Code Expert...\n\n---\n"
    }]
)
```

**Example daily note summary:**
```python
mcp__obsidian__update_note(
    path="Daily Notes/2025-12-30.md",
    edits=[{
        "mode": "insert",
        "heading": "Learnings from Claude Code",
        "position": "append",
        "content": "## Learnings from Claude Code\n\n**Date:** 2025-12-30\n**Items captured:** 5\n\n### By Type:\n- [[Knowledge/Patterns/2025-12-30|Patterns]] (2 items)\n- [[Knowledge/Workflows/2025-12-30|Workflows]] (1 item)\n- [[Knowledge/Gotchas/2025-12-30|Gotchas]] (2 items)\n\n---\n"
    }]
)
```

---

### Phase 7: Confirmation & Summary

**Display capture summary:**

**For current session:**
```
✅ Knowledge Capture Complete!

📝 Captured {count} items to Obsidian:

📁 Knowledge Notes Created:
- Knowledge/Patterns/{date}.md ({n} items)
- Knowledge/Decisions/{date}.md ({m} items)
- Knowledge/Workflows/{date}.md ({k} items)
- Knowledge/Techniques/{date}.md ({j} items)
- Knowledge/Gotchas/{date}.md ({i} items)
- Knowledge/Configurations/{date}.md ({h} items)

📌 Daily Note Updated: Daily Notes/{date}.md (with summary links)

🏷️ Tags Applied: #knowledge #pattern #workflow #project/{name} ...

💡 Tip: Run /review-knowledge at the end of each session to build your knowledge base.
```

**For historical conversations (days parameter):**
```
✅ Knowledge Capture Complete!

📝 Captured {count} items from {days} days to Obsidian:

📅 Breakdown by Date:
- {date_1}: {n} items across {t} type notes
- {date_2}: {m} items across {u} type notes
...

📁 Knowledge Notes Created/Updated:
- Knowledge/Patterns/ ({dates})
- Knowledge/Decisions/ ({dates})
- Knowledge/Workflows/ ({dates})
- Knowledge/Techniques/ ({dates})
- Knowledge/Gotchas/ ({dates})
- Knowledge/Configurations/ ({dates})

📌 Daily Notes Updated: {count} daily notes with summary links

🏷️ Tags Applied: #knowledge #pattern #workflow #project/{name} ...

💡 Tip: Run /review-knowledge days=7 weekly to capture learnings from past sessions.
```

---

## Knowledge Categories Reference

| Type | Description | Example |
|------|-------------|---------|
| pattern | Reusable code/architectural pattern | "React custom hook for debounced search" |
| decision | Why something was done | "Chose SQLAlchemy over raw SQL for type safety" |
| workflow | Step-by-step process | "Debugging GraphQL N+1 queries" |
| technique | Tool usage or shortcut | "Using Serena MCP for cross-file refactoring" |
| gotcha | Pitfall or mistake | "PostgreSQL port conflict on WSL2" |
| config | Important configuration | "Vite env vars must start with VITE_" |

---

## Obsidian Vault Configuration

- **Vault Path:** `/home/dxta/Documents/Obsidian/personal`
- **Knowledge Base Structure:**
  - `Knowledge/Patterns/{date}.md` - Reusable code/architectural patterns
  - `Knowledge/Decisions/{date}.md` - Architectural/technical decisions
  - `Knowledge/Workflows/{date}.md` - Debugging steps, deployment processes
  - `Knowledge/Techniques/{date}.md` - Tool combinations, shortcuts
  - `Knowledge/Gotchas/{date}.md` - Pitfalls, mistakes to avoid
  - `Knowledge/Configurations/{date}.md` - Settings, environment variables
- **Daily Notes:** `Daily Notes/{YYYY-MM-DD}.md` - Summary with links to knowledge notes

---

## Error Handling

**For `days` parameter:**
- If `days` is not a positive integer: "❌ Invalid days={{days}}. Must be a positive integer (max 90)."
- If `days` > 90: "❌ Invalid days={{days}}. Maximum is 90 days."
- If `history.jsonl` not found: "❌ Cannot find ~/.claude/history.jsonl. Please ensure history is enabled."
- If no conversations found in date range: "ℹ️ No conversations found in the past {{days}} days."
- If project conversation files missing: "⚠️ Some conversation files could not be found. Knowledge extraction may be incomplete."

**If Obsidian MCP unavailable:**
- Output formatted markdown to console
- Suggest manual copy-paste to Obsidian

**If daily note doesn't exist:**
- Create it with minimal header: "# {date}\n\n"
- Then append learnings section

**If no learnings found:**
- Display: "No significant learnings identified in this conversation."
- Suggest: "Run this command after completing a task or solving a problem."

---

## Success Criteria

- [ ] Conversation(s) scanned for all 6 knowledge categories
- [ ] Items formatted with title, type, tags, content
- [ ] User presented with numbered list and selection options
- [ ] Selected items organized by type into separate `Knowledge/{Type}/` notes
- [ ] Proper tags applied: `#knowledge ##{type} #project/{name} #{technology}`
- [ ] Daily notes updated with summary and links to knowledge notes
- [ ] Historical conversations use conversation date for note filenames
- [ ] Summary displayed with confirmation
