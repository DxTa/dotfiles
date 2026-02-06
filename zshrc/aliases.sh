#!/bin/zsh
# aliases.sh - Command aliases

# Docker aliases
alias docker-clean='docker container rm $(docker ps -a -q --filter "status=exited") && docker system prune -a --filter "until=24h"'
alias docker-clean-more='docker container rm $(docker ps -a -q --filter "status=exited") || true && docker system prune -a --filter "until=1h"'

# pkgx aliases
pkgx_node_spec() {
    local version

    if [[ -s .nvmrc ]]; then
        version="$(tr -d '[:space:]' < .nvmrc)"
        version="${version#v}"

        if [[ -n "$version" ]]; then
            printf '+node@%s' "$version"
            return
        fi
    fi

    printf '+node'
}

alias pkgx-yarn='pkgx $(pkgx_node_spec) +classic.yarnpkg.com yarn'
alias yarn='pkgx $(pkgx_node_spec) +classic.yarnpkg.com yarn'
alias node='pkgx $(pkgx_node_spec) +classic.yarnpkg.com node'
alias pkgx-node='pkgx $(pkgx_node_spec)'
alias pkgx-python310-venv="pkgx uv venv --python 3.10 --seed venv"
alias wormhole='$HOME/.local/venv/bin/wormhole'
alias ccmanager='pkgx npx ccmanager'
alias bun='pkgx bun'

# rm alias (safer deletion with trash - cross-platform)
if command -v trash-put &>/dev/null; then
    alias rm='trash-put'  # Linux
elif command -v trash &>/dev/null; then
    alias rm='trash'  # macOS (brew install trash)
fi
