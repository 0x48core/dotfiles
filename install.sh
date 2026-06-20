#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  echo "  linked $dst"
}

echo "Installing dotfiles from $DOTFILES"

# zsh
link "$DOTFILES/zsh/.zshrc"    "$HOME/.zshrc"
link "$DOTFILES/zsh/.zshenv"   "$HOME/.zshenv"
link "$DOTFILES/zsh/.zprofile" "$HOME/.zprofile"

# git
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# starship
link "$DOTFILES/config/starship.toml" "$HOME/.config/starship.toml"

# nvim
link "$DOTFILES/nvim/init.vim" "$HOME/.config/nvim/init.vim"

echo "Done."
