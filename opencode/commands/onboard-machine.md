---
description: Automated setup script for configuring opencode on a new machine after cloning the repository
---

# Onboard New Machine

Automated setup script for configuring `~/.config/opencode` on a new machine after cloning the repository.

---

## Usage

```bash
cd ~/.config/opencode
/onboard-machine
```

Or execute specific phases manually by copying bash blocks below.

---

## What This Command Does

This command automates the setup of your `~/.config/opencode` environment through 13 phases:

1. **Prerequisites Check** - Verify claude CLI, repo location, environment
2. **File Permissions** - Set executable permissions on scripts
3. **Path Configuration** - Update settings.json with correct paths
4. **Credentials Setup** - Create credential templates
5. **MCP Server Installation** - Guide through MCP server setup
5.5. **Obsidian MCP & PKM Setup** - Configure Personal Knowledge Management
5.7. **Session-End PKM Hook** - Optional PKM review prompts at session end
6. **Plugin Installation** - Install plugins from marketplaces
6.5. **Skill Rules Setup** - Check local skills and generate activation triggers
7. **ccline Setup** - Configure status line binary
8. **Serena MCP Setup** - Guide through code analysis setup
9. **Additional Setup** - Python venv, Node.js verification
10. **Verification & Testing** - Test all components
11. **Final Checklist** - Manual steps remaining

---

## Phase 1: Prerequisites Check

```bash
#!/bin/bash

echo "========================================"
echo "Phase 1: Prerequisites Check"
echo "========================================"

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo "✗ ERROR: Claude CLI not found"
    echo "  Install from: https://docs.anthropic.com/claude/docs/claude-cli"
    exit 1
fi
echo "✓ Claude CLI installed: $(claude --version)"

# Check if we're in the right directory
if [ ! -f "$HOME/.config/opencode/CLAUDE.md" ]; then
    echo "✗ ERROR: Not in opencode directory or CLAUDE.md missing"
    echo "  Expected: $HOME/.config/opencode/CLAUDE.md"
    echo "  Please run: cd ~/.config/opencode"
    exit 1
fi
echo "✓ Repository cloned to: $HOME/.config/opencode"

# Detect environment
echo ""
echo "Environment Detection:"
echo "  OS: $(uname -s)"
echo "  Shell: $SHELL"
echo "  User: $USER"
echo "  Home: $HOME"

# Check if WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "  WSL: Yes"
    WSL_DETECTED=true
else
    echo "  WSL: No"
    WSL_DETECTED=false
fi

# Check Python
if command -v python3 &> /dev/null; then
    echo "✓ Python3: $(python3 --version)"
else
    echo "⚠ WARNING: Python3 not found (optional for some features)"
fi

# Check Node.js
if command -v node &> /dev/null; then
    echo "✓ Node.js: $(node --version)"
else
    echo "⚠ WARNING: Node.js not found (needed for ccline and some MCP servers)"
fi

# Check nvm
if [ -d "$HOME/.nvm" ]; then
    echo "✓ nvm detected at: $HOME/.nvm"
    NVM_PATH=$(find $HOME/.nvm/versions/node -type f -name "node" | head -1 | sed 's|/bin/node||')
    echo "  Latest Node: $NVM_PATH"
else
    echo "⚠ WARNING: nvm not found (optional)"
    NVM_PATH=""
fi

echo ""
echo "✓ Phase 1 Complete"
echo ""
```

---

## Phase 2: File Permissions

```bash
#!/bin/bash

echo "========================================"
echo "Phase 2: File Permissions"
echo "========================================"

cd ~/.config/opencode

# Set executable permissions on hooks
if [ -d "hooks" ]; then
    chmod +x hooks/*.sh 2>/dev/null
    chmod +x hooks/*.ts 2>/dev/null
    echo "✓ Hooks scripts made executable"
fi

# Set executable permissions on scripts
if [ -d "scripts" ]; then
    chmod +x scripts/*.sh 2>/dev/null
    chmod +x scripts/*.py 2>/dev/null
    echo "✓ Utility scripts made executable"
fi

# Set executable permissions on hook scripts
chmod +x hooks/scripts/auto-approve-mcp.py 2>/dev/null
chmod +x hooks/scripts/notification-wrapper.sh 2>/dev/null
chmod +x hooks/scripts/check-focus.ps1 2>/dev/null
echo "✓ Hook scripts made executable"

# Verify Python3 for auto-approve-mcp.py
if [ -f "hooks/scripts/auto-approve-mcp.py" ]; then
    if command -v python3 &> /dev/null; then
        echo "✓ Python3 available for auto-approve-mcp.py"
    else
        echo "⚠ WARNING: auto-approve-mcp.py requires Python3"
    fi
fi

echo ""
echo "✓ Phase 2 Complete"
echo ""
```

