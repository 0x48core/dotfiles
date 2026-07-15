# gRPC-Gateway with buf

gRPC-Gateway generates a reverse-proxy HTTP/JSON → gRPC so you can expose a single `.proto` service as both a gRPC API and a REST API.

```
Client (HTTP/JSON)  →  gRPC-Gateway proxy  →  gRPC Server
```

---

## Install

```bash
./scripts/setup-grpc-gateway.sh
```

Or manually:

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest   # optional: OpenAPI spec
```

---

## Project structure

```
myapp/
├── buf.yaml
├── buf.gen.yaml
├── proto/
│   └── myapp/
│       └── v1/
│           ├── service.proto
│           └── service.http.yaml     # HTTP rules (alternative to inline annotations)
├── gen/
│   └── go/                          # generated code lands here
├── cmd/
│   └── server/
│       └── main.go
└── go.mod
```

---

## buf.yaml

```yaml
version: v2
modules:
  - path: proto
deps:
  - buf.build/googleapis/googleapis          # required for google.api.http annotations
  - buf.build/grpc-ecosystem/grpc-gateway    # required for openapiv2 annotations
lint:
  use:
    - STANDARD
breaking:
  use:
    - FILE
```

```bash
buf dep update    # resolve and lock dependencies → generates buf.lock
```

---

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

  - plugin: grpc-gateway
    out: gen/go
    opt:
      - paths=source_relative
      - generate_unbound_methods=true

  - plugin: openapiv2
    out: gen/openapi
    opt:
      - output_format=yaml
```

---

## service.proto — with HTTP annotations

```proto
syntax = "proto3";

package myapp.v1;

import "google/api/annotations.proto";

option go_package = "github.com/youruser/myapp/gen/go/myapp/v1;myappv1";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {
    option (google.api.http) = {
      get: "/v1/users/{id}"
    };
  }

  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {
    option (google.api.http) = {
      post: "/v1/users"
      body: "*"
    };
  }

  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse) {
    option (google.api.http) = {
      get: "/v1/users"
    };
  }

  rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse) {
    option (google.api.http) = {
      delete: "/v1/users/{id}"
    };
  }
}

message User {
  string id    = 1;
  string name  = 2;
  string email = 3;
}

message GetUserRequest     { string id = 1; }
message GetUserResponse    { User user = 1; }
message CreateUserRequest  { string name = 2; string email = 3; }
message CreateUserResponse { User user = 1; }
message ListUsersRequest   { int32 page_size = 1; string page_token = 2; }
message ListUsersResponse  { repeated User users = 1; string next_page_token = 2; }
message DeleteUserRequest  { string id = 1; }
message DeleteUserResponse {}
```

---

## Generate code

```bash
buf generate
```

Output:
```
gen/
├── go/myapp/v1/
│   ├── service.pb.go              # message structs
│   ├── service_grpc.pb.go         # gRPC server/client interfaces
│   └── service.pb.gw.go           # HTTP gateway handler
└── openapi/
    └── myapp/v1/service.yaml      # OpenAPI spec
```

---

## main.go — run gRPC + HTTP gateway together

```go
package main

import (
    "context"
    "log"
    "net"
    "net/http"

    "github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
    "google.golang.org/grpc/reflection"

    pb "github.com/youruser/myapp/gen/go/myapp/v1"
)

const (
    grpcPort = ":50051"
    httpPort = ":8080"
)

// --- gRPC server implementation ---

type userServer struct {
    pb.UnimplementedUserServiceServer
}

func (s *userServer) GetUser(_ context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
    return &pb.GetUserResponse{
        User: &pb.User{Id: req.Id, Name: "Augustus", Email: "you@example.com"},
    }, nil
}

func (s *userServer) CreateUser(_ context.Context, req *pb.CreateUserRequest) (*pb.CreateUserResponse, error) {
    return &pb.CreateUserResponse{
        User: &pb.User{Id: "new-id", Name: req.Name, Email: req.Email},
    }, nil
}

// --- main ---

func main() {
    // Start gRPC server
    lis, err := net.Listen("tcp", grpcPort)
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }
    grpcServer := grpc.NewServer()
    pb.RegisterUserServiceServer(grpcServer, &userServer{})
    reflection.Register(grpcServer)

    go func() {
        log.Printf("gRPC server listening on %s", grpcPort)
        if err := grpcServer.Serve(lis); err != nil {
            log.Fatalf("gRPC serve error: %v", err)
        }
    }()

    // Start HTTP gateway
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    mux := runtime.NewServeMux()
    opts := []grpc.DialOption{grpc.WithTransportCredentials(insecure.NewCredentials())}

    if err := pb.RegisterUserServiceHandlerFromEndpoint(ctx, mux, "localhost"+grpcPort, opts); err != nil {
        log.Fatalf("failed to register gateway: %v", err)
    }

    log.Printf("HTTP gateway listening on %s", httpPort)
    if err := http.ListenAndServe(httpPort, mux); err != nil {
        log.Fatalf("HTTP serve error: %v", err)
    }
}
```

---

## go.mod dependencies

```bash
go get google.golang.org/protobuf
go get google.golang.org/grpc
go get github.com/grpc-ecosystem/grpc-gateway/v2
```

---

## Test

```bash
go run ./cmd/server

# gRPC
grpcurl -plaintext -d '{"id":"123"}' localhost:50051 myapp.v1.UserService/GetUser

# REST (via gateway)
curl http://localhost:8080/v1/users/123
curl -X POST http://localhost:8080/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Augustus","email":"you@example.com"}'
curl http://localhost:8080/v1/users
```

---

## View OpenAPI spec

```bash
# Serve the generated spec
npx @redocly/cli preview-docs gen/openapi/myapp/v1/service.yaml

# Or with swagger-ui
docker run -p 8090:8080 \
  -e SWAGGER_JSON=/spec/service.yaml \
  -v $(pwd)/gen/openapi/myapp/v1:/spec \
  swaggerapi/swagger-ui
```

---

## buf workflow recap

```bash
buf dep update      # update buf.lock after editing buf.yaml deps
buf generate        # regenerate all code
buf lint            # lint proto files
buf breaking --against '.git#branch=main'  # check for breaking changes
```
