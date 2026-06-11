# Audio-Platzhalter

Die `.placeholder`-Dateien dokumentieren, welche finalen `.ogg`-Dateien noch fehlen.

Sie sind absichtlich keine `.ogg`-Dateien. So wird verhindert, dass versehentlich ungueltige Audio-Dateien in die GME gebaut werden.

Wenn ihr fuer einen Hardware-Test stille, technisch gueltige `.ogg`-Platzhalter braucht, koennt ihr sie mit ffmpeg erzeugen:

```powershell
.\scripts\New-PlaceholderAudio.ps1
```
