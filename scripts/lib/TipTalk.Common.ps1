Set-StrictMode -Version Latest

function Get-TipTalkProjectRoot {
    $root = Join-Path -Path $PSScriptRoot -ChildPath '..\..'
    return (Resolve-Path -LiteralPath $root).Path
}

function Resolve-TipTalkPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $normalized = $Path -replace '/', [System.IO.Path]::DirectorySeparatorChar
    return Join-Path -Path (Get-TipTalkProjectRoot) -ChildPath $normalized
}

function Get-TipTalkTttoolPath {
    param(
        [string] $OverridePath
    )

    $projectRoot = Get-TipTalkProjectRoot
    $candidates = @()

    if ($OverridePath) {
        $candidates += $OverridePath
    }

    $candidates += @(
        (Join-Path -Path $projectRoot -ChildPath 'tools\tttool\tttool.exe'),
        (Join-Path -Path $projectRoot -ChildPath 'tools\tttool.exe'),
        (Join-Path -Path $projectRoot -ChildPath 'tttool.exe')
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $command = Get-Command 'tttool.exe' -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $command = Get-Command 'tttool' -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

function Read-TipTalkCsv {
    param(
        [Parameter(Mandatory = $true)]
        [string] $RelativePath
    )

    $path = Resolve-TipTalkPath -Path $RelativePath
    return Import-Csv -LiteralPath $path -Encoding UTF8
}

function Write-TipTalkStatus {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('OK', 'ERROR', 'WARN', 'INFO')]
        [string] $Level,

        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    $color = switch ($Level) {
        'OK' { 'Green' }
        'ERROR' { 'Red' }
        'WARN' { 'Yellow' }
        default { 'Cyan' }
    }

    Write-Host ("[{0}] {1}" -f $Level, $Message) -ForegroundColor $color
}

function Assert-TipTalkFile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Description fehlt: $Path"
    }
}