---

## Phase 3: Path Configuration

```bash
#!/bin/bash

echo "========================================"
echo "Phase 3: Path Configuration"
echo "========================================"

cd ~/.config/opencode

# Backup settings.json
if [ -f "settings.json" ]; then
    BACKUP_FILE="settings.json.backup-$(date +%Y%m%d-%H%M%S)"
    cp settings.json "$BACKUP_FILE"
    echo "✓ Backed up settings.json to: $BACKUP_FILE"
fi

# Replace /home/daniel with actual $HOME
if [ -f "settings.json" ]; then
    sed -i "s|/home/daniel|$HOME|g" settings.json
    echo "✓ Updated home directory paths in settings.json"
fi

# Update nvm Node.js path
if [ -n "$NVM_PATH" ]; then
    sed -i "s|/home/daniel/.nvm/versions/node/v[0-9.]*|$NVM_PATH|g" settings.json
    echo "✓ Updated nvm Node.js path to: $NVM_PATH"
else
    echo "⚠ WARNING: Could not auto-detect nvm path"
    echo "  Manual update needed in settings.json for ccline path"
fi

# Create settings.local.json template if it doesn't exist
if [ ! -f "settings.local.json" ]; then
    cat > settings.local.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(cat:*)",
      "Bash(test:*)"
    ]
  },
  "outputStyle": "Explanatory"
}
EOF
    chmod 600 settings.local.json
    echo "✓ Created settings.local.json template"
else
    echo "✓ settings.local.json already exists"
fi

echo ""
echo "✓ Phase 3 Complete"
echo ""
```

---

## Phase 4: Credentials Setup

```bash
#!/bin/bash

echo "========================================"
echo "Phase 4: Credentials Setup"
echo "========================================"

cd ~/.config/opencode

# 1. Claude AI OAuth credentials (.credentials.json)
echo "Setting up Claude AI OAuth credentials..."
if [ -f ".credentials.json" ]; then
    echo "✓ .credentials.json already exists (preserving)"
else
    echo "⚠ .credentials.json not found (managed by Claude CLI)"
fi

# 2. MCP Server credentials (.mcp-credentials.json)
echo ""
echo "Setting up MCP server credentials..."
if [ -f ".mcp-credentials.json" ]; then
    echo "✓ .mcp-credentials.json already exists (preserving)"
else
    # Create from template if template exists
    if [ -f ".mcp-credentials.json.template" ]; then
        cp .mcp-credentials.json.template .mcp-credentials.json
        chmod 600 .mcp-credentials.json
        echo "✓ Created .mcp-credentials.json from template"
        echo ""
        echo "⚠ IMPORTANT: Update .mcp-credentials.json with your actual credentials:"
        echo "  - Slack bot token (xoxb-...) and team ID"
        echo "  - AWS credentials (if using aws-cost-ops)"
        echo "  - Neo4j password (for graphiti-memory)"
        echo "  - OpenAI API key (for graphiti-memory)"
        echo "  - GitHub token (if needed)"
    else
        echo "⚠ WARNING: .mcp-credentials.json.template not found"
        echo "  You'll need to create .mcp-credentials.json manually"
    fi
fi

# 3. Add credential loader to shell RC file
echo ""
echo "Setting up shell integration..."
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    SOURCE_LINE="source ~/.config/opencode/scripts/load-mcp-credentials.sh"
    if grep -q "load-mcp-credentials.sh" "$SHELL_RC" 2>/dev/null; then
        echo "✓ Credential loader already in $SHELL_RC"
    else
        echo "" >> "$SHELL_RC"
        echo "# Load MCP credentials for Claude Code" >> "$SHELL_RC"
        echo "$SOURCE_LINE" >> "$SHELL_RC"
        echo "✓ Added credential loader to $SHELL_RC"
        echo ""
        echo "⚠ NOTE: Run 'source $SHELL_RC' or restart your shell to load credentials"
    fi
else
    echo "⚠ WARNING: Could not detect shell (zsh/bash)"
    echo "  Manually add this to your shell RC file:"
    echo "  source ~/.config/opencode/scripts/load-mcp-credentials.sh"
fi

echo ""
echo "✓ Phase 4 Complete"
echo ""
```

---

## Phase 5: MCP Server Installation

