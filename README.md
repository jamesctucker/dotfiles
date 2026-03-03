# dotfiles

Personal dotfiles for macOS and Ubuntu 24.04 LTS, managed via symlinks.

## What's Inside

| File | Location |
|---|---|
| tmux | `.config/tmux/tmux.conf` |
| zsh | `.config/zsh/.zshrc` |
| git | `.config/git/gitconfig` |
| git global ignore | `.config/git/gitignore_global` |
| Neovim | `.config/nvim/` |

## New Machine Setup

```zsh
git clone git@github.com:yourname/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Create your personal values file (see Personal Config below)
cp install-config.example install-config
vim install-config

# Run bootstrap (installs packages + symlinks dotfiles)
./bootstrap.sh

# Reload shell
exec $SHELL
```

Then create your two machine-local files manually (see [Machine-Local Config](#machine-local-config) below).

## Everyday Usage

| Task | Command |
|---|---|
| Pull latest config + re-link | `cd ~/dotfiles && git pull && ./bootstrap.sh --skip-system-packages` |
| Re-link dotfiles only | `cd ~/dotfiles && ./install.sh` |
| Reload tmux config | `Ctrl-a` then `r` (inside tmux) |
| Reload zsh | `exec $SHELL` |

## What bootstrap.sh Installs

### macOS
- Homebrew
- tmux, Neovim, fzf, ripgrep, fd, git
- Ghostty (cask)
- mise (manages Node, Python, Ruby)
- OpenCode

### Ubuntu 24.04 LTS
- tmux, git, curl, build-essential, ripgrep, fzf, fd-find
- Neovim (latest, pulled directly from GitHub releases)
- mise (manages Node, Python, Ruby)
- OpenCode

### All Platforms via mise
| Runtime | Version |
|---|---|
| Node | LTS (20.x) |
| Python | Latest (3.12.x) |
| Ruby | Latest (3.x) |

## Personal Config

`install-config` is **gitignored** and never committed. It holds your personal
values used during bootstrap. Create it from the example before running:

```zsh
# ~/dotfiles/install-config
GITHUB_USERNAME="yourname"
GIT_NAME="Your Name"
GIT_EMAIL="you@example.com"
```

An `install-config.example` is committed to the repo as a reference template.

## Machine-Local Config

These two files are **gitignored** and created manually on each machine.
They hold config that differs between machines (OS-specific paths, work email, signing keys).

### `~/.zshrc.local`

```zsh
# macOS (MacBook Air)
eval "$(/opt/homebrew/bin/brew shellenv)"
export LDFLAGS="-L/opt/homebrew/opt/zlib/lib"
export CPPFLAGS="-I/opt/homebrew/opt/zlib/include"
```

```zsh
# Ubuntu - add any Linux-specific overrides here
```

### `~/.config/git/config.local`

```gitconfig
[user]
  name = Your Name
  email = you@yourcompany.com
```

This file is referenced via `[include]` in `gitconfig` but is gitignored—
git identity is never committed to the repo.

## Backups

`install.sh` detects existing files before overwriting and backs them up to:

```
~/.dotfiles-backup/YYYYMMDD_HHMMSS/
```

To restore a backup:

```zsh
ls ~/.dotfiles-backup/                          # find your timestamp
cp ~/.dotfiles-backup/20260303_120000/.zshrc ~/  # restore specific file
```

## tmux Quick Reference

Prefix is `Ctrl-a`.

| Action | Keys |
|---|---|
| Vertical split | `Ctrl-a` `\|` |
| Horizontal split | `Ctrl-a` `-` |
| Navigate panes | `Ctrl-a` `h/j/k/l` |
| Resize pane | `Ctrl-a` `H/J/K/L` |
| New window | `Ctrl-a` `c` |
| Rename window | `Ctrl-a` `,` |
| Switch window | `Ctrl-a` `0-9` |
| New session | `tmux new -s name` |
| List sessions | `tmux ls` |
| Detach | `Ctrl-a` `d` |
| Attach | `tmux attach -t name` |
| Switch session | `Ctrl-a` `s` |
| Reload config | `Ctrl-a` `r` |

## Structure

```
dotfiles/
├── README.md
├── bootstrap.sh          # installs system packages + runs install.sh
├── install.sh            # symlinks dotfiles to expected locations
├── install-config        # gitignored: personal values (name, email)
├── install-config.example
├── .gitignore
└── .config/
    ├── tmux/
    │   └── tmux.conf
    ├── zsh/
    │   └── .zshrc
    ├── git/
    │   ├── gitconfig
    │   └── gitignore_global
    └── nvim/             # populated in Phase 2 of learning plan
```

## Adding a New Dotfile

1. Move the file into `~/dotfiles/.config/<tool>/`
2. Add a symlink entry to `install.sh`
3. Run `./install.sh`
4. Commit

```zsh
# Example: adding a new tool config
mv ~/.toolrc ~/dotfiles/.config/tool/toolrc
# Add to install.sh links map:
#   .config/tool/toolrc   "$HOME/.toolrc"
cd ~/dotfiles && ./install.sh
git add . && git commit -m "Add tool config"
```
