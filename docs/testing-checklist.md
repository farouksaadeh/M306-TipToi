# TipTalk Test-Checkliste

Diese Checkliste ist fuer lokale Tests mit tttool und spaetere Hardwaretests mit dem Tiptoi-Stift gedacht.

## 1. Projektcheck

- [ ] PowerShell im Projektordner oeffnen.
- [ ] `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` ausfuehren.
- [ ] `.\scripts\Test-Project.ps1` ausfuehren.
- [ ] Pruefen, ob `tttool.exe` gefunden wird.
- [ ] Pruefen, ob alle Audio-Platzhalter oder finalen Audios vorhanden sind.

## 2. YAML und GME

- [ ] `.\scripts\Build-Gme.ps1` ausfuehren.
- [ ] Sicherstellen, dass `build/gme/tiptalk.gme` erzeugt wurde.
- [ ] Bei Fehlern zuerst `tiptalk.yaml` auf Einrueckungen und Dateinamen pruefen.
- [ ] Optional `.\tools\tttool\tttool.exe play .\tiptalk.yaml` testen.

## 3. OID-Ausgabe

- [ ] `.\scripts\New-OidAssets.ps1 -Mode Table` ausfuehren.
- [ ] PDF unter `build/oid/table/tiptalk_oid_table.pdf` oeffnen.
- [ ] START, REPLAY, STOP und alle 30 Satzfelder pruefen.
- [ ] Fuer das finale Layout `.\scripts\New-OidAssets.ps1 -Mode Codes` ausfuehren.

## 4. Drucktest

- [ ] OID-Tabelle oder Testlayout ohne Skalierung drucken.
- [ ] Druckeroptionen pruefen: keine automatische Anpassung an Seite.
- [ ] Falls Codes schlecht erkannt werden: `-PixelSize 3` oder andere Druckeinstellungen testen.
- [ ] Nicht skalieren, drehen oder weichzeichnen.

## 5. Tiptoi-Stift

- [ ] `build/gme/tiptalk.gme` auf den Stift kopieren.
- [ ] Sicherstellen, dass keine zweite GME mit derselben Product-ID `930` auf dem Stift liegt.
- [ ] START-Feld antippen.
- [ ] Jedes Land und jeden Satz testen.
- [ ] REPLAY und STOP optional testen.

## 6. Fehlerdokumentation

Fuer jeden Fehler notieren:

- Datum
- OID-Feld, zum Beispiel `china_mandarin_01`
- OID-Code, zum Beispiel `11001`
- Audio-ID
- erwartete Ausgabe
- tatsaechliche Ausgabe
- verwendeter Ausdruck oder Layoutstand
- verwendete GME-Datei

## 7. Abnahme mit Team

- [ ] Stimmen die Zielsprachentexte fachlich?
- [ ] Stimmen Aussprache und Betonung in den finalen Audios?
- [ ] Sind die antippbaren Bereiche gross genug?
- [ ] Ist das START-Feld gut sichtbar?
- [ ] Sind OID-Muster auf hellen, kontrastreichen Flaechen platziert?