```bash
#!/bin/bash

echo "========================================"
echo "Phase 5: MCP Server Installation"
echo "========================================"

# Check if mcp.json already exists
MCP_CONFIG="$HOME/.config/claude/mcp.json"

if [ -f "$MCP_CONFIG" ]; then
    echo "⚠ WARNING: $MCP_CONFIG already exists"
    echo "  You may need to merge the following configuration manually"
    echo ""
fi

echo "MCP Servers to Install:"
echo "  1. graphiti-memory - Knowledge graph memory (requires Neo4j)"
echo "  2. context7 - Library documentation"
echo "  3. obsidian - Personal Knowledge Management vault"
echo "  4. slack - Slack integration"
echo "  5. aws-cost-ops - AWS cost analysis (3 sub-servers)"
echo "  6. code-reasoning - Reasoning tool"
echo "  7. serena-mcp - Language server code analysis (setup in Phase 8)"
echo ""

cat << 'EOF'
Create or update ~/.config/claude/mcp.json with:

IMPORTANT: Environment variables (${VAR_NAME}) are loaded from ~/.config/opencode/.mcp-credentials.json
via the load-mcp-credentials.sh script sourced in your shell RC file.

{
  "mcpServers": {
    "graphiti-memory": {
      "command": "uvx",
      "args": [
        "--from",
        "graphiti-mcp-server",
        "graphiti-mcp-server"
      ],
      "env": {
        "NEO4J_URI": "${NEO4J_URI}",
        "NEO4J_USER": "${NEO4J_USER}",
        "NEO4J_PASSWORD": "${NEO4J_PASSWORD}",
        "OPENAI_API_KEY": "${OPENAI_API_KEY}",
        "GRAPHITI_DEFAULT_GROUP_ID": "default"
      }
    },
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp"
      ]
    },
    "slack": {
      "command": "npx",
      "args": [
        "@modelcontextprotocol/server-slack"
      ],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
      }
    },
    "code-reasoning": {
      "command": "npx",
      "args": [
        "@thinkstack/code-reasoning-mcp"
      ]
    },
    "plugin:aws-cost-ops:pricing": {
      "enabled": true
    },
    "plugin:aws-cost-ops:costexp": {
      "enabled": true,
      "env": {
        "AWS_REGION": "${AWS_REGION}",
        "AWS_PROFILE": "${AWS_PROFILE}"
      }
    },
    "plugin:aws-cost-ops:cw": {
      "enabled": true,
      "env": {
        "AWS_REGION": "${AWS_REGION}"
      }
    }
  }
}

MCP Server Setup Steps:

1. graphiti-memory:
   - Install Neo4j: docker run -d --name neo4j -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password neo4j:latest
   - Test server: uvx --from graphiti-mcp-server graphiti-mcp-server --help
   - Update NEO4J_PASSWORD and OPENAI_API_KEY in mcp.json

2. context7:
   - Auto-installs via npx on first use
   - No additional setup needed

3. slack:
   - Create Slack app: https://api.slack.com/apps
   - Add scopes: channels:history, channels:read, chat:write, users:read
   - Install to workspace
   - Copy bot token (xoxb-*) and team ID
   - Update SLACK_BOT_TOKEN and SLACK_TEAM_ID in mcp.json

4. aws-cost-ops:
   - Configure AWS CLI: aws configure
   - Or set AWS_PROFILE in mcp.json
   - Update AWS_REGION as needed

5. code-reasoning:
   - Auto-installs via npx on first use
   - No additional setup needed

EOF

echo ""
echo "✓ Phase 5 Complete (manual configuration required)"
echo ""
```

---

## Phase 5.5: Obsidian MCP & PKM Setup

