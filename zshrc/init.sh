#!/bin/zsh
# init.sh - Main entry point for shell customizations
# Sourced by ~/.zshenv for non-interactive shell support

DOTFILES_ZSHRC="$HOME/.dotfiles/zshrc"

# Source secrets (if exists)
[[ -f "$DOTFILES_ZSHRC/secrets.sh" ]] && source "$DOTFILES_ZSHRC/secrets.sh"

# Source paths and environment variables
source "$DOTFILES_ZSHRC/paths.sh"

# Source aliases
source "$DOTFILES_ZSHRC/aliases.sh"

# Source functions
source "$DOTFILES_ZSHRC/functions.sh"

# NOTE: completions.sh is sourced from zshrc (after oh-my-zsh loads compdef)
