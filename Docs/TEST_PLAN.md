# Validation checklist

1. Compile with zero errors; inspect every warning.
2. Backtest with `Every tick based on real ticks` on the exact Exness XAU symbol.
3. Test fixed lot with DCA disabled first.
4. Enable DCA conservatively and verify maximum levels.
5. Confirm basket TP, basket SL, spread filter, cooldown and equity protection.
6. Forward-test on an Exness demo account for several weeks.
7. Never assume backtest profit guarantees future performance.
