# ArgoCD — Local Setup & Guide

ArgoCD is a GitOps continuous delivery tool for Kubernetes. It syncs your cluster state from a Git repo.

## Install on local cluster

```bash
./scripts/setup-argocd.sh
```

This installs ArgoCD into the `argocd` namespace, waits for it to be ready, and port-forwards the UI to `https://localhost:8080`.

## First login

```bash
# Get initial password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d

argocd login localhost:8080 --insecure --username admin
argocd account update-password
```

## Register a cluster

```bash
# current context (local cluster)
argocd cluster add $(kubectl config current-context)

argocd cluster list
```

## Deploy an application (CLI)

```bash
argocd app create myapp \
  --repo https://github.com/youruser/myrepo \
  --path helm/myapp \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal

argocd app sync myapp
argocd app get  myapp
argocd app logs myapp
```

## Deploy an application (declarative)

```yaml
# argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/youruser/myrepo
    targetRevision: HEAD
    path: helm/myapp
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

```bash
kubectl apply -f argocd-app.yaml
```

## Projects (multi-team isolation)

```bash
argocd proj create myteam \
  --dest https://kubernetes.default.svc,default \
  --src https://github.com/youruser/*

argocd proj list
```

## Common commands

```bash
argocd app list
argocd app diff   myapp
argocd app sync   myapp --force
argocd app delete myapp

argocd repo add https://github.com/youruser/myrepo \
  --username git --password <token>

argocd repo list
```

## Uninstall

```bash
kubectl delete namespace argocd
```