```bash
#!/bin/bash

echo "========================================"
echo "Phase 5.5: Obsidian MCP & PKM Setup"
echo "========================================"

echo "Obsidian MCP enables Personal Knowledge Management via vault integration"
echo ""

# Check if Obsidian is installed
if command -v obsidian &> /dev/null; then
    echo "✓ Obsidian app found"
else
    echo "⚠ Obsidian app not found (optional - can use vault without app)"
fi

# Check vault path
VAULT_PATH="$HOME/Documents/Obsidian/personal"
if [ -d "$VAULT_PATH" ]; then
    echo "✓ Obsidian vault found: $VAULT_PATH"
else
    echo "⚠ WARNING: Vault not found at: $VAULT_PATH"
    echo "  Create vault or update path in skills/pkm"
fi

# Check PKM skill
if [ -f "$HOME/.config/opencode/skills/pkm" ]; then
    echo "✓ PKM skill exists"
    chmod +x "$HOME/.config/opencode/skills/pkm"
else
    echo "⚠ WARNING: PKM skill not found at ~/.config/opencode/skills/pkm"
fi

cat << 'EOF'

Add Obsidian MCP to ~/.config/claude/mcp.json:

{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": [
        "-y",
        "@huangyihe/obsidian-mcp"
      ],
      "env": {
        "OBSIDIAN_VAULT_PATH": "${OBSIDIAN_VAULT_PATH}"
      }
    }
  }
}

Environment Variables (~/.config/opencode/.mcp-credentials.json):
  OBSIDIAN_VAULT_PATH=/home/YOUR_USERNAME/Documents/Obsidian/personal

Setup Steps:
1. Update OBSIDIAN_VAULT_PATH in .mcp-credentials.json
2. Add obsidian server to ~/.config/claude/mcp.json
3. Test: claude chat → "Search my Obsidian vault for test"

EOF

echo ""
echo "✓ Phase 5.5 Complete"
echo ""
```

---

## Phase 5.7: Session-End PKM Hook Setup

```bash
#!/bin/bash

echo "========================================"
echo "Phase 5.7: Session-End PKM Hook Setup"
echo "========================================"

echo "The Stop hook triggers when Claude sessions end."
echo "You can optionally add PKM review prompts to capture learnings."
echo ""

# Current Stop hook
echo "Current Stop hook:"
echo "  File: ~/.config/opencode/hooks/scripts/notify-stop.sh"
echo "  Purpose: Sends desktop notification when session ends"
echo ""

cat << 'EOF'
Optional: Add PKM Review Prompt to Stop Hook

Create or modify ~/.config/opencode/hooks/scripts/notify-stop.sh:

#!/bin/bash
# Claude Code Hook: Stop Event Notification + Optional PKM Prompt

# Desktop notification
if [ -n "$TMUX" ]; then
    SESSION_NAME=$(tmux display-message -p '#S')
    notify-send 'Claude' "Ready for input in session: $SESSION_NAME" -t 5000 -u normal
else
    notify-send 'Claude' 'Ready for your next prompt' -t 5000 -u normal
fi

# Optional: PKM review prompt (uncomment to enable)
# echo ""
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "  Session Ended - PKM Review Opportunity"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo ""
# echo "Capture learnings from this session?"
# echo "  Say: 'Capture this: [what you learned]'"
# echo ""
# echo "Review past sessions?"
# echo "  Run: /retrospective"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

Configuration:
- The Stop hook is already configured in settings.json
- Edit notify-stop.sh to add/remove PKM prompts
- Set environment variable to enable/disable:
  export PKM_REVIEW_PROMPT=true  # Add to ~/.bashrc or ~/.zshrc

EOF

# Check if hook is executable
if [ -f "$HOME/.config/opencode/hooks/scripts/notify-stop.sh" ]; then
    if [ -x "$HOME/.config/opencode/hooks/scripts/notify-stop.sh" ]; then
        echo "✓ notify-stop.sh is executable"
    else
        echo "⚠ notify-stop.sh exists but not executable"
        echo "  Run: chmod +x ~/.config/opencode/hooks/scripts/notify-stop.sh"
    fi
else
    echo "⚠ notify-stop.sh not found"
fi

echo ""
echo "✓ Phase 5.7 Complete"
echo ""
```

---

## Phase 6: Plugin Installation

```bash
#!/bin/bash

echo "========================================"
echo "Phase 6: Plugin Installation"
echo "========================================"

echo "Adding plugin marketplaces..."

# Add marketplaces
claude plugins add claude-code-plugins-plus 2>/dev/null || echo "  Marketplace already added: claude-code-plugins-plus"
claude plugins add anthropic-agent-skills 2>/dev/null || echo "  Marketplace already added: anthropic-agent-skills"
claude plugins add aws-skills 2>/dev/null || echo "  Marketplace already added: aws-skills"

echo ""
echo "Installing plugins..."

# Install plugins from claude-code-plugins-plus
PLUGINS_PLUS=(
    "chaos-engineering-toolkit"
    "performance-test-suite"
    "test-coverage-analyzer"
    "security-test-scanner"
    "security-pro-pack"
    "fullstack-starter-pack"
    "ci-cd-pipeline-builder"
    "infrastructure-as-code-generator"
    "ansible-playbook-creator"
)

for plugin in "${PLUGINS_PLUS[@]}"; do
    echo "  Installing: $plugin@claude-code-plugins-plus"
    claude plugins install "$plugin@claude-code-plugins-plus" 2>&1 | grep -v "already installed" || true
done

# Install from anthropic-agent-skills
echo "  Installing: example-skills@anthropic-agent-skills"
claude plugins install "example-skills@anthropic-agent-skills" 2>&1 | grep -v "already installed" || true

# Install from aws-skills
echo "  Installing: aws-cost-ops@aws-skills"
claude plugins install "aws-cost-ops@aws-skills" 2>&1 | grep -v "already installed" || true

echo ""
echo "Verifying installed plugins..."
claude plugins list

echo ""
echo "✓ Phase 6 Complete"
echo ""
```

