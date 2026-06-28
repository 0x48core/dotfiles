#!/usr/bin/env bash
# Install and bootstrap ArgoCD on the current kubectl context
set -euo pipefail

NAMESPACE="argocd"
VERSION="${ARGOCD_VERSION:-stable}"
PORT="${ARGOCD_PORT:-8080}"

command -v kubectl >/dev/null || { echo "kubectl not found — run brew bundle"; exit 1; }
command -v argocd  >/dev/null || brew install argocd

echo "Installing ArgoCD ($VERSION) into namespace '$NAMESPACE'..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n "$NAMESPACE" \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/$VERSION/manifests/install.yaml"

echo "Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=available deployment/argocd-server \
  -n "$NAMESPACE" --timeout=120s

echo "Port-forwarding ArgoCD UI → localhost:$PORT (background)..."
kubectl port-forward svc/argocd-server -n "$NAMESPACE" "$PORT:443" &
PF_PID=$!
sleep 3

INITIAL_PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
  -n "$NAMESPACE" -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "ArgoCD is ready."
echo "  UI:       https://localhost:$PORT"
echo "  User:     admin"
echo "  Password: $INITIAL_PASSWORD"
echo ""
echo "Login and change the password:"
echo "  argocd login localhost:$PORT --insecure --username admin --password '$INITIAL_PASSWORD'"
echo "  argocd account update-password"
echo ""
echo "Port-forward PID: $PF_PID (kill it when done)"
