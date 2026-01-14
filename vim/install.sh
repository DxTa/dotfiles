#!/bin/bash
# install.sh - Setup vim configuration with YouCompleteMe
# Usage: bash ~/.dotfiles/vim/install.sh
#
# This script:
# 1. Creates symlinks: ~/.vimrc -> dotfiles, ~/.vim_runtime -> dotfiles
# 2. Initializes git submodules (YouCompleteMe)
# 3. Builds YouCompleteMe if not already compiled
# 4. Backs up existing files before creating symlinks
# 5. Is idempotent (safe to run multiple times)

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_VIM="$DOTFILES_DIR/vim"

# Source shared utilities
source "$DOTFILES_DIR/lib/common.sh"
source "$DOTFILES_DIR/lib/platform.sh"

# Skip YCM build if requested
SKIP_YCM="${SKIP_YCM:-false}"

# ==========================================
# Step 1: Configure ~/.vimrc (symlink)
# ==========================================
configure_vimrc() {
    create_symlink "$DOTFILES_VIM/vimrc" "$HOME/.vimrc"
}

# ==========================================
# Step 2: Configure ~/.vim_runtime (symlink)
# ==========================================
configure_vim_runtime() {
    create_symlink "$DOTFILES_VIM/vim_runtime" "$HOME/.vim_runtime"
}

# ==========================================
# Step 3: Initialize git submodules
# ==========================================
init_submodules() {
    log_info "Initializing git submodules (YouCompleteMe)..."
    cd "$DOTFILES_DIR"
    git submodule update --init --recursive
    
    if [[ -d "$DOTFILES_VIM/vim_runtime/my_plugins/YouCompleteMe" ]]; then
        log_info "YouCompleteMe submodule initialized successfully!"
    else
        log_error "YouCompleteMe submodule initialization failed!"
        exit 1
    fi
}

# ==========================================
# Step 4: Build YouCompleteMe
# ==========================================
build_ycm() {
    if [[ "$SKIP_YCM" == "true" ]]; then
        log_info "Skipping YouCompleteMe build (SKIP_YCM=true)"
        return 0
    fi
    
    local ycm_dir="$DOTFILES_VIM/vim_runtime/my_plugins/YouCompleteMe"
    
    # Check if already built
    if [[ -d "$ycm_dir/third_party/ycmd" ]] && [[ -n "$(find "$ycm_dir/third_party/ycmd" -name 'ycm_core*.so' -o -name 'ycm_core*.dylib' 2>/dev/null)" ]]; then
        log_info "YouCompleteMe already built, skipping..."
        return 0
    fi
    
    log_info "Building YouCompleteMe (this may take several minutes)..."
    
    # Platform-specific dependency hints
    case "$OS_TYPE" in
        linux|wsl)
            log_info "Required: build-essential, cmake, python3-dev"
            ;;
        macos)
            log_info "Required: Xcode Command Line Tools, cmake, python"
            ;;
    esac
    
    # Check if python3 is available
    if ! command -v python3 &> /dev/null; then
        log_error "python3 is required but not found!"
        case "$OS_TYPE" in
            linux|wsl)
                log_error "Install with: sudo apt install python3"
                ;;
            macos)
                log_error "Install with: brew install python"
                ;;
        esac
        exit 1
    fi
    
    # Run YCM installer
    cd "$ycm_dir"
    if python3 install.py --all; then
        log_info "YouCompleteMe built successfully!"
    else
        log_warn "YouCompleteMe build failed or requires additional dependencies"
        case "$OS_TYPE" in
            linux|wsl)
                log_warn "Install with: sudo apt install build-essential cmake python3-dev"
                ;;
            macos)
                log_warn "Install with: xcode-select --install && brew install cmake python"
                ;;
        esac
        log_warn "Then run: python3 $ycm_dir/install.py --all"
    fi
}

# ==========================================
# Step 5: Verify installation
# ==========================================
verify_installation() {
    log_info "Verifying installation..."
    
    local errors=0

    # Check source files exist
    if [[ ! -f "$DOTFILES_VIM/vimrc" ]]; then
        log_error "vimrc not found at $DOTFILES_VIM/vimrc"
        ((errors++))
    fi

    if [[ ! -d "$DOTFILES_VIM/vim_runtime" ]]; then
        log_error "vim_runtime not found at $DOTFILES_VIM/vim_runtime"
        ((errors++))
    fi

    # Check symlinks
    if [[ ! -L "$HOME/.vimrc" ]]; then
        log_error "~/.vimrc is not a symlink!"
        ((errors++))
    elif [[ "$(readlink "$HOME/.vimrc")" != "$DOTFILES_VIM/vimrc" ]]; then
        log_error "~/.vimrc points to wrong location: $(readlink "$HOME/.vimrc")"
        ((errors++))
    fi

    if [[ ! -L "$HOME/.vim_runtime" ]]; then
        log_error "~/.vim_runtime is not a symlink!"
        ((errors++))
    elif [[ "$(readlink "$HOME/.vim_runtime")" != "$DOTFILES_VIM/vim_runtime" ]]; then
        log_error "~/.vim_runtime points to wrong location: $(readlink "$HOME/.vim_runtime")"
        ((errors++))
    fi

    # Check YCM submodule
    if [[ ! -d "$DOTFILES_VIM/vim_runtime/my_plugins/YouCompleteMe" ]]; then
        log_error "YouCompleteMe submodule not found!"
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
    echo "  Dotfiles Vim Configuration Installer"
    echo "  Platform: $OS_TYPE"
    echo "=========================================="
    echo ""

    configure_vimrc
    configure_vim_runtime
    init_submodules
    build_ycm
    verify_installation

    echo ""
    log_info "Installation complete!"
    log_info "Backups saved to: $BACKUP_DIR (if any files were modified)"
    echo ""
    log_info "Next steps:"
    echo "  1. Open vim and check that it loads without errors"
    echo "  2. Run :YcmDebugInfo in vim to verify YouCompleteMe is working"
    if [[ "$SKIP_YCM" != "true" ]]; then
        echo "  3. If YCM build failed, run: python3 $DOTFILES_VIM/vim_runtime/my_plugins/YouCompleteMe/install.py --all"
    fi
    echo ""
}

main "$@"
