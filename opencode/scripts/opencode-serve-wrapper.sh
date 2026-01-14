#!/usr/bin/env bash
# Wrapper script for opencode serve with MCP credentials loaded
# Used by systemd service: opencode-serve.service

# Load MCP credentials into environment
source ~/.config/opencode/scripts/load-mcp-credentials-safe.sh

# Start opencode serve with all arguments passed through
exec /home/dxta/.opencode/bin/opencode "$@"
