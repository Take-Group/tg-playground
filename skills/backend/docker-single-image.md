# Skill: Jeden obraz Docker dla całego projektu

## Co to robi

Cały projekt — backend (API, worker Temporal, migracje) i frontend (Next.js) —
buduje się z jednego `Dockerfile` w katalogu głównym i uruchamia z jednego
`compose.yaml`. Backend i frontend działają w **jednym kontenerze** (`app`),
jako trzy procesy pod supervisorem.

## Pliki

- `Dockerfile` — jedyny plik budujący obrazy. Targety:
  - `bun-binary` — źródło binarki `bun` kopiowanej do obrazu finalnego
  - `frontend-build` — `bun install` + `bun run build` (tryb standalone)
  - `backend-build` — `uv sync` (środowisko wirtualne + kod)
  - `app` — obraz finalny: backend + frontend + supervisor
  - `postgres` — PostgreSQL 18 z `tzdata`, non-root, bez `gosu`
  - `redis` — Redis 8 Alpine z `tzdata`
- `compose.yaml` — serwisy: `postgres`, `redis`, `temporal-schema-setup`,
  `temporal`, `temporal-create-namespace`, `app`
- `docker/entrypoint.sh` — migracje Alembic z retry, potem `exec` supervisora
- `docker/supervisord.conf` — definicje procesów `api`, `worker`, `frontend`
- `.dockerignore` — kontekst budowania to katalog główny, więc wycina
  `backend/.venv/`, `frontend/node_modules/`, `frontend/.next/` itd.

## Przepływ

1. `docker compose up --build` buduje targety `postgres`, `redis` i `app`.
2. Compose startuje infrastrukturę: PostgreSQL → schemat Temporal →
   serwer Temporal → namespace.
3. Kontener `app` startuje po `service_healthy` (postgres, redis) i
   `service_completed_successfully` (namespace Temporal).
4. `entrypoint.sh` wykonuje `alembic upgrade head` (do 30 prób co 2 s).
5. `exec supervisord` uruchamia trzy procesy; wszystkie logują na stdout
   kontenera, więc `docker compose logs app` pokazuje komplet.
6. Healthcheck serwisu `app` odpytuje `http://127.0.0.1:8000/health`.

## Pułapka: ścieżki budowania muszą być identyczne z finalnymi

`uv sync` zapisuje **absolutne** ścieżki w shebangach skryptów w
`.venv/bin/` (np. `#!/app/backend/.venv/bin/python`). Jeśli etap budowania
użyje innego katalogu niż obraz finalny, każdy skrypt z venv wywali się jako
`not found` mimo że plik istnieje.

Dlatego `backend-build` ma `WORKDIR /app/backend`, a `frontend-build`
`WORKDIR /app/frontend` — dokładnie tak jak w targecie `app`. Nie zmieniaj
tych ścieżek osobno.

## Jak rozszerzać

- **Nowy proces w kontenerze** — dodaj sekcję `[program:nazwa]` w
  `docker/supervisord.conf` (pamiętaj o `stdout_logfile=/dev/fd/1`,
  `stdout_logfile_maxbytes=0`, `redirect_stderr=true`).
- **Nowa zależność systemowa backendu** — `apt-get install` w targecie `app`.
- **Nowy obraz infrastruktury** — dodaj kolejny target na końcu `Dockerfile`
  i wskaż go przez `build.target` w `compose.yaml`. Nie twórz osobnych
  plików `Dockerfile.*`.
- **Nowa zmienna publiczna frontendu (`NEXT_PUBLIC_*`)** — musi być ustawiona
  jako `ENV` w etapie `frontend-build`, bo Next inline'uje ją w czasie builda.
  Ustawienie jej tylko w `compose.yaml` nie zadziała dla kodu w przeglądarce.
- **Restart pojedynczego procesu** bez przebudowy obrazu:
  `docker compose exec app supervisorctl -c /etc/supervisor/supervisord.conf restart api`

## Ograniczenia, o których trzeba wiedzieć

- Brak hot-reloadu — frontend jest budowany produkcyjnie, backend startuje bez
  `--reload`. Każda zmiana kodu wymaga `docker compose up --build`.
- Backend i frontend restartują się razem przy restarcie kontenera.
- Nie da się skalować backendu niezależnie od frontendu.
