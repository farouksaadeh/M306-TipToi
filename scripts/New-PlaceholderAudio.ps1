[CmdletBinding()]
param(
    [double] $DurationSeconds = 0.4,
    [switch] $Overwrite
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\lib\TipTalk.Common.ps1"

$projectRoot = Get-TipTalkProjectRoot
$outputRoot = Join-Path -Path $projectRoot -ChildPath 'audio\ogg'
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$ffmpeg = Get-Command 'ffmpeg' -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
    throw 'ffmpeg wurde nicht gefunden. Installiere ffmpeg, wenn du echte stille .ogg-Platzhalter erzeugen willst.'
}

$audioRows = Read-TipTalkCsv -RelativePath 'data\oid_mapping.csv' |
    Where-Object { $_.audio_id -and $_.audio_file }

$created = 0
foreach ($row in $audioRows) {
    $targetPath = Resolve-TipTalkPath -Path $row.audio_file

    if ((Test-Path -LiteralPath $targetPath -PathType Leaf) -and (-not $Overwrite)) {
        Write-TipTalkStatus -Level INFO -Message ("Ueberspringe vorhandene Datei: {0}" -f $row.audio_file)
        continue
    }

    Write-TipTalkStatus -Level INFO -Message ("Erzeuge stillen Audio-Platzhalter: {0}" -f $row.audio_file)
    & $ffmpeg.Source -y -f lavfi -i 'anullsrc=channel_layout=mono:sample_rate=22050' -t ([string] $DurationSeconds) -c:a libvorbis $targetPath

    if ($LASTEXITCODE -ne 0) {
        throw ("ffmpeg konnte den Platzhalter nicht erzeugen: {0}" -f $targetPath)
    }

    $created += 1
}

Write-TipTalkStatus -Level OK -Message ("Stille .ogg-Platzhalter erstellt/aktualisiert: {0}" -f $created)
exit 0
