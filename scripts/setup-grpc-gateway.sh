#!/usr/bin/env bash
# Install grpc-gateway plugins for buf code generation
set -euo pipefail

command -v go  >/dev/null || { echo "Go not found — install Go first"; exit 1; }
command -v buf >/dev/null || { echo "buf not found — run brew bundle"; exit 1; }

echo "Installing grpc-gateway plugins..."

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest

echo ""
echo "Installed:"
for bin in protoc-gen-go protoc-gen-go-grpc protoc-gen-grpc-gateway protoc-gen-openapiv2; do
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
