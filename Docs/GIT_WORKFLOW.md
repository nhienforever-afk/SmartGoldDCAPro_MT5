# Git workflow

## One-time setup

Open PowerShell in the repository root:

```powershell
git init
git branch -M main
git remote add origin https://github.com/nhienforever-afk/SmartGoldDCAPro_MT5.git
git add .
git commit -m "chore: establish SmartGoldDCAPro v1.30 baseline"
git push -u origin main
```

If the remote already exists, do not add it again.

## Daily work

Create a feature branch:

```powershell
.\Tools\Start-Feature.ps1 -Name "smart-lot"
```

Deploy and verify:

```powershell
.\Tools\Deploy-To-MT5.ps1 -Mt5Mql5Folder "C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5"

.\Tools\Verify-MT5-Deployment.ps1 -Mt5Mql5Folder "C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5"
```

Compile in MetaEditor, test, then commit:

```powershell
git add .
git commit -m "feat(risk): add smart lot engine"
git push -u origin feature/smart-lot
```
