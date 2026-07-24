# Skill: Frontend timezone

## What it does

Keeps server-side and browser-side date formatting in the Polish
`Europe/Warsaw` timezone, regardless of the user's device timezone.

## Files involved

- `frontend/docker-compose.yml` — sets `TZ` and `NEXT_PUBLIC_TIME_ZONE`
- `frontend/Dockerfile` — installs `tzdata` and sets both variables for build
  and production runtime
- `frontend/src/lib/date-time.ts` — shared `formatDateTime` formatter

## Flow

1. The Next.js server runs with `TZ=Europe/Warsaw`.
2. `NEXT_PUBLIC_TIME_ZONE` makes the same setting available in browser code.
3. `formatDateTime` always passes the explicit timezone to
   `Intl.DateTimeFormat` and uses the `pl-PL` locale.

## How to extend

- Use `formatDateTime` instead of calling `toLocaleString()` directly.
- For a live clock based on the current moment, render it after client mount
  to avoid a Next.js hydration mismatch.
- Keep API timestamps unambiguous, preferably ISO 8601 with an explicit
  offset or `Z`.
