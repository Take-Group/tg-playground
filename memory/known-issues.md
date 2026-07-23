# Known issues & workarounds

## ESLint przypięty do 9.x (frontend)
**Nie aktualizuj ESLint do 10.x** dopóki Next.js 16 tego nie wspiera.

ESLint 10 usunął przestarzałe API `context.getFilename()`, którego nadal używa
`eslint-plugin-react` dołączany przez `eslint-config-next` (Next 16.2.x). Skutek:
`bun run lint` wywala się z `TypeError: ...getFilename is not a function`.

Dlatego w `frontend/package.json` ESLint jest trzymany na `^9` (nie `^10`),
mimo `bun update --latest`. Przy kolejnych aktualizacjach pomijaj ten pakiet,
chyba że `eslint-config-next` ogłosi wsparcie dla ESLint 10.

## TypeScript przypięty do 6.x (frontend)
**Nie aktualizuj TypeScript do 7.x** (stan na 2026-07-14).

TypeScript 7 (natywny kompilator) przechodzi `tsc --noEmit`, ale wywala
`bun run lint`: `@typescript-eslint/typescript-estree` (ciągnięty przez
`eslint-config-next`) czyta z API TS enum, którego nie ma w TS 7
(`TypeError: Cannot read properties of undefined (reading 'Cjs')`).

Dlatego w `frontend/package.json` TypeScript jest trzymany na `^6`.
Odblokować, gdy `@typescript-eslint` ogłosi wsparcie dla TS 7.

## Redis 8 (backend)
Obrazy i klient podbite z Redis 7 → 8 (`redis:8-alpine`, `redis-py` 8.x).
Redis 8 jest na licencji AGPLv3/RSALv2/SSPLv1 — dla boilerplate'u OK, ale
warto pamiętać przy komercyjnym użyciu.

## Temporal UI usunięte
Panel `temporal-ui` (port 8233) wyrzucony z `backend/docker-compose.yml` —
sam serwer `temporal` zostaje, bo worker go potrzebuje. Serwer działa na
wspieranym `temporalio/server`; schemat i namespace inicjalizują osobne,
krótkotrwałe kontenery `temporalio/admin-tools`. Port 7233 nie jest
publikowany na hoście.

## Upstreamowe CVE w obrazach Temporal

Trivy może nadal zgłaszać podatności w skompilowanych binariach Go
dostarczanych przez oficjalne obrazy Temporal. Nie da się ich naprawić
aktualizacją pakietów aplikacji. Przy kolejnych wydaniach obrazów sprawdź,
czy upstream opublikował wersję z poprawionym Go/gRPC, i aktualizuj przypięte
tagi po pełnym teście Docker Compose.

## Lokalny wolumen PostgreSQL z obcą historią Alembic

Na maszynie użytej podczas audytu istniejący wolumen
`tg-playground-backend_pgdata` zawiera rewizję Alembic `478be46c25fa`
i tabele, których nie ma w tym boilerplate. Wolumen został zachowany.
Świeży wolumen przechodzi migracje poprawnie. Przed ewentualnym
`docker compose down -v` trzeba zdecydować, czy te lokalne dane wymagają
kopii zapasowej.
