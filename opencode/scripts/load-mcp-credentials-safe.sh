#!/usr/bin/env bash
# Load MCP Credentials - Safe version for sourcing in shell
# Add to ~/.zshrc or ~/.bashrc:
#   source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh

MCP_CREDS_FILE="${MCP_CREDS_FILE:-$HOME/.config/opencode/.mcp-credentials.json}"

# Skip if credentials file doesn't exist (won't break shell startup)
if [ ! -f "$MCP_CREDS_FILE" ]; then
    return 0 2>/dev/null
    exit 0
fi

# Skip if python3 not available
if ! command -v python3 &> /dev/null; then
    return 0 2>/dev/null
    exit 0
fi

# Use python3 to parse JSON and export variables
EVAL_OUTPUT="$(MCP_CREDS_FILE="$MCP_CREDS_FILE" python3 <<'PY'
import json, os
path = os.environ.get('MCP_CREDS_FILE')
try:
    with open(path) as f:
        creds = json.load(f)
    def emit(var, value):
        if value:
            # Escape single quotes in values to prevent shell injection
            safe_value = str(value).replace("'", "'\\''")
            print(f"export {var}='{safe_value}'")
    slack = creds.get('slack', {})
    emit('SLACK_BOT_TOKEN', slack.get('bot_token'))
    emit('SLACK_MCP_XOXP_TOKEN', slack.get('user_token'))
    emit('SLACK_TEAM_ID', slack.get('team_id'))

    neo4j = creds.get('neo4j', {})
    emit('NEO4J_URI', neo4j.get('uri', 'bolt://localhost:7687'))
    emit('NEO4J_USER', neo4j.get('user', 'neo4j'))
    emit('NEO4J_PASSWORD', neo4j.get('password'))

    emit('OPENAI_API_KEY', creds.get('openai', {}).get('api_key'))
    emit('ANTHROPIC_API_KEY', creds.get('anthropic', {}).get('api_key'))

    github = creds.get('github', {})
    emit('GITHUB_TOKEN', github.get('token'))
    emit('CR_PAT', github.get('token'))
    emit('GITHUB_USERNAME', github.get('username'))

    emit('GITLAB_TOKEN', creds.get('gitlab', {}).get('token'))
    emit('CONTEXT7_API_KEY', creds.get('context7', {}).get('api_key'))
    emit('GEMINI_API_KEY', creds.get('gemini', {}).get('api_key'))
    emit('MODEL_NAME', creds.get('graphiti', {}).get('model_name'))
    emit('Z_AI_API_KEY', creds.get('zai', {}).get('api_key'))

    claude = creds.get('claude', {})
    emit('ANTHROPIC_AUTH_TOKEN', claude.get('auth_token'))
    emit('ANTHROPIC_BASE_URL', claude.get('base_url'))
    emit('API_TIMEOUT_MS', claude.get('api_timeout_ms'))
    emit('CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC', claude.get('disable_nonessential_traffic'))
    emit('ANTHROPIC_DEFAULT_HAIKU_MODEL', claude.get('default_haiku_model'))
    emit('ANTHROPIC_DEFAULT_SONNET_MODEL', claude.get('default_sonnet_model'))
except Exception:
    pass
PY
)"

# shellcheck disable=SC2086
if [ -n "$EVAL_OUTPUT" ]; then
    eval "$EVAL_OUTPUT"
fi
