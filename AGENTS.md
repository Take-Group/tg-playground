# AGENTS.md — TG Playground

## Jak uruchomić projekt

**Jedynym wspieranym sposobem uruchomienia projektu jest Docker.**

Projekt składa się z dwóch niezależnych instancji Docker — jednej dla backendu, drugiej dla frontendu. Każda z nich ma własny `docker-compose` w swoim folderze.

### Backend
```bash
cd backend
docker compose up --build
```
Backend podnosi: API (FastAPI), worker (Temporal), migracje (Alembic), PostgreSQL, Redis, Temporal.

### Frontend
```bash
cd frontend
docker compose up --build
```

### Zatrzymanie
W każdym folderze osobno:
```bash
docker compose down
```
Aby usunąć dane (volumes):
```bash
docker compose down -v
```

### Dostępne adresy po uruchomieniu
| Serwis       | Adres                          |
|--------------|--------------------------------|
| Frontend     | http://localhost:3000           |
| API          | http://localhost:8000           |
| API health   | http://localhost:8000/health    |
| Temporal UI  | http://localhost:8233           |

---

## Struktura projektu

Projekt składa się z dwóch głównych folderów:

| Folder       | Opis                                                        |
|--------------|-------------------------------------------------------------|
| `backend/`   | Python 3.14+, FastAPI, SQLAlchemy, Temporal, Redis          |
| `frontend/`  | Next.js 16, React 19, TypeScript, Tailwind CSS, Bun         |

**Szczegóły stacku technologicznego i instrukcje pracy z kodem znajdziesz w `AGENTS.md` wewnątrz każdego folderu:**
- [backend/AGENTS.md](backend/AGENTS.md)
- [frontend/AGENTS.md](frontend/AGENTS.md)

---

## Zasady dla AI agentów

### Cel projektu
Ten projekt to boilerplate do kodowania z pomocą AI. Użytkownicy tego projektu to osoby nietechniczne — kod musi być idioto-odporny, czytelny i dobrze zorganizowany.

### Podział odpowiedzialności
- **`backend/`** — cała logika biznesowa, przetwarzanie danych, workflow, integracje z zewnętrznymi serwisami. Backend wystawia endpointy REST API, z których korzysta frontend.
- **`frontend/`** — część wizualna, UI, interakcja z użytkownikiem. Frontend komunikuje się z backendem wyłącznie przez endpointy API.

**Nigdy nie mieszaj tych warstw.** Logika biznesowa nie trafia do frontendu. Kod wizualny nie trafia do backendu.

### Sposób pracy — Plan Mode
Gdy użytkownik opisze nową funkcjonalność, **zawsze najpierw wejdź w Plan Mode** i rozplanuj całość:
1. Zadaj pytania doprecyzowujące (jeśli potrzeba)
2. Zaplanuj co musi powstać po stronie **backendu** (endpointy, serwisy, modele, workflow)
3. Zaplanuj co musi powstać po stronie **frontendu** (strony, komponenty, hooki, wywołania API)
4. Określ kontrakt API między backendem a frontendem (URL, metoda, request body, response)
5. Dopiero po zatwierdzeniu planu przez użytkownika — zacznij implementację

### Pytaj zamiast zgadywać
**Twoje główne zadanie to zadawanie pytań.** Jeśli użytkownik opisze zadanie w 10 wyrazach — nie zgaduj co miał na myśli. Zapytaj:
- Co dokładnie chcesz osiągnąć?
- Jakie dane wchodzą, jakie wychodzą?
- Czy to ma być endpoint, job, czy coś innego?
- Kto będzie tego używał?

Lepiej zadać 3 pytania za dużo niż zbudować coś źle.

### SOLID
Cały kod musi przestrzegać zasad SOLID:
- **S** — Single Responsibility: każdy plik/klasa/komponent ma jedną odpowiedzialność
- **O** — Open/Closed: rozszerzaj przez nowe moduły, nie modyfikuj istniejących
- **L** — Liskov Substitution: podtypy muszą być wymienne z typami bazowymi
- **I** — Interface Segregation: małe, dedykowane interfejsy zamiast jednego dużego
- **D** — Dependency Inversion: zależności od abstrakcji, nie od konkretnych implementacji

### Limit rozmiaru plików
**Maksymalnie 600 linii na plik.** Bez wyjątków.

Jeśli plik zbliża się do limitu:
1. Wydziel logikę do osobnych modułów
2. Rozbij duże klasy/komponenty na mniejsze
3. Przenieś helpery do dedykowanych plików

Uzasadnienie: duże pliki zapychają kontekst AI i uniemożliwiają efektywną pracę.

