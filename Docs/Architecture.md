# SmartGoldDCAPro MT5 — Architecture

## 1. Overview

SmartGoldDCAPro is a modular MetaTrader 5 Expert Advisor designed for
XAUUSD trading, basket management, adaptive DCA, risk protection and
decision-based trade execution.

The project follows a layered architecture. Each layer has one primary
responsibility and communicates through stable public APIs.

The Trading Core architecture is frozen at version 1.0. New development
must use the existing modules and must not introduce new processing
layers unless required to fix a confirmed technical limitation.

---

## 2. Main Processing Flow

```text
MarketAnalyzer
      |
      v
SignalEngine
      |
      v
SignalCoordinator
      |
      v
DecisionEngine
      |
      v
EntryRequestBuilder
      |
      v
EntryEngine
      |
      v
OrderManager
      |
      v
PositionManager / BasketManager
      |
      v
DCAEngine
      |
      v
ExitEngine
      |
      v
Dashboard