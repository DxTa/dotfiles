#!/bin/bash
# lib/platform.sh - Cross-platform detection utilities

detect_os() {
    case "$(uname -s)" in
        Linux*)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

detect_package_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v brew &>/dev/null; then
        echo "brew"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Cross-platform helper: check if command exists
check_command() {
    command -v "$1" &>/dev/null
}

# Cross-platform sshfs wrapper
_sshfs() {
    case "$OS_TYPE" in
        macos)
            if check_command sshfs-mac; then
                sshfs-mac "$@"
            else
                echo "Error: sshfs-mac not found. Install with: brew install gromgit/fuse/sshfs-mac" >&2
                return 1
            fi
            ;;
        *)
            if check_command sshfs; then
                sshfs "$@"
            else
                echo "Error: sshfs not found. Install with: sudo apt install sshfs" >&2
                return 1
            fi
            ;;
    esac
}

# Cross-platform unmount for sshfs
_unmount_sshfs() {
    local mount_dir="$1"
    case "$OS_TYPE" in
        macos)
            diskutil unmount "$mount_dir" 2>/dev/null || umount "$mount_dir" 2>/dev/null
            ;;
        *)
            fusermount -uz "$mount_dir" 2>/dev/null || umount -l "$mount_dir" 2>/dev/null
            ;;
    esac
}

# Cross-platform check if directory is mounted
_is_mounted() {
    local mount_dir="$1"
    case "$OS_TYPE" in
        macos)
            mount | grep -q " on ${mount_dir} "
            ;;
        *)
            mountpoint -q "$mount_dir" 2>/dev/null
            ;;
    esac
}

# Cross-platform md5 hash (for functions.sh)
portable_md5() {
    if check_command md5sum; then
        md5sum | cut -c1-6
    else
        md5 | cut -c1-6  # macOS
    fi
}

# Platform helper functions for functions.sh
_is_linux() { [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; }
_is_macos() { [[ "$OS_TYPE" == "macos" ]]; }
_is_wsl() { [[ "$OS_TYPE" == "wsl" ]]; }

# Auto-detect on source
OS_TYPE=$(detect_os)
PKG_MANAGER=$(detect_package_manager)