---

## Phase 6.5: Skill Rules Setup

```bash
#!/bin/bash

echo "========================================"
echo "Phase 6.5: Skill Rules Setup"
echo "========================================"

cd ~/.config/opencode

# Check if skill-rules.json exists
SKILL_RULES="$HOME/.config/opencode/skills/skill-rules.json"

if [ -f "$SKILL_RULES" ]; then
    echo "✓ skill-rules.json exists"

    # Count skills in file
    SKILL_COUNT=$(python3 -c "import json; print(len(json.load(open('$SKILL_RULES')).get('skills', {})))" 2>/dev/null || echo "0")
    echo "  Current skill rules: $SKILL_COUNT"
else
    echo "⚠ skill-rules.json not found"
    echo "  Will need to generate skill rules"
fi

# Count local skills
echo ""
echo "Local skills in ~/.config/opencode/skills/:"
LOCAL_SKILL_COUNT=0
for dir in $(find ~/.config/opencode/skills -mindepth 2 -maxdepth 4 -type d); do
    if [ -f "${dir}SKILL.md" ]; then
        SKILL_NAME=$(basename "$dir")
        echo "  ✓ $SKILL_NAME"
        ((LOCAL_SKILL_COUNT++))
    fi
done
echo "  Total: $LOCAL_SKILL_COUNT local skills"

# Count enabled plugins
echo ""
echo "Enabled marketplace plugins:"
if [ -f "$HOME/.config/opencode/settings.json" ]; then
    python3 << 'PYEOF'
import json
import os
settings_path = os.path.expanduser("~/.config/opencode/settings.json")
with open(settings_path) as f:
    settings = json.load(f)
    plugins = settings.get("enabledPlugins", {})
    enabled = [k for k, v in plugins.items() if v]
    for p in enabled:
        print(f"  ✓ {p}")
    print(f"  Total: {len(enabled)} plugins")
PYEOF
fi

# Recommendation
echo ""
if [ ! -f "$SKILL_RULES" ] || [ "$SKILL_COUNT" = "0" ]; then
    echo "⚠ IMPORTANT: Run /update-skill-rules to generate skill activation triggers"
    echo "  This enables automatic skill suggestions based on your prompts"
else
    echo "✓ skill-rules.json is configured"
    echo "  Run /update-skill-rules if you've added new skills or plugins"
fi

echo ""
echo "✓ Phase 6.5 Complete"
echo ""
```

---

## Phase 7: ccline Setup

```bash
#!/bin/bash

echo "========================================"
echo "Phase 7: ccline Setup"
echo "========================================"

cd ~/.config/opencode

# Check if ccline binary exists
if [ -f "ccline/ccline" ]; then
    echo "✓ ccline binary found"

    # Create symlink in nvm bin if nvm exists
    if [ -n "$NVM_PATH" ] && [ -d "$NVM_PATH/bin" ]; then
        ln -sf "$HOME/.config/opencode/ccline/ccline" "$NVM_PATH/bin/ccline"
        echo "✓ Created symlink: $NVM_PATH/bin/ccline"
    else
        echo "⚠ WARNING: Could not create symlink (nvm path not found)"
        echo "  Add to PATH manually: export PATH=\"$HOME/.config/opencode/ccline:\$PATH\""
    fi
else
    echo "⚠ WARNING: ccline binary not found at ~/.config/opencode/ccline/ccline"
    echo ""
    echo "To build ccline:"
    echo "  cd ~/.config/opencode/ccline"
    echo "  npm install"
    echo "  npm run build"
    echo ""
    echo "Or download pre-built binary (if available)"
fi

# Verify ccline is accessible
if command -v ccline &> /dev/null; then
    echo "✓ ccline is in PATH"
else
    echo "⚠ WARNING: ccline not in PATH"
fi

echo ""
echo "✓ Phase 7 Complete"
echo ""
```

