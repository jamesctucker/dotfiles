#!/usr/bin/env zsh
set -e

DOTFILES_DIR="${0:A:h}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

typeset -A links
links=(
  .config/tmux/.tmux.conf         "$HOME/.tmux.conf"
  .config/zsh/.zshrc             "$HOME/.zshrc"
  .config/git/.gitconfig          "$HOME/.gitconfig"
  .config/git/.gitignore_global   "$HOME/.gitignore_global"
  .config/nvim                   "$HOME/.config/nvim"
)

# ── Pre-flight: detect files that would be overwritten ────────────────────────
typeset -a will_overwrite
for src target in ${(kv)links}; do
  if [[ -e "$target" && ! -L "$target" ]]; then
    # Exists AND is a real file/dir (not already a symlink we manage)
    will_overwrite+=("$target")
  elif [[ -L "$target" ]]; then
    current_dest=$(readlink "$target")
    if [[ "$current_dest" != "$DOTFILES_DIR/$src" ]]; then
      # Symlink exists but points somewhere else
      will_overwrite+=("$target (symlink → $current_dest)")
    fi
  fi
done

if (( ${#will_overwrite[@]} > 0 )); then
  echo "⚠️  The following existing files will be backed up and replaced:\n"
  for f in "${will_overwrite[@]}"; do
    echo "  • $f"
  done
  echo "\nBackup destination: $BACKUP_DIR"
  echo -n "\nProceed? [y/N] "
  read -r response
  [[ "$response" =~ ^[Yy]$ ]] || { echo "Aborted. Nothing was changed."; exit 0; }

  # Back up before overwriting
  mkdir -p "$BACKUP_DIR"
  for src target in ${(kv)links}; do
    if [[ -e "$target" && ! -L "$target" ]] || \
       [[ -L "$target" && "$(readlink "$target")" != "$DOTFILES_DIR/$src" ]]; then
      cp -r "$target" "$BACKUP_DIR/" 2>/dev/null || true
      echo "  Backed up $(basename $target) → $BACKUP_DIR/"
    fi
  done
fi

# ── Create symlinks ───────────────────────────────────────────────────────────
echo "\nLinking dotfiles..."
for src target in ${(kv)links}; do
  mkdir -p "${target:h}"
  ln -sfn "$DOTFILES_DIR/$src" "$target"
  echo "  Linked $src → $target"
done

echo "\n✅ Done. Run: exec \$SHELL"