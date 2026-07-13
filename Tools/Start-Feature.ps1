param(
    [Parameter(Mandatory=$true)]
    [string]$Name
)

$Branch = "feature/" + ($Name.Trim().ToLower() -replace '[^a-z0-9\-]+','-')
git status --short
if ($LASTEXITCODE -ne 0) { throw "This folder is not a Git repository." }

$Dirty = git status --porcelain
if ($Dirty) { throw "Working tree is not clean. Commit or stash changes first." }

git checkout main
git pull
git checkout -b $Branch

Write-Host "Created branch: $Branch" -ForegroundColor Green
