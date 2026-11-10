# dotfiles

Personal dotfiles for zsh, git, neovim, and starship.

## Structure

```
dotfiles/
├── zsh/
│   ├── .zshrc       # main shell config (oh-my-zsh + starship)
│   ├── .zshenv      # env vars, PATH (sourced by all shells)
│   └── .zprofile    # login shell config (brew on macOS/Linux, aliases)
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

### Windows (WSL2)

Install Ubuntu on WSL2 and Docker Desktop, then from the Ubuntu terminal:

```bash
git clone https://github.com/0x48core/dotfiles ~/dotfiles
~/dotfiles/scripts/setup-wsl.sh
```

See [docs/wsl.md](docs/wsl.md) for the Windows side (font, Docker integration, mkcert, gcloud).

## Secrets

Keep secrets out of this repo. Export them in `~/.zshenv.local` (not tracked):

```bash
export ANTHROPIC_API_KEY="anthropic_api_key"
export DIGITALOCEAN_TOKEN="dop_v1_..."      # terraform digitalocean provider
```

`zsh/.zshenv` sources it automatically when present.
