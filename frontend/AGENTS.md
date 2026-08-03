# TG Playground Frontend

## Stack

| Warstwa         | Technologia                          |
| --------------- | ------------------------------------ |
| Runtime         | Bun                                  |
| Framework       | Next.js 16 (App Router, standalone)  |
| Jezyk           | TypeScript 6                         |
| UI              | React 19, Base UI, shadcn/ui 4       |
| Style           | Tailwind CSS 4, tw-animate-css, CVA  |
| State / Fetch   | TanStack React Query 5               |
| Ikony           | Lucide React                         |
| Linting         | ESLint 9 (eslint-config-next)        |

## Uruchomienie (jedyny wspierany sposob)

```bash
cd tg-playground
docker compose up --build
```

Frontend nie ma wlasnego `Dockerfile` ani `docker-compose.yml`. Buduje go
glowny `Dockerfile` w katalogu glownym:

1. **frontend-build** — obraz Bun instaluje zaleznosci i wykonuje `bun run build`.
2. **app** — obraz finalny dostaje sam wynik `next build` (standalone) plus
   binarke `bun`, i serwuje go przez `bun server.js` jako non-root, obok
   procesow backendu (supervisor).

Next.js jest skonfigurowany z `output: "standalone"` (`next.config.ts`), dzieki czemu `.next/standalone` zawiera minimalny serwer gotowy do deploymentu.

**Nie ma hot-reloadu.** Frontend leci w buildzie produkcyjnym, wiec po kazdej
zmianie w `src/` trzeba przebudowac obraz (`docker compose up --build`).
Restart samego procesu frontendu bez przebudowy:

```bash
docker compose exec app supervisorctl -c /etc/supervisor/supervisord.conf restart frontend
```

Frontend jest dostepny pod http://localhost:3000. Jesli port 3000 jest zajety
przez inna aplikacje — nie zabijaj jej. Zmien port zgodnie z procedura
w glownym [AGENTS.md](../AGENTS.md).

## Zasady kodowania

### SOLID

- **S** — Single Responsibility: Kazdy komponent / hook / modul odpowiada za jedna rzecz.
- **O** — Open/Closed: Rozszerzaj zachowanie przez props / kompozycje, nie przez modyfikacje istniejacych komponentow.
- **L** — Liskov Substitution: Komponenty wrappujace musza akceptowac te same props co bazowe.
- **I** — Interface Segregation: Eksportuj male, dedykowane typy. Nie tworz "god" interfejsow.
- **D** — Dependency Inversion: Komponenty korzystaja z abstrakcji (hooki, providery), nie z bezposrednich importow serwisow.

### Limity rozmiaru

- **Maksymalnie 600 linii na plik.** Jesli plik przekracza ten limit — rozdziel go na mniejsze moduly. Celem jest utrzymanie czytelnosci i niedopuszczenie do zapychania kontekstu AI.

### Bezwzgledny zakaz pisania testow automatycznych

**AI nie moze w zadnym przypadku tworzyc ani modyfikowac testow automatycznych.**

- Nie tworz plikow testowych, test case'ow, fixture'ow, mockow ani snapshotow.
- Nie dodawaj frameworkow testowych, skryptow testowych ani konfiguracji testow lub CI.
- Nie rozszerzaj ani nie poprawiaj istniejacych testow automatycznych.
- Frontend weryfikuj przez lint, type-check, audyty, build oraz reczne sprawdzenie dzialania w Dockerze.

### Next.js 16

<!-- BEGIN:nextjs-agent-rules -->
This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->
