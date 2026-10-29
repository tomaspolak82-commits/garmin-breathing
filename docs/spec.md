# Zadání – Koherenční dech pro Garmin Forerunner 165 Music

Stav k 2026-10-29. Zatím jen lokálně, bez GitHubu.

## Cíl
Aplikace pro hodinky, která vede koherenční dýchání jemnými vibracemi a uloží cvičení do Garmin Connect jako meditaci s tepem.

## Verze 1

### Nastavení před startem (tlačítky na hodinkách)
- Nádech: 2–10 s, výchozí 5 s.
- Výdech: 2–10 s, výchozí 5 s, nastavuje se zvlášť.
- Délka: odpočet (výchozí 10 min), nebo volné cvičení bez limitu.
- Poslední nastavení si hodinky pamatují.

### Během cvičení
- Černý displej, dole malým bílým písmem odpočet, nebo uplynulý čas.
- Při každém přepnutí nádech/výdech jedno krátké jemné ťuknutí. Fáze se nerozlišují.
- Žádný zvuk. Tep se nezobrazuje, ale nahrává.
- Zhasnutí displeje nevadí, vibrace běží dál.

### Pauza a konec
- Tlačítko START/STOP: pauza a menu Pokračovat / Uložit / Zrušit.
- Konec odpočtu: dvojitá dlouhá vibrace (výrazně jiná než ťuknutí), pípnutí jen pokud ho FR165 Music umí, pak stejné menu.
- Uložení jako aktivita Meditace (SPORT_MEDITATION, podtyp SUB_SPORT_BREATHING) s tepem.

### Dechová frekvence
- Zaznamenat cílový rytmus (např. 5/5 = 6 dechů/min).
- Zjistit, jestli Garmin Connect ukáže naměřenou dechovou frekvenci sám.

## Verze 2 (později)
- Krabicový dech: nádech – zadržení – výdech – zadržení.
- Porovnání cíl × skutečnost dechové frekvence, případně vlastní výpočet z kolísání tepu.

## Otevřené otázky (ověří první test na hodinkách)
- Uloží se aktivita v Garmin Connect jako Meditace?
- Nahrává se tep?
- Je krátké ťuknutí dost jemné? (Forerunner nemá nastavitelnou sílu vibrace, jen délku.)
- Zhasíná displej během aplikace?
- Umí FR165 Music z aplikace pípnout?
- Ukáže Garmin Connect dechovou frekvenci?
