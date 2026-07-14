# Changelog

## 1.10 — Foundation milestone

- Added structured logger.
- Added configuration validation.
- Added optional trading-session filter.
- Added daily loss protection.
- Integrated the new modules into the main EA.
- Kept the original EMA/RSI/ATR signal, DCA engine, basket exit, equity protection and dashboard.

## 1.20 — Trading Engine milestone

- Added EntryEngine.
- Added ExitEngine.
- Added TradeStateMachine.
- Added SignalCoordinator.
- Added CSV TradeJournal.
- Refactored the main EA into an orchestration layer.


## 1.30 — Sprint 2.1 Adaptive Grid

- Added centralized MarketAnalyzer.
- Added MarketState data structure.
- Added ATR-based AdaptiveGridEngine.
- Added bounded minimum and maximum grid distances.
- Added high-volatility DCA blocking.
- Added conservative SmartLotCalculator foundation.
- Added ATR and adaptive-grid values to the dashboard.
