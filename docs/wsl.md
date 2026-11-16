# Windows — WSL2 Setup

The dotfiles run unchanged inside WSL2 Ubuntu: zsh, git, nvim, starship, and Homebrew on Linux for the Brewfile. Windows only hosts the terminal, the font, and Docker Desktop.

## 1. Windows side (PowerShell as admin)

```powershell
wsl --install -d Ubuntu-24.04      # reboot when asked, then create your Linux user
winget install Microsoft.WindowsTerminal
winget install Docker.DockerDesktop
```

- **Font:** the `agnoster` theme and starship need Powerline glyphs. Install a Nerd Font (e.g. *MesloLGS NF* or *JetBrainsMono Nerd Font* from nerdfonts.com) and set it in Windows Terminal → Settings → Ubuntu → Appearance → Font face.
- **Docker:** Docker Desktop → Settings → Resources → WSL integration → enable *Ubuntu-24.04*. The `docker` CLI then appears inside WSL; don't install Docker separately in Ubuntu.
- **Resources (optional):** limit WSL's memory in `%UserProfile%\.wslconfig`, then `wsl --shutdown`:

  ```ini
  [wsl2]
  memory=8GB
  processors=4
  ```

## 2. Linux side (Ubuntu terminal)

Clone into the Linux filesystem, **not** `/mnt/c/...` (cross-filesystem I/O is slow, and file permissions and line endings break):

```bash
git clone https://github.com/0x48core/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
exec zsh -l
```

`install.sh` detects WSL and installs the apt prerequisites, Homebrew (`/home/linuxbrew/.linuxbrew`), Oh My Zsh with `zsh-autosuggestions`, links the dotfiles, runs `brew bundle`, then sets zsh as the default shell. It is safe to rerun.

macOS-only Brewfile entries (`docker-desktop`, `multipass`, `google-cloud-sdk`) are skipped on Linux.

## 3. Verify

```bash
docker version                 # Client and Server both show a version
tenv tf install latest && terraform version
kubectl version --client
k3d version
```

## Extras

### Google Cloud CLI

The Homebrew cask is macOS-only. `./scripts/setup-gcloud.sh` installs from Google's apt repo instead (with `gke-gcloud-auth-plugin`).

### mkcert (trusted local HTTPS in Windows browsers)

`mkcert -install` inside WSL only trusts the CA in Linux. Your browser runs on Windows, so share one CA:

```powershell
winget install FiloSottile.mkcert
mkcert -install                    # trusts the CA in Windows
```

```bash
# in WSL: reuse the Windows CA (replace <you> with your Windows user)
export CAROOT=/mnt/c/Users/<you>/AppData/Local/mkcert
mkcert opsforge.localhost "*.opsforge.localhost"
```

Put the `CAROOT` export in `~/.zshenv.local` to keep it.

### Networking

WSL2 forwards `localhost` ports to Windows, so a service on `127.0.0.1:8080` in WSL opens at `http://localhost:8080` in a Windows browser, and `*.localhost` names resolve to loopback in Chrome and Edge.

### VMs (Multipass)

Multipass is macOS-only in the Brewfile. On Windows, install it on the Windows side (`winget install Canonical.Multipass`) and run `multipass` from PowerShell, or use a Docker-based test VM instead.

### Clipboard and SSH

`scripts/setup-ssh.sh` works as-is (`--apple-use-keychain` is skipped). `.zshrc` maps `pbcopy` → `clip.exe`, `pbpaste` → PowerShell `Get-Clipboard` and `open` → `explorer.exe`, so macOS commands in the docs work unchanged:

```bash
cat ~/.ssh/id_ed25519_github.pub | pbcopy
open .                             # opens the folder in Explorer
```
