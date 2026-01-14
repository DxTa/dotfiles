#!/bin/bash
# lib/common.sh - Shared installer utilities

# Resolve DOTFILES_DIR from anywhere
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()   { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()   { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()  { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${BLUE}[====]${NC} $1"; }

# Global backup directory for this session
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

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

# Set secure permissions on sensitive files
secure_permissions() {
    chmod 600 "$DOTFILES_DIR/zshrc/secrets.sh" 2>/dev/null || true
    chmod 700 "$HOME/.dotfiles-backup" 2>/dev/null || true
}
