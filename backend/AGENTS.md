# AGENTS.md

## Stack technologiczny (Backend)
- **Python 3.14+** z **FastAPI** (async ASGI via Uvicorn)
- **SQLAlchemy 2.0+** (async) z **asyncpg** jako driver do PostgreSQL
- **Alembic** do migracji bazy danych
- **Pydantic 2** do walidacji danych i konfiguracji
- **Temporal** jako silnik workflow (definiowanie workflow + activities)
- **Redis 7** jako cache / message broker
- **structlog** do logowania
- **httpx** jako async HTTP client
- **UV** jako package manager

---

## Serwisy backendowe w Docker Compose
Backend składa się z trzech serwisów Docker:

| Serwis     | Opis                                              |
|------------|----------------------------------------------------|
| api        | FastAPI REST API (port 8000)                       |
| worker     | Temporal worker - przetwarza workflow              |
| migrations | Alembic migracje (run-to-completion przed startem) |

Zależności infrastrukturalne:

| Serwis      | Port | Opis                        |
|-------------|------|-----------------------------|
| postgres    | 5433 | PostgreSQL 18               |
| redis       | 6379 | Redis 7 (Alpine)            |
| temporal    | 7233 | Temporal server             |
| temporal-ui | 8233 | Panel Temporal (debug UI)   |

---

## Uruchomienie w Docker

### Wymagania
- Docker + Docker Compose

### Start (cały stack)
```bash
cd tg-playground
docker compose up --build
```
Migracje bazy wykonają się automatycznie przed startem API.

### Dostępne adresy
- API: http://localhost:8000
- API health: http://localhost:8000/health
- API readiness: http://localhost:8000/health/ready
- Temporal UI: http://localhost:8233

### Zatrzymanie
```bash
docker compose down
```
Aby usunąć dane (volumes):
```bash
docker compose down -v
```

### Uruchomienie lokalne (dev bez Dockera)
Wymaga lokalnie uruchomionych PostgreSQL, Redis i Temporal.
```bash
cd backend
cp .env.example .env
uv sync
uv run alembic upgrade head
uv run serve    # API na :8000
uv run worker   # Temporal worker (osobny terminal)
```

---

## Zasady dla AI agentów

### SOLID
Kod musi przestrzegać zasad SOLID:
- **S** - Single Responsibility: każda klasa/moduł ma jedną odpowiedzialność
- **O** - Open/Closed: rozszerzaj przez nowe klasy, nie modyfikuj istniejących
- **I** - Interface Segregation: małe, specyficzne interfejsy zamiast jednego dużego
- **L** - Liskov Substitution: podtypy muszą być wymienne z typami bazowymi
- **D** - Dependency Inversion: zależności od abstrakcji, nie od konkretów

### Limit rozmiaru plików
**Maksymalnie 600 linii na plik.** Jeśli plik przekracza ten limit:
1. Wydziel logikę do osobnych modułów
2. Rozbij duże klasy na mniejsze (zgodnie z SRP)
3. Przenieś helpery/utils do dedykowanych plików

Uzasadnienie: duże pliki zapychają kontekst AI i utrudniają code review.

### Struktura kodu
- Logika biznesowa w serwisach, nie w endpointach
- Temporal: workflow i activities w osobnych plikach
- Migracje: każda zmiana schematu jako osobna migracja Alembic
