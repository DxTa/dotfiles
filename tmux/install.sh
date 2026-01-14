#!/bin/bash
# install.sh - Setup tmux configuration for new machines
# Usage: bash ~/.dotfiles/tmux/install.sh
#
# This script:
# 1. Creates symlink: ~/.tmux.conf -> dotfiles
# 2. Backs up existing files before creating symlinks
# 3. Is idempotent (safe to run multiple times)

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_TMUX="$DOTFILES_DIR/tmux"

# Source shared utilities
source "$DOTFILES_DIR/lib/common.sh"
source "$DOTFILES_DIR/lib/platform.sh"

# ==========================================
# Step 1: Configure ~/.tmux.conf (symlink)
# ==========================================
configure_tmux() {
    create_symlink "$DOTFILES_TMUX/tmux.conf" "$HOME/.tmux.conf"
}

# ==========================================
# Step 2: Verify installation
# ==========================================
verify_installation() {
    log_info "Verifying installation..."
    
    local errors=0

    # Check source files exist
    if [[ ! -f "$DOTFILES_TMUX/tmux.conf" ]]; then
        log_error "tmux.conf not found at $DOTFILES_TMUX/tmux.conf"
        ((errors++))
    fi

    # Check symlinks
    if [[ ! -L "$HOME/.tmux.conf" ]]; then
        log_error "~/.tmux.conf is not a symlink!"
        ((errors++))
    elif [[ "$(readlink "$HOME/.tmux.conf")" != "$DOTFILES_TMUX/tmux.conf" ]]; then
        log_error "~/.tmux.conf points to wrong location: $(readlink "$HOME/.tmux.conf")"
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        log_info "Installation verified successfully!"
    else
        log_error "Installation completed with $errors errors"
        exit 1
    fi
}

# ==========================================
# Main
# ==========================================
main() {
    echo ""
    echo "=========================================="
    echo "  Dotfiles Tmux Configuration Installer"
    echo "  Platform: $OS_TYPE"
    echo "=========================================="
    echo ""

    configure_tmux
    verify_installation

    echo ""
    log_info "Installation complete!"
    log_info "Backups saved to: $BACKUP_DIR (if any files were modified)"
    echo ""
    log_info "Next steps:"
    echo "  1. Reload tmux config: tmux source-file ~/.tmux.conf"
    echo "  2. Or restart tmux sessions"
    echo ""
}

main "$@"
