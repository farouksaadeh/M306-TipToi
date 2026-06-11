# TipTalk Team-Absprachen

Diese Punkte sollte das Code-Team mit Layout- und Audio-Team abstimmen.

## Audio

- Jede finale Datei muss exakt den Namen aus `data/oid_mapping.csv` haben.
- Format: Ogg Vorbis, mono, 22050 Hz.
- Die Zielsprachentexte in `data/tiptalk_mapping.csv` sind ein technischer Entwurf und sollten sprachlich geprueft werden.
- Pro Satz sollte eine klare, kurze Aufnahme geliefert werden.
- Keine Hintergrundmusik in den Satzdateien, damit die Ausgabe gut verstaendlich bleibt.

## Layout

- Product-ID und START-Feld: `930`.
- Satzfelder: `11001` bis `11030`.
- Die generierten Dateien `oid-930-*.png` oder die OID-Tabelle aus `build/oid/` sind die technische Grundlage.
- OID-Muster nicht skalieren, drehen oder nachschaerfen.
- Antippbereiche hell halten, damit der Stift die Punkte erkennt.
- Vor dem finalen Druck mindestens einen Hardwaretest auf Papier machen.

## Inhalt

- Die drei Grundsaetze koennen erweitert werden, solange neue Felder in `tiptalk.yaml`, `data/tiptalk_mapping.csv` und `data/oid_mapping.csv` ergaenzt werden.
- Bei Aenderungen an bestehenden Feldern sollten OID-Codes moeglichst stabil bleiben, damit alte Ausdrucke weiter funktionieren.
