# Development workflow

`main` must always contain a version that compiles with zero errors.

Create one branch per change:

```powershell
git checkout -b feature/adaptive-grid
```

Before merging:

1. Deploy to MT5.
2. Compile in MetaEditor.
3. Run the relevant smoke test/backtest.
4. Commit source and documentation.
5. Merge only after validation.

Suggested commit format:

```text
feat(dca): add ATR adaptive grid
fix(execution): handle rejected close request
docs(test): add adaptive-grid A/B checklist
```
