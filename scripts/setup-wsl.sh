#!/usr/bin/env bash
# Bootstrap these dotfiles inside WSL2 Ubuntu (run from the Linux side, not PowerShell)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -qi microsoft /proc/version 2>/dev/null || { echo "Not running inside WSL"; exit 1; }

case "$DOTFILES" in
  /mnt/*) echo "Clone the repo into the Linux filesystem (e.g. ~/dotfiles), not $DOTFILES"; exit 1 ;;
esac

echo "Installing apt prerequisites..."
sudo apt-get update
sudo apt-get install -y build-essential procps curl file git zsh unzip

# Homebrew on Linux
BREW=/home/linuxbrew/.linuxbrew/bin/brew
if [ ! -x "$BREW" ]; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("$BREW" shellenv)"

# Oh My Zsh + the zsh-autosuggestions plugin used in .zshrc
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
AUTOSUGGEST="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
[ -d "$AUTOSUGGEST" ] || git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGEST"

"$DOTFILES/install.sh"

echo "Installing Brewfile packages (this takes a while)..."
brew bundle --file="$DOTFILES/Brewfile" || echo "Some packages failed — rerun: brew bundle --file=$DOTFILES/Brewfile"

ZSH_BIN="$(command -v zsh)"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_BIN" ]; then
  echo "Setting zsh as the default shell..."
  sudo chsh -s "$ZSH_BIN" "$USER"
fi

echo ""
echo "Done. Next:"
echo "  1. Restart the terminal (or run: exec zsh -l)"
echo "  2. Enable Docker Desktop > Settings > Resources > WSL integration for this distro"
echo "  3. docker version && tenv tf install latest"
