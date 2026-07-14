param(
    [Parameter(Mandatory=$true)]
    [string]$Mt5Mql5Folder
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Source = Join-Path $RepoRoot "Experts\SmartGoldDCAPro.mq5"
$Target = Join-Path $Mt5Mql5Folder "Experts\SmartGoldDCAPro.mq5"

if (-not (Test-Path $Source)) { throw "Source not found: $Source" }
if (-not (Test-Path $Target)) { throw "Target not found: $Target" }

$SourceHash = (Get-FileHash $Source -Algorithm SHA256).Hash
$TargetHash = (Get-FileHash $Target -Algorithm SHA256).Hash

$SourceVersion = (Select-String -Path $Source -Pattern '#property\s+version\s+"([^"]+)"').Matches[0].Groups[1].Value
$TargetVersion = (Select-String -Path $Target -Pattern '#property\s+version\s+"([^"]+)"').Matches[0].Groups[1].Value

Write-Host "Repository version: $SourceVersion"
Write-Host "MT5 version:        $TargetVersion"
Write-Host "Repository SHA256:  $SourceHash"
Write-Host "MT5 SHA256:         $TargetHash"

if ($SourceHash -eq $TargetHash) {
    Write-Host "VERIFIED: MT5 is using the repository EA source." -ForegroundColor Green
    exit 0
}

Write-Host "MISMATCH: run Deploy-To-MT5.ps1 again." -ForegroundColor Red
exit 1
