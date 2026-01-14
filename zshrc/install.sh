#!/bin/bash
# install.sh - Setup zsh configuration for new machines
# Usage: bash ~/.dotfiles/zshrc/install.sh
#
# This script:
# 1. Installs oh-my-zsh if not present
# 2. Creates symlinks: ~/.zshrc -> dotfiles, ~/.zshenv -> dotfiles
# 3. Backs up existing files before creating symlinks
# 4. Is idempotent (safe to run multiple times)

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_ZSHRC="$DOTFILES_DIR/zshrc"

# Source shared utilities
source "$DOTFILES_DIR/lib/common.sh"
source "$DOTFILES_DIR/lib/platform.sh"

# ==========================================
# Step 1: Install oh-my-zsh if missing
# ==========================================
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "oh-my-zsh already installed, skipping..."
        return 0
    fi

    log_info "Installing oh-my-zsh..."
    
    # Use unattended install (RUNZSH=no prevents auto-switching shell)
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "oh-my-zsh installed successfully!"
    else
        log_error "oh-my-zsh installation failed!"
        exit 1
    fi
}

# ==========================================
# Step 2: Configure ~/.zshenv (symlink)
# ==========================================
configure_zshenv() {
    create_symlink "$DOTFILES_ZSHRC/zshenv" "$HOME/.zshenv"
}

# ==========================================
# Step 3: Configure ~/.zshrc (symlink)
# ==========================================
configure_zshrc() {
    create_symlink "$DOTFILES_ZSHRC/zshrc" "$HOME/.zshrc"
}

# ==========================================
# Step 4: Verify installation
# ==========================================
verify_installation() {
    log_info "Verifying installation..."
    
    local errors=0

    # Check oh-my-zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_error "oh-my-zsh not found!"
        ((errors++))
    fi

    # Check source files exist
    if [[ ! -f "$DOTFILES_ZSHRC/init.sh" ]]; then
        log_warn "init.sh not found at $DOTFILES_ZSHRC/init.sh"
        log_warn "Make sure to create your dotfiles before using them!"
    fi

    if [[ ! -f "$DOTFILES_ZSHRC/zshenv" ]]; then
        log_error "zshenv not found at $DOTFILES_ZSHRC/zshenv"
        ((errors++))
    fi

    if [[ ! -f "$DOTFILES_ZSHRC/zshrc" ]]; then
        log_error "zshrc not found at $DOTFILES_ZSHRC/zshrc"
        ((errors++))
    fi

    # Check symlinks
    if [[ ! -L "$HOME/.zshenv" ]]; then
        log_error "~/.zshenv is not a symlink!"
        ((errors++))
    elif [[ "$(readlink "$HOME/.zshenv")" != "$DOTFILES_ZSHRC/zshenv" ]]; then
        log_error "~/.zshenv points to wrong location: $(readlink "$HOME/.zshenv")"
        ((errors++))
    fi

    if [[ ! -L "$HOME/.zshrc" ]]; then
        log_error "~/.zshrc is not a symlink!"
        ((errors++))
    elif [[ "$(readlink "$HOME/.zshrc")" != "$DOTFILES_ZSHRC/zshrc" ]]; then
        log_error "~/.zshrc points to wrong location: $(readlink "$HOME/.zshrc")"
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
    echo "  Dotfiles ZSH Configuration Installer"
    echo "  Platform: $OS_TYPE"
    echo "=========================================="
    echo ""

    install_oh_my_zsh
    configure_zshenv
    configure_zshrc
    verify_installation

    echo ""
    log_info "Installation complete!"
    log_info "Backups saved to: $BACKUP_DIR (if any files were modified)"
    echo ""
    log_info "Next steps:"
    echo "  1. Copy your secrets to ~/.dotfiles/zshrc/secrets.sh"
    echo "  2. Open a new terminal to test"
    echo "  3. Run 'alias' to verify aliases are loaded"
    echo ""
}

main "$@"
