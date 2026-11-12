# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Starship draws the prompt when installed; agnoster is only the fallback
# (it also warns "character not in range" when en_US.UTF-8 isn't generated)
if command -v starship >/dev/null 2>&1; then
  ZSH_THEME=""
else
  ZSH_THEME="agnoster"
fi

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

# Set by `brew shellenv` in .zprofile (/opt/homebrew, /usr/local or /home/linuxbrew/.linuxbrew)
_brew_prefix="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}"
[ -d "$_brew_prefix/opt/libpq/bin" ] && export PATH="$_brew_prefix/opt/libpq/bin:$PATH"

# Homebrew Ruby (ahead of the system Ruby) + its gem executables
if [ -n "$_brew_prefix" ] && [ -d "$_brew_prefix/opt/ruby/bin" ]; then
  # Pick the newest gems dir so a Ruby upgrade doesn't need a manual edit
  _ruby_gem_bins=("$_brew_prefix"/lib/ruby/gems/*/bin(Nn))
  (( ${#_ruby_gem_bins} )) && export PATH="${_ruby_gem_bins[-1]}:$PATH"
  export PATH="$_brew_prefix/opt/ruby/bin:$PATH"
fi
unset _brew_prefix _ruby_gem_bins

# macOS-style open/pbcopy/pbpaste on Linux and WSL
if [[ "$OSTYPE" == linux* ]]; then
  if grep -qi microsoft /proc/version 2>/dev/null; then
    alias open='explorer.exe'
    alias pbcopy='clip.exe'
    pbpaste() { powershell.exe -NoProfile -Command Get-Clipboard | tr -d '\r'; }
  else
    alias open='xdg-open'
    if command -v wl-copy >/dev/null 2>&1; then
      alias pbcopy='wl-copy'
      alias pbpaste='wl-paste --no-newline'
    elif command -v xclip >/dev/null 2>&1; then
      alias pbcopy='xclip -selection clipboard'
      alias pbpaste='xclip -selection clipboard -o'
    fi
  fi
fi

# Kubernetes
if command -v kubectl >/dev/null 2>&1; then
  alias k='kubectl'
  (( $+functions[compdef] )) || { autoload -Uz compinit && compinit; }
  source <(kubectl completion zsh)
  compdef k=kubectl
fi

# Initialize Starship if installed
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
