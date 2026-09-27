# Ruby & Jekyll Setup Guide

macOS ships Ruby 2.6, which is too old for current Jekyll. Use Homebrew's Ruby instead.

## Install

```bash
./scripts/setup-jekyll.sh
source ~/.zshrc
```

Or manually:

```bash
brew install ruby
source ~/.zshrc          # zsh/.zshrc puts Homebrew Ruby first on PATH
gem install bundler jekyll
```

---

## PATH

`zsh/.zshrc` prepends, when Homebrew Ruby is installed:

| Chip | Ruby | Gem executables |
|------|------|-----------------|
| Apple Silicon (`arm64`) | `/opt/homebrew/opt/ruby/bin` | `/opt/homebrew/lib/ruby/gems/<ver>/bin` |
| Intel (`x86_64`) | `/usr/local/opt/ruby/bin` | `/usr/local/lib/ruby/gems/<ver>/bin` |

`<ver>` is detected automatically (newest dir under `lib/ruby/gems/`), so a Ruby upgrade needs no edit.

## Verify

```bash
which ruby   # /opt/homebrew/opt/ruby/bin/ruby (or /usr/local/...)
ruby -v      # 3.x, not 2.6
jekyll -v
```

---

## Usage

```bash
jekyll new mysite
cd mysite
bundle exec jekyll serve   # http://localhost:4000
```

## Troubleshooting

- **`jekyll: command not found`** — the gems bin dir isn't on PATH. Open a new shell, then check `ruby -e 'puts Gem.bindir'` is listed in `echo $PATH`.
- **`which ruby` shows `/usr/bin/ruby`** — Homebrew Ruby isn't installed or the shell wasn't reloaded.
