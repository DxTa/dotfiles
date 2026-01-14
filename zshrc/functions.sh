#!/bin/zsh
# functions.sh - Shell functions

# Source platform utilities for cross-platform support
if [[ -f "$HOME/.dotfiles/lib/platform.sh" ]]; then
    source "$HOME/.dotfiles/lib/platform.sh"
fi

# Docker: Clean running containers older than 2 hours
docker-clean-containers() {
	docker ps -f status=running --format "{{.ID}} {{.CreatedAt}}" | while read id cdate ctime _; do if [[ $(date +'%s' -d "${cdate} ${ctime}") -lt $(date +'%s' -d '2 hours ago') ]]; then docker kill $id; fi; done
}

# Helper function for SSHFS mount cleanup (cross-platform)
_dev_cleanup_mount() {
    local mount_dir="$1"
    if _is_mounted "$mount_dir"; then
        _unmount_sshfs "$mount_dir"
    fi
    rmdir "$mount_dir" 2>/dev/null
}

# List SSHFS mounts for dev sessions
dev-list() {
    echo "Dev SSHFS mounts in $HOME/dev/sshfs_dirs/:"
    if [[ -d "$HOME/dev/sshfs_dirs" ]]; then
        for mount_dir in $HOME/dev/sshfs_dirs/*/; do
            if [[ -d "$mount_dir" ]]; then
                local dir_name=$(basename "${mount_dir%/}")
                local session_name="dev-${dir_name}"
                if _is_mounted "$mount_dir"; then
                    echo "  ✓ MOUNTED: ${mount_dir%/}"
                    echo "    Session: ${session_name}"
                else
                    echo "  - Stale: ${mount_dir%/} (not mounted)"
                fi
            fi
        done
    else
        echo "  (no mounts directory)"
    fi
}

# Clean up stale SSHFS mounts
dev-cleanup() {
    echo "Cleaning up stale SSHFS mounts..."
    if [[ -d "$HOME/dev/sshfs_dirs" ]]; then
        local cleaned=0
        for mount_dir in $HOME/dev/sshfs_dirs/*/; do
            if [[ -d "$mount_dir" ]]; then
                if ! _is_mounted "$mount_dir"; then
                    rmdir "$mount_dir" 2>/dev/null && cleaned=$((cleaned + 1))
                fi
            fi
        done
        echo "Cleaned $cleaned stale mount directories"
    fi
}

