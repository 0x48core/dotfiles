#!/usr/bin/env bash
# Local Kubernetes setup — minikube or kind
set -euo pipefail

CLUSTER_TYPE="${1:-minikube}"  # minikube | kind
CLUSTER_NAME="${2:-local}"

command -v brew >/dev/null || { echo "Homebrew required"; exit 1; }

install_if_missing() {
  command -v "$1" >/dev/null || brew install "$1"
}

install_if_missing kubectl
install_if_missing helm
install_if_missing k9s

case "$CLUSTER_TYPE" in
  minikube)
    install_if_missing minikube
    echo "Starting minikube cluster '$CLUSTER_NAME'..."
    minikube start \
      --profile "$CLUSTER_NAME" \
      --driver docker \
      --cpus 4 \
      --memory 8192 \
      --addons ingress,metrics-server
    minikube profile "$CLUSTER_NAME"
    ;;

  kind)
    install_if_missing kind
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
      echo "kind cluster '$CLUSTER_NAME' already exists, skipping create."
    else
      echo "Creating kind cluster '$CLUSTER_NAME'..."
      kind create cluster --name "$CLUSTER_NAME" --config "$(dirname "$0")/kind-config.yaml"
    fi
    kubectl cluster-info --context "kind-${CLUSTER_NAME}"
    ;;

  *)
    echo "Usage: $0 [minikube|kind] [cluster-name]"
    exit 1
    ;;
esac

echo ""
echo "Cluster ready. Useful commands:"
echo "  kubectl get nodes"
echo "  k9s"
case "$CLUSTER_TYPE" in
  minikube) echo "  minikube dashboard --profile $CLUSTER_NAME" ;;
  kind)     echo "  kind get clusters" ;;
esac
