#!/usr/bin/env bash
# Install and configure Google Cloud CLI
set -euo pipefail

PROJECT_ID="${1:-}"

# Install gcloud via brew cask
if ! command -v gcloud >/dev/null; then
  echo "Installing Google Cloud CLI..."
  brew install --cask google-cloud-sdk
else
  echo "gcloud already installed: $(gcloud version 2>/dev/null | head -1)"
fi

# Install common components
echo "Installing gcloud components..."
gcloud components install gke-gcloud-auth-plugin kubectl beta --quiet 2>/dev/null || true

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