# Unmount specific dev session and kill tmux session
dev-umount() {
    local arg="$1"
    if [[ -z "$arg" ]]; then
        echo "Usage: dev-umount <session_name|mount_path>"
        echo "List sessions with: dev-list"
        return 1
    fi

    local session_name
    local mount_dir

    # Detect if argument is a path or session name
    if [[ "$arg" == /* ]] || [[ "$arg" == "$HOME"* ]]; then
        # It's a path - extract session name from it
        local dir_name=$(basename "$arg")
        session_name="dev-${dir_name}"
        mount_dir="$arg"
    else
        # It's a session name
        session_name="$arg"
        local name_part="${session_name#dev-}"
        mount_dir="$HOME/dev/sshfs_dirs/$name_part"
    fi

    # Try to kill the tmux session (if it exists)
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Killing session '$session_name'..."
        tmux kill-session -t "$session_name"
    else
        echo "Note: Session '$session_name' not found (may already be dead)"
    fi

    # Clean up mount
    if [[ -d "$mount_dir" ]]; then
        echo "Unmounting $mount_dir..."
        if _is_mounted "$mount_dir"; then
            _unmount_sshfs "$mount_dir"
        fi
        rmdir "$mount_dir" 2>/dev/null && echo "Removed mount directory"
    fi

    echo "Cleanup complete"
}

# Dev workspace function - creates tmux session with vim, opencode, and shell windows
# Supports local directories and remote SSH paths (host:/path or user@host:/path)
dev() {
    local arg="${1:-$PWD}"

    if [[ "$arg" == *":"* ]]; then
        local remote_spec="${arg%%:*}"
        local remote_path="${arg#*:}"
        local host_part
        if [[ "$remote_spec" == *"@"* ]]; then
            host_part="${remote_spec#*@}"
        else
            host_part="$remote_spec"
        fi
        local path_last=$(basename "$remote_path")
        local hash=$(echo "$arg" | portable_md5)
        local mount_dir="$HOME/dev/sshfs_dirs/${host_part}-${path_last}-${hash}"
        local session_name="dev-${host_part}-${path_last}-${hash}"
        session_name=$(echo "$session_name" | tr -cd 'a-zA-Z0-9-_' | tr -s '_')

        if tmux has-session -t "$session_name" 2>/dev/null; then
            tmux attach -t "$session_name"
            return
        fi

        mkdir -p "$HOME/dev/sshfs_dirs"

        local session_exists=false
        local mount_exists=false
        local is_mounted=false

        tmux has-session -t "$session_name" 2>/dev/null && session_exists=true
        [[ -d "$mount_dir" ]] && mount_exists=true
        _is_mounted "$mount_dir" && is_mounted=true

        if $session_exists || $mount_exists; then
            echo ""
            echo "WARNING: Existing session or mount detected!"
            echo "  Session '$session_name': $($session_exists && echo 'EXISTS' || echo 'not found')"
            echo "  Mount '$mount_dir': $($is_mounted && echo 'MOUNTED' || ($mount_exists && echo 'stale (not mounted)' || echo 'not found'))"
            echo ""
            echo "Options:"
            echo "  A) Reuse - Attach to existing session"
            echo "  B) Kill & restart - Unmount, kill session, start fresh"
            echo "  C) Abort - Cancel and do nothing"
            echo ""
            echo -n "Choose [A/B/C]: "
            read -r choice

            case "${choice:l}" in
                a)
                    if $session_exists; then
                        echo "Attaching to existing session..."
                        tmux attach -t "$session_name"
                        return
                    else
                        echo "No existing session to attach. Use B to start fresh."
                        return 1
                    fi
                    ;;
                b)
                    echo "Cleaning up..."
                    tmux kill-session -t "$session_name" 2>/dev/null
                    if $is_mounted; then
                        _unmount_sshfs "$mount_dir"
                    fi
                    rmdir "$mount_dir" 2>/dev/null
                    echo "Cleaned. Starting fresh..."
                    ;;
                c|*)
                    echo "Cancelled."
                    return 0
                    ;;
            esac
        fi

        if ! _is_mounted "$mount_dir"; then
            mkdir -p "$mount_dir"

            trap "_dev_cleanup_mount \"$mount_dir\"; trap - INT TERM EXIT" INT TERM EXIT

            echo "Mounting $remote_spec:$remote_path to $mount_dir..."
            if ! _sshfs "${remote_spec}:${remote_path}" "$mount_dir" -o reconnect -o Compression=yes -o ServerAliveInterval=15 -o ServerAliveCountMax=3; then
                echo "ERROR: SSHFS mount failed for $remote_spec:$remote_path"
                _dev_cleanup_mount "$mount_dir"
                return 1
            fi

            if ! _is_mounted "$mount_dir"; then
                echo "ERROR: SSHFS command succeeded but mount point is not accessible"
                _dev_cleanup_mount "$mount_dir"
                return 1
            fi

            trap - INT TERM EXIT
        else
            echo "Already mounted: ${mount_dir}"
        fi

        tmux new-session -d -s "$session_name" -n vim -c "$mount_dir"
        tmux send-keys -t "${session_name}:vim" 'vim' "Enter"

        tmux new-window -t "$session_name" -n opencode -c "$mount_dir"
        tmux send-keys -t "${session_name}:opencode" 'opencode' "Enter"

        tmux new-window -t "$session_name" -n ssh -c "$HOME"
        tmux send-keys -t "${session_name}:ssh" "ssh ${remote_spec}" "Enter"

        sleep 1
        tmux send-keys -t "${session_name}:ssh" "cd ${remote_path}" "Enter"
        
        echo "DEBUG: session_name=[$session_name]"
        echo "DEBUG: remote_spec=[$remote_spec]"

        echo ""
        echo "Remote session created: $session_name"
        echo "Mount point: $mount_dir"
        echo "Run 'dev-umount $session_name' when done to unmount"

        sleep 0.2
        tmux select-window -t "${session_name}:0"
        tmux attach -t "$session_name"
        return
    fi

    local dir="$arg"
    dir="$(cd "$dir" && pwd)"

    local last2=$(echo "$dir" | rev | cut -d'/' -f1-2 | rev | tr '/' '-')
    local hash=$(echo "$dir" | portable_md5)
    local session_name="dev-${last2}-${hash}"
    session_name=$(echo "$session_name" | tr -cd 'a-zA-Z0-9-_' | tr -s '_')

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach -t "$session_name"
        return
    fi

    tmux new-session -d -s "$session_name" -n vim -c "$dir"
    tmux send-keys -t "${session_name}:vim" 'vim' "Enter"

    tmux new-window -t "$session_name" -n opencode -c "$dir"
    tmux send-keys -t "${session_name}:opencode" 'opencode' "Enter"

    tmux new-window -t "$session_name" -n shell -c "$dir"

    tmux select-window -t "${session_name}:vim"
    tmux attach -t "$session_name"
}
