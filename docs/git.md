# Git & GitHub CLI Guide

## GitHub CLI (gh)

### Authentication

```bash
# Login
gh auth login --hostname github.com

# Switch between accounts
gh auth switch --hostname github.com --user 0x48core

# Check current status
gh auth status
```

### Multi-account setup

```bash
# Login with a second account (work, personal, etc.)
gh auth login --hostname github.com

# List all authenticated accounts
gh auth status

# Switch to a specific account before running gh commands
gh auth switch --hostname github.com --user 0x48core
```

### Common commands

```bash
# Repos
gh repo clone 0x48core/dotfiles
gh repo create myapp --private
gh repo view --web

# Pull requests
gh pr create --title "feat: my feature" --body "description"
gh pr list
gh pr checkout 42
gh pr merge 42 --squash

# Issues
gh issue create --title "bug: something broken"
gh issue list
gh issue view 10

# Workflows (GitHub Actions)
gh run list
gh run view 123
gh run watch
```

---

## Git config

```bash
# Identity
git config --global user.name  "Augustus Nguyen"
git config --global user.email "yourmail@example.com"

# Default branch
git config --global init.defaultBranch main

# Credential helper (via gh)
git config --global credential.helper "!/opt/homebrew/bin/gh auth git-credential"
```

---

## Useful aliases

Add to `git/.gitconfig`:

```ini
[alias]
  st  = status -sb
  lg  = log --oneline --graph --decorate --all
  undo = reset --soft HEAD~1
  aliases = config --get-regexp alias
```

---

## Common workflows

```bash
# Undo last commit (keep changes staged)
git reset --soft HEAD~1

# Stash with a name
git stash push -m "wip: my feature"
git stash list
git stash pop

# Clean up merged branches
git branch --merged | grep -v '\*\|main' | xargs git branch -d

# Sync fork with upstream
git remote add upstream https://github.com/original/repo
git fetch upstream
git rebase upstream/main
```
