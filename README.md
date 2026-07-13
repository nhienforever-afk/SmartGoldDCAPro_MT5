# SmartGoldDCAPro MT5 — Git Repository Baseline v1.30

> **Source of truth:** this Git repository. Never edit a separate copy inside MT5 and forget to sync it back.


A modular XAU/GOLD DCA Expert Advisor for MetaTrader 5.

Included: EMA/RSI/ATR signal filter, BUY/SELL mode, DCA distance and lot multiplier, basket TP/SL, spread filter, cooldown, magic-number isolation, peak-equity drawdown protection, dashboard, Exness demo preset, and a PowerShell deploy script.

## Status
This is a complete testable MVP, not a promise of profitability. It has not been compiled inside your local MetaEditor or validated against your exact Exness symbol specification. Compile, backtest and forward-test on demo before considering live use.

## Deploy
Run from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\Tools\Deploy-To-MT5.ps1 -Mt5Mql5Folder "C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5"
```

Then open MetaEditor, refresh Navigator, open `Experts\SmartGoldDCAPro.mq5`, and press F7.


## Foundation v1.10 additions

- Configuration validator
- Structured logger
- Optional session filter
- Daily loss protection

## Verified deployment workflow

Use `Tools/Deploy-To-MT5.ps1`, then run `Tools/Verify-MT5-Deployment.ps1`. The verifier compares the repository EA and the MT5 EA using SHA-256 and reports both version numbers. This prevents compiling an old copy by mistake.
