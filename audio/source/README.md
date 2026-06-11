# Rohaufnahmen

Hier koennen spaeter Rohaufnahmen abgelegt werden.

Empfohlen: Benenne jede Rohaufnahme bereits wie die Ziel-`audio_id`, zum Beispiel:

```text
china_mandarin_01_hallo_wie_geht_es_dir.wav
```

Danach kann sie mit folgendem Befehl nach `../ogg/` konvertiert werden:

```powershell
.\scripts\Convert-Audio.ps1
```

Einzeldatei:

```powershell
.\scripts\Convert-Audio.ps1 -InputFile .\audio\source\china_mandarin_01_hallo_wie_geht_es_dir.wav -AudioId china_mandarin_01_hallo_wie_geht_es_dir
```
