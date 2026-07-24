---
name: Project timezone
description: Polish time is the business and presentation timezone across all services.
type: decision
---

The project timezone is `Europe/Warsaw`.

- Every Docker service receives `TZ=Europe/Warsaw`.
- PostgreSQL uses `Europe/Warsaw` for session output and logs.
- Backend code can read the value from `settings.timezone`.
- Frontend date rendering uses the shared `formatDateTime` helper, which
  explicitly selects `Europe/Warsaw` and `pl-PL`.
- Persisted and API timestamps must remain unambiguous instants. Business
  rules and presentation convert them to Polish time instead of storing
  ambiguous naive local datetimes.
- `Europe/Warsaw` must be used instead of a fixed UTC offset because it
  includes Poland's daylight-saving time rules.
