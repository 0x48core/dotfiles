#!/usr/bin/env bash
# Install and configure Google Cloud CLI
set -euo pipefail

PROJECT_ID="${1:-}"

# shellcheck source=scripts/lib/platform.sh
source "$(dirname "$0")/lib/platform.sh"
OS="$(detect_os)"

# macOS: brew cask (has the components manager).
# Linux/WSL: Google's apt/dnf repo, where components are packages instead.
install_gcloud() {
  if [[ "$OS" == macos ]]; then
    brew install --cask google-cloud-sdk
    return
  fi
  case "$(linux_pkg_manager)" in
    apt)
      as_root apt-get install -y apt-transport-https ca-certificates gnupg curl
      curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | as_root gpg --dearmor --yes -o /usr/share/keyrings/cloud.google.gpg
      echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        | as_root tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null
      as_root apt-get update
      as_root apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
      ;;
    dnf)
      as_root tee /etc/yum.repos.d/google-cloud-sdk.repo >/dev/null <<REPO
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-$(uname -m)
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
REPO
      as_root dnf install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
      ;;
    *)
      echo "Install gcloud manually: https://cloud.google.com/sdk/docs/install"
      exit 1
      ;;
  esac
}

if ! command -v gcloud >/dev/null; then
  echo "Installing Google Cloud CLI..."
  install_gcloud
else
  echo "gcloud already installed: $(gcloud version 2>/dev/null | head -1)"
fi

# Install common components (kubectl comes from the Brewfile)
if [[ "$OS" == macos ]]; then
  echo "Installing gcloud components..."
  gcloud components install gke-gcloud-auth-plugin beta --quiet 2>/dev/null || true
fi

# Authenticate
echo ""
echo "Authenticating..."
gcloud auth login
gcloud auth application-default login

# Set project
if [[ -n "$PROJECT_ID" ]]; then
  gcloud config set project "$PROJECT_ID"
  echo "Active project: $PROJECT_ID"
else
  echo ""
  echo "No project set. Run:"
  echo "  gcloud config set project YOUR_PROJECT_ID"
fi

echo ""
echo "Setup complete. Verify with:"
echo "  gcloud auth list"
echo "  gcloud config list"
