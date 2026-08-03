# AGENTS.md

## Stack technologiczny (Backend)
- **Python 3.14+** z **FastAPI** (async ASGI via Uvicorn)
- **SQLAlchemy 2.0+** (async) z **asyncpg** jako driver do PostgreSQL
- **Alembic** do migracji bazy danych
- **Pydantic 2** do walidacji danych i konfiguracji
- **Temporal** jako silnik workflow (definiowanie workflow + activities)
- **Redis 8** jako cache / message broker
- **structlog** do logowania
- **httpx** jako async HTTP client
- **UV** jako package manager

---

## Procesy backendowe
Backend nie ma własnego `Dockerfile` ani `docker-compose.yml`. Buduje go
główny `Dockerfile` w katalogu głównym (target `app`), a uruchamia
`compose.yaml` z katalogu głównego.

W kontenerze `app` backend działa jako dwa procesy pod supervisorem, obok
procesu frontendu:

| Proces     | Opis                                               |
|------------|----------------------------------------------------|
| api        | FastAPI REST API (port 8000)                       |
| worker     | Temporal worker - przetwarza workflow              |

Migracje Alembic nie są osobnym serwisem — wykonuje je `docker/entrypoint.sh`
przed startem supervisora (z retry, na wypadek gdyby baza jeszcze nie
przyjmowała połączeń).

Zależności infrastrukturalne:

| Serwis                     | Opis                                      |
|----------------------------|-------------------------------------------|
| postgres                   | PostgreSQL 18, non-root                    |
| redis                      | Redis 8 (Alpine)                           |
| temporal-schema-setup      | Jednorazowa inicjalizacja schematu        |
| temporal                   | Temporal Server bez Web UI                 |
| temporal-create-namespace  | Jednorazowa inicjalizacja namespace       |

Serwisy infrastrukturalne nie publikują portów na hoście. Komunikują się
wyłącznie wewnątrz sieci Docker Compose.

---

## Uruchomienie w Docker

### Wymagania
- Docker + Docker Compose

### Start (jedyny wspierany sposób)
```bash
cd tg-playground
docker compose up --build
```
Migracje bazy wykonają się automatycznie przed startem API.

Nie da się uruchomić samego backendu — cały projekt startuje z jednego
`compose.yaml` w katalogu głównym. Aby zrestartować sam proces API bez
przebudowy obrazu:
```bash
docker compose exec app supervisorctl -c /etc/supervisor/supervisord.conf restart api
```

### Dostępne adresy
- API: http://localhost:8000
- API health: http://localhost:8000/health
- API readiness: http://localhost:8000/health/ready

Jeśli port 8000 jest zajęty przez inną aplikację — nie zabijaj jej. Zmień port
zgodnie z procedurą „Konflikty portów" w głównym [AGENTS.md](../AGENTS.md).

### Zatrzymanie
```bash
docker compose down
```
Aby usunąć dane (volumes):
```bash
docker compose down -v
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

### Bezwzględny zakaz pisania testów automatycznych
**AI nie może w żadnym przypadku tworzyć ani modyfikować testów automatycznych.**

- Nie twórz plików testowych, test case'ów, fixture'ów, mocków ani snapshotów
- Nie dodawaj frameworków testowych, skryptów testowych ani konfiguracji testów lub CI
- Nie rozszerzaj ani nie poprawiaj istniejących testów automatycznych
- Backend weryfikuj przez lintery, type-checkery, audyty, uruchomienie stacku w Dockerze oraz ręczne wywołanie endpointu, joba lub workflow

### Struktura kodu
- Logika biznesowa w serwisach, nie w endpointach
- Temporal: workflow i activities w osobnych plikach
- Migracje: każda zmiana schematu jako osobna migracja Alembic
