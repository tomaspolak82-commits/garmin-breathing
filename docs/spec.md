# Zadání – Koherenční dech pro Garmin Forerunner 165 Music

Stav k 2026-10-29. Zatím jen lokálně, bez GitHubu.

## Cíl
Aplikace pro hodinky, která vede koherenční dýchání jemnými vibracemi a uloží cvičení do Garmin Connect jako meditaci s tepem a dechovou frekvencí.

## Nastavení (menu na hodinkách, pamatuje si poslední hodnoty)
- Nádech: 2–10 s, výchozí 5 s.
- Výdech: 2–10 s, výchozí 5 s.
- Délka: volná, nebo 5–60 min, výchozí 10 min.
- Vibrace: Vyp / 15 / 30 / 40 ms, výchozí 15 ms.
- Vedení: celou dobu / 10 / 30 / 50 % odpočtu, výchozí celou dobu. U volné délky vždy celou dobu.
- Animace: Ne / Kruhy / Tvář, výchozí Ne.

## Během cvičení
- Černý displej, dole malý bílý čas: odpočet, nebo uplynulý čas.
- Při každém přepnutí nádech/výdech jedno ťuknutí. Po skončení vedení vibrace potichu přestanou.
- Animace Kruhy: 4 soustředné kruhy, při nádechu přibývají (tyrkysové), při výdechu ubývají (jantarové).
- Animace Tvář: šedá čára profilu obličeje, při nádechu přibývají tyrkysové obloučky uvnitř hlavy za nosem, při výdechu přibývají jantarové obloučky před obličejem.
- Žádný zvuk.

## Pauza a konec
- START/STOP: pauza a menu Pokračovat / Uložit / Zrušit.
- Uložit: uloží aktivitu a ukončí aplikaci.
- Zrušit: po potvrzení zahodí aktivitu a vrátí se do menu Koherence.
- Konec odpočtu: jedna dlouhá vibrace (1 s), pak stejné menu. Pokračovat přepne na volné cvičení.
- Aktivita: Meditace (SPORT_MEDITATION, SUB_SPORT_BREATHING), název podle nastavení, např. „Koherence 5/5 · vedení 3 min".

## Ověřeno na hodinkách (2026-10-29)
- Záznam jako meditace s tepem a dechovou frekvencí v Garmin Connect.
- Ťuknutí 15 ms stačí a neruší.
- Vibrační vzory nefungují: více vibrací s mezerou se slije do jedné dlouhé.
- Pípnutí z aplikace není slyšet.
- Menu, paměť nastavení, pauza a pokračování.

## Nápady na později
- Krabicový dech: nádech – zadržení – výdech – zadržení.
