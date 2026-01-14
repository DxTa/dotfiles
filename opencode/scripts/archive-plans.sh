#!/bin/bash
# Auto-archive plan files older than 30 days
# Run via cron: 0 0 * * * ~/.config/opencode/scripts/archive-plans.sh

PLANS_DIR="$HOME/.config/opencode/plans"
ARCHIVE_DIR="$PLANS_DIR/archive"

mkdir -p "$ARCHIVE_DIR"

# Find and move files older than 30 days (excluding archive directory)
find "$PLANS_DIR" -maxdepth 1 -name "*.md" -type f -mtime +30 -exec mv {} "$ARCHIVE_DIR/" \;

# Log action
echo "$(date '+%Y-%m-%d %H:%M:%S'): Archived plan files older than 30 days to $ARCHIVE_DIR" >> "$PLANS_DIR/archive.log"
