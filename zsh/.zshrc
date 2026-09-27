# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(git zsh-autosuggestions)

# Load Oh My Zsh if installed
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# PATH
if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export GOPRIVATE=gitlab.ghn.vn/*

# Homebrew Ruby (ahead of macOS system Ruby 2.6) + its gem executables
if [[ "$(uname -m)" == "arm64" ]]; then
  _brew_prefix="/opt/homebrew"
else
  _brew_prefix="/usr/local"
fi
if [ -d "$_brew_prefix/opt/ruby/bin" ]; then
  # Pick the newest gems dir so a Ruby upgrade doesn't need a manual edit
  _ruby_gem_bins=("$_brew_prefix"/lib/ruby/gems/*/bin(Nn))
  (( ${#_ruby_gem_bins} )) && export PATH="${_ruby_gem_bins[-1]}:$PATH"
  export PATH="$_brew_prefix/opt/ruby/bin:$PATH"
fi
unset _brew_prefix _ruby_gem_bins

# Initialize Starship if installed
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