---

## Phase 8: Serena MCP Setup

```bash
#!/bin/bash

echo "========================================"
echo "Phase 8: Serena MCP Setup"
echo "========================================"

echo "Serena is a language server-based code analysis tool for Claude Code"
echo ""

# Check if uv/uvx is installed
if command -v uvx &> /dev/null; then
    echo "✓ uvx available (required for Serena MCP)"
else
    echo "⚠ uvx not found"
    echo ""
    cat << 'EOF'
To install uv/uvx:

1. Install uv (fast Python package manager):
   curl -LsSf https://astral.sh/uv/install.sh | sh

2. Restart your shell or run:
   source ~/.bashrc  # or ~/.zshrc

EOF
fi

# Check if Serena MCP is configured
MCP_CONFIG="$HOME/.config/opencode.json"
if [ -f "$MCP_CONFIG" ]; then
    if grep -q "serena-mcp" "$MCP_CONFIG"; then
        echo "✓ Serena MCP configured in ~/.config/opencode/opencode.json"
    else
        echo "⚠ Serena MCP not found in ~/.config/opencode/opencode.json"
        echo ""
        cat << 'EOF'
Add Serena MCP to ~/.config/opencode/opencode.json mcpServers section:

"serena-mcp": {
  "type": "stdio",
  "command": "uvx",
  "args": [
    "--from",
    "git+https://github.com/oraios/serena",
    "serena",
    "start-mcp-server",
    "--context",
    "agent",
    "--project",
    "$(pwd)",
    "--enable-web-dashboard",
    "false",
    "--enable-gui-log-window",
    "false"
  ]
}

EOF
    fi
else
    echo "⚠ ~/.config/opencode/opencode.json not found (see Phase 5)"
fi

# Test Serena MCP availability
echo ""
echo "Testing Serena availability..."
if uvx --from git+https://github.com/oraios/serena serena --help &>/dev/null; then
    echo "✓ Serena can be executed via uvx"
else
    echo "⚠ Serena not accessible (will be installed on first use)"
fi

echo ""
echo "✓ Phase 8 Complete"
echo ""
```

---

## Phase 9: Additional Setup

```bash
#!/bin/bash

echo "========================================"
echo "Phase 9: Additional Setup"
echo "========================================"

cd ~/.config/opencode

# Check nvm and Node.js
echo "Checking Node.js setup..."
if [ -d "$HOME/.nvm" ]; then
    echo "✓ nvm found at: $HOME/.nvm"

    # Source nvm to make it available
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command -v nvm &> /dev/null; then
        echo "✓ nvm loaded: $(nvm --version)"
        echo "  Current Node.js: $(node --version 2>/dev/null || echo 'none')"
    fi
else
    echo "⚠ nvm not found"
    echo "  Install from: https://github.com/nvm-sh/nvm"
fi

# Python virtual environment
echo ""
echo "Checking Python setup..."
if command -v python3 &> /dev/null; then
    echo "✓ Python3: $(python3 --version)"

    # Create venv if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "  Creating Python virtual environment..."
        python3 -m venv venv
        echo "✓ Virtual environment created"
    else
        echo "✓ Virtual environment exists"
    fi

    # Check for requirements.txt and install
    if [ -f "requirements.txt" ]; then
        echo "  Installing Python dependencies..."
        source venv/bin/activate
        pip install -q -r requirements.txt
        deactivate
        echo "✓ Python dependencies installed"
    fi
else
    echo "⚠ Python3 not found"
fi

# Ensure necessary directories exist
echo ""
echo "Checking directory structure..."
for dir in debug session-env file-history todos plans shell-snapshots; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "✓ Created directory: $dir"
    fi
done

echo ""
echo "✓ Phase 9 Complete"
echo ""
```

---

## Phase 10: Verification & Testing

