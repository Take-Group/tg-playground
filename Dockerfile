# =============================================================================
# TG Playground — jeden Dockerfile budujący całość
#
# Targety:
#   app       — backend (API + worker + migracje) i frontend w jednym kontenerze
#   postgres  — obraz PostgreSQL ze strefą czasową Europe/Warsaw
#   redis     — obraz Redis ze strefą czasową Europe/Warsaw
#
# Kontekst budowania to katalog główny repozytorium.
# =============================================================================


# --- Źródło binarki Bun (kopiowana do finalnego obrazu) ----------------------
FROM oven/bun:1.3.14 AS bun-binary


# --- Build frontendu: Next.js w trybie standalone ----------------------------
# WAŻNE: katalogi robocze etapów budowania muszą być identyczne ze ścieżkami
# w obrazie finalnym. Środowisko wirtualne uv zapisuje absolutne ścieżki
# w shebangach, więc przeniesienie go pod inny katalog je psuje.
FROM oven/bun:1.3.14 AS frontend-build

USER root
WORKDIR /app/frontend

ENV TZ=Europe/Warsaw \
    NEXT_PUBLIC_TIME_ZONE=Europe/Warsaw \
    NODE_ENV=production

# Zależności najpierw — osobna, cache'owana warstwa
COPY frontend/package.json frontend/bun.lock ./
RUN bun install --frozen-lockfile

COPY frontend/ ./
RUN bun run build


# --- Build backendu: zależności Pythona + kod aplikacji ----------------------
FROM ghcr.io/astral-sh/uv:0.11.31-python3.14-trixie-slim AS backend-build

WORKDIR /app/backend

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Zależności najpierw — osobna, cache'owana warstwa
COPY backend/pyproject.toml backend/uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev

COPY backend/ ./
RUN uv sync --frozen --no-dev


# --- Obraz finalny: backend i frontend pod jednym supervisorem ---------------
FROM ghcr.io/astral-sh/uv:0.11.31-python3.14-trixie-slim AS app

ENV TZ=Europe/Warsaw \
    PYTHONUNBUFFERED=1 \
    NODE_ENV=production \
    NEXT_PUBLIC_TIME_ZONE=Europe/Warsaw \
    HOSTNAME=0.0.0.0 \
    PORT=3000 \
    PATH="/app/backend/.venv/bin:${PATH}"

RUN apt-get update \
    && apt-get install --yes --no-install-recommends tzdata supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --system app && useradd --system --gid app --home-dir /app app

# Runtime JS — pojedyncza binarka, bez pełnego obrazu Node/Bun
COPY --from=bun-binary /usr/local/bin/bun /usr/local/bin/bun

# Backend: kod, alembic i gotowe środowisko wirtualne
COPY --from=backend-build --chown=app:app /app/backend /app/backend

# Frontend: wynik `next build --output standalone`
COPY --from=frontend-build --chown=app:app /app/frontend/.next/standalone /app/frontend
COPY --from=frontend-build --chown=app:app /app/frontend/.next/static /app/frontend/.next/static
COPY --from=frontend-build --chown=app:app /app/frontend/public /app/frontend/public

COPY docker/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER app
WORKDIR /app

# 8000 — API (FastAPI), 3000 — frontend (Next.js)
EXPOSE 8000 3000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/supervisord.conf"]


# --- PostgreSQL --------------------------------------------------------------
FROM postgres:18.4 AS postgres

ENV TZ=Europe/Warsaw

RUN apt-get update \
    && apt-get install --yes --no-install-recommends tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && rm /usr/local/bin/gosu

USER postgres


# --- Redis -------------------------------------------------------------------
FROM redis:8.8.0-alpine AS redis

ENV TZ=Europe/Warsaw

RUN apk add --no-cache tzdata
