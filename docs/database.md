# Database — Migrations with golang-migrate

## Install

```bash
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

Or install all Go tools at once:

```bash
./scripts/setup-go-tools.sh
```

---

## Create migration files

```bash
migrate create -ext sql -dir db/migrations -seq create_users_table
# creates:
#   db/migrations/000001_create_users_table.up.sql
#   db/migrations/000001_create_users_table.down.sql
```

---

## Write migrations

**up** — apply the change:

```sql
-- db/migrations/000001_create_users_table.up.sql
CREATE TABLE users (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  email      TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**down** — reverse the change:

```sql
-- db/migrations/000001_create_users_table.down.sql
DROP TABLE IF EXISTS users;
```

---

## Run migrations

```bash
# Set your database URL
export DATABASE_URL="postgres://user:password@localhost:5432/mydb?sslmode=disable"

# Apply all pending migrations
migrate -path db/migrations -database "$DATABASE_URL" up

# Apply N migrations
migrate -path db/migrations -database "$DATABASE_URL" up 2

# Roll back last migration
migrate -path db/migrations -database "$DATABASE_URL" down 1

# Roll back all
migrate -path db/migrations -database "$DATABASE_URL" down

# Check current version
migrate -path db/migrations -database "$DATABASE_URL" version

# Jump to a specific version
migrate -path db/migrations -database "$DATABASE_URL" goto 3

# Force version (fix dirty state)
migrate -path db/migrations -database "$DATABASE_URL" force 3
```

---

## Use in Go code

```bash
go get github.com/golang-migrate/migrate/v4
go get github.com/golang-migrate/migrate/v4/database/postgres
go get github.com/golang-migrate/migrate/v4/source/file
```

```go
package main

import (
    "log"

    "github.com/golang-migrate/migrate/v4"
    _ "github.com/golang-migrate/migrate/v4/database/postgres"
    _ "github.com/golang-migrate/migrate/v4/source/file"
)

func runMigrations(databaseURL string) {
    m, err := migrate.New("file://db/migrations", databaseURL)
    if err != nil {
        log.Fatalf("migration init error: %v", err)
    }
    defer m.Close()

    if err := m.Up(); err != nil && err != migrate.ErrNoChange {
        log.Fatalf("migration error: %v", err)
    }

    log.Println("migrations applied")
}
```

---

## Project layout

```
myapp/
└── db/
    └── migrations/
        ├── 000001_create_users_table.up.sql
        ├── 000001_create_users_table.down.sql
        ├── 000002_add_user_roles.up.sql
        └── 000002_add_user_roles.down.sql
```

---

## Local Postgres with Docker

```bash
docker run -d \
  --name postgres-local \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 \
  postgres:16-alpine

export DATABASE_URL="postgres://user:password@localhost:5432/mydb?sslmode=disable"
migrate -path db/migrations -database "$DATABASE_URL" up
```

---

## Tips

- Always write a `down` migration — it enables clean rollbacks.
- Never edit an already-applied migration — create a new one instead.
- Commit migration files alongside the code change that requires them.
- In CI, run `migrate up` before tests and `migrate down` after (or use a fresh DB per run).
