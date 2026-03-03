# ── mise (replaces nvm, pyenv, rbenv) ────────────────────────────────────────
eval "$($HOME/.local/bin/mise activate zsh)"

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# ── AWS aliases ───────────────────────────────────────────────────────────────
alias aca="aws sts get-caller-identity"
alias apl="export AWS_PROFILE=lower"
alias app="export AWS_PROFILE=production"

# ── Git worktree PR checkout ──────────────────────────────────────────────────
pr() {
  local n="$1"
  if [ -z "$n" ]; then echo "usage: pr <number>"; return 1; fi
  git fetch origin pull/$n/head:pr-$n || return 1
  git worktree add ../$(basename "$PWD")-pr-$n pr-$n || return 1
  echo "Worktree at ../$(basename "$PWD")-pr-$n"
  (cd ../$(basename "$PWD")-pr-$n && git diff --name-status origin/master...HEAD)
}

# ── Machine-local overrides (gitignored, not committed) ──────────────────────
# Create ~/.zshrc.local for machine-specific config (e.g. Homebrew paths on Mac)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"