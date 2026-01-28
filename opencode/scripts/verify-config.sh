#!/usr/bin/env bash
# Verify Claude/OpenCode Configuration
# This script ensures the correct paths are being used

set -e

echo "🔍 Verifying Claude/OpenCode Configuration..."
echo

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SUCCESS=0
ERRORS=0

# Check 1: ~/.config/opencode exists and is a symlink
echo -n "✓ Checking ~/.config/opencode symlink... "
if [ -L "$HOME/.config/opencode" ]; then
    TARGET=$(readlink -f "$HOME/.config/opencode")
    if [ "$TARGET" = "$HOME/.dotfiles/opencode" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((SUCCESS++))
    else
        echo -e "${RED}✗ FAIL${NC} (points to wrong location: $TARGET)"
        ((ERRORS++))
    fi
else
    echo -e "${RED}✗ FAIL${NC} (not a symlink or doesn't exist)"
    ((ERRORS++))
fi

# Check 2: ~/.config/Claude symlink exists (required for mcp_skill)
echo -n "✓ Checking ~/.config/Claude symlink exists... "
if [ -L "$HOME/.config/Claude" ]; then
    TARGET=$(readlink -f "$HOME/.config/Claude")
    if [ "$TARGET" = "$HOME/.dotfiles/opencode" ] || [ "$TARGET" = "$HOME/.config/opencode" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((SUCCESS++))
    else
        echo -e "${RED}✗ FAIL${NC} (points to wrong location: $TARGET)"
        ((ERRORS++))
    fi
else
    echo -e "${RED}✗ FAIL${NC} (missing - required for skill loading)"
    echo -e "  ${YELLOW}Run: ln -s ~/.config/opencode ~/.config/Claude${NC}"
    ((ERRORS++))
fi

# Check 3: AGENTS.md exists in correct location
echo -n "✓ Checking AGENTS.md in ~/.dotfiles/opencode/... "
if [ -f "$HOME/.dotfiles/opencode/AGENTS.md" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((SUCCESS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((ERRORS++))
fi

# Check 4: skill-rules.json exists
echo -n "✓ Checking skill-rules.json exists... "
if [ -f "$HOME/.dotfiles/opencode/skill-rules.json" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((SUCCESS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((ERRORS++))
fi

# Check 5: skills directory exists
echo -n "✓ Checking skills/ directory exists... "
if [ -d "$HOME/.dotfiles/opencode/skills" ]; then
    SKILL_COUNT=$(find "$HOME/.dotfiles/opencode/skills" -maxdepth 1 -type d | wc -l)
    echo -e "${GREEN}✓ PASS${NC} ($((SKILL_COUNT - 1)) skills found)"
    ((SUCCESS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((ERRORS++))
fi

# Check 6: ~/.dotfiles/Claude symlink exists (string replacement workaround)
echo -n "✓ Checking ~/.dotfiles/Claude symlink exists... "
if [ -L "$HOME/.dotfiles/Claude" ]; then
    TARGET=$(readlink -f "$HOME/.dotfiles/Claude")
    if [ "$TARGET" = "$HOME/.dotfiles/opencode" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((SUCCESS++))
    else
        echo -e "${RED}✗ FAIL${NC} (points to wrong location: $TARGET)"
        ((ERRORS++))
    fi
else
    echo -e "${RED}✗ FAIL${NC} (missing - required for string replacement workaround)"
    echo -e "  ${YELLOW}Run: ln -s ~/.dotfiles/opencode ~/.dotfiles/Claude${NC}"
    ((ERRORS++))
fi

# Check 7: Prevention marker exists (optional)
echo -n "✓ Checking prevention marker exists... "
if [ -f "$HOME/.config/.claude-blocked" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((SUCCESS++))
else
    echo -e "${YELLOW}⚠ INFO${NC} (marker not present, but symlinks make it unnecessary)"
fi

# Summary
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary:"
echo -e "  ${GREEN}Passed: $SUCCESS${NC}"
if [ $ERRORS -gt 0 ]; then
    echo -e "  ${RED}Failed: $ERRORS${NC}"
    echo
    echo -e "${RED}⚠️  Configuration has errors!${NC}"
    exit 1
else
    echo
    echo -e "${GREEN}✓ Configuration is correct!${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
