# TG Playground Frontend

Frontend projektu działa na Next.js, React, TypeScript, Tailwind CSS i Bun.

## Uruchomienie

```bash
cd frontend
docker compose up --build
```

Aplikacja będzie dostępna pod adresem http://localhost:3000.

To jedyny wspierany sposób uruchamiania projektu. Kod z `src/` i `public/`
jest montowany do kontenera, więc zmiany są widoczne automatycznie.

## Zatrzymanie

```bash
docker compose down
```
