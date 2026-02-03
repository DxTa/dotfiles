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

# Check if GNOME Window Calls extension is available
_has_window_calls() {
    gdbus call --session --dest org.gnome.Shell \
        --object-path /org/gnome/Shell/Extensions/Windows \
        --method org.gnome.Shell.Extensions.Windows.List &>/dev/null
}

# Close Zed window by directory name (GNOME Wayland + xdotool fallback)
_close_zed_window() {
    local dir_hint="$1"
    [[ -z "$dir_hint" ]] && return 1
    
    # Method 1: GNOME Window Calls extension (Wayland)
    if _has_window_calls; then
        # Find ALL Zed windows matching the directory name in title
        local window_ids=$(gdbus call --session --dest org.gnome.Shell \
            --object-path /org/gnome/Shell/Extensions/Windows \
            --method org.gnome.Shell.Extensions.Windows.List 2>/dev/null | \
            sed "s/^('//;s/',)$//" | \
            jq -r ".[] | select(.wm_class == \"dev.zed.Zed\" and (.title | contains(\"$dir_hint\"))) | .id" 2>/dev/null)
        
        if [[ -n "$window_ids" ]]; then
            local closed_count=0
            while IFS= read -r window_id; do
                if [[ -n "$window_id" && "$window_id" != "null" ]]; then
                    echo "Closing Zed window via GNOME Window Calls (ID: $window_id)..."
                    gdbus call --session --dest org.gnome.Shell \
                        --object-path /org/gnome/Shell/Extensions/Windows \
                        --method org.gnome.Shell.Extensions.Windows.Close "$window_id" &>/dev/null
                    closed_count=$((closed_count + 1))
                fi
            done <<< "$window_ids"
            [[ $closed_count -gt 0 ]] && return 0
        fi
    fi
    
    # Method 2: xdotool fallback (X11)
    if command -v xdotool &>/dev/null; then
        local window_id=$(xdotool search --name ".*${dir_hint}.*" --class "Zed" 2>/dev/null | head -1)
        if [[ -n "$window_id" ]]; then
            echo "Closing Zed window via xdotool (ID: $window_id)..."
            xdotool windowclose "$window_id" 2>/dev/null
            return 0
        fi
    fi
    
    echo "Note: Could not find Zed window to close"
    return 1
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

    # Try to close Zed window if this is a dev-zed session
    if [[ "$session_name" == dev-zed-* ]]; then
        local dir_basename=""
        # Only use basename if mount_dir actually exists
        if [[ -d "$mount_dir" ]]; then
            dir_basename=$(basename "$mount_dir")
        fi
        # Extract directory hint from session name if mount_dir doesn't exist
        if [[ -z "$dir_basename" ]]; then
            # Extract directory hint from session name (e.g., dev-zed-tds-brose-hash → brose)
            dir_basename=$(echo "$session_name" | sed 's/^dev-zed-//; s/-[a-f0-9]*$//' | rev | cut -d'-' -f1 | rev)
        fi
        if [[ -n "$dir_basename" ]]; then
            _close_zed_window "$dir_basename"
            sleep 0.3
        fi
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

        # Find a free port in 40000-50000 for opencode server
        local opencode_port=$(python3 -c "
import socket, random
for _ in range(100):
    p = random.randint(40000, 50000); s = socket.socket()
    try: s.bind(('', p)); s.close(); print(p); break
    except: s.close()
")

        # Window 1: side-by-side vim (60%) | opencode (40%)
        tmux new-session -d -s "$session_name" -n editor -c "$mount_dir"
        tmux set-environment -t "$session_name" OPENCODE_PORT "$opencode_port"
        tmux send-keys -t "${session_name}:editor" 'vim' "Enter"
        tmux split-window -h -p 40 -t "${session_name}:editor" -c "$mount_dir"
        tmux send-keys -t "${session_name}:editor.2" "opencode --port $opencode_port" "Enter"

        # Window 2: SSH to remote
        tmux new-window -t "$session_name" -n ssh -c "$HOME"
        tmux send-keys -t "${session_name}:ssh" "ssh ${remote_spec}" "Enter"
        sleep 1
        tmux send-keys -t "${session_name}:ssh" "cd ${remote_path}" "Enter"

        echo ""
        echo "Remote session created: $session_name"
        echo "Mount point: $mount_dir"
        echo "opencode port: $opencode_port"
        echo "Run 'dev-umount $session_name' when done to unmount"

        sleep 0.2
        # Focus vim pane, attach
        tmux select-window -t "${session_name}:editor"
        tmux select-pane -t "${session_name}:editor.1"
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

    # Find a free port in 40000-50000 for opencode server
    local opencode_port=$(python3 -c "
import socket, random
for _ in range(100):
    p = random.randint(40000, 50000); s = socket.socket()
    try: s.bind(('', p)); s.close(); print(p); break
    except: s.close()
")

    # Window 1: side-by-side vim (60%) | opencode (40%)
    tmux new-session -d -s "$session_name" -n editor -c "$dir"
    tmux set-environment -t "$session_name" OPENCODE_PORT "$opencode_port"
    tmux send-keys -t "${session_name}:editor" 'vim' "Enter"
    tmux split-window -h -p 40 -t "${session_name}:editor" -c "$dir"
    tmux send-keys -t "${session_name}:editor.2" "opencode --port $opencode_port" "Enter"

    # Window 2: plain shell
    tmux new-window -t "$session_name" -n shell -c "$dir"

    # Focus vim pane, attach
    tmux select-window -t "${session_name}:editor"
    tmux select-pane -t "${session_name}:editor.1"
    tmux attach -t "$session_name"
}

# Dev workspace with Zed editor - creates tmux session with zed, opencode, and shell windows
# Supports local directories and remote SSH paths (host:/path or user@host:/path)
dev-zed() {
    local arg="${1:-$PWD}"

    if [[ "$arg" == *":"* ]]; then
        # === REMOTE PATH HANDLING ===
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
        local session_name="dev-zed-${host_part}-${path_last}-${hash}"
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

        # Check for Window Calls extension (warning will show in first pane)
        local window_calls_warning=""
        if ! _has_window_calls && [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
            window_calls_warning="echo -e '\\n⚠️  WARNING: GNOME Window Calls extension not installed.\\nZed window will NOT auto-close on Ctrl+Q+k.\\nInstall from: https://extensions.gnome.org/extension/4724/window-calls/\\n'"
        fi

        # Open Zed first (before tmux) so it can launch in background
        echo "Opening Zed for $mount_dir..."
        zed -n "$mount_dir" &

        tmux new-session -d -s "$session_name" -n editor -c "$mount_dir"
        [[ -n "$window_calls_warning" ]] && tmux send-keys -t "${session_name}:editor" "$window_calls_warning" "Enter"
        tmux send-keys -t "${session_name}:editor" "zed --wait '$mount_dir' 2>/dev/null || echo 'Zed window closed'" "Enter"

        tmux new-window -t "$session_name" -n opencode -c "$mount_dir"
        tmux send-keys -t "${session_name}:opencode" 'opencode' "Enter"

        tmux new-window -t "$session_name" -n ssh -c "$HOME"
        tmux send-keys -t "${session_name}:ssh" "ssh ${remote_spec}" "Enter"

        sleep 1
        tmux send-keys -t "${session_name}:ssh" "cd ${remote_path}" "Enter"

        echo ""
        echo "Remote Zed session created: $session_name"
        echo "Mount point: $mount_dir"
        echo "Run 'dev-umount $session_name' when done to unmount"
        echo ""
        echo "Note: Close Zed window or use Ctrl+Q+k to cleanup"

        sleep 0.2
        tmux select-window -t "${session_name}:opencode"
        tmux attach -t "$session_name"
        return
    fi

    # === LOCAL PATH HANDLING ===
    local dir="$arg"
    dir="$(cd "$dir" && pwd)"

    local last2=$(echo "$dir" | rev | cut -d'/' -f1-2 | rev | tr '/' '-')
    local hash=$(echo "$dir" | portable_md5)
    local session_name="dev-zed-${last2}-${hash}"
    session_name=$(echo "$session_name" | tr -cd 'a-zA-Z0-9-_' | tr -s '_')

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach -t "$session_name"
        return
    fi

    # Check for Window Calls extension (warning will show in first pane)
    local window_calls_warning=""
    if ! _has_window_calls && [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        window_calls_warning="echo -e '\\n⚠️  WARNING: GNOME Window Calls extension not installed.\\nZed window will NOT auto-close on Ctrl+Q+k.\\nInstall from: https://extensions.gnome.org/extension/4724/window-calls/\\n'"
    fi

    # Open Zed first (before tmux) so it can launch in background
    echo "Opening Zed for $dir..."
    zed -n "$dir" &

    tmux new-session -d -s "$session_name" -n editor -c "$dir"
    [[ -n "$window_calls_warning" ]] && tmux send-keys -t "${session_name}:editor" "$window_calls_warning" "Enter"
    tmux send-keys -t "${session_name}:editor" "zed --wait '$dir' 2>/dev/null || echo 'Zed window closed'" "Enter"

    tmux new-window -t "$session_name" -n opencode -c "$dir"
    tmux send-keys -t "${session_name}:opencode" 'opencode' "Enter"

    tmux new-window -t "$session_name" -n shell -c "$dir"

    tmux select-window -t "${session_name}:opencode"
    tmux attach -t "$session_name"
}
