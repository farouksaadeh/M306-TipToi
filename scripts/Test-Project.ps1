[CmdletBinding()]
param(
    [string] $TttoolPath,
    [switch] $RequireFinalAudio
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\lib\TipTalk.Common.ps1"

$projectRoot = Get-TipTalkProjectRoot
$failedChecks = 0

function Add-Failure {
    $script:failedChecks += 1
}

Write-Host ''
Write-Host 'TipTalk Projektpruefung' -ForegroundColor Cyan
Write-Host ('Projekt: {0}' -f $projectRoot)
Write-Host ''

$resolvedTttool = Get-TipTalkTttoolPath -OverridePath $TttoolPath
if ($resolvedTttool) {
    Write-TipTalkStatus -Level OK -Message ("tttool gefunden: {0}" -f $resolvedTttool)
    & $resolvedTttool --help *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-TipTalkStatus -Level OK -Message 'tttool kann ausgefuehrt werden.'
    }
    else {
        Write-TipTalkStatus -Level ERROR -Message 'tttool wurde gefunden, konnte aber nicht erfolgreich gestartet werden.'
        Add-Failure
    }
}
else {
    Write-TipTalkStatus -Level ERROR -Message 'tttool.exe nicht gefunden. Lege es nach tools\tttool\tttool.exe oder fuege es zum PATH hinzu.'
    Add-Failure
}

$requiredFiles = @(
    @{ Path = 'tiptalk.yaml'; Name = 'tttool YAML' },
    @{ Path = 'data\tiptalk_mapping.csv'; Name = 'Mapping Datei' },
    @{ Path = 'data\oid_mapping.csv'; Name = 'OID Mapping Datei' },
    @{ Path = 'README.md'; Name = 'README' }
)

foreach ($item in $requiredFiles) {
    $path = Resolve-TipTalkPath -Path $item.Path
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        Write-TipTalkStatus -Level OK -Message ("{0} vorhanden: {1}" -f $item.Name, $item.Path)
    }
    else {
        Write-TipTalkStatus -Level ERROR -Message ("{0} fehlt: {1}" -f $item.Name, $item.Path)
        Add-Failure
    }
}

$requiredDirectories = @(
    'audio\ogg',
    'audio\source',
    'audio\placeholders',
    'build\gme',
    'build\oid\table',
    'build\oid\codes',
    'tools\tttool'
)

foreach ($dir in $requiredDirectories) {
    $path = Resolve-TipTalkPath -Path $dir
    if (Test-Path -LiteralPath $path -PathType Container) {
        Write-TipTalkStatus -Level OK -Message ("Ordner vorhanden: {0}" -f $dir)
    }
    else {
        Write-TipTalkStatus -Level ERROR -Message ("Ordner fehlt: {0}" -f $dir)
        Add-Failure
    }
}

try {
    $oidRows = Read-TipTalkCsv -RelativePath 'data\oid_mapping.csv'
    $audioRows = $oidRows | Where-Object { $_.audio_id -and $_.audio_file }

    foreach ($row in $audioRows) {
        $audioPath = Resolve-TipTalkPath -Path $row.audio_file
        $placeholderPath = Resolve-TipTalkPath -Path $row.placeholder_file

        if (Test-Path -LiteralPath $audioPath -PathType Leaf) {
            Write-TipTalkStatus -Level OK -Message ("Audio vorhanden: {0}" -f $row.audio_file)
            continue
        }

        if ((-not $RequireFinalAudio) -and (Test-Path -LiteralPath $placeholderPath -PathType Leaf)) {
            Write-TipTalkStatus -Level OK -Message ("Audio-Platzhalter vorhanden: {0}" -f $row.placeholder_file)
            continue
        }

        if ($RequireFinalAudio -and (Test-Path -LiteralPath $placeholderPath -PathType Leaf)) {
            Write-TipTalkStatus -Level ERROR -Message ("Finale .ogg fehlt fuer {0}; aktuell existiert nur der Platzhalter." -f $row.audio_id)
        }
        else {
            Write-TipTalkStatus -Level ERROR -Message ("Audio oder Platzhalter fehlt fuer {0}" -f $row.audio_id)
        }
        Add-Failure
    }
}
catch {
    Write-TipTalkStatus -Level ERROR -Message ("Audio-Mapping konnte nicht geprueft werden: {0}" -f $_.Exception.Message)
    Add-Failure
}

Write-Host ''
if ($failedChecks -eq 0) {
    Write-TipTalkStatus -Level OK -Message 'Projektpruefung erfolgreich abgeschlossen.'
    exit 0
}

Write-TipTalkStatus -Level ERROR -Message ("Projektpruefung mit {0} Fehler(n) abgeschlossen." -f $failedChecks)
exit 1
