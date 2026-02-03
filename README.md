# dotfiles

Dotfiles + a lightweight "dev session" workflow built around:
- `dev` shell function (creates an opinionated tmux session)
- remote SSHFS mounts for `user@host:/path` targets
- tmux prefix rebinding + a few productivity keys
- Vim shortcuts (including opencode TUI send-from-Vim helpers)

Shortcuts below are sourced from this repo's config files and may be overridden by local changes.

## Dev workflow (custom)

Source of truth: `zshrc/functions.sh`

### Start / attach a dev session

- Local:
  - `dev [path]`
    - If `path` omitted: uses current directory
    - Creates/attaches a tmux session named like `dev-<last2dirs>-<hash>`
    - Windows:
      - `editor`: Vim + opencode side-by-side
      - `shell`: plain shell

- Remote (SSHFS, Linux-oriented):
  - `dev user@host:/remote/path`
    - Mounts the remote path via SSHFS into:
      - `~/dev/sshfs_dirs/<host>-<dir>-<hash>`
    - Creates/attaches a tmux session named like:
      - `dev-<host>-<dir>-<hash>`
    - Windows:
      - `editor`: Vim + opencode side-by-side (working directory is the mounted SSHFS dir)
      - `ssh`: SSH into host and `cd` to the remote path
    - When you're done:
      - `dev-umount <session_name>` kills the tmux session and unmounts the SSHFS mount.

- Zed variant:
  - `dev-zed [path]` or `dev-zed user@host:/remote/path`
    - Similar idea, but uses Zed + an `opencode` tmux window

### List / cleanup

- `dev-list` — shows mounted dev SSHFS dirs + their session names
- `dev-cleanup` — removes stale (not-mounted) dirs under `~/dev/sshfs_dirs/`
- `dev-umount <session_name|mount_path>`
  - Kills the tmux session (if present)
  - Unmounts SSHFS (if mounted) + removes the mount dir

## tmux shortcuts (custom)

Source of truth: `tmux/tmux.conf`

### Prefix

- tmux prefix is backtick: `` ` `` (rebinding from `C-b`)
- Send a literal backtick: double-tap `` ` ``

### Session-aware "dev cleanup"

- `` ` `` + `x`
  - If session name matches `^dev-`: confirm → run `dev-umount <session>`
  - Otherwise: shows "Not a dev session"

### Windows & panes

- `F1`..`F12` — select window N if it exists, otherwise create it
- `` ` `` + `h/j/k/l` — move between panes (repeatable)
- `` ` `` + `z` — toggle pane zoom

### Essentials (standard tmux, with this config)

- Detach: `` ` `` then `d`
- List sessions: `tmux ls`
- Attach: `tmux a -t <name>`
- Create window: `` ` `` then `c`
- Rename window: `` ` `` then `,`
- Split panes:
  - `` ` `` then `"` (horizontal)
  - `` ` `` then `%` (vertical)
- Copy mode (vi keys enabled):
  - Enter copy mode: `` ` `` then `[`
  - Move with `h/j/k/l`, search with `/`, quit with `q`

## Vim shortcuts (custom)

Sources of truth:
- `vim/vim_runtime/my_configs.vim` (custom mappings + opencode integration)
- `vim/vimrc` (loads vim_runtime config)

### opencode TUI integration (custom)

These mappings send text/prompts to the opencode server running in the dev tmux session.
They rely on `OPENCODE_PORT` being set in the tmux session environment.

- Visual mode:
  - `<leader>ke` — "Explain this code:" (sends selection)
  - `<leader>kr` — "Review this code:" (sends selection)
  - `<leader>kf` — "Fix this code:" (sends selection)
  - `<leader>kt` — "Write tests for:" (sends selection)
- Normal mode:
  - `<leader>kp` — prompt input → send as freeform opencode prompt

Leader key varies by your Vim setup; check with:
- `:let mapleader`

### YouCompleteMe (custom)

- `<leader>gd` — go to definition
- `<leader>gr` — go to references
- `<leader>gt` — get type
- `<leader>gk` — get doc
- `<leader>fi` — FixIt
- `<leader>rr` — rename (enters command expecting a name)
- `<leader>gi` — go to implementation

## Vim essentials (standard)

- Save: `:w`   Quit: `:q`   Save+quit: `:wq`   Quit without saving: `:q!`
- Search: `/pattern` (next `n`, previous `N`)
- Split windows: `:vs` (vertical), `:sp` (horizontal)
- Move between splits: `Ctrl-w h/j/k/l`
- Buffers: `:ls`, `:b <num>`, `:bd` (close buffer)
