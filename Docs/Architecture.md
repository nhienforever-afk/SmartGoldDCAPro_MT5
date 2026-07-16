# SmartGoldDCAPro MT5

> **Software Architecture Document (SAD)**  
> Version **1.0**  
> Trading Core Frozen Architecture

---

# Table of Contents

1. Overview
2. Architecture Objectives
3. Design Principles
4. High-Level Architecture
5. Processing Flow
6. Project Structure
7. Layer Responsibilities
8. Dependency Rules

---

# 1. Overview

## 1.1 Purpose

SmartGoldDCAPro is a modular Expert Advisor for MetaTrader 5 designed
primarily for XAUUSD trading using a basket-based Dollar Cost Averaging
(DCA) strategy.

Unlike a traditional EA where trading logic is concentrated inside
`OnTick()`, SmartGoldDCAPro separates every responsibility into an
independent module.

Each module owns exactly one responsibility.

This architecture provides:

- high maintainability
- predictable behaviour
- isolated testing
- easier debugging
- safer future development

---

## 1.2 Project Goals

The primary goals of SmartGoldDCAPro are:

- deterministic trade execution
- modular architecture
- complete separation of responsibilities
- reusable components
- regression-safe development
- long-term maintainability
- production-ready trading framework

---

## 1.3 Supported Platform

Current target platform:

| Item | Value |
|------|-------|
| Platform | MetaTrader 5 |
| Language | MQL5 |
| Broker | MT5 Compatible |
| Primary Symbol | XAUUSD |
| Trading Style | Basket DCA |
| Architecture | Layered Modular |

---

# 2. Architecture Objectives

The architecture was designed around the following objectives.

## O1 — Single Responsibility

Every class has one responsibility only.

Example:

| Class | Responsibility |
|-------|----------------|
| MarketAnalyzer | Build market snapshot |
| SignalEngine | Produce signal score |
| DecisionEngine | Decide BUY / SELL / WAIT |
| EntryEngine | Execute first order |
| DCAEngine | Decide additional orders |
| ExitEngine | Close basket |

---

## O2 — Loose Coupling

Modules communicate only through public APIs.

No module may access another module's private data.

---

## O3 — Testability

Every important module must be testable independently.

Current strategy:

```
One Module
      ↓
One Test Expert
      ↓
Regression PASS
```

---

## O4 — Predictability

The same input must always produce the same output.

Hidden state should be avoided whenever possible.

---

## O5 — Safety

When required information is unavailable:

- do not trade
- report diagnostic reason
- preserve account safety

Fail-safe behaviour always has higher priority than trade frequency.

---

# 3. Design Principles

The project follows several software engineering principles.

---

## Principle 1

### Separation of Concerns

Market analysis is not allowed to submit trades.

Decision logic is not allowed to execute orders.

Dashboard is not allowed to modify trading state.

---

## Principle 2

### Composition over Complexity

Large features are created by combining simple modules.

Example:

```
MarketAnalyzer

+

SignalEngine

+

DecisionEngine

↓

Trading Decision
```

---

## Principle 3

### Frozen Public APIs

After Trading Core v1.0

Public APIs should remain stable.

Whenever possible:

- extend behaviour
- avoid breaking interfaces

---

## Principle 4

### Regression First

Every logic modification must preserve existing behaviour.

Workflow:

```
Modify Module

↓

Compile

↓

Run Module Test

↓

PASS

↓

Commit
```

---

## Principle 5

### Readability

Readable code is preferred over shorter code.

Examples:

Good

```cpp
double basketProfit;
```

Avoid

```cpp
double bp;
```

---

# 4. High-Level Architecture

```
                 +-------------------+
                 |   Market Layer    |
                 +---------+---------+
                           |
                           v
                 +-------------------+
                 |   Signal Layer    |
                 +---------+---------+
                           |
                           v
                 +-------------------+
                 | Decision Layer    |
                 +---------+---------+
                           |
                           v
                 +-------------------+
                 |  Entry Layer      |
                 +---------+---------+
                           |
                           v
                 +-------------------+
                 | Position/Basket   |
                 +---------+---------+
                           |
                 +---------+---------+
                 |                   |
                 v                   v
        +---------------+   +---------------+
        |   DCA Layer   |   |  Exit Layer   |
        +-------+-------+   +-------+-------+
                |                   |
                +---------+---------+
                          |
                          v
                  +---------------+
                  |  Dashboard    |
                  +---------------+
```

---

# 5. Processing Flow

The final EA processes market data using the following pipeline.

```
MarketAnalyzer
      │
      ▼
SignalEngine
      │
      ▼
SignalCoordinator
      │
      ▼
DecisionEngine
      │
      ▼
EntryRequestBuilder
      │
      ▼
EntryEngine
      │
      ▼
OrderManager
      │
      ▼
PositionManager
      │
      ├───────────────┐
      ▼               ▼
DCAEngine        ExitEngine
      │               │
      └───────┬───────┘
              ▼
         Dashboard
```

The pipeline is strictly directional.

Lower layers never call higher layers.

---

# 6. Project Structure

```
SmartGoldDCAPro_MT5_vNext
│
├── Docs
│
├── Experts
│
├── Include
│   │
│   └── SmartGoldDCAPro
│       │
│       ├── Core
│       ├── Filters
│       ├── Risk
│       ├── Market
│       ├── Signal
│       ├── Decision
│       ├── Trade
│       ├── DCA
│       └── Dashboard
│
├── Presets
│
└── Tests
```

Folder responsibilities:

| Folder | Purpose |
|---------|---------|
| Docs | Documentation |
| Experts | Main EA and test Experts |
| Include | Framework source code |
| Presets | Configuration sets |
| Tests | Development tests |

---

# 7. Layer Responsibilities

| Layer | Responsibility |
|--------|----------------|
| Core | Shared infrastructure |
| Filters | Trading permission |
| Risk | Account protection |
| Market | Market analysis |
| Signal | Signal generation |
| Decision | Trading decision |
| Trade | Entry and execution |
| DCA | Basket expansion |
| Exit | Basket closing |
| Dashboard | Visualization |

Each layer owns only its designated responsibility.

---

# 8. Dependency Rules

The dependency direction is fixed.

```
Core

↓

Risk / Filters

↓

Market

↓

Signal

↓

Decision

↓

Trade

↓

DCA

↓

Exit

↓

Dashboard
```

Rules:

- Lower layers must not depend on higher layers.
- Dashboard is read-only.
- Decision never executes trades.
- Market never produces orders.
- DCA never evaluates market directly without MarketAnalyzer.
- Exit never generates signals.

---

**End of Part 1**