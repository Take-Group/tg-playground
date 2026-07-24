# TG Playground Frontend

Frontend projektu działa na Next.js, React, TypeScript, Tailwind CSS i Bun.

## Uruchomienie

Cały projekt z katalogu głównego:

```bash
docker compose up --build
```

Tylko frontend:

```bash
cd frontend
docker compose up --build
```

Aplikacja będzie dostępna pod adresem http://localhost:3000.

Docker jest jedynym wspieranym sposobem uruchamiania projektu. Kod z `src/`
i `public/` jest montowany do kontenera, więc zmiany są widoczne
automatycznie.

## Zatrzymanie

```bash
docker compose down
```
