# Helm — Chart Guide

Helm is the package manager for Kubernetes. Charts are reusable, versioned application templates.

## Scaffold a new chart

```bash
./scripts/new-helm-chart.sh myapp ./charts
```

Or manually:

```bash
helm create charts/myapp
```

## Chart structure

```
myapp/
├── Chart.yaml          # chart metadata (name, version, appVersion)
├── values.yaml         # default configuration values
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── _helpers.tpl    # named templates / partials
│   └── NOTES.txt       # post-install instructions
└── charts/             # sub-chart dependencies
```

## Develop & test

```bash
# Validate syntax
helm lint charts/myapp

# Render templates locally (no cluster needed)
helm template myapp charts/myapp --values charts/myapp/values.yaml

# Dry-run against a cluster
helm install myapp charts/myapp --dry-run --debug

# Diff an upgrade (requires helm-diff plugin)
helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade myapp charts/myapp
```

## Install / upgrade

```bash
# Install
helm install myapp charts/myapp \
  --namespace default \
  --create-namespace \
  --values charts/myapp/values.yaml \
  --set image.tag=v1.2.3

# Upgrade
helm upgrade myapp charts/myapp --install \   # --install = upsert
  --values charts/myapp/values.yaml \
  --set image.tag=v1.3.0

# Rollback
helm history myapp
helm rollback myapp 1
```

## Manage releases

```bash
helm list -A                        # all namespaces
helm status myapp
helm get values  myapp
helm get manifest myapp
helm uninstall myapp
```

## Use a remote chart

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/postgresql

# Install with custom values
helm install pg bitnami/postgresql \
  --set auth.postgresPassword=secret \
  --set primary.persistence.size=5Gi
```

## Package & publish

```bash
helm package charts/myapp                         # → myapp-0.1.0.tgz
helm repo index . --url https://youruser.github.io/charts
# push index.yaml + tgz to GitHub Pages branch
```

## ArgoCD + Helm

Point an ArgoCD Application at a Helm chart:

```yaml
source:
  repoURL: https://github.com/youruser/myrepo
  targetRevision: HEAD
  path: charts/myapp
  helm:
    valueFiles:
      - values.yaml
      - values-prod.yaml
    parameters:
      - name: image.tag
        value: v1.3.0
```
