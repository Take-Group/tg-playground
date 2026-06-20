# Known issues & workarounds

## ESLint przypięty do 9.x (frontend)
**Nie aktualizuj ESLint do 10.x** dopóki Next.js 16 tego nie wspiera.

ESLint 10 usunął przestarzałe API `context.getFilename()`, którego nadal używa
`eslint-plugin-react` dołączany przez `eslint-config-next` (Next 16.2.x). Skutek:
`bun run lint` wywala się z `TypeError: ...getFilename is not a function`.

Dlatego w `frontend/package.json` ESLint jest trzymany na `^9` (nie `^10`),
mimo `bun update --latest`. Przy kolejnych aktualizacjach pomijaj ten pakiet,
chyba że `eslint-config-next` ogłosi wsparcie dla ESLint 10.

## Redis 8 (backend)
Obrazy i klient podbite z Redis 7 → 8 (`redis:8-alpine`, `redis-py` 8.x).
Redis 8 jest na licencji AGPLv3/RSALv2/SSPLv1 — dla boilerplate'u OK, ale
warto pamiętać przy komercyjnym użyciu.

## Temporal UI usunięte
Panel `temporal-ui` (port 8233) wyrzucony z `backend/docker-compose.yml` —
sam serwer `temporal` (7233) zostaje, bo worker go potrzebuje.
