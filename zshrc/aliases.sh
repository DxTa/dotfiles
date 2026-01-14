#!/bin/zsh
# aliases.sh - Command aliases

# Docker aliases
alias docker-clean='docker container rm $(docker ps -a -q --filter "status=exited") && docker system prune -a --filter "until=24h"'
alias docker-clean-more='docker container rm $(docker ps -a -q --filter "status=exited") || true && docker system prune -a --filter "until=1h"'

# pkgx aliases
alias pkgx-yarn='pkgx +node@$(cat .nvmrc) +classic.yarnpkg.com yarn'
alias yarn='pkgx +node@$(cat .nvmrc) +classic.yarnpkg.com yarn'
alias pkgx-node='pkgx +node@$(cat .nvmrc)'
alias pkgx-python310-venv="pkgx uv venv --python 3.10 --seed venv"
alias wormhole='$HOME/.local/venv/bin/wormhole'
alias ccmanager='pkgx npx ccmanager'
alias bun='pkgx bun'

# rm alias (safer deletion with trash-put)
alias rm='trash-put'
