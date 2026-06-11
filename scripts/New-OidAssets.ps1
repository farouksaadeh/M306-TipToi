[CmdletBinding()]
param(
    [string] $TttoolPath,
    [string] $ConfigPath = 'config\paths.json',
    [string] $CodesOutputDirectory,
    [string] $TableOutputDirectory,

    [ValidateSet('Table', 'Codes', 'Both')]
    [string] $Mode = 'Both',

    [ValidateSet('PDF', 'SVG')]
    [string] $TableFormat = 'PDF',

    [ValidateSet('PNG', 'SVG', 'SVG+PNG')]
    [string] $CodesFormat = 'PNG',

    [string] $CodeDim = '30x30',
    [int] $Dpi = 1200,
    [int] $PixelSize = 2
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\lib\TipTalk.Common.ps1"

$projectRoot = Get-TipTalkProjectRoot
$resolvedTttool = Get-TipTalkTttoolPath -OverridePath $TttoolPath

if (-not $resolvedTttool) {
    throw 'tttool.exe wurde nicht gefunden. Lege es nach tools\tttool\tttool.exe oder fuege tttool zum PATH hinzu.'
}

$yamlPath = Join-Path -Path $projectRoot -ChildPath 'tiptalk.yaml'
Assert-TipTalkFile -Path $yamlPath -Description 'YAML Datei'

$resolvedConfigPath = $null
if ($ConfigPath) {
    if ([System.IO.Path]::IsPathRooted($ConfigPath)) {
        $resolvedConfigPath = $ConfigPath
    }
    else {
        $resolvedConfigPath = Resolve-TipTalkPath -Path $ConfigPath
    }
}

if ($resolvedConfigPath -and (Test-Path -LiteralPath $resolvedConfigPath -PathType Leaf)) {
    $config = Get-Content -Raw -LiteralPath $resolvedConfigPath -Encoding UTF8 | ConvertFrom-Json

    if (-not $CodesOutputDirectory -and ($config.PSObject.Properties.Name -contains 'oidCodesOutputDirectory')) {
        $CodesOutputDirectory = $config.oidCodesOutputDirectory
    }

    if (-not $TableOutputDirectory -and ($config.PSObject.Properties.Name -contains 'oidTableOutputDirectory')) {
        $TableOutputDirectory = $config.oidTableOutputDirectory
    }
}

if (-not $TableOutputDirectory) {
    $TableOutputDirectory = 'build\oid\table'
}

if (-not $CodesOutputDirectory) {
    $CodesOutputDirectory = 'build\oid\codes'
}

if ([System.IO.Path]::IsPathRooted($TableOutputDirectory)) {
    $tableDirectory = $TableOutputDirectory
}
else {
    $tableDirectory = Resolve-TipTalkPath -Path $TableOutputDirectory
}

if ([System.IO.Path]::IsPathRooted($CodesOutputDirectory)) {
    $codesDirectory = $CodesOutputDirectory
}
else {
    $codesDirectory = Resolve-TipTalkPath -Path $CodesOutputDirectory
}

New-Item -ItemType Directory -Force -Path $tableDirectory, $codesDirectory | Out-Null

$patternArgs = @('--code-dim', $CodeDim, '--dpi', [string] $Dpi, '--pixel-size', [string] $PixelSize)

if ($Mode -in @('Table', 'Both')) {
    $extension = $TableFormat.ToLowerInvariant()
    $tableOutput = Join-Path -Path $tableDirectory -ChildPath ("tiptalk_oid_table.{0}" -f $extension)
    $args = @($patternArgs + @('--image-format', $TableFormat, 'oid-table', $yamlPath, $tableOutput))

    Write-TipTalkStatus -Level INFO -Message ("Erzeuge OID-Tabelle: {0}" -f $tableOutput)
    Push-Location -LiteralPath $projectRoot
    try {
        & $resolvedTttool @args
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    if ($exitCode -ne 0) {
        throw ("tttool oid-table ist fehlgeschlagen. Exit-Code: {0}" -f $exitCode)
    }
    Write-TipTalkStatus -Level OK -Message ("OID-Tabelle erstellt: {0}" -f $tableOutput)
}

if ($Mode -in @('Codes', 'Both')) {
    $args = @($patternArgs + @('--image-format', $CodesFormat, 'oid-codes', $yamlPath))

    Write-TipTalkStatus -Level INFO -Message ("Erzeuge einzelne OID-Codes in: {0}" -f $codesDirectory)
    Push-Location -LiteralPath $codesDirectory
    try {
        & $resolvedTttool @args
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    if ($exitCode -ne 0) {
        throw ("tttool oid-codes ist fehlgeschlagen. Exit-Code: {0}" -f $exitCode)
    }
    Write-TipTalkStatus -Level OK -Message ("OID-Code-Dateien erstellt in: {0}" -f $codesDirectory)
}

exit 0
