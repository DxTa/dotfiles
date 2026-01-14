#!/bin/bash
# install.sh - Master installer for all dotfiles configurations
# Usage: bash ~/.dotfiles/install.sh [OPTIONS] [COMPONENT]
#
# Components:
#   all (default) - Install all configurations
#   zsh           - Install only zsh configuration
#   tmux          - Install only tmux configuration
#   vim           - Install only vim configuration
#
# Options:
#   --dry-run        Show what would be done without making changes
#   --install-deps   Install missing dependencies via package manager
#   --check-deps     Only check dependencies, don't install anything
#   --skip-ycm       Skip YouCompleteMe compilation (faster)
#   -h, --help       Show this help message
#
# This script:
# 1. Runs all sub-installers (zshrc, tmux, vim)
# 2. Backs up existing files before making changes
# 3. Is idempotent (safe to run multiple times)

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Source shared utilities
source "$DOTFILES_DIR/lib/common.sh"
source "$DOTFILES_DIR/lib/platform.sh"
source "$DOTFILES_DIR/lib/deps.sh"

# Parse arguments
DRY_RUN=false
INSTALL_DEPS=false
CHECK_ONLY=false
SKIP_YCM=false
COMPONENT="all"

show_usage() {
    cat << EOF

Usage: bash ~/.dotfiles/install.sh [OPTIONS] [COMPONENT]

Components:
  all (default)  Install all configurations
  zsh            Install only zsh configuration
  tmux           Install only tmux configuration
  vim            Install only vim configuration

Options:
  --dry-run        Show what would be done without making changes
  --install-deps   Install missing dependencies via package manager
  --check-deps     Only check dependencies, don't install anything
  --skip-ycm       Skip YouCompleteMe compilation (faster)
  -h, --help       Show this help message

Platform detected: $OS_TYPE (package manager: $PKG_MANAGER)

Examples:
  bash ~/.dotfiles/install.sh                    # Install everything
  bash ~/.dotfiles/install.sh --check-deps       # Check dependencies
  bash ~/.dotfiles/install.sh --install-deps     # Install deps and dotfiles
  bash ~/.dotfiles/install.sh --skip-ycm vim     # Install vim without YCM
  bash ~/.dotfiles/install.sh --dry-run          # Preview what would happen

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            export DRY_RUN
            shift
            ;;
        --install-deps)
            INSTALL_DEPS=true
            shift
            ;;
        --check-deps)
            CHECK_ONLY=true
            shift
            ;;
        --skip-ycm)
            SKIP_YCM=true
            export SKIP_YCM
            shift
            ;;
        -h|--help|help)
            show_usage
            exit 0
            ;;
        all|zsh|tmux|vim)
            COMPONENT="$1"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

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

main() {
    local errors=0
    
    echo ""
    echo "============================================"
    echo "  Dotfiles Master Installer"
    echo "  Platform: $OS_TYPE | Package Manager: $PKG_MANAGER"
    [[ "$DRY_RUN" == "true" ]] && echo "  Mode: DRY RUN (no changes will be made)"
    echo "============================================"
    echo ""
    
    # Check dependencies if requested or if installing
    if [[ "$CHECK_ONLY" == "true" ]] || [[ "$INSTALL_DEPS" == "true" ]]; then
        if check_all_deps; then
            echo ""
            log_info "All dependencies satisfied!"
            [[ "$CHECK_ONLY" == "true" ]] && exit 0
        else
            echo ""
            if [[ "$INSTALL_DEPS" == "true" ]]; then
                log_header "Installing missing dependencies..."
                
                # Install based on component selection
                case "$COMPONENT" in
                    all)
                        install_deps_zsh || ((errors++))
                        install_deps_tmux || ((errors++))
                        install_deps_vim || ((errors++))
                        ;;
                    zsh)  install_deps_zsh || ((errors++)) ;;
                    tmux) install_deps_tmux || ((errors++)) ;;
                    vim)  install_deps_vim || ((errors++)) ;;
                esac
                
                if [[ $errors -gt 0 ]]; then
                    log_error "Failed to install some dependencies"
                    exit 1
                fi
                echo ""
                log_info "Dependencies installed successfully!"
                echo ""
            elif [[ "$CHECK_ONLY" == "true" ]]; then
                log_warn "Some dependencies missing. Run with --install-deps to install them."
                exit 1
            else
                log_warn "Some dependencies missing. Installation may fail."
                log_warn "Run with --install-deps to install dependencies first."
                echo ""
            fi
        fi
    fi
    
    # Exit if only checking dependencies
    if [[ "$CHECK_ONLY" == "true" ]]; then
        exit 0
    fi
    
    # Perform installation
    case "$COMPONENT" in
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
    
    # Set secure permissions
    secure_permissions
    
    log_info "Next steps:"
    echo "  1. Open a new terminal to test zsh configuration"
    echo "  2. Reload tmux: tmux source-file ~/.tmux.conf"
    echo "  3. Open vim and run :YcmDebugInfo to verify YouCompleteMe"
    echo ""
}

main "$@"
