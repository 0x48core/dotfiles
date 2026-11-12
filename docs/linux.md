# Linux Setup

`./install.sh` supports apt (Debian, Ubuntu), dnf (Fedora) and pacman (Arch) distros. Run it as your normal user with `sudo` access, not as root: Homebrew refuses to run as root.

```bash
git clone https://github.com/0x48core/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
exec zsh -l
```

Homebrew lives in `/home/linuxbrew/.linuxbrew`; `.zprofile` finds it automatically. On Windows, see [wsl.md](wsl.md) instead.

## What's different from macOS

The Brewfile's macOS-only casks are skipped. Install their Linux equivalents yourself:

| macOS cask | Linux |
|---|---|
| `docker-desktop` | Docker Engine (below) |
| `multipass` | `sudo snap install multipass` |
| `google-cloud-sdk` | `./scripts/setup-gcloud.sh` (apt or dnf repo) |

### Docker Engine

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"   # log out and back in to use docker without sudo
docker version
```

### Clipboard

`.zshrc` maps `pbcopy`/`pbpaste` to `wl-copy`/`wl-paste` (Wayland) or `xclip` (X11), and `open` to `xdg-open`. Neovim's `clipboard=unnamedplus` uses the same tools. Install one:

```bash
sudo apt-get install -y wl-clipboard   # or: xclip
```

### mkcert

`mkcert -install` needs `certutil` to add the CA to Firefox and Chrome:

```bash
sudo apt-get install -y libnss3-tools  # Fedora: sudo dnf install -y nss-tools
mkcert -install
```
