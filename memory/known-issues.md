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
Panel `temporal-ui` (port 8233) wyrzucony z `compose.yaml` —
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

## `shadcn` jest devDependency, nie dependency

Pakiet `shadcn` to CLI + arkusz `shadcn/tailwind.css` importowany w
`src/app/globals.css`. Potrzebny **wyłącznie na etapie budowania** — wynik
`next build --output standalone` go nie zawiera. Trzymanie go w
`dependencies` ciągnęło do audytu cały jego łańcuch (`@modelcontextprotocol/sdk`,
`ts-morph`, `@dotenvx/dotenvx`, `hono`, `undici`, `ip-address`, `cosmiconfig`)
i odpowiadało za większość zgłoszeń `bun audit`. Nie przenoś go z powrotem do
`dependencies`.

## Bun nie obsługuje zagnieżdżonych `overrides`

Ani zagnieżdżona składnia npm (`"minimatch": { "brace-expansion": "..." }`),
ani ścieżkowe `resolutions` w stylu Yarn nie działają — Bun wypisuje
`warn: Bun currently does not support nested "overrides"` i je ignoruje.
Obsługiwane są tylko płaskie `overrides` (jedna wersja na pakiet w całym drzewie).

Konsekwencja: gdy dwie gałęzie drzewa potrzebują **różnych** major wersji tego
samego pakietu (np. `brace-expansion` 1.x dla `minimatch@3` i 5.x dla
`minimatch@10`, o niekompatybilnym kształcie eksportu), płaski override nic nie
da — złamie jedną z gałęzi. Rozwiązanie: **skasuj `bun.lock` i zrób
`bun install` od zera**. `bun update` podbija tylko zależności bezpośrednie
i zostawia przypięte tranzytywne; świeża rozwiązywalność podnosi każdą z nich
do najwyższej wersji mieszczącej się w jej zakresie semver — a łatki
bezpieczeństwa zwykle się w tych zakresach mieszczą.

## Nienaprawialne CVE w obrazie `app` (perl, jaraco-context)

`docker scout` zgłasza w obrazie `app` dwa pakiety, których **nie da się
naprawić** i które nie są osiągalne z kodu aplikacji:

- **`perl-base` 5.40.1-6** (2× CRITICAL, 2× HIGH) — pakiet *essential* Debiana
  trixie, bez poprawki upstream i bez możliwości odinstalowania.
- **`jaraco-context` 6.0.1** (CVE-2026-23949, HIGH) — wchodzi przez
  `python3-pkg-resources`, od którego zależy apt-owy `supervisor`.
  Poprawiona wersja to 6.1.0, Debian trixie jej nie ma.

Żaden z nich nie jest wywoływany przez API, worker ani frontend. Przy kolejnym
przeglądzie sprawdź, czy Debian wydał poprawki; alternatywą jest porzucenie
apt-owego `supervisora` na rzecz instalacji przez `uv` w osobnym venv
(usuwa `python3-pkg-resources` z obrazu), ale to zmienia ścieżkę startu kontenera.

## Fałszywy alarm: CVE Go w obrazie `postgres`

`docker scout` raportuje dla obrazu `postgres` ~26 podatności w `golang/stdlib
1.24.6`. To artefakt skanowania warstw pośrednich — binarka `gosu` jest
kasowana w naszym `Dockerfile` (`rm /usr/local/bin/gosu`) i **w finalnym
systemie plików nie ma żadnej binarki Go** (zweryfikowane skanem
`find / -xdev -type f -perm -u+x` + `grep go1.`). Nie ma tu czego naprawiać.

## Lokalny wolumen PostgreSQL z obcą historią Alembic — ROZWIĄZANE

Wolumen `tg-playground-backend_pgdata` zawierał obcą rewizję Alembic
`478be46c25fa`, przez co `alembic upgrade head` padał z
`Can't locate revision identified by '478be46c25fa'` (katalog
`backend/alembic/versions/` jest pusty — jest tylko `.gitkeep`) i kontener
`app` nie startował.

2026-08-03 użytkownik zdecydował o skasowaniu wolumenu (`docker compose down -v`).
Uzasadnienie użytkownika: to playground, lokalne dane nie mają wartości —
liczy się to, żeby stack działał. Po skasowaniu pełny stack startuje
poprawnie. Przy podobnym problemie w przyszłości nie trzeba się wahać z
`docker compose down -v`, ale nadal warto o tym poinformować.

## Porty 3000 i 8000 bywają zajęte przez inny projekt

Aplikacje budowane na tym boilerplate dziedziczą porty 3000 i 8000 i kolidują
ze sobą, gdy działają równolegle. Na maszynie użytkownika robi to m.in. projekt
`pulse` (`~/projects/affleaders/pulse`).

Nie zabijaj cudzego stacku. Pełna procedura zmiany portu jest w `AGENTS.md`
(sekcja „Konflikty portów"), kontekst decyzji w `memory/port-conflicts.md`.
Sam TG Playground zostaje na 3000/8000 — reguła dotyczy appek budowanych
na jego bazie.
