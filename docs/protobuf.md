# Protobuf & gRPC Setup Guide

## Install tools

```bash
# buf — modern protobuf toolchain (lint, format, generate, breaking change detection)
brew install bufbuild/buf/buf

# Go plugins
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest       # Go structs from messages
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest      # gRPC server/client stubs
```

Make sure `$(go env GOPATH)/bin` is on your PATH (already set in `zsh/.zshrc`).

---

## Project structure

```
myapp/
├── buf.yaml                  # buf module config
├── buf.gen.yaml              # code generation config
└── proto/
    └── myapp/
        └── v1/
            ├── user.proto
            └── service.proto
```

---

## buf.yaml

```yaml
version: v2
modules:
  - path: proto
lint:
  use:
    - STANDARD
breaking:
  use:
    - FILE
```

## buf.gen.yaml

```yaml
version: v2
plugins:
  - plugin: go
    out: gen/go
    opt: paths=source_relative
  - plugin: go-grpc
    out: gen/go
    opt:
      - paths=source_relative
      - require_unimplemented_servers=false
```

---

## Example .proto file

```proto
syntax = "proto3";

package myapp.v1;

option go_package = "github.com/youruser/myapp/gen/go/myapp/v1;myappv1";

message User {
  string id    = 1;
  string name  = 2;
  string email = 3;
}

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
}

message GetUserRequest  { string id = 1; }
message GetUserResponse { User user = 1; }

message ListUsersRequest  { int32 page_size = 1; }
message ListUsersResponse { repeated User users = 1; }
```

---

## Generate code

```bash
# Generate Go structs + gRPC stubs
buf generate

# Output lands in gen/go/myapp/v1/
#   user.pb.go        ← message structs
#   service_grpc.pb.go ← server/client interfaces
```

---

## Common buf commands

```bash
# Lint proto files
buf lint

# Format in place
buf format -w

# Check for breaking changes against main branch
buf breaking --against '.git#branch=main'

# Check against a specific tag
buf breaking --against '.git#tag=v1.0.0'

# Push to Buf Schema Registry (BSR)
buf push

# List available plugins
buf registry plugin list
```

---

## Implement the gRPC server (Go)

```go
package main

import (
    "context"
    "log"
    "net"

    "google.golang.org/grpc"
    pb "github.com/youruser/myapp/gen/go/myapp/v1"
)

type server struct {
    pb.UnimplementedUserServiceServer
}

func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
    return &pb.GetUserResponse{
        User: &pb.User{Id: req.Id, Name: "Augustus", Email: "you@example.com"},
    }, nil
}

func main() {
    lis, _ := net.Listen("tcp", ":50051")
    s := grpc.NewServer()
    pb.RegisterUserServiceServer(s, &server{})
    log.Println("gRPC server listening on :50051")
    s.Serve(lis)
}
```

## Call with grpcurl

```bash
brew install grpcurl

# List services
grpcurl -plaintext localhost:50051 list

# Call a method
grpcurl -plaintext -d '{"id": "123"}' \
  localhost:50051 myapp.v1.UserService/GetUser
```

---

## go.mod dependencies

```bash
go get google.golang.org/protobuf
go get google.golang.org/grpc
```
