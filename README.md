# TipTalk

TipTalk ist ein vorbereitetes lokales tttool-Projekt fuer ein interaktives Tiptoi-Sprachlernspiel zu asiatischen Sprachen. Auf dem spaeteren Lernblatt gibt es OID-Felder fuer 10 Laender und je 3 Alltagssaetze. Beim Antippen spielt der Tiptoi-Stift die passende Audio-Datei ab.

Dieses Repository enthaelt keine finalen Audios und kein finales Layout. Es ist technisch vorbereitet, damit spaeter nur noch echte `.ogg`-Audios und die finale Druckgestaltung ergaenzt werden muessen.

## Projektstruktur

```text
.
|-- tiptalk.yaml                 # tttool-Projektdatei
|-- audio/
|   |-- ogg/                     # finale Ogg Vorbis Audios
|   |-- source/                  # Rohaufnahmen
|   `-- placeholders/            # Marker fuer fehlende Audios
|-- build/
|   |-- gme/                     # erzeugte GME-Datei
|   `-- oid/                     # OID-Tabelle und OID-Muster
|-- config/
|   `-- paths.json               # einstellbare Ausgabeordner
|-- data/
|   |-- tiptalk_mapping.csv      # Sprache/Satz/Audio/OID-Zuordnung
|   `-- oid_mapping.csv          # technische OID-Zuordnung
|-- docs/
|   `-- testing-checklist.md
|-- scripts/
|   |-- Install-Tttool.ps1
|   |-- Build-Gme.ps1
|   |-- New-OidAssets.ps1
|   |-- Convert-Audio.ps1
|   |-- New-PlaceholderAudio.ps1
|   `-- Test-Project.ps1
`-- tools/
    `-- tttool/                  # tttool.exe hier ablegen
```

## tttool herunterladen

1. Oeffne die offizielle Release-Seite: https://github.com/entropia/tip-toi-reveng/releases
2. Lade die neueste `tttool-<version>.zip` herunter.
3. Entpacke die ZIP-Datei.
4. Kopiere `tttool.exe` nach:

```text
tools/tttool/tttool.exe
```

Die offizielle Dokumentation beschreibt tttool als Kommandozeilentool. Unter Windows reicht Entpacken; eine Installation ist nicht noetig.

Optional kannst du tttool automatisch in diesen Ordner laden:

```powershell
.\scripts\Install-Tttool.ps1
```

## Projekt pruefen