```bash
#!/bin/bash

echo "========================================"
echo "Phase 10: Verification & Testing"
echo "========================================"

cd ~/.config/opencode

echo "Testing hook scripts..."

# Test auto-approve-mcp.py
if [ -f "hooks/scripts/auto-approve-mcp.py" ] && [ -x "hooks/scripts/auto-approve-mcp.py" ]; then
    echo '{"tool_name": "test"}' | python3 hooks/scripts/auto-approve-mcp.py &>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ auto-approve-mcp.py works"
    else
        echo "⚠ auto-approve-mcp.py test failed"
    fi
fi

# Test notification-wrapper.sh
if [ -f "hooks/scripts/notification-wrapper.sh" ] && [ -x "hooks/scripts/notification-wrapper.sh" ]; then
    ./hooks/scripts/notification-wrapper.sh test &>/dev/null
    if [ $? -eq 0 ] || [ $? -eq 1 ]; then  # May exit 1 if no notification system
        echo "✓ notification-wrapper.sh executable"
    else
        echo "⚠ notification-wrapper.sh test failed"
    fi
fi

# Validate settings.json JSON syntax
echo ""
echo "Validating configuration files..."
if command -v python3 &> /dev/null; then
    python3 -c "import json; json.load(open('settings.json'))" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ settings.json is valid JSON"
    else
        echo "✗ settings.json has syntax errors"
    fi
fi

# Check path replacements
if grep -q "/home/daniel" settings.json; then
    echo "⚠ WARNING: Found /home/daniel in settings.json (may need manual update)"
else
    echo "✓ No hardcoded paths found in settings.json"
fi

# Check ccline
echo ""
echo "Checking ccline..."
if command -v ccline &> /dev/null; then
    echo "✓ ccline is accessible via PATH"
elif [ -f "ccline/ccline" ]; then
    echo "⚠ ccline binary exists but not in PATH"
else
    echo "⚠ ccline not found (optional)"
fi

# MCP server health check
echo ""
echo "Checking MCP configuration..."
if [ -f "$HOME/.config/claude/mcp.json" ]; then
    echo "✓ MCP configuration exists: ~/.config/claude/mcp.json"

    # Count configured servers
    SERVER_COUNT=$(grep -c '"command"' "$HOME/.config/claude/mcp.json" 2>/dev/null || echo 0)
    echo "  Configured servers: $SERVER_COUNT"
else
    echo "⚠ MCP configuration not found (needs setup in Phase 5)"
fi

# List configured MCP servers
echo ""
echo "Configured MCP servers:"
if [ -f "$HOME/.config/claude/mcp.json" ]; then
    python3 << 'PYEOF' 2>/dev/null || echo "  (Unable to parse mcp.json)"
import json
with open("/home/" + os.environ.get("USER", "daniel") + "/.config/claude/mcp.json") as f:
    config = json.load(f)
    for server in config.get("mcpServers", {}).keys():
        print(f"  - {server}")
PYEOF
else
    echo "  None configured yet"
fi

# Check Obsidian PKM
echo ""
echo "Checking Obsidian PKM setup..."
if [ -f "$HOME/.config/opencode/skills/pkm" ]; then
    echo "✓ PKM skill exists"
else
    echo "⚠ PKM skill not found"
fi

VAULT_PATH="$HOME/Documents/Obsidian/personal"
if [ -d "$VAULT_PATH" ]; then
    echo "✓ Obsidian vault: $VAULT_PATH"
else
    echo "⚠ Vault not found (may be different path)"
fi

echo ""
echo "✓ Phase 10 Complete"
echo ""
```

---

## Phase 11: Final Checklist

```bash
#!/bin/bash

echo "========================================"
echo "Phase 11: Final Checklist"
echo "========================================"

cat << 'EOF'
Manual steps remaining:

☐ Update .credentials.json with actual credentials:
  - Slack bot token (xoxb-...)
  - Slack team ID
  - AWS credentials (if needed)
  - Neo4j password
  - OpenAI API key

☐ Update ~/.config/claude/mcp.json with actual values:
  - NEO4J_PASSWORD
  - OPENAI_API_KEY
  - SLACK_BOT_TOKEN
  - SLACK_TEAM_ID
  - AWS_REGION (if different from us-east-1)
  - AWS_PROFILE (if different from default)
  - OBSIDIAN_VAULT_PATH (your Obsidian vault path)

☐ Configure Obsidian PKM:
  - Update OBSIDIAN_VAULT_PATH in .mcp-credentials.json
  - Add obsidian server to ~/.config/claude/mcp.json
  - Test: pkm search "test" or via Claude chat

☐ Test session-end review:
  - Run /retrospective to review past sessions
  - Use "Capture this: [content]" to manually add to vault
  - Optional: Enable PKM prompt in notify-stop.sh hook

☐ Start required services:
  - Neo4j: docker start neo4j (or docker run if first time)
  - Serena MCP: Configured in ~/.config/opencode/opencode.json (auto-starts with Claude)

☐ Generate/Update skill rules:
  - Run: /update-skill-rules
  - This enables the skill activation hook
  - Re-run after adding new skills or plugins

☐ Test Claude CLI with MCP:
  - claude chat (start new session)
  - Try: @graphiti-memory search (test memory)
  - Try: @context7 (test documentation lookup)

☐ Read main documentation:
  - ~/.config/opencode/CLAUDE.md (workflow and best practices)
  - ~/.config/opencode/SETUP.md (detailed setup reference)

☐ Explore available commands:
  - /help (list all slash commands)
  - /setup-repo (for new projects)
  - /retrospective (for session reviews)

Next Steps:
  1. Update credentials and MCP configuration
  2. Start Neo4j and other services
  3. Test MCP servers with 'claude chat'
  4. Read CLAUDE.md for workflow guidance
  5. Start using Claude with your enhanced setup!

EOF

echo ""
echo "✓ Phase 11 Complete"
echo ""
echo "========================================"
echo "Onboarding Complete!"
echo "========================================"
echo ""
echo "Your ~/.config/opencode environment is now set up."
echo "Review the checklist above and complete manual steps."
echo ""
```

