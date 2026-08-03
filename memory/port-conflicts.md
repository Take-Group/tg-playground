---
name: Konflikty portów między aplikacjami z boilerplate'u
description: Porty hosta kolidują między appkami budowanymi na tym boilerplate — zmieniaj port w tym projekcie, nigdy nie zabijaj cudzego stacku.
type: feedback
---

Użytkownik (2026-08-03): jeśli widzisz, że port Dockera jest zajęty — zmień go
w tym projekcie na inny, losowy, i zaktualizuj we wszystkich miejscach, gdzie
występuje. Nie zatrzymuj cudzego kontenera.

**Why:** TG Playground to boilerplate, na jego bazie powstaje kilkanaście
osobnych aplikacji. Wszystkie dziedziczą porty 3000 i 8000, więc gdy działają
równolegle na jednej maszynie, kolidują ze sobą. To stan normalny i będzie się
powtarzać przy każdej kolejnej appce.

**How to apply:**
- Pełna procedura jest w `AGENTS.md`, sekcja „Konflikty portów — obowiązkowa
  procedura dla AI agentów". Trzymaj ją aktualną.
- Losowy wolny port z zakresu 10000–65000, zmieniana tylko strona hosta
  w `compose.yaml`; porty wewnątrz kontenera zostają.
- Zawsze powiedz użytkownikowi, jakie porty wybrałeś.
- Konkretny przypadek na maszynie użytkownika: projekt `pulse`
  (`~/projects/affleaders/pulse`) trzyma `127.0.0.1:3000` i `127.0.0.1:8000`.
  Użytkownik świadomie **nie chce** zmieniać portów w samym TG Playground —
  reguła dotyczy aplikacji budowanych na jego bazie.

Powiązane: [[docker-orchestration]]
