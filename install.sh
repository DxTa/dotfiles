#!/bin/bash
# install.sh - Master installer for all dotfiles configurations
# Usage: bash ~/.dotfiles/install.sh [component]
#
# Components:
#   all (default) - Install all configurations
#   zsh          - Install only zsh configuration
#   tmux         - Install only tmux configuration
#   vim          - Install only vim configuration
#
# This script:
# 1. Runs all sub-installers (zshrc, tmux, vim)
# 2. Backs up existing files before making changes
# 3. Is idempotent (safe to run multiple times)

set -e

DOTFILES_DIR="$HOME/.dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${BLUE}[====]${NC} $1"; }

# ==========================================
# Component Installation Functions
# ==========================================

install_zsh() {
    log_header "Installing ZSH configuration..."
    if [[ -f "$DOTFILES_DIR/zshrc/install.sh" ]]; then
        bash "$DOTFILES_DIR/zshrc/install.sh"
    else
        log_error "ZSH installer not found at $DOTFILES_DIR/zshrc/install.sh"
        return 1
    fi
}

install_tmux() {
    log_header "Installing Tmux configuration..."
    if [[ -f "$DOTFILES_DIR/tmux/install.sh" ]]; then
        bash "$DOTFILES_DIR/tmux/install.sh"
    else
        log_error "Tmux installer not found at $DOTFILES_DIR/tmux/install.sh"
        return 1
    fi
}

install_vim() {
    log_header "Installing Vim configuration..."
    if [[ -f "$DOTFILES_DIR/vim/install.sh" ]]; then
        bash "$DOTFILES_DIR/vim/install.sh"
    else
        log_error "Vim installer not found at $DOTFILES_DIR/vim/install.sh"
        return 1
    fi
}

# ==========================================
# Main Installation Logic
# ==========================================

show_usage() {
    echo ""
    echo "Usage: bash ~/.dotfiles/install.sh [component]"
    echo ""
    echo "Components:"
    echo "  all (default)  Install all configurations"
    echo "  zsh            Install only zsh configuration"
    echo "  tmux           Install only tmux configuration"
    echo "  vim            Install only vim configuration"
    echo ""
}

main() {
    local component="${1:-all}"
    local errors=0
    
    echo ""
    echo "============================================"
    echo "  Dotfiles Master Installer"
    echo "============================================"
    echo ""
    
    case "$component" in
        all)
            log_info "Installing all configurations..."
            echo ""
            
            install_zsh || ((errors++))
            echo ""
            
            install_tmux || ((errors++))
            echo ""
            
            install_vim || ((errors++))
            echo ""
            ;;
        zsh)
            install_zsh || ((errors++))
            ;;
        tmux)
            install_tmux || ((errors++))
            ;;
        vim)
            install_vim || ((errors++))
            ;;
        -h|--help|help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown component: $component"
            show_usage
            exit 1
            ;;
    esac
    
    echo ""
    echo "============================================"
    if [[ $errors -eq 0 ]]; then
        log_info "All installations completed successfully!"
    else
        log_error "Installation completed with $errors errors"
        exit 1
    fi
    echo "============================================"
    echo ""
    
    log_info "Next steps:"
    echo "  1. Open a new terminal to test zsh configuration"
    echo "  2. Reload tmux: tmux source-file ~/.tmux.conf"
    echo "  3. Open vim and run :YcmDebugInfo to verify YouCompleteMe"
    echo ""
}

main "$@"
