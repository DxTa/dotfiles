#!/home/dxta/.config/opencode/venv/bin/python
"""
PKM Skill - Personal Knowledge Management via Obsidian

Simple wrapper around Obsidian MCP server for capturing learnings and searching vault.

Usage:
    pkm capture "content to capture" --tags tag1,tag2
    pkm search "query"

The skill uses MCP tools internally via Claude Code's MCP integration.
"""

import os
import sys
import json
import argparse
from datetime import datetime
from pathlib import Path

# Configuration
VAULT_PATH = "/home/dxta/Documents/Obsidian/personal"
DAILY_NOTES_DIR = "Daily Notes"

def get_daily_note_path() -> str:
    """Get the path for today's daily note"""
    today = datetime.now().strftime("%Y-%m-%d")
    return f"{DAILY_NOTES_DIR}/{today}.md"

def format_capture_note(content: str, tags: list = None) -> str:
    """Format a learning capture note"""
    tag_list = tags or []
    tags_str = ", ".join(f'"{t}"' for t in tag_list) if tag_list else "[]"
    current_time = datetime.now().isoformat()

    return f"""---
type: learning
source: claude-code
tags: [{tags_str}]
created: {current_time}
---

## Learning

{content}

---
_Captured via Claude Code @ {datetime.now().strftime('%H:%M')}_
"""

def skill_capture(content: str, tags: list = None) -> str:
    """
    Capture a learning to today's daily note

    This function outputs the note content that will be written via MCP.
    The actual MCP call happens in Claude Code context.
    """
    note_path = get_daily_note_path()
    note_content = format_capture_note(content, tags)

    # Return instructions for Claude to use MCP
    return f"""Please create/update note at: {note_path}

Content to append:
{note_content}

Use the obsidian MCP create_note or update_note tool.
If the note exists, append this content to it.
"""

def skill_search(query: str, max_results: int = 10) -> str:
    """
    Search the vault for notes matching query

    This function returns instructions for Claude to search via MCP.
    """
    return f"""Please search the Obsidian vault for: {query}

Use the obsidian MCP search_vault tool with query: "{query}"
Return the top {max_results} results with relevant excerpts.
"""

# ============================================================================
# CLI interface (for direct testing)
# ============================================================================

def main():
    """CLI interface for direct invocation"""
    parser = argparse.ArgumentParser(
        description="PKM Skill - Personal Knowledge Management via Obsidian",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  pkm capture "Learned about React hooks" --tags react,frontend
  pkm search "obsidian"
        """
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Capture command
    capture_parser = subparsers.add_parser("capture", help="Capture a learning to daily notes")
    capture_parser.add_argument("content", help="Content to capture")
    capture_parser.add_argument("--tags", nargs="*", default=[], help="Tags for the learning")

    # Search command
    search_parser = subparsers.add_parser("search", help="Search vault for notes")
    search_parser.add_argument("query", help="Search query")
    search_parser.add_argument("--max", type=int, default=10, help="Maximum results")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    if args.command == "capture":
        # For CLI mode, output the formatted note
        note_path = get_daily_note_path()
        note_content = format_capture_note(args.content, args.tags)
        print(f"Note path: {note_path}")
        print(f"Content:\n{note_content}")
        print("\nUse Claude Code with Obsidian MCP to create this note.")

    elif args.command == "search":
        result = skill_search(args.query, args.max)
        print(result)

if __name__ == "__main__":
    main()
