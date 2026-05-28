# UI Design System — Frontend

Ustalone konwencje wizualne frontendu (TG Playground admin panel). Dotyczą `frontend/`.

## Typografia
- Globalny font: sans stack — `"Inter", "Geist", "SF Pro Display", "SF Pro Text", "Segoe UI", system-ui, sans-serif` (zmienne `--font-sans` i `--font-heading` w `globals.css`).
- Monospace TYLKO przez `font-mono` (`--font-mono` pozostaje Menlo/Monaco/Consolas…).
- `html` ma `text-base` (nie `text-sm`).

## Dark theme (domyślny — `<html class="dark">`)
- Paleta slate/navy (hue 248), nie czysta czerń, z tealowym primary accentem (hue 176).
- Kluczowe tokeny OKLCH: background `0.18 0.018 248`, card `0.225 0.018 248`, popover `0.24 0.018 248`, foreground `0.96 0.006 248`, primary `0.78 0.105 176`, muted `0.28 0.016 248`, muted-foreground `0.74 0.025 248`, border `1 0 0 / 12%`. `ring` = primary (teal).

## Kursory (globalne reguły w `globals.css @layer base`)
- `cursor-pointer` dla: button, a[href], label[for], select, summary, [role="button"].
- `cursor-not-allowed` dla disabled / [aria-disabled="true"] / [data-disabled].
- Button (`ui/button.tsx`) ma dodatkowo `cursor-pointer` + `disabled:cursor-not-allowed` w base; wariant default: `hover:bg-primary/90 active:bg-primary/80`; focus-visible ring już był.

## Dashboardy / panele operatorskie
- Spokojny layout operatorski, NIE hero/marketing.
- Czytelny tekst; główna treść NIE `text-xs`.
- Karty tylko dla realnych elementów roboczych.
- Radius maksymalnie `rounded-lg`.

## Modale (gdy powstaną — brak komponentu Dialog na dziś)
- Klik poza modalem zamyka; Escape zamyka.
- Overlay lekki: `bg-background/45 backdrop-blur-sm` (NIE ciężki czarny overlay).
- Treść czytelna, nie przeskalowana: tytuł `text-xl md:text-2xl`, body `text-sm leading-6`, sekcje `p-3`/`p-4`.
- Lista wyników w modalu → TABELA, nie pionowe bloki. Np. kolumny: URL | Template | Status code / Wykryta wartość. Wynik po prawej wyraźny: `text-base font-semibold`.

**How to apply:** Przy każdym nowym widoku/komponencie frontendu trzymaj się tych tokenów i reguł. Modal/tabela: zaimplementuj wg powyższych wytycznych przy pierwszym Dialogu.
