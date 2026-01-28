---
description: Setup OpenCode configuration on a new machine
---

# Onboard OpenCode

Automated setup for configuring `~/.config/opencode` directory and plugins.

## Usage
```
/onboard-opencode
```

## What This Command Does

This command helps you configure OpenCode with:

1. **Directory structure verification** - Ensure `~/.config/opencode/` exists
2. **Commands migration** - Migrate Claude commands to OpenCode format
3. **Skills migration** - Migrate Claude skills to OpenCode format  
4. **Skill rules copy** - Copy skill activation rules
5. **Plugin setup** - Install plugin dependencies
6. **Agent configuration** - Verify agents in AGENTS.md
7. **MCP server verification** - Test configured MCP servers
8. **Testing** - Validate all components work

## Setup Steps

### 1. Verify OpenCode Installation

```bash
# Check if OpenCode CLI is available
opencode --version

# Verify config directory
ls -la ~/.config/opencode/
```

### 2. Install Plugin Dependencies

```bash
cd ~/.config/opencode
bun install
```

This installs `@opencode-ai/plugin` dependency required for TypeScript plugins.

### 3. Verify Skills

OpenCode auto-discovers skills from:
- `~/.config/opencode/skills/*/SKILL.md` (global)
- `.opencode/skills/*/SKILL.md` (project)
- `~/.config/opencode/skills/*/SKILL.md` (Claude-compatible fallback)

```bash
# List discovered skills
ls ~/.config/opencode/skills/ 2>/dev/null
```

### 4. Test Plugin Loading

After restart, plugins should auto-load. Verify:

```bash
# Check if plugins loaded
opencode --help

# Look for plugin output in logs
tail -f ~/.cache/opencode/logs/*.log
```

### 5. Verify MCP Servers

```bash
# Check opencode.json for MCP configuration
cat ~/.config/opencode/opencode.json | jq '.mcp'
```

### 6. Test Available Commands

```bash
# List all available commands (including migrated)
opencode --help
```

Expected commands include:
- `/claude-md` - Read CLAUDE.md instructions
- `/review` - Antagonistic code review
- `/push-all` - Commit and push changes
- `/convert-md-to-pdf` - Convert markdown to PDF
- `/onboard-opencode` - This command

### 7. Verify AGENTS.md

```bash
# Read agents configuration
cat ~/.config/opencode/AGENTS.md
```

Ensure it contains:
- Tiered workflow guidelines
- Tool usage patterns
- Self-monitor metrics
- Anti-patterns

## Troubleshooting

### Plugins not loading

```bash
# Check for TypeScript errors
cd ~/.config/opencode
bun run build

# Re-install dependencies
rm -rf node_modules bun.lock
bun install
```

### Skills not appearing

```bash
# Check SKILL.md frontmatter format
# Must have: name, description
# name must match directory name (kebab-case)
```

### Commands not appearing

```bash
# Verify .md files in ~/.config/opencode/command/
ls ~/.config/opencode/command/

# Check frontmatter has valid 'description'
```

## Next Steps

After completing this command:

1. Restart OpenCode to load all plugins and skills
2. Test commands from the TUI interface
3. Verify skill activation works by typing prompts with keywords
4. Test MCP servers using appropriate tools
