# Local Temporal stack

## Cel

Lokalny Temporal działa w Docker Compose bez Temporal Web UI. Schemat bazy
i namespace są inicjalizowane przez krótkotrwałe kontenery `admin-tools`,
a właściwy serwer działa na wspieranym obrazie `temporalio/server`.

## Pliki

- `compose.yaml` — serwer, zależności i kolejność startu.
- `Dockerfile` (target `postgres`) — minimalny obraz PostgreSQL uruchamiany
  bezpośrednio jako non-root, bez nieużywanego binarium `gosu`.
- `backend/temporal/scripts/setup-postgres.sh` — tworzenie i aktualizacja
  schematów `temporal` oraz `temporal_visibility`.
- `backend/temporal/scripts/create-namespace.sh` — idempotentne utworzenie
  namespace po osiągnięciu gotowości przez serwer.
- `backend/temporal/dynamicconfig/development-sql.yaml` — ustawienia
  dynamiczne przeznaczone wyłącznie dla lokalnego środowiska SQL.
- `backend/app/temporal/worker.py` — worker łączący się z serwerem.

## Przepływ startu

1. PostgreSQL przechodzi healthcheck.
2. `temporal-schema-setup` tworzy lub aktualizuje oba schematy Temporal.
3. `temporal` uruchamia serwer z konfiguracją SQL.
4. `temporal-create-namespace` czeka na serwer i zapewnia namespace `default`.
5. Kontener `app` startuje dopiero po zakończeniu inicjalizacji namespace;
   supervisor uruchamia w nim proces `worker`.

PostgreSQL, Redis i Temporal są dostępne wyłącznie w sieci Compose. Web UI
nie jest częścią stacku.

## Rozszerzanie

- Wersje serwera i `admin-tools` aktualizuj razem.
- Zmiany schematu zostaw `temporal-sql-tool`; nie twórz dla nich migracji
  Alembic aplikacji.
- Nowy namespace dodaj jako osobny, idempotentny serwis inicjalizacyjny.
- Nowe ustawienia lokalnego serwera dodawaj do pliku `development-sql.yaml`.
- Nie dodawaj `temporalio/ui` ani nie publikuj portu 7233 bez uzgodnienia
  nowego wymagania.
