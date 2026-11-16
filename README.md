# dotfiles

Personal dotfiles for zsh, git, neovim, starship, and Ghostty.

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
│   ├── starship.toml  # prompt (needs a Nerd Font; Ghostty bundles one)
│   └── ghostty/config # terminal colors and font size
├── scripts/
│   ├── lib/platform.sh  # OS detection shared by the scripts
│   └── setup-*.sh       # optional tool setup (see below)
├── docs/            # setup guides and cheat sheets
├── Brewfile         # packages installed by `brew bundle`
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

macOS-only Brewfile entries (`ghostty`, `docker-desktop`, `multipass`, `google-cloud-sdk`) are skipped on Linux and WSL.

## What you get

- **Shell:** Oh My Zsh with a Starship prompt, `zsh-autosuggestions`, `zsh-syntax-highlighting`, fzf key bindings (Ctrl-R, Ctrl-T) and zoxide (`z`)
- **CLI tools:** `eza`, `bat`, `btop`, `lazydocker`, `jq`, `yq`, `gh`
- **Aliases:** `vim` → `nvim`, `k` → `kubectl` (with completion); `open`, `pbcopy` and `pbpaste` work on Linux and WSL too
- **Kubernetes:** `kubectl`, `minikube`, `kind`, `k3d`, `helm`, `k9s`, `kubectx`, `stern`, `argocd`
- **Infrastructure:** `tenv` (Terraform), `ansible`, `doctl`, `cloud-sql-proxy`, Google Cloud SDK
- **Other:** `buf`, `grpcurl`, `trivy`, `mkcert`, `hey`, `k6`, `shellcheck`, `actionlint`

See the [Brewfile](Brewfile) for the full list.

## Setup scripts

Optional, run them when you need them:

| Script | Purpose |
|---|---|
| `scripts/setup-ssh.sh <email> [host-alias] [key-name]` | SSH key and `~/.ssh/config` for GitHub |
| `scripts/setup-gcloud.sh [project-id]` | Install and configure the Google Cloud CLI |
| `scripts/setup-k8s.sh [minikube\|kind] [cluster-name]` | Local Kubernetes cluster |
| `scripts/setup-argocd.sh` | Install ArgoCD on the current kubectl context |
| `scripts/new-helm-chart.sh [name] [dest]` | Scaffold a Helm chart |
| `scripts/setup-terraform.sh [name] [dest]` | Bootstrap a Terraform project |
| `scripts/setup-go-tools.sh` | Common Go tools |
| `scripts/setup-grpc-gateway.sh` | grpc-gateway plugins for buf |
| `scripts/setup-jekyll.sh` | Homebrew Ruby and Jekyll |

## Guides

- Platforms: [Linux](docs/linux.md), [Windows / WSL2](docs/wsl.md)
- Git & SSH: [Git & GitHub CLI](docs/git.md), [SSH keys](docs/ssh.md)
- Kubernetes: [Local clusters](docs/k8s-local.md), [Helm](docs/helm.md), [ArgoCD](docs/argocd.md)
- Infrastructure: [Terraform](docs/terraform.md), [Google Cloud](docs/google-cloud.md)
- Backend: [Protobuf & gRPC](docs/protobuf.md), [gRPC-Gateway](docs/grpc-gateway.md), [Database migrations](docs/database.md)
- Other: [Ruby & Jekyll](docs/jekyll.md)

## Secrets

Keep secrets out of this repo. Export them in `~/.zshenv.local` (not tracked):

```bash
export ANTHROPIC_API_KEY="anthropic_api_key"
export DIGITALOCEAN_TOKEN="dop_v1_..."      # terraform digitalocean provider
```

`zsh/.zshenv` sources it automatically when present.

## CI

[GitHub Actions](.github/workflows/ci.yml) runs `shellcheck` on the scripts, then on Ubuntu and macOS checks zsh syntax, runs `./install.sh --no-packages`, makes sure the shell loads, and resolves the Brewfile.
