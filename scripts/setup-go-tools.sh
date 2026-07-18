#!/usr/bin/env bash
# Install common Go tools
set -euo pipefail

command -v go >/dev/null || { echo "Go not found — install Go first"; exit 1; }

echo "Installing Go tools..."

# Protobuf
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# gRPC-Gateway
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest

# Database migrations
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

echo ""
echo "Installed tools:"
for bin in protoc-gen-go protoc-gen-go-grpc protoc-gen-grpc-gateway protoc-gen-openapiv2 migrate; do
  path="$(go env GOPATH)/bin/$bin"
  if [[ -f "$path" ]]; then
    echo "  ✓ $bin"
  else
    echo "  ✗ $bin (not found)"
  fi
done

echo ""
echo "Make sure $(go env GOPATH)/bin is on your PATH."
echo "It is already set in zsh/.zshrc."