In PowerShell im Projektordner:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\Test-Project.ps1
```

Das Script prueft:

- `tttool.exe` vorhanden und ausfuehrbar
- `tiptalk.yaml` vorhanden
- Mapping-Dateien vorhanden
- erwartete Audio-Dateien oder Platzhalter vorhanden
- Output-Ordner vorhanden

Wenn du nur finale `.ogg`-Dateien akzeptieren willst:

```powershell
.\scripts\Test-Project.ps1 -RequireFinalAudio
```

## GME-Datei bauen

```powershell
.\scripts\Build-Gme.ps1
```

Ergebnis:

```text
build/gme/tiptalk.gme
```

Die YAML enthaelt fuer die Entwicklung `speak`-Eintraege. Wenn finale `.ogg`-Dateien fehlen, kann tttool daraus Testansagen erzeugen. Sobald echte Dateien in `audio/ogg/` liegen, werden diese verwendet.

## OID-Tabelle und OID-Codes erzeugen

OID-Codes sind die Punktmuster, die der Tiptoi-Stift auf dem gedruckten Blatt erkennt. Der Stift erkennt also nicht direkt das Bild von China oder Japan, sondern den OID-Code, der im Layout auf diesem Bereich liegt.

Es gibt zwei Arten von OID-Ausgaben:

- OID-Tabelle als PDF: gut fuer schnelle Tests ohne finales Layout.
- Einzelne OID-Felder als PNG: gut fuer das finale Layout, weil jedes Feld separat platziert werden kann.

### OID-Tabelle als PDF erzeugen

Dieser Befehl erzeugt eine Test-Tabelle:

```powershell
.\scripts\New-OidAssets.ps1 -Mode Table
```

Ausgabe:

```text
build/oid/table/tiptalk_oid_table.pdf
```

Diese PDF kann ausgedruckt werden, um die Codes schnell mit dem Tiptoi-Stift zu testen.

### Einzelne OID-Felder als PNG erzeugen

Dieser Befehl erzeugt jedes OID-Feld einzeln als PNG:

```powershell
.\scripts\New-OidAssets.ps1 -Mode Codes
```

Aktueller Ausgabeordner:

```text
C:\Users\saade\OneDrive - bbw.ch\03_Berufsschule Donnerstag\6Semester\Modul 306\TipToi Projekt\OID Felder
```

Beispiele fuer erzeugte Dateien:

```text
oid-930-START.png
oid-930-REPLAY.png
oid-930-STOP.png
oid-930-china_mandarin_01.png
oid-930-china_mandarin_02.png
oid-930-china_mandarin_03.png
```

Insgesamt werden 33 PNG-Dateien erzeugt:

- 1 START-Feld
- 1 REPLAY-Feld
- 1 STOP-Feld
- 30 Satzfelder fuer die 10 Laender

### Ausgabeordner fuer OID-PNGs aendern

Der Ausgabeordner fuer die einzelnen PNG-Dateien steht hier:

```text
config/paths.json
```

Beispiel:

```json
{
  "oidCodesOutputDirectory": "C:\\Users\\saade\\OneDrive - bbw.ch\\03_Berufsschule Donnerstag\\6Semester\\Modul 306\\TipToi Projekt\\OID Felder",
  "oidTableOutputDirectory": "build\\oid\\table"
}
```

Wenn ein anderer Ordner verwendet werden soll, nur diesen Wert aendern:

```json
"oidCodesOutputDirectory": "DEIN\\NEUER\\ORDNER"
```

Danach wieder ausfuehren:

```powershell
.\scripts\New-OidAssets.ps1 -Mode Codes
```

### PDF und PNGs gleichzeitig erzeugen

Dieser Befehl erzeugt die OID-Tabelle und die einzelnen PNG-Felder:

```powershell
.\scripts\New-OidAssets.ps1 -Mode Both
```

### OID-Felder im Layout verwenden

Fuer das finale Lernblatt werden die PNG-Dateien aus dem OID-Ordner ins Design eingefuegt.

Wichtig:

- `oid-930-START.png` muss auf ein Startfeld im Layout.
- `oid-930-china_mandarin_01.png` gehoert zum Feld China, Satz 1.
- `oid-930-china_mandarin_02.png` gehoert zum Feld China, Satz 2.
- `oid-930-china_mandarin_03.png` gehoert zum Feld China, Satz 3.
- Die genaue Zuordnung steht in `data/oid_mapping.csv`.

Das Layout-Team soll die PNGs nicht umbenennen, nicht verzerren und nicht drehen.

Wichtig fuer den Druck:

- OID-Muster nicht skalieren.
- OID-Muster nicht drehen.
- OID-Muster nicht weichzeichnen.
- Nicht mit zu niedriger Druckqualitaet drucken.
- Beim Testdruck keine automatische Seitenskalierung verwenden.
- Der antippbare Bereich muss genug OID-Muster enthalten, damit der Stift ihn erkennt.

### Was kommt auf den Stift und was kommt aufs Papier?

Auf den Tiptoi-Stift kommt nur die GME-Datei:

```text
build/gme/tiptalk.gme
```

Auf das Papier beziehungsweise ins Layout kommen die OID-Codes:

```text
C:\Users\saade\OneDrive - bbw.ch\03_Berufsschule Donnerstag\6Semester\Modul 306\TipToi Projekt\OID Felder
```

Die CSV-, YAML- und PowerShell-Dateien bleiben auf dem PC.

## Echte Audios ersetzen

Finale Audios muessen exakt die Dateinamen aus `data/oid_mapping.csv` verwenden und hier liegen:

```text
audio/ogg/
```

Format:

- Ogg Vorbis
- mono
- 22050 Hz

Beispiel:

```text
audio/ogg/china_mandarin_01_hallo_wie_geht_es_dir.ogg
```

Wenn Rohaufnahmen vorhanden sind, lege sie in `audio/source/` ab. Der Dateiname ohne Endung sollte der `audio_id` aus dem Mapping entsprechen. Danach:

```powershell
.\scripts\Convert-Audio.ps1
```

Einzeldatei konvertieren:

```powershell
.\scripts\Convert-Audio.ps1 -InputFile .\audio\source\china_mandarin_01_hallo_wie_geht_es_dir.wav -AudioId china_mandarin_01_hallo_wie_geht_es_dir
```

Dafuer muss `ffmpeg.exe` im PATH vorhanden sein.

## Inhalt

Vorbereitet sind genau diese 10 Laender und Sprachen:

- China: Chinesisch / Mandarin
- Japan: Japanisch
- Vietnam: Vietnamesisch
- Suedkorea: Koreanisch
- Malaysia: Malaiisch
- Thailand: Thailaendisch
- Saudi Arabien: Arabisch
- Kambodscha: Khmer
- Mongolei: Mongolisch
- Philippinen: Filipino / Tagalog

Pro Sprache sind 3 Saetze vorbereitet:

1. Hallo, wie geht es dir?
2. Wie heisst du?
3. Du hast schoene Augen.

Die Zielsprachentexte, Audio-Dateinamen und OID-Felder stehen in:

```text
data/tiptalk_mapping.csv
data/oid_mapping.csv
```

## Lokal testen

1. `.\scripts\Test-Project.ps1` ausfuehren.
2. `.\scripts\Build-Gme.ps1` ausfuehren.
3. `.\scripts\New-OidAssets.ps1 -Mode Table` ausfuehren.
4. `build/oid/table/tiptalk_oid_table.pdf` ausdrucken.
5. `build/gme/tiptalk.gme` auf den Tiptoi-Stift kopieren.
6. Mit START-Feld aktivieren, danach Satzfelder testen.
7. Fehler mit OID-Feld, Audio-ID, erwarteter Ausgabe und echter Ausgabe dokumentieren.

Optionaler tttool-Simulationstest:

```powershell
.\tools\tttool\tttool.exe play .\tiptalk.yaml
```

## Quellen

- tttool Inspiration: https://tttool.entropia.de/
- tttool Dokumentation: https://tttool.readthedocs.io/de/latest/index.html
- tttool Releases: https://github.com/entropia/tip-toi-reveng/releases
