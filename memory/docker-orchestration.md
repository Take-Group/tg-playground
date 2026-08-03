---
name: Docker orchestration
description: One root Dockerfile and one root Compose file; backend and frontend share a single container.
type: decision
---

Decyzja użytkownika (2026-08-03): **jeden główny `Dockerfile` buduje wszystko**,
a backend i frontend działają w **jednym kontenerze**.

Jedyna komenda startowa, z katalogu głównego repozytorium:

```bash
docker compose up --build
```

Osobne pliki `backend/docker-compose.yml`, `frontend/docker-compose.yml`,
`backend/Dockerfile`, `backend/Dockerfile.postgres`, `backend/Dockerfile.redis`
i `frontend/Dockerfile` zostały usunięte. Nie odtwarzaj ich — użytkownik
świadomie wybrał układ jednoplikowy.

Kompromis zaakceptowany przez użytkownika mimo wyraźnego ostrzeżenia:
brak hot-reloadu (frontend leci na buildzie produkcyjnym, backend bez
`--reload`), wspólne logi i wspólny restart obu warstw. Nie "poprawiaj" tego
wracając do osobnych kontenerów bez pytania.

Wolumen PostgreSQL zachował dotychczasową nazwę `tg-playground-backend_pgdata`,
żeby scalenie stosów nie skasowało lokalnych danych deweloperskich. Nazwa jest
myląca (sugeruje osobny stos backendu), ale zmiana oznaczałaby utratę danych.

Szczegóły techniczne i pułapki: `skills/backend/docker-single-image.md`.
