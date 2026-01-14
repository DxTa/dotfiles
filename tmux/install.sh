#!/bin/bash
# install.sh - Setup tmux configuration for new machines
# Usage: bash ~/.dotfiles/tmux/install.sh
#
# This script:
# 1. Creates symlink: ~/.tmux.conf -> dotfiles
# 2. Backs up existing files before creating symlinks
# 3. Is idempotent (safe to run multiple times)

set -e

DOTFILES_TMUX="$HOME/.dotfiles/tmux"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Backup a file if it exists
backup_file() {
    local file="$1"
    if [[ -e "$file" ]] || [[ -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -P "$file" "$BACKUP_DIR/$(basename "$file")"
        log_info "Backed up $file to $BACKUP_DIR/"
    fi
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Already correct symlink?
    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
        log_info "$target already symlinked correctly, skipping..."
        return 0
    fi
    
    # Backup existing file (if regular file or different symlink)
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        backup_file "$target"
        rm -f "$target"
    fi
    
    # Create symlink
    ln -s "$source" "$target"
    log_info "Created symlink: $target -> $source"
}

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
