---
name: pkm
description: Personal Knowledge Management via Obsidian MCP - capture learnings to daily notes and search vault
version: "1.0.0"
license: MIT
compatibility: opencode
---

# Personal Knowledge Management (PKM)

Capture learnings and search your Obsidian vault using the Obsidian MCP server.

## Overview

This skill provides personal knowledge management functionality:
- **Capture Learnings**: Save insights and learnings to today's daily note
- **Search Vault**: Find notes matching specific queries
- **Daily Notes**: Automatically append to daily notes in your vault

## Prerequisites

**Required**:
- Obsidian vault at `/home/dxta/Documents/Obsidian/personal`
- Obsidian MCP server configured in `~/.config/opencode/opencode.json`
- Obsidian Local REST API enabled in Obsidian settings

**Verify MCP Configuration**:
```bash
cat ~/.config/opencode/opencode.json | grep -A 10 obsidian
```

Should show:
```json
"obsidian": {
  "type": "local",
  "command": ["npx", "-y", "@huangyihe/obsidian-mcp"],
  "environment": {
    "OBSIDIAN_VAULT_PATH": "/home/dxta/Documents/Obsidian/personal",
    "OBSIDIAN_API_TOKEN": "{env:OBSIDIAN_API_TOKEN}",
    "OBSIDIAN_API_PORT": "27123"
  },
  "enabled": true
}
```

**Enable Obsidian Local REST API**:
1. Open Obsidian
2. Go to Settings → Third-party plugin → Community plugins
3. Browse → Install "Local REST API"
4. Settings → Options → Set API token and enable plugin
5. Set API token in environment: `export OBSIDIAN_API_TOKEN=your-token`

## Usage

### CLI Commands

```bash
# Capture a learning to today's daily note
~/.config/opencode/skills/pkm/scripts/pkm.py capture "content to capture" --tags tag1,tag2

# Search vault for notes
~/.config/opencode/skills/pkm/scripts/pkm.py search "query" --max 10

# Show help
~/.config/opencode/skills/pkm/scripts/pkm.py --help
```

### Command Examples

**Capture a learning:**
```bash
~/.config/opencode/skills/pkm/scripts/pkm.py capture "Learned about React hooks optimization" --tags react,frontend
```

**Search for notes:**
```bash
~/.config/opencode/skills/pkm/scripts/pkm.py search "obsidian"
```

**Search with max results:**
```bash
~/.config/opencode/skills/pkm/scripts/pkm.py search "project management" --max 20
```

**Capture without tags:**
```bash
~/.config/opencode/skills/pkm/scripts/pkm.py capture "Important meeting notes"
```

**Capture with multiple tags:**
```bash
~/.config/opencode/skills/pkm/scripts/pkm.py capture "Key insight about database design" --tags database,backend,sql
```

## Daily Notes Structure

Learnings are captured to daily notes at:
```
Daily Notes/YYYY-MM-DD.md
```

Each learning entry is formatted as:

```markdown
---
type: learning
source: opencode
tags: ["tag1", "tag2"]
created: 2025-01-02T10:30:00Z
---

## Learning

[Your captured content]

---
_Captured via OpenCode @ 10:30_
```

## Integration with OpenCode

The PKM skill integrates with OpenCode's MCP tools:
- Uses `obsidian_create_note` or `obsidian_update_note` MCP tools
- Requires Obsidian MCP server to be enabled in `opencode.json`

**To verify MCP is working:**
```bash
# In OpenCode, the skill will instruct AI to use:
@obsidian_search_vault(query="your query")

# Or create/update notes:
@obsidian_create_note(path="Daily Notes/2025-01-02.md", content="...")
```

## Output Format

**Capture output (instructions for AI):**
```
Please create/update note at: Daily Notes/2025-01-02.md

Content to append:
---
type: learning
source: opencode
tags: ["react", "frontend"]
created: 2025-01-02T10:30:00Z
---

## Learning

Learned about React hooks optimization

---
_Captured via OpenCode @ 10:30_

Use the obsidian MCP create_note or update_note tool.
If note exists, append this content to it.
```

**Search output (instructions for AI):**
```
Please search the Obsidian vault for: project management

Use the obsidian MCP search_vault tool with query: "project management"
Return of the top 10 results with relevant excerpts.
```

**CLI mode output (direct invocation):**
```
Note path: Daily Notes/2025-01-02.md
Content:
---
type: learning
source: opencode
tags: ["react", "frontend"]
created: 2025-01-02T10:30:00Z
---

## Learning

Learned about React hooks optimization

---
_Captured via OpenCode @ 10:30_

Use Claude Code with Obsidian MCP to create this note.
```

## Error Handling

1. **Obsidian MCP not configured**
   - **Error**: `Obsidian MCP server not found or disabled`
   - **Solution**: Ensure Obsidian MCP is enabled in `opencode.json` and `OBSIDIAN_API_TOKEN` is set

2. **Obsidian not running**
   - **Error**: `Connection refused` or `ECONNREFUSED`
   - **Solution**: Ensure Obsidian is open and Local REST API plugin is enabled

3. **Vault path not found**
   - **Error**: `Vault path does not exist`
   - **Solution**: Verify vault path in `opencode.json` matches actual location

4. **API token invalid**
   - **Error**: `Unauthorized` or `403 Forbidden`
   - **Solution**: Set correct `OBSIDIAN_API_TOKEN` in environment or `opencode.json`

## Examples

### Example 1: Capture Technical Learning

**User Request**: "I just learned about useCallback optimization"

**Usage**: The skill instructs AI to capture via MCP

**Output (what AI executes):**
```bash
@obsidian_create_note(
  path="Daily Notes/2025-01-02.md",
  content="---\ntype: learning\nsource: opencode\ntags: [\"react\", \"hooks\", \"optimization\"]\ncreated: 2025-01-02T10:30:00Z\n---\n\n## Learning\n\nLearned about useCallback optimization to prevent unnecessary re-renders.\n\n---\n_Captured via OpenCode @ 10:30_"
)
```

### Example 2: Search for Previous Notes

**User Request**: "What have I learned about databases?"

**Usage**: The skill instructs AI to search via MCP

**Output (what AI executes):**
```bash
@obsidian_search_vault(query="database", max_results=10)
```

### Example 3: CLI Direct Invocation

**User Request**: "Capture this learning: 'Database indexing improves read performance by 100x'"

**Command**:
```bash
~/.config/opencode/skills/pkm/scripts/pkm.py capture "Database indexing improves read performance by 100x" --tags database,performance,optimization
```

## Notes

- This skill is a wrapper around Obsidian MCP tools
- In OpenCode, the skill generates instructions for the AI to use MCP tools directly
- CLI mode outputs formatted content for manual note creation
- Daily notes follow the `Daily Notes/YYYY-MM-DD.md` convention
- Tags are comma-separated and will be formatted as a JSON array
- Source is always marked as `opencode` for captures via this skill
