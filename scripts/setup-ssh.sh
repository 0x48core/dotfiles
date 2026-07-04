#!/usr/bin/env bash
# Generate SSH keys and configure ~/.ssh/config for GitHub access
set -euo pipefail

EMAIL="${1:-}"
HOST_ALIAS="${2:-github.com}"       # e.g. github.com or github.com-work
KEY_NAME="${3:-id_ed25519_github}"  # filename under ~/.ssh/

if [[ -z "$EMAIL" ]]; then
  echo "Usage: $0 <email> [host-alias] [key-name]"
  echo ""
  echo "Examples:"
  echo "  $0 you@example.com                              # personal (github.com)"
  echo "  $0 you@work.com github.com-work id_ed25519_work # second account"
  exit 1
fi

KEY_PATH="$HOME/.ssh/$KEY_NAME"
SSH_CONFIG="$HOME/.ssh/config"

# Generate key if it doesn't exist
if [[ -f "$KEY_PATH" ]]; then
  echo "Key $KEY_PATH already exists, skipping generation."
else
  echo "Generating SSH key for $EMAIL..."
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""
fi

# Add to ssh-agent
eval "$(ssh-agent -s)" > /dev/null
ssh-add --apple-use-keychain "$KEY_PATH" 2>/dev/null || ssh-add "$KEY_PATH"

# Append SSH config block if not already present
if ! grep -q "IdentityFile $KEY_PATH" "$SSH_CONFIG" 2>/dev/null; then
  mkdir -p ~/.ssh
  cat >> "$SSH_CONFIG" <<EOF

Host $HOST_ALIAS
  HostName github.com
  User git
  IdentityFile $KEY_PATH
  IdentitiesOnly yes
EOF
  chmod 600 "$SSH_CONFIG"
  echo "Added $HOST_ALIAS block to $SSH_CONFIG"
fi

echo ""
echo "Public key (add this to GitHub → Settings → SSH keys):"
echo ""
cat "${KEY_PATH}.pub"
echo ""
echo "Open: https://github.com/settings/ssh/new"
echo ""
echo "Test the connection:"
echo "  ssh -T git@$HOST_ALIAS"
