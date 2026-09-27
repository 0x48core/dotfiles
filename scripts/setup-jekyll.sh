#!/usr/bin/env bash
# Install Homebrew Ruby and Jekyll
set -euo pipefail

command -v brew >/dev/null || { echo "Homebrew required — see https://brew.sh"; exit 1; }

# Install Ruby via brew
if ! brew list ruby >/dev/null 2>&1; then
  echo "Installing Ruby..."
  brew install ruby
else
  echo "Ruby already installed via brew."
fi

# Use Homebrew Ruby for this script, even before the shell is reloaded
BREW_PREFIX="$(brew --prefix)"
RUBY_BIN="$BREW_PREFIX/opt/ruby/bin"
export PATH="$RUBY_BIN:$PATH"

if [[ "$(command -v ruby)" != "$RUBY_BIN/ruby" ]]; then
  echo "Expected ruby at $RUBY_BIN/ruby, got $(command -v ruby)"
  exit 1
fi
echo "Using $(ruby -v)"

# Gem executables land in lib/ruby/gems/<api-version>/bin
GEM_BIN="$(ruby -e 'puts Gem.bindir')"
export PATH="$GEM_BIN:$PATH"

echo "Installing bundler and jekyll..."
gem install bundler jekyll

echo ""
echo "Installed:"
for bin in bundle jekyll; do
  if [[ -x "$GEM_BIN/$bin" ]]; then
    echo "  ✓ $bin"
  else
    echo "  ✗ $bin (not found in $GEM_BIN)"
  fi
done

echo ""
echo "Ruby and gem bin paths are set in zsh/.zshrc. Reload your shell:"
echo "  source ~/.zshrc"
echo "  which ruby    # $RUBY_BIN/ruby"
echo "  jekyll -v"
