param(
    [Parameter(Mandatory=$true)]
    [string]$Mt5Mql5Folder
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ExpertSource = Join-Path $RepoRoot "Experts\SmartGoldDCAPro.mq5"
$IncludeSource = Join-Path $RepoRoot "Include\SmartGoldDCAPro"
$PresetSource = Join-Path $RepoRoot "Presets\SmartGoldDCAPro_Exness_Demo.set"

if (-not (Test-Path $Mt5Mql5Folder)) {
    throw "MT5 MQL5 folder not found: $Mt5Mql5Folder"
}
if (-not (Test-Path $ExpertSource)) {
    throw "EA source not found: $ExpertSource"
}
if (-not (Test-Path $IncludeSource)) {
    throw "Include source not found: $IncludeSource"
}

$ExpertTarget = Join-Path $Mt5Mql5Folder "Experts\SmartGoldDCAPro.mq5"
$IncludeTarget = Join-Path $Mt5Mql5Folder "Include\SmartGoldDCAPro"
$PresetTargetFolder = Join-Path $Mt5Mql5Folder "Profiles\Tester"
$DeployMetaFolder = Join-Path $RepoRoot ".deploy"

New-Item -ItemType Directory -Force -Path `
    (Split-Path $ExpertTarget -Parent), `
    (Split-Path $IncludeTarget -Parent), `
    $PresetTargetFolder, `
    $DeployMetaFolder | Out-Null

if (Test-Path $IncludeTarget) {
    Remove-Item $IncludeTarget -Recurse -Force
}

Copy-Item $ExpertSource $ExpertTarget -Force
Copy-Item $IncludeSource $IncludeTarget -Recurse -Force

if (Test-Path $PresetSource) {
    Copy-Item $PresetSource (Join-Path $PresetTargetFolder "SmartGoldDCAPro_Exness_Demo.set") -Force
}

$SourceHash = (Get-FileHash $ExpertSource -Algorithm SHA256).Hash
$TargetHash = (Get-FileHash $ExpertTarget -Algorithm SHA256).Hash

if ($SourceHash -ne $TargetHash) {
    throw "Deployment verification failed: EA source and destination hashes differ."
}

$VersionLine = Select-String -Path $ExpertSource -Pattern '#property\s+version\s+"([^"]+)"'
$Version = if ($VersionLine.Matches.Count -gt 0) {
    $VersionLine.Matches[0].Groups[1].Value
} else {
    "unknown"
}

$Metadata = [ordered]@{
    deployed_at = (Get-Date).ToString("s")
    version = $Version
    repository = $RepoRoot
    mt5_mql5_folder = $Mt5Mql5Folder
    expert_sha256 = $SourceHash
}
$Metadata | ConvertTo-Json | Set-Content (Join-Path $DeployMetaFolder "last-deploy.json") -Encoding UTF8

Write-Host ""
Write-Host "Deployment completed and verified." -ForegroundColor Green
Write-Host "EA version: $Version"
Write-Host "EA target:  $ExpertTarget"
Write-Host "SHA256:     $SourceHash"
Write-Host ""
Write-Host "Next: open MetaEditor, refresh Navigator, open Experts\SmartGoldDCAPro.mq5, and press F7."
