# SmartGoldDCAPro v1.40 — Weighted Signal Builder

## New capabilities

- Optional ADX filter with +DI/-DI direction.
- Weighted EMA, RSI and ADX voting.
- Configurable minimum signal score.
- Configurable minimum advantage between BUY and SELL.
- Dashboard shows BUY Score, SELL Score, RSI and ADX.
- ATR remains a volatility gate and does not add directional score.

## Score example

With default weights:

- EMA = 40
- RSI = 25
- ADX = 35
- Total = 100

If EMA and ADX support BUY but RSI does not:

- BUY score = 75
- SELL score = 0
- A BUY signal is allowed when minimum score is 65 and advantage is at least 10.

## Strict mode

Set `InpUseWeightedSignal=false` to require every enabled directional indicator to agree.

## Recommended first test

Run A/B tests:

1. v1.32 EMA + RSI without ADX.
2. v1.40 weighted EMA + RSI + ADX.
3. Compare total trades, profit factor, drawdown and average trade duration.
