[CmdletBinding(DefaultParameterSetName = 'Batch')]
param(
    [Parameter(ParameterSetName = 'Single', Mandatory = $true)]
    [string] $InputFile,

    [Parameter(ParameterSetName = 'Single', Mandatory = $true)]
    [string] $AudioId,

    [Parameter(ParameterSetName = 'Batch')]
    [string] $InputRoot,

    [string] $OutputRoot
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\lib\TipTalk.Common.ps1"

$projectRoot = Get-TipTalkProjectRoot

if (-not $InputRoot) {
    $InputRoot = Join-Path -Path $projectRoot -ChildPath 'audio\source'
}
elseif (-not [System.IO.Path]::IsPathRooted($InputRoot)) {
    $InputRoot = Resolve-TipTalkPath -Path $InputRoot
}

if (-not $OutputRoot) {
    $OutputRoot = Join-Path -Path $projectRoot -ChildPath 'audio\ogg'
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputRoot)) {
    $OutputRoot = Resolve-TipTalkPath -Path $OutputRoot
}

$ffmpeg = Get-Command 'ffmpeg' -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
    throw 'ffmpeg wurde nicht gefunden. Installiere ffmpeg und stelle sicher, dass ffmpeg.exe im PATH liegt.'
}

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null

$audioRows = Read-TipTalkCsv -RelativePath 'data\oid_mapping.csv' |
    Where-Object { $_.audio_id -and $_.audio_file }

$validAudioIds = @{}
foreach ($row in $audioRows) {
    $validAudioIds[$row.audio_id] = $row
}

function Convert-OneAudio {
    param(
        [Parameter(Mandatory = $true)]
        [string] $SourceFile,

        [Parameter(Mandatory = $true)]
        [string] $TargetAudioId
    )

    if (-not $validAudioIds.ContainsKey($TargetAudioId)) {
        throw ("Unbekannte Audio-ID: {0}. Nutze einen audio_id Wert aus data\oid_mapping.csv." -f $TargetAudioId)
    }

    Assert-TipTalkFile -Path $SourceFile -Description 'Eingabe-Audiodatei'

    $targetPath = Join-Path -Path $OutputRoot -ChildPath ("{0}.ogg" -f $TargetAudioId)
    Write-TipTalkStatus -Level INFO -Message ("Konvertiere {0} -> {1}" -f $SourceFile, $targetPath)

    & $ffmpeg.Source -y -i $SourceFile -ar 22050 -ac 1 -c:a libvorbis $targetPath
    if ($LASTEXITCODE -ne 0) {
        throw ("ffmpeg ist fehlgeschlagen fuer: {0}" -f $SourceFile)
    }

    Write-TipTalkStatus -Level OK -Message ("Audio erstellt: {0}" -f $targetPath)
}

if ($PSCmdlet.ParameterSetName -eq 'Single') {
    if (-not [System.IO.Path]::IsPathRooted($InputFile)) {
        $InputFile = Resolve-TipTalkPath -Path $InputFile
    }

    Convert-OneAudio -SourceFile $InputFile -TargetAudioId $AudioId
    exit 0
}

if (-not (Test-Path -LiteralPath $InputRoot -PathType Container)) {
    throw ("InputRoot fehlt: {0}" -f $InputRoot)
}

$converted = 0
$sourceFiles = @(Get-ChildItem -LiteralPath $InputRoot -Recurse -File)

foreach ($row in $audioRows) {
    $matches = @(
        $sourceFiles |
            Where-Object { $_.BaseName -eq $row.audio_id -and $_.Extension -ne '.placeholder' } |
            Sort-Object -Property LastWriteTime -Descending
    )

    if ($matches.Count -eq 0) {
        Write-TipTalkStatus -Level WARN -Message ("Keine Quelldatei gefunden fuer audio_id: {0}" -f $row.audio_id)
        continue
    }

    if ($matches.Count -gt 1) {
        Write-TipTalkStatus -Level WARN -Message ("Mehrere Quelldateien fuer {0}; verwende die neueste: {1}" -f $row.audio_id, $matches[0].FullName)
    }

    Convert-OneAudio -SourceFile $matches[0].FullName -TargetAudioId $row.audio_id
    $converted += 1
}

Write-TipTalkStatus -Level OK -Message ("Konvertierung abgeschlossen. Erstellt/aktualisiert: {0} Datei(en)." -f $converted)
exit 0
