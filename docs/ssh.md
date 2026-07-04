# SSH Key Setup for GitHub

## Quick setup

```bash
./scripts/setup-ssh.sh <email> [host-alias] [key-name]
```

The script generates an ed25519 key, adds it to ssh-agent, updates `~/.ssh/config`, and prints the public key to paste into GitHub.

---

## Manual setup

### 1. Generate a key

```bash
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519_github
```

### 2. Add to ssh-agent

```bash
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
```

### 3. Configure ~/.ssh/config

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  IdentitiesOnly yes
```

### 4. Add public key to GitHub

```bash
cat ~/.ssh/id_ed25519_github.pub | pbcopy
```

Go to **GitHub → Settings → SSH and GPG keys → New SSH key**, paste, save.

### 5. Test the connection

```bash
ssh -T git@github.com
# Hi 0x48core! You've successfully authenticated...
```

---

## Multi-account setup

Use a different `Host` alias per account so SSH picks the right key.

### ~/.ssh/config

```
# Personal
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  IdentitiesOnly yes

# Work / GHEC
Host github.com-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
```

### Generate the second key

```bash
./scripts/setup-ssh.sh you@work.com github.com-work id_ed25519_work
```

### Clone using the alias

```bash
# Personal
git clone git@github.com:0x48core/myrepo.git

# Work account — swap host to the alias
git clone git@github.com-work:yourorg/myrepo.git
```

### Switch remote on an existing repo

```bash
git remote set-url origin git@github.com-work:yourorg/myrepo.git
```

### Test each account

```bash
ssh -T git@github.com          # → Hi 0x48core!
ssh -T git@github.com-work     # → Hi workuser!
```

---

## Persist keys across reboots (macOS)

Add to `~/.ssh/config` once:

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
```

Keys added with `--apple-use-keychain` survive restarts without needing `ssh-add` again.

---

## Troubleshooting

```bash
# Verbose connection debug
ssh -vT git@github.com

# List keys loaded in agent
ssh-add -l

# Re-add a key manually
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github

# Verify which key is being used for a host
ssh -vT git@github.com 2>&1 | grep "Offering"
```
