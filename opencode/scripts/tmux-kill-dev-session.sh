#!/bin/bash
# Helper script for tmux to kill dev session with confirmation

session_name="$1"

if [[ -z "$session_name" ]]; then
    echo "Error: No session name provided"
    exit 1
fi

# Use tmux's display-message for confirmation in tmux context
# Default is 'y', so just pressing Enter confirms
read -p "Kill session '$session_name' and unmount? [Y/n]: " -n 1 -r
echo

# If empty or starts with y/Y, proceed
if [[ -z "$REPLY" ]] || [[ $REPLY =~ ^[Yy]$ ]]; then
    # Source zsh to get the dev-umount function
    source ~/.zshrc
    dev-umount "$session_name"
else
    echo "Cancelled."
fi
