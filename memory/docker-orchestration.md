---
name: Docker orchestration
description: The whole project starts from one root Compose file while component Compose files stay reusable.
type: decision
---

The default project startup command is run from the repository root:

```bash
docker compose up --build
```

The root `compose.yaml` includes `backend/docker-compose.yml` and
`frontend/docker-compose.yml`. Developers may still run either component
independently from its own directory.

The PostgreSQL volume has the explicit name
`tg-playground-backend_pgdata`, so root and backend-only startup modes use
the same local data instead of creating separate databases.

Do not run the root stack and either component stack at the same time. They
use the same host ports, and both backend modes share the PostgreSQL volume.
