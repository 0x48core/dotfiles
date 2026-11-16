# shellcheck shell=bash
# Shared helpers for install.sh and scripts/*.sh (source it, don't run it)

# Prints macos | wsl | linux
detect_os() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then echo wsl; else echo linux; fi ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; return 1 ;;
  esac
}

# Prints apt | dnf | pacman
linux_pkg_manager() {
  local pm
  for pm in apt-get dnf pacman; do
    if command -v "$pm" >/dev/null; then echo "${pm%-get}"; return; fi
  done
  echo "No supported package manager (apt, dnf, pacman)" >&2
  return 1
}

# Run a command as root: directly when already root, otherwise via sudo
as_root() {
  if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi
}

# Path to brew, wherever it is installed (same order as zsh/.zprofile)
brew_bin() {
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [ -x "$b" ]; then echo "$b"; return; fi
  done
  return 1
}
