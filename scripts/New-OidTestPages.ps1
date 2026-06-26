[CmdletBinding()]
param(
    [string] $TttoolPath,
    [string] $OutputDirectory = 'build\oid\testpages',
    [string] $CodeDim = '30x30',
    [switch] $IncludeSvg
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

if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
    $resolvedOutputDirectory = $OutputDirectory
}
else {
    $resolvedOutputDirectory = Resolve-TipTalkPath -Path $OutputDirectory
}

New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

$variants = @(
    [pscustomobject]@{ Name = 'test-1200-pixel-2'; Dpi = 1200; PixelSize = 2; Format = 'PDF' },
    [pscustomobject]@{ Name = 'test-1200-pixel-3'; Dpi = 1200; PixelSize = 3; Format = 'PDF' },
    [pscustomobject]@{ Name = 'test-600-pixel-4-stark'; Dpi = 600; PixelSize = 4; Format = 'PDF' }
)

if ($IncludeSvg) {
    $variants += [pscustomobject]@{ Name = 'test-1200-pixel-3-firefox'; Dpi = 1200; PixelSize = 3; Format = 'SVG' }
}

foreach ($variant in $variants) {
    $extension = $variant.Format.ToLowerInvariant()
    $outputPath = Join-Path -Path $resolvedOutputDirectory -ChildPath ("{0}.{1}" -f $variant.Name, $extension)
    $args = @(
        '--code-dim', $CodeDim,
        '--dpi', [string] $variant.Dpi,
        '--pixel-size', [string] $variant.PixelSize,
        '--image-format', $variant.Format,
        'oid-table',
        $yamlPath,
        $outputPath
    )

    Write-TipTalkStatus -Level INFO -Message ("Erzeuge Testseite: {0}" -f $outputPath)
    Push-Location -LiteralPath $projectRoot
    try {
        & $resolvedTttool @args
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    if ($exitCode -ne 0) {
        throw ("tttool oid-table ist fehlgeschlagen fuer {0}. Exit-Code: {1}" -f $variant.Name, $exitCode)
    }

    Write-TipTalkStatus -Level OK -Message ("Testseite erstellt: {0}" -f $outputPath)
}

exit 0
