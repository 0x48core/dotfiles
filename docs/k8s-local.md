# Local Kubernetes Setup

Two options depending on your use case:

| | **minikube** | **kind** |
|---|---|---|
| Best for | Dev + dashboard + addons | CI parity, multi-node |
| Driver | Docker / HyperKit | Docker only |
| Setup | `./scripts/setup-k8s.sh minikube` | `./scripts/setup-k8s.sh kind` |

---

## Prerequisites

```bash
brew bundle          # installs kubectl, helm, k9s, minikube, kind
```

Docker Desktop (or OrbStack) must be running.

---

## minikube

### Start

```bash
./scripts/setup-k8s.sh minikube [cluster-name]
# default cluster-name: local
```

This starts minikube with 4 CPUs, 8 GB RAM, and enables the `ingress` and `metrics-server` addons.

### Common commands

```bash
minikube start --profile local
minikube stop  --profile local
minikube delete --profile local

minikube dashboard --profile local   # browser UI
minikube tunnel --profile local      # expose LoadBalancer services on localhost

minikube profile list                # list all clusters
```

### Use a local image without pushing to a registry

```bash
eval $(minikube docker-env --profile local)
docker build -t myapp:dev .
# now reference image: myapp:dev with imagePullPolicy: Never
```

---

## kind

### Start

```bash
./scripts/setup-k8s.sh kind [cluster-name]
# default cluster-name: local
```

Creates a 1 control-plane + 2 worker cluster with ports 80/443 mapped to localhost.

### Common commands

```bash
kind create cluster --name local --config scripts/kind-config.yaml
kind delete cluster --name local
kind get clusters

# Load a local image into kind (no registry needed)
kind load docker-image myapp:dev --name local
```

### Ingress (nginx) for kind

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

---

## kubectl quick reference

```bash
kubectl get nodes
kubectl get pods -A                    # all namespaces
kubectl describe pod <name>
kubectl logs <pod> -f
kubectl exec -it <pod> -- bash
kubectl port-forward svc/<svc> 8080:80

kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
```

## Helm quick reference

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/postgresql
helm install my-pg bitnami/postgresql --set auth.postgresPassword=secret
helm list
helm uninstall my-pg
```

## k9s

Interactive TUI for Kubernetes — just run `k9s`. Key bindings:

| Key | Action |
|-----|--------|
| `:pod` | switch to pods view |
| `d` | describe resource |
| `l` | logs |
| `s` | shell into container |
| `ctrl-d` | delete resource |
| `?` | help |

---

## Switching contexts

```bash
kubectl config get-contexts
kubectl config use-context minikube          # or kind-local
kubectl config current-context
```
