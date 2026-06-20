# dotfiles

Personal dotfiles for zsh, git, neovim, and starship.

## Structure

```
dotfiles/
├── zsh/
│   ├── .zshrc       # main shell config (oh-my-zsh + starship)
│   ├── .zshenv      # env vars, PATH (sourced by all shells)
│   └── .zprofile    # login shell config (brew, aliases)
├── git/
│   └── .gitconfig   # git identity, LFS, gh credential helper
├── nvim/
│   └── init.vim     # neovim config (vim-plug, gruvbox, coc.nvim)
├── config/
│   └── starship.toml
└── install.sh       # symlinks everything into place
```

## Install

```bash
git clone https://github.com/0x48core/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Secrets

Keep secrets out of this repo. Export them in `~/.zshenv.local` (not tracked):

```bash
export ANTHROPIC_API_KEY="anthropic_api_key"
```

Then source it at the end of `zsh/.zshenv`.
