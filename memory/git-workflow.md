---
name: Git workflow — commit prosto na main
description: Użytkownik commituje i pushuje bezpośrednio na main. Nie twórz gałęzi ani PR-ów bez wyraźnej prośby.
type: feedback
---

Użytkownik (2026-08-03): **commituj i pushuj bezpośrednio na `main`.**
Nie zakładaj gałęzi roboczych ani pull requestów, jeśli nie poprosił o to
wprost.

**Why:** To boilerplate i playground, nie produkcja. Użytkownik pracuje sam
i review przez PR jest tu zbędnym narzutem. Gdy poprosił „zrób commit
i wypchnij", a agent założył gałąź `chore/...` i zaproponował PR-a, uznał to
za niepotrzebne obejście jego polecenia.

**How to apply:**
- „zrób commit" / „wypchnij" = `git commit` + `git push origin main`, na
  bieżącej gałęzi `main`.
- Nie pytaj przy tym o PR, nie proponuj gałęzi.
- Gałąź zakładaj tylko wtedy, gdy użytkownik sam o nią poprosi.
- Nadal obowiązuje zasada: commituj **tylko** gdy użytkownik o to poprosi.
