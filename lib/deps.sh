#!/bin/bash
# lib/deps.sh - Dependency checking and installation

# Resolve DOTFILES_DIR
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Source platform detection
source "$DOTFILES_DIR/lib/platform.sh"

check_command() {
    local cmd="$1"
    command -v "$cmd" &>/dev/null
}

# Check and optionally install zsh dependencies
check_deps_zsh() {
    local errors=0
    check_command zsh || ((errors++))
    check_command curl || ((errors++))
    check_command git || ((errors++))
    return $errors
}

install_deps_zsh() {
    log_header "Installing zsh dependencies..."
    case "$PKG_MANAGER" in
        apt)
            sudo apt update && sudo apt install -y zsh curl git
            ;;
        brew)
            brew install zsh curl git
            ;;
        dnf)
            sudo dnf install -y zsh curl git
            ;;
        *)
            log_error "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# Check and optionally install vim dependencies
check_deps_vim() {
    local errors=0
    check_command vim || ((errors++))
    check_command python3 || ((errors++))
    check_command cmake || ((errors++))
    
    # Platform-specific build tools
    case "$OS_TYPE" in
        linux|wsl)
            if ! dpkg -l | grep -q python3-dev 2>/dev/null; then
                log_warn "python3-dev may be required for YCM"
                ((errors++))
            fi
            ;;
    esac
    
    return $errors
}

install_deps_vim() {
    log_header "Installing vim dependencies..."
    case "$PKG_MANAGER" in
        apt)
            sudo apt update && sudo apt install -y vim python3 python3-dev cmake build-essential git
            ;;
        brew)
            brew install vim python cmake git
            ;;
        dnf)
            sudo dnf install -y vim python3 python3-devel cmake gcc-c++ git
            ;;
        *)
            log_error "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# Check and optionally install tmux dependencies
check_deps_tmux() {
    check_command tmux
}

install_deps_tmux() {
    log_header "Installing tmux dependencies..."
    case "$PKG_MANAGER" in
        apt)
            sudo apt update && sudo apt install -y tmux
            ;;
        brew)
            brew install tmux
            ;;
        dnf)
            sudo dnf install -y tmux
            ;;
        *)
            log_error "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# Check all dependencies for all components
check_all_deps() {
    local errors=0
    
    log_header "Checking dependencies..."
    
    echo ""
    echo "ZSH dependencies:"
    if check_deps_zsh; then
        log_info "✓ All zsh dependencies satisfied"
    else
        log_error "✗ Missing zsh dependencies"
        ((errors++))
    fi
    
    echo ""
    echo "Tmux dependencies:"
    if check_deps_tmux; then
        log_info "✓ All tmux dependencies satisfied"
    else
        log_error "✗ Missing tmux dependencies"
        ((errors++))
    fi
    
    echo ""
    echo "Vim dependencies:"
    if check_deps_vim; then
        log_info "✓ All vim dependencies satisfied"
    else
        log_warn "⚠ Some vim dependencies missing (may be needed for YCM)"
    fi
    
    return $errors
}
