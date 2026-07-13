# Sprint 2.1 Test Checklist

## Compile
- [ ] Compile `Experts/SmartGoldDCAPro.mq5`.
- [ ] Confirm 0 errors.
- [ ] Review every warning.

## Smoke test
- [ ] Attach to an Exness demo XAU symbol.
- [ ] Confirm dashboard shows ATR and Adaptive Grid.
- [ ] Confirm AutoTrading can remain disabled for the visual smoke test.
- [ ] Confirm no initialization errors in Experts/Journal.

## Strategy Tester
Run two comparable tests:

### Test A — Fixed grid
- `InpUseAdaptiveGrid=false`
- Use the current fixed DCA distance.

### Test B — Adaptive grid
- `InpUseAdaptiveGrid=true`
- `InpGridATRMultiplier=1.50`
- `InpMinimumGridPoints=200`
- `InpMaximumGridPoints=1200`
- `InpBlockDCAInHighVolatility=true`

Compare:
- Net profit
- Maximum equity drawdown
- Profit factor
- Total trades
- Maximum simultaneous positions
- Largest losing basket
- Margin level
