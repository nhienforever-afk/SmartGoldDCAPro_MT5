# Sprint 2.1 — Adaptive Grid Design

## Objective

Replace the fixed DCA distance with a bounded ATR-based grid:

`gridPoints = clamp(ATR_points × multiplier, minimumGrid, maximumGrid)`

## Safety behavior

- Falls back to the original fixed distance when adaptive mode is disabled.
- Blocks new DCA orders when ATR reaches the configured high-volatility threshold.
- Keeps the maximum DCA-level limit.
- Uses a drawdown-aware lot multiplier that becomes more conservative at 5% and 10% equity drawdown.
- Does not change the initial entry signal logic.

## New modules

- `Market/MarketState.mqh`
- `Market/MarketAnalyzer.mqh`
- `DCA/AdaptiveGridEngine.mqh`
- `Risk/SmartLotCalculator.mqh`

## Acceptance criteria

- MetaEditor compile: 0 errors.
- Dashboard displays ATR and current adaptive grid.
- With adaptive grid disabled, DCA uses `InpDCADistancePoints`.
- Grid never falls below `InpMinimumGridPoints`.
- Grid never exceeds `InpMaximumGridPoints`.
- High-volatility protection blocks DCA without closing an existing basket.
