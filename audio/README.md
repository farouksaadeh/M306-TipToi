# TipTalk Audio

Dieser Ordner ist fuer alle Audio-Dateien des TipTalk-Projekts vorbereitet.

- `ogg/`: Finale Tiptoi-Audios. Diese Dateien muessen Ogg Vorbis, mono, 22050 Hz sein.
- `source/`: Rohaufnahmen oder Team-Lieferungen, zum Beispiel WAV, MP3 oder M4A.
- `placeholders/`: Markerdateien fuer noch fehlende finale Audios.

Die verbindliche Dateiliste steht in `../data/oid_mapping.csv`. Finale Dateien muessen exakt so heissen wie dort in `audio_file` angegeben.

Konvertierung mit ffmpeg:

```powershell
.\scripts\Convert-Audio.ps1
```

Dabei sucht das Script in `audio/source/` nach Dateien, deren Dateiname ohne Endung der `audio_id` entspricht, und schreibt die fertigen `.ogg`-Dateien nach `audio/ogg/`.
