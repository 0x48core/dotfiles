#!/usr/bin/env bash
# Bootstrap dotfiles on macOS, Linux, or Windows (WSL2)
#   ./install.sh                # prerequisites, Homebrew, Oh My Zsh, symlinks, Brewfile
#   ./install.sh --no-packages  # same, without `brew bundle`
#   ./install.sh --links        # symlinks only
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/platform.sh
source "$DOTFILES/scripts/lib/platform.sh"

MODE="full"
case "${1:-}" in
  "")            ;;
  --no-packages) MODE="no-packages" ;;
  --links)       MODE="links" ;;
  *) echo "Usage: $0 [--no-packages|--links]"; exit 1 ;;
esac

OS="$(detect_os)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  # Keep a real file instead of silently overwriting it
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "  backed up $dst"
  fi
  ln -sfn "$src" "$dst"
  echo "  linked $dst"
}

link_all() {
  echo "Linking dotfiles..."
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
}

install_prerequisites() {
  echo "Installing prerequisites..."
  case "$OS" in
    macos)
      if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install
        echo "Finish the Command Line Tools install, then rerun $0"
        exit 1
      fi
      ;;
    linux|wsl)
      if [ "$(id -u)" -eq 0 ]; then
        echo "Run as your normal user, not root (Homebrew refuses to run as root)"
        exit 1
      fi
      if [ "$OS" = wsl ]; then
        case "$DOTFILES" in
          /mnt/*) echo "Clone into the Linux filesystem (e.g. ~/dotfiles), not $DOTFILES"; exit 1 ;;
        esac
      fi
      case "$(linux_pkg_manager)" in
        apt)
          as_root apt-get update
          as_root apt-get install -y build-essential procps curl file git zsh
          ;;
        dnf)
          as_root dnf group install -y development-tools
          as_root dnf install -y procps-ng curl file git zsh util-linux-user
          ;;
        pacman)
          as_root pacman -Sy --needed --noconfirm base-devel procps-ng curl file git zsh
          ;;
      esac
      ;;
  esac
}

install_homebrew() {
  if ! brew_bin >/dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$("$(brew_bin)" shellenv)"
}

# Oh My Zsh + the zsh-autosuggestions plugin used in .zshrc
install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  local plugin="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  [ -d "$plugin" ] || git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$plugin"
}

install_packages() {
  echo "Installing Brewfile packages (this takes a while)..."
  brew bundle --file="$DOTFILES/Brewfile" \
    || echo "Some packages failed — rerun: brew bundle --file=$DOTFILES/Brewfile"
}

set_default_shell() {
  local zsh_bin
  zsh_bin="$(command -v zsh)"
  [ "$(basename "${SHELL:-}")" = zsh ] && return
  # chsh asks for a password; don't hang in CI or piped runs
  if [ ! -t 0 ]; then
    echo "Set zsh as your shell with: chsh -s $zsh_bin"
    return
  fi
  grep -qx "$zsh_bin" /etc/shells || echo "$zsh_bin" | as_root tee -a /etc/shells >/dev/null
  as_root chsh -s "$zsh_bin" "$(id -un)"
}

echo "Installing dotfiles from $DOTFILES ($OS, $MODE)"

if [ "$MODE" = links ]; then
  link_all
else
  install_prerequisites
  install_homebrew
  link_all            # before Oh My Zsh, so its installer keeps our .zshrc
  install_oh_my_zsh
  [ "$MODE" = full ] && install_packages
  set_default_shell
fi

echo ""
echo "Done. Open a new terminal (or run: exec zsh -l)."
if [ "$OS" = wsl ]; then
  echo "Enable Docker Desktop > Settings > Resources > WSL integration for this distro."
fi