### Weryfikacja przed odpowiedzią
Za każdym razem gdy zmieniasz kod, **zanim powiesz użytkownikowi że jest gotowe**, musisz:
1. **Sprawdzić poprawność kodu** — uruchom lintery/type-checkery aby upewnić się, że nie ma błędów importów, brakujących zależności ani warningów
2. **Przetestować działanie** — jeśli to endpoint: wyślij request i sprawdź czy zwraca poprawny status. Jeśli to job/workflow: uruchom go i zweryfikuj wynik
3. **Nie zgłaszaj niczego jako gotowe** dopóki testy nie przejdą pomyślnie

### Pamięć projektu
Po każdej sesji pracy **zapisuj kluczowe informacje** do folderu `memory/` w katalogu głównym projektu. Zapisuj:
- Decyzje architektoniczne podjęte z użytkownikiem (np. "autoryzacja przez JWT", "płatności przez Stripe")
- Ustalony kontrakt API między backendem a frontendem
- Kontekst biznesowy — co projekt robi, dla kogo, jakie ma cele
- Preferencje użytkownika dotyczące sposobu pracy
- Znane problemy i obejścia

**Nie zapisuj** rzeczy, które można odczytać z kodu (struktura plików, nazwy zmiennych, git history).

Przed rozpoczęciem pracy **zawsze sprawdź folder `memory/`** — tam znajdziesz kontekst z poprzednich sesji.

### Skills — dokumentacja funkcjonalności
Folder `skills/` zawiera opisy złożonych funkcjonalności projektu, podzielone na `skills/backend/` i `skills/frontend/`.

**Kiedy tworzyć skill:**
Gdy funkcjonalność obejmuje wiele plików (np. 3+ plików współpracujących ze sobą) i ponowna analiza tych plików za każdym razem byłaby stratą kontekstu — stwórz skill. Skill to krótki dokument `.md` który opisuje jak dana funkcjonalność działa, jakie pliki są zaangażowane i jak je ze sobą powiązać.

**Jak tworzyć skill:**
1. Nazwa pliku: `skills/backend/nazwa-funkcji.md` lub `skills/frontend/nazwa-funkcji.md`
2. Zawartość:
   - Krótki opis co funkcjonalność robi
   - Lista plików które ją tworzą (ścieżki względne)
   - Jak te pliki ze sobą współpracują (przepływ danych)
   - Jak rozszerzać tę funkcjonalność (gdzie dodać nowy endpoint, nowy komponent itp.)
3. Po utworzeniu skilla — dopisz go do listy poniżej

**Kiedy używać skilli:**
Przed modyfikacją istniejącej funkcjonalności **sprawdź czy istnieje dla niej skill** w `skills/`. Jeśli tak — przeczytaj go zamiast analizować pliki od zera.

**Aktualizacja skilli:**
Gdy zmieniasz kod objęty skillem — zaktualizuj też skill. Nieaktualny skill jest gorszy niż brak skilla.

#### Lista skilli

**Backend (`skills/backend/`):**
- [new-endpoint.md](skills/backend/new-endpoint.md) — how to add a new REST API endpoint (router → service → schema)
- [new-model.md](skills/backend/new-model.md) — how to add a SQLAlchemy model + Alembic migration
- [new-workflow.md](skills/backend/new-workflow.md) — how to add a Temporal workflow + activities

**Frontend (`skills/frontend/`):**
- [new-page.md](skills/frontend/new-page.md) — how to add a new page/route (App Router)
- [new-component.md](skills/frontend/new-component.md) — how to add a UI component (shadcn + CVA pattern)
- [api-communication.md](skills/frontend/api-communication.md) — how to connect frontend to backend API (React Query + fetch)

### Firmowe API (MCP — TG Endpoints)
Jeśli potrzebujesz danych z wewnętrznych projektów firmowych — **Blog CMS, VOD CMS, LP CMS, OSA, OMS, DMS** — korzystaj z firmowego serwera MCP.

- **Strona z instrukcją instalacji:** https://endpoints-mcp.affleaders.com/
- **Adres połączenia MCP:** https://endpoints-mcp.affleaders.com/mcp

Serwer MCP daje read-only dostęp do endpointów produkcyjnych tych projektów. Workflow:
1. `list_endpoints` z nazwą projektu → lista dostępnych endpointów
2. `call_endpoint` z projektem + nazwą endpointu → dane
3. Opcjonalnie można nadpisać query/path params przez argument `params`

### Narzędzia
Pracujemy głównie z **Claude Code** i **Codex**. Oba narzędzia czytają ten plik, więc trzymaj się tych zasad niezależnie od tego, które narzędzie jest używane.
