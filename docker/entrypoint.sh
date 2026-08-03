#!/bin/sh
# Uruchamiane przed startem supervisora: migracje bazy danych.
# Compose czeka na healthcheck PostgreSQL, ale retry chroni przed sytuacją,
# w której baza jest "up", a jeszcze nie przyjmuje połączeń.
set -e

cd /app/backend

attempt=1
max_attempts=30

echo "[entrypoint] Uruchamiam migracje bazy danych..."
until /app/backend/.venv/bin/alembic upgrade head; do
    if [ "$attempt" -ge "$max_attempts" ]; then
        echo "[entrypoint] Migracje nie powiodły się po ${max_attempts} próbach." >&2
        exit 1
    fi
    echo "[entrypoint] Próba ${attempt}/${max_attempts} nieudana, ponawiam za 2s..."
    attempt=$((attempt + 1))
    sleep 2
done

echo "[entrypoint] Migracje zakończone. Startuję API, worker i frontend."

cd /app
exec "$@"
