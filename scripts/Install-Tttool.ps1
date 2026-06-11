[CmdletBinding()]
param(
    [switch] $KeepZip
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\lib\TipTalk.Common.ps1"

$projectRoot = Get-TipTalkProjectRoot
$toolDirectory = Join-Path -Path $projectRoot -ChildPath 'tools\tttool'
$downloadDirectory = Join-Path -Path $toolDirectory -ChildPath '_download'
New-Item -ItemType Directory -Force -Path $toolDirectory, $downloadDirectory | Out-Null

$downloadUrl = $null
$assetName = $null

try {
    $releaseUrl = 'https://api.github.com/repos/entropia/tip-toi-reveng/releases/latest'
    Write-TipTalkStatus -Level INFO -Message 'Lade Informationen zum neuesten tttool Release von GitHub...'
    $release = Invoke-RestMethod -Uri $releaseUrl -Headers @{ 'User-Agent' = 'TipTalk-Setup' }

    $zipAsset = $release.assets |
        Where-Object { $_.name -match '^tttool.*\.zip$' } |
        Select-Object -First 1

    if ($zipAsset) {
        $downloadUrl = $zipAsset.browser_download_url
        $assetName = $zipAsset.name
    }
}
catch {
    Write-TipTalkStatus -Level WARN -Message 'GitHub API konnte nicht genutzt werden. Versuche Fallback ueber releases/latest.'
}

if (-not $downloadUrl) {
    $latestUrl = 'https://github.com/entropia/tip-toi-reveng/releases/latest'
    $request = [System.Net.WebRequest]::Create($latestUrl)
    $request.Method = 'HEAD'
    $request.AllowAutoRedirect = $false
    $response = $request.GetResponse()
    $location = $response.Headers['Location']
    $response.Close()

    if ($location -notmatch '/releases/tag/([^/]+)$') {
        throw 'Der neueste tttool Release konnte nicht automatisch erkannt werden.'
    }

    $tag = $Matches[1]
    $assetName = "tttool-$tag.zip"
    $downloadUrl = "https://github.com/entropia/tip-toi-reveng/releases/download/$tag/$assetName"
}

$zipPath = Join-Path -Path $downloadDirectory -ChildPath $assetName
Write-TipTalkStatus -Level INFO -Message ("Lade herunter: {0}" -f $downloadUrl)
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -TimeoutSec 600

$extractPath = Join-Path -Path $downloadDirectory -ChildPath 'extracted'
if (Test-Path -LiteralPath $extractPath) {
    Remove-Item -LiteralPath $extractPath -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $extractPath | Out-Null

Write-TipTalkStatus -Level INFO -Message 'Entpacke tttool ZIP...'
Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

$tttoolExe = Get-ChildItem -LiteralPath $extractPath -Recurse -Filter 'tttool.exe' -File |
    Select-Object -First 1

if (-not $tttoolExe) {
    throw 'Die ZIP-Datei wurde entpackt, aber tttool.exe wurde nicht gefunden.'
}

$extractedRoot = Split-Path -Path $tttoolExe.FullName -Parent
Get-ChildItem -LiteralPath $extractedRoot -Force |
    Copy-Item -Destination $toolDirectory -Recurse -Force

$targetPath = Join-Path -Path $toolDirectory -ChildPath 'tttool.exe'
Write-TipTalkStatus -Level OK -Message ("tttool.exe installiert: {0}" -f $targetPath)

if (-not $KeepZip) {
    Remove-Item -LiteralPath $downloadDirectory -Recurse -Force
}

Write-TipTalkStatus -Level OK -Message 'Fertig. Danach kannst du .\scripts\Test-Project.ps1 ausfuehren.'
exit 0
