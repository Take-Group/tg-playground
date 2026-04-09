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

## Uruchomienie w Docker

```bash
docker build -t tg-playground-frontend .
docker run -p 3000:3000 tg-playground-frontend
```

Dockerfile korzysta z multi-stage build:

1. **base** — `oven/bun:1` — instaluje zaleznosci i buduje aplikacje (`bun run build`).
2. **runner** — `oven/bun:1-slim` — kopiuje standalone output i serwuje przez `bun server.js`.

Next.js jest skonfigurowany z `output: "standalone"` (`next.config.ts`), dzieki czemu `.next/standalone` zawiera minimalny serwer gotowy do deploymentu.

## Zasady kodowania

### SOLID

- **S** — Single Responsibility: Kazdy komponent / hook / modul odpowiada za jedna rzecz.
- **O** — Open/Closed: Rozszerzaj zachowanie przez props / kompozycje, nie przez modyfikacje istniejacych komponentow.
- **L** — Liskov Substitution: Komponenty wrappujace musza akceptowac te same props co bazowe.
- **I** — Interface Segregation: Eksportuj male, dedykowane typy. Nie tworz "god" interfejsow.
- **D** — Dependency Inversion: Komponenty korzystaja z abstrakcji (hooki, providery), nie z bezposrednich importow serwisow.

### Limity rozmiaru

- **Maksymalnie 600 linii na plik.** Jesli plik przekracza ten limit — rozdziel go na mniejsze moduly. Celem jest utrzymanie czytelnosci i niedopuszczenie do zapychania kontekstu AI.

### Next.js 16

<!-- BEGIN:nextjs-agent-rules -->
This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->
