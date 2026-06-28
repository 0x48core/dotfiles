#!/usr/bin/env bash
# Scaffold a new Helm chart with sensible defaults
set -euo pipefail

NAME="${1:-myapp}"
DEST="${2:-.}"

command -v helm >/dev/null || { echo "helm not found — run brew bundle"; exit 1; }

helm create "$DEST/$NAME"

# Patch values.yaml with opinionated defaults
cat > "$DEST/$NAME/values.yaml" <<EOF
replicaCount: 1

image:
  repository: ${NAME}
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: nginx
  annotations: {}
  hosts:
    - host: ${NAME}.local
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80

livenessProbe:
  httpGet:
    path: /healthz
    port: http

readinessProbe:
  httpGet:
    path: /healthz
    port: http
EOF

echo "Chart created at $DEST/$NAME"
echo ""
echo "Next steps:"
echo "  helm lint $DEST/$NAME"
echo "  helm install $NAME $DEST/$NAME --dry-run"
echo "  helm install $NAME $DEST/$NAME"
