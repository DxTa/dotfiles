#!/bin/zsh
# completions.sh - Zsh completions (interactive-only)

# bun completions
[ -s "/home/daniel/.bun/_bun" ] && source "/home/daniel/.bun/_bun"

# Completion for dev function - SSH hosts and remote paths
_dev() {
    local curcontext="$curcontext" state line ret=1

    _arguments -C \
        '1:path:->path' \
        && ret=0

    case "$state" in
    path)
        if compset -P 1 '*:'; then
            # After colon - complete remote paths via SSH
            local host="${IPREFIX%:}"
            _remote_files -h "$host" -- ssh && ret=0
        elif compset -P 1 '*@'; then
            # After @ in user@host - complete hosts
            _wanted hosts expl 'remote host' _ssh_hosts -r: -S: && ret=0
        else
            # Could be local path or start of remote spec (host or user@host)
            _alternative \
                'files:local directory:_files -/' \
                'hosts:SSH host:_ssh_hosts -r: -S:' \
                && ret=0
        fi
        ;;
    esac

    return ret
}

compdef _dev dev
