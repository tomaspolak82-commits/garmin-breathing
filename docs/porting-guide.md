# Koherence – popis pro převod na jiné hodinky

Kompletní logika a grafika aplikace Koherence, nezávislá na Garminu. Slouží jako zadání pro vlastní verzi na jiných hodinkách (Xiaomi, Wear OS, Apple Watch…), ať už ji píše člověk, nebo AI.

Originál pro Garmin: zdrojový kód ve složce `source/`, náhled animace v `docs/images/face-animation.png`.

## Co aplikace dělá

Vede koherenční dýchání: hodinky jemně ťuknou vibrací při každém přepnutí mezi nádechem a výdechem. Člověk se nemusí dívat na displej ani počítat. Volitelně zobrazí jednoduchou animaci. Na Garminu se cvičení ukládá jako meditace s tepem a dechovou frekvencí.

## Nastavení

Menu před startem. Hodinky si pamatují poslední zvolené hodnoty.

| Položka | Možnosti | Výchozí |
|---|---|---|
| Nádech | 2, 3, 4, 5, 6, 7, 8, 9, 10 s | 5 s |
| Výdech | 2, 3, 4, 5, 6, 7, 8, 9, 10 s | 5 s |
| Délka | volná, 5, 10, 15, 20, 30, 45, 60 min | 10 min |
| Vibrace | Vyp, 15, 30, 40 ms | 15 ms |
| Vedení | celou dobu, 10 %, 30 %, 50 % délky | celou dobu |
| Animace | Ne, Kruhy, Tvář | Ne |

- U položky Start je popisek s aktuálním nastavením, např. „5/5 s · 10 min“.
- Vedení: vibrace běží jen první část cvičení, pak člověk dýchá sám a podle záznamu dechu zjistí, jestli rytmus udržel. U volné délky platí vždy „celou dobu“.

## Časování

Časovač tiká každých 250 ms, když je zapnutá animace, jinak každých 1000 ms.

```
stav:  elapsedMs = 0, phaseMs = 0, inhale = true
start: ťuknutí, spustit časovač

při každém tiku (tickMs):
    elapsedMs += tickMs
    když je délka omezená a elapsedMs >= délka:
        pauza, dlouhá vibrace 1000 ms, otevřít menu pauzy, konec
    phaseMs += tickMs
    když phaseMs >= délka aktuální fáze (nádech nebo výdech):
        phaseMs = 0
        inhale = !inhale
        ťuknutí
    překreslit obrazovku

ťuknutí:
    nic, když je vibrace Vyp
    nic, když je vedení omezené a elapsed >= délka × procento vedení
    jinak jedna vibrace o síle 100 % a délce 15/30/40 ms
```

Krok animace v rámci fáze (1 až 4):

```
phaseStep = floor(phaseMs × 4 / délka fáze) + 1
```

## Obrazovka během cvičení

- Černé pozadí.
- Dole malý bílý čas ve formátu m:ss: zbývající čas při odpočtu, uplynulý čas u volné délky. Střed textu je ve 85 % výšky displeje.
- Během pauzy uprostřed nápis „Pauza“.
- Žádný tep ani jiné údaje.

### Barvy

| Prvek | Barva |
|---|---|
| Nádech | tyrkysová `#1B7F79` |
| Výdech | jantarová `#B0651E` |
| Profil obličeje | šedá `#8C959F` |
| Čas | bílá `#FFFFFF` |

### Animace Kruhy

- Soustředné kružnice se středem ve vodorovném středu a ve 45 % výšky displeje. Čára je silná 3 px.
- Poloměr i-té kružnice je i × 7 % šířky displeje (i = 1 až 4).
- Nádech: tyrkysové, kružnic přibývá (počet = phaseStep).
- Výdech: jantarové, kružnic ubývá (počet = 5 − phaseStep).

### Animace Tvář

Souřadnice jsou pro displej 390 × 390 px s počátkem vlevo nahoře. Na jiném displeji je vynásob poměrem šířka / 390.

**Profil obličeje** je lomená čára šedé barvy, silná 4 px, otočená doprava. Jde od čela přes nos a ústa k bradě a krku:

```
(155,66) (175,72) (198,90) (208,115) (210,135) (206,146) (212,160) (228,185) (226,192)
(212,196) (216,206) (210,212) (215,220) (206,230) (208,242) (198,252) (175,256) (165,270) (167,288)
```

**Obloučky** jsou silné 5 px. Počet = phaseStep (1 až 4) a v obou fázích přibývají. Poloměry jsou 26, 46, 66 a 86 px.

- Nádech (vzduch proudí dovnitř): tyrkysové obloučky uvnitř hlavy za nosem. Střed je (218, 198), oblouk vede od 140° do 220°.
- Výdech (vzduch proudí ven): jantarové obloučky před obličejem. Střed je (222, 198), oblouk vede od 320° přes 0° do 40°.

Úhly: 0° míří doprava (na 3 hodiny) a rostou proti směru hodinových ručiček, 90° míří nahoru. Nádechové obloučky jsou tedy na levé straně svého středu a vydouvají se doleva. Výdechové jsou na pravé straně a vydouvají se doprava.

Pozor na souřadnice: v kreslicích knihovnách, kde osa y roste dolů a úhly rostou po směru hodinových ručiček (HTML canvas, SVG, Android), odpovídá Garmin úhlu α úhel −α. Oblouky jsou ale symetrické podle vodorovné osy, takže stačí kreslit od −40° do 40° (výdech) a od 140° do 220° (nádech).

## Pauza a konec

- Hlavní tlačítko nebo ťuknutí na displej během cvičení: pauza, zastaví se časovač i záznam a otevře se menu Pokračovat / Uložit / Zrušit.
- Pokračovat: rytmus začne znovu nádechem. Když už odpočet skončil, cvičení pokračuje jako volné, bez limitu.
- Uložit: uloží cvičení a ukončí aplikaci.
- Zrušit: po potvrzení „Zrušit aktivitu?“ zahodí cvičení a vrátí se do hlavního menu.
- Tlačítko Zpět během cvičení nedělá nic, aby se cvičení neukončilo omylem.
- Konec odpočtu: jedna dlouhá vibrace (1 s), pak stejné menu pauzy.

## Uložení cvičení

Na Garminu:
- Typ: meditace, podtyp dýchání.
- Zapnutý snímač tepu. Dechovou frekvenci dopočítají hodinky samy.
- Název podle nastavení: „Koherence 5/5“, při omezeném vedení „Koherence 5/5 · vedení 3 min“ (u lichých minut „1,5 min“).

Na jiných hodinkách záleží na tom, jestli platforma dovoluje aplikacím třetích stran ukládat cvičení do zdravotní aplikace. Když to nejde, aplikace funguje i bez ukládání, jen jako vedení dechu.

## Zjištění z testování na Garminu

Mohou se lišit podle hodinek, stojí za to je ověřit:
- Vibrace 15 ms je znatelná a meditaci neruší.
- Forerunner slévá několik vibrací s mezerami do jedné dlouhé, proto aplikace používá jen jednotlivé vibrace.
- Zvuk z aplikace nebyl slyšet, aplikace proto zvuk nepoužívá.
