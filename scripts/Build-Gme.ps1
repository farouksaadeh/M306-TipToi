[CmdletBinding()]
param(
    [string] $TttoolPath,
    [string] $YamlPath,
    [string] $OutputPath
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\lib\TipTalk.Common.ps1"

$projectRoot = Get-TipTalkProjectRoot
$resolvedTttool = Get-TipTalkTttoolPath -OverridePath $TttoolPath

if (-not $resolvedTttool) {
    throw 'tttool.exe wurde nicht gefunden. Lege es nach tools\tttool\tttool.exe oder fuege tttool zum PATH hinzu.'
}

if (-not $YamlPath) {
    $YamlPath = Join-Path -Path $projectRoot -ChildPath 'tiptalk.yaml'
}
elseif (-not [System.IO.Path]::IsPathRooted($YamlPath)) {
    $YamlPath = Resolve-TipTalkPath -Path $YamlPath
}

if (-not $OutputPath) {
    $OutputPath = Join-Path -Path $projectRoot -ChildPath 'build\gme\tiptalk.gme'
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Resolve-TipTalkPath -Path $OutputPath
}

Assert-TipTalkFile -Path $YamlPath -Description 'YAML Datei'

$outputDirectory = Split-Path -Path $OutputPath -Parent
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

$oidRows = Read-TipTalkCsv -RelativePath 'data\oid_mapping.csv'
$missingFinalAudio = @(
    $oidRows |
        Where-Object { $_.audio_id -and $_.audio_file } |
        Where-Object { -not (Test-Path -LiteralPath (Resolve-TipTalkPath -Path $_.audio_file) -PathType Leaf) }
)

if ($missingFinalAudio.Count -gt 0) {
    Write-TipTalkStatus -Level INFO -Message ("{0} finale .ogg-Datei(en) fehlen. tttool nutzt dafuer die speak-Entwicklungsansagen aus tiptalk.yaml, falls die lokale tttool-Version TTS unterstuetzt." -f $missingFinalAudio.Count)
}

Write-TipTalkStatus -Level INFO -Message ("Baue GME: {0}" -f $OutputPath)

Push-Location -LiteralPath $projectRoot
try {
    & $resolvedTttool assemble $YamlPath $OutputPath
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    throw ("tttool assemble ist fehlgeschlagen. Exit-Code: {0}" -f $exitCode)
}

if (Test-Path -LiteralPath $OutputPath -PathType Leaf) {
    Write-TipTalkStatus -Level OK -Message ("GME erstellt: {0}" -f $OutputPath)
    exit 0
}

throw ("tttool meldete Erfolg, aber die GME-Datei wurde nicht gefunden: {0}" -f $OutputPath)