---

## Troubleshooting

### Common Issues During Onboarding

#### 1. Permission Denied Errors

```bash
# Re-run Phase 2
chmod +x ~/.config/opencode/hooks/*.sh
chmod +x ~/.config/opencode/scripts/*.sh
chmod +x ~/.config/opencode/*.sh
chmod +x ~/.config/opencode/*.py
```

#### 2. Path Update Failed

```bash
# Manually update paths
cd ~/.config/opencode
cp settings.json settings.json.backup
sed -i "s|/home/daniel|$HOME|g" settings.json
```

#### 3. MCP Servers Not Detected

```bash
# Check MCP configuration
cat ~/.config/claude/mcp.json

# Verify format with Python
python3 -c "import json; print(json.dumps(json.load(open('$HOME/.config/claude/mcp.json')), indent=2))"

# Check Claude logs
tail -f ~/.cache/claude/logs/*.log
```

#### 4. Neo4j Connection Failed

```bash
# Check if Neo4j is running
docker ps | grep neo4j

# Start Neo4j if not running
docker start neo4j

# Or create new instance
docker run -d \
  --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  neo4j:latest

# Test connection
curl http://localhost:7474
```

#### 5. Plugin Installation Failed

```bash
# List available marketplaces
claude plugins marketplace list

# Re-add marketplace
claude plugins add claude-code-plugins-plus --force

# Install specific plugin
claude plugins install chaos-engineering-toolkit@claude-code-plugins-plus
```

#### 6. ccline Not Working

```bash
# Check if binary exists
ls -la ~/.config/opencode/ccline/ccline

# Build ccline from source
cd ~/.config/opencode/ccline
npm install
npm run build

# Add to PATH manually
echo 'export PATH="$HOME/.config/opencode/ccline:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Manual Configuration Templates

### .credentials.json Template

```json
{
  "slack": {
    "bot_token": "xoxb-YOUR-BOT-TOKEN",
    "user_token": "xoxp-YOUR-USER-TOKEN",
    "team_id": "T-YOUR-TEAM-ID"
  },
  "aws": {
    "access_key_id": "YOUR-ACCESS-KEY",
    "secret_access_key": "YOUR-SECRET-KEY",
    "region": "us-east-1"
  },
  "neo4j": {
    "uri": "bolt://localhost:7687",
    "user": "neo4j",
    "password": "YOUR-NEO4J-PASSWORD"
  },
  "openai": {
    "api_key": "sk-YOUR-OPENAI-KEY"
  },
  "obsidian": {
    "vault_path": "/home/YOUR_USERNAME/Documents/Obsidian/personal"
  }
}
```

### settings.local.json Template

```json
{
  "permissions": {
    "allow": [
      "Bash(cat:*)",
      "Bash(test:*)",
      "mcp__graphiti-memory__add_memory"
    ]
  },
  "outputStyle": "Explanatory"
}
```

---

## Post-Onboarding Testing

After completing all phases, test your setup:

```bash
# 1. Start a new Claude session
claude chat

# 2. Test memory (graphiti-memory)
# In Claude chat:
"Search memory for test"

# 3. Test documentation lookup (context7)
# In Claude chat:
"Get documentation for React hooks"

# 4. Test Slack integration
# In Claude chat:
"List my Slack channels"

# 5. Test AWS cost analysis
# In Claude chat:
"Get AWS EC2 pricing for t3.medium in us-east-1"

# 6. Run a slash command
/help

# 7. Test code expert agent
# In Claude chat:
"Use Code Expert to analyze this codebase structure"
```

---

**Last Updated:** 2025-11-20
