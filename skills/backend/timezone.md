# Skill: Backend timezone

## What it does

Configures every backend container to use the `Europe/Warsaw` IANA timezone,
including automatic daylight-saving time changes.

## Files involved

- `compose.yaml` — passes `TZ` to every service and configures PostgreSQL
  session and log timezones
- `Dockerfile` — one file, three targets: `app` (installs `tzdata` for API,
  worker and migrations), `postgres`, and `redis` (both add `tzdata`)
- `backend/app/config.py` — exposes the application timezone as
  `settings.timezone`
- `backend/.env.example` — documents the default `TZ`

## Flow

1. Docker Compose passes `TZ=Europe/Warsaw` to every process.
2. Images owned by the project install `tzdata`, so DST rules are available.
3. PostgreSQL starts with `timezone` and `log_timezone` set to
   `Europe/Warsaw`.
4. Application code reads the same value through `settings.timezone`.

Temporal and database timestamps still represent unambiguous instants.
Business rules and presentation convert those instants to `Europe/Warsaw`.

## How to extend

- Add `TZ: Europe/Warsaw` to every new service in the root `compose.yaml`.
- Install `tzdata` in every new minimal or Alpine-based target added to the
  root `Dockerfile`.
- Use timezone-aware datetimes. Do not persist ambiguous naive local
  datetimes.
