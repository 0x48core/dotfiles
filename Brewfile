brew "libpq"
brew "starship"
brew "neovim"
brew "gh"
brew "jq"
brew "yq"

# Ruby (Jekyll)
brew "ruby"

# Containers (on WSL, install Docker Desktop on Windows instead — see docs/wsl.md)
if OS.mac?
  cask "docker-desktop"
  cask "multipass"  # local Ubuntu VMs
end

# Kubernetes
brew "kubectl"
brew "minikube"
brew "kind"
brew "k3d"          # k3s in Docker
brew "helm"
brew "k9s"
brew "argocd"

# Infrastructure
brew "tenv"         # terraform version manager (provides `terraform`)
brew "ansible"      # includes ansible.posix and community.* collections
brew "ansible-lint"
brew "doctl"        # DigitalOcean CLI
brew "cloud-sql-proxy"

# Google Cloud (cask is macOS-only; on WSL see docs/wsl.md)
cask "google-cloud-sdk" if OS.mac?

# Protobuf
brew "bufbuild/buf/buf"
brew "grpcurl"

# Security
brew "trivy"        # vulnerability / misconfig scanner
brew "mkcert"       # locally trusted TLS certs

# Testing & linting
brew "hey"          # HTTP load generator
brew "k6"           # load testing
brew "shellcheck"
brew "actionlint"   # GitHub Actions linter
