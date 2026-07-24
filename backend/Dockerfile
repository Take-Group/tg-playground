FROM ghcr.io/astral-sh/uv:0.11.31-python3.14-trixie-slim AS base

WORKDIR /app

ENV TZ=Europe/Warsaw \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install --yes --no-install-recommends tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --system app && useradd --system --gid app --home-dir /app app

# Install dependencies first (cached layer)
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev

# Copy application code
COPY --chown=app:app . .
RUN uv sync --frozen --no-dev && chown -R app:app /app

USER app

# --- API target ---
FROM base AS api
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

# --- Worker target ---
FROM base AS worker
CMD ["uv", "run", "worker"]

# --- Migrations target ---
FROM base AS migrations
CMD ["uv", "run", "alembic", "upgrade", "head"]
