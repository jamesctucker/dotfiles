#!/usr/bin/env zsh
set -e

DOTFILES_DIR="${0:A:h}"
SKIP_PACKAGES="${1:-}"

# ── Load personal overrides if present (gitignored) ───────────────────────────
if [[ -f "$DOTFILES_DIR/install-config" ]]; then
  source "$DOTFILES_DIR/install-config"
else
  echo "⚠️  No install-config file found."
  echo "   Git identity (name/email) will NOT be configured automatically."
  echo "   Create $DOTFILES_DIR/install-config when ready (see README).\n"
fi

# ── OS Detection ──────────────────────────────────────────────────────────────
if [[ "$OSTYPE" == darwin* ]]; then
  OS="macos"
elif [[ -f /etc/os-release ]] && grep -qi "ubuntu" /etc/os-release; then
  OS="ubuntu"
  ARCH=$(uname -m)
else
  echo "⚠️  Unsupported OS. Add support in bootstrap.sh or install manually."
  exit 1
fi

echo "🖥  Detected OS: $OS"

# ── Package Installation ──────────────────────────────────────────────────────
if [[ "$SKIP_PACKAGES" != "--skip-system-packages" ]]; then
  echo "\nPackages to install: tmux, neovim, fzf, ripgrep, fd, mise, opencode"
  echo -n "Proceed? [y/N] "
  read -r response

  if [[ "$response" =~ ^[Yy]$ ]]; then

    # ── macOS ──────────────────────────────────────────────────────────────
    if [[ "$OS" == "macos" ]]; then
      if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew update
      brew install tmux neovim fzf ripgrep fd git
      brew install --cask ghostty 2>/dev/null || true

    # ── Ubuntu ─────────────────────────────────────────────────────────────
    elif [[ "$OS" == "ubuntu" ]]; then
      sudo apt-get update -qq
      sudo apt-get install -y tmux git curl unzip build-essential ripgrep fd-find fzf

      if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -1)" < "NVIM v0.10" ]]; then
        [[ "$ARCH" == "aarch64" ]] \
          && NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz" \
          || NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        curl -fsSL "$NVIM_URL" -o /tmp/nvim.tar.gz
        sudo tar -C /usr/local -xzf /tmp/nvim.tar.gz --strip-components=1
        rm /tmp/nvim.tar.gz
      fi

      if ! command -v fd &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
      fi
    fi

    # ── mise ───────────────────────────────────────────────────────────────
    if ! command -v mise &>/dev/null; then
      echo "Installing mise..."
      curl https://mise.run | sh
    fi
    export PATH="$HOME/.local/bin:$PATH"
    eval "$($HOME/.local/bin/mise activate zsh)"
    mise install node@lts python@latest ruby@latest
    mise use --global node@lts python@latest ruby@latest

    # ── OpenCode ───────────────────────────────────────────────────────────
    if ! command -v opencode &>/dev/null; then
      echo "Installing OpenCode..."
      curl -fsSL https://opencode.ai/install | sh
    fi

  else
    echo "Skipping package installs."
  fi
fi

# ── Configure git identity ────────────────────────────────────────────────────
if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  echo "  Git identity set: $GIT_NAME <$GIT_EMAIL>"
fi

# ── Symlink dotfiles (install.sh handles its own overwrite warnings) ──────────
echo "\nLinking dotfiles..."
"$DOTFILES_DIR/install.sh"

echo "\n✅ Bootstrap complete. Run: exec \$SHELL"