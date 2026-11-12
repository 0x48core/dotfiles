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
├── scripts/lib/platform.sh  # OS detection shared by the scripts
└── install.sh       # bootstrap + symlinks (macOS, Linux, WSL)
```

## Install

Works on macOS, Linux (apt, dnf or pacman) and Windows via WSL2:

```bash
git clone https://github.com/0x48core/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh                # prerequisites, Homebrew, Oh My Zsh, symlinks, Brewfile
./install.sh --no-packages  # same, without `brew bundle`
./install.sh --links        # symlinks only
```

Existing files are moved to `<file>.bak.<timestamp>` before being linked. Rerunning is safe.

| Platform | Notes |
|---|---|
| macOS | Installs Xcode Command Line Tools first if missing |
| Linux | Run as your user (not root); see [docs/linux.md](docs/linux.md) for Docker and clipboard |
| Windows | Run inside WSL2 Ubuntu; see [docs/wsl.md](docs/wsl.md) for the Windows side |

macOS-only Brewfile entries (`docker-desktop`, `multipass`, `google-cloud-sdk`) are skipped on Linux and WSL.

## Secrets

Keep secrets out of this repo. Export them in `~/.zshenv.local` (not tracked):

```bash
export ANTHROPIC_API_KEY="anthropic_api_key"
export DIGITALOCEAN_TOKEN="dop_v1_..."      # terraform digitalocean provider
```

`zsh/.zshenv` sources it automatically when present.
