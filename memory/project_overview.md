---
name: TG Playground — cel i zasady projektu
description: Boilerplate do kodowania z AI dla osób nietechnicznych. Docker-only, SOLID, max 600 linii, pytaj zamiast zgaduj.
type: project
---

TG Playground to boilerplate do kodowania z pomocą AI (Claude Code, Codex). Użytkownicy to osoby nietechniczne.

**Why:** Osoby nietechniczne nie wiedzą jak poruszać się po kodzie — projekt musi być idioto-odporny, dobrze zorganizowany i czytelny.

**How to apply:**
- Zawsze pytaj użytkownika o szczegóły zamiast zgadywać intencje
- Uruchamianie wyłącznie przez Docker — osobno w `backend/` i `frontend/` (`cd backend && docker compose up --build`, analogicznie frontend)
- Zasady SOLID w całym kodzie
- Max 600 linii na plik
- Przed zgłoszeniem gotowości: uruchom lintery i przetestuj endpoint/job
- Szczegóły stacku w `backend/AGENTS.md` i `frontend/AGENTS.md`
