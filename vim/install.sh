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

DOTFILES_VIM="$HOME/.dotfiles/vim"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Backup a file or directory if it exists
backup_file() {
    local file="$1"
    if [[ -e "$file" ]] || [[ -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        if [[ -d "$file" ]] && [[ ! -L "$file" ]]; then
            # It's a directory (not a symlink to a directory)
            cp -rP "$file" "$BACKUP_DIR/$(basename "$file")"
        else
            # It's a file or symlink
            cp -P "$file" "$BACKUP_DIR/$(basename "$file")"
        fi
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
        rm -rf "$target"
    fi
    
    # Create symlink
    ln -s "$source" "$target"
    log_info "Created symlink: $target -> $source"
}

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
    cd "$HOME/.dotfiles"
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
    local ycm_dir="$DOTFILES_VIM/vim_runtime/my_plugins/YouCompleteMe"
    
    # Check if already built
    if [[ -d "$ycm_dir/third_party/ycmd" ]] && [[ -n "$(find "$ycm_dir/third_party/ycmd" -name 'ycm_core*.so' 2>/dev/null)" ]]; then
        log_info "YouCompleteMe already built, skipping..."
        return 0
    fi
    
    log_info "Building YouCompleteMe (this may take several minutes)..."
    log_info "This requires: build-essential, cmake, python3-dev"
    
    # Check if python3 is available
    if ! command -v python3 &> /dev/null; then
        log_error "python3 is required but not found!"
        log_error "Install with: sudo apt install python3"
        exit 1
    fi
    
    # Run YCM installer
    cd "$ycm_dir"
    if python3 install.py --all; then
        log_info "YouCompleteMe built successfully!"
    else
        log_warn "YouCompleteMe build failed or requires additional dependencies"
        log_warn "You may need to install: sudo apt install build-essential cmake python3-dev"
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
    echo "  3. If YCM build failed, run: python3 $DOTFILES_VIM/vim_runtime/my_plugins/YouCompleteMe/install.py --all"
    echo ""
}

main "$@"
