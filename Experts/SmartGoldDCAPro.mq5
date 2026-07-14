#property copyright "Copyright 2026 NhienForever"
<<<<<<< HEAD
#property version   "1.40"
#property strict
#property description "SmartGoldDCAPro - Weighted Signal Builder"
=======
#property version   "1.30"
#property strict
#property description "SmartGoldDCAPro - Milestone 2 Trading Engine"
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/Logger.mqh>
#include <SmartGoldDCAPro/Core/TradeJournal.mqh>
#include <SmartGoldDCAPro/Core/ConfigValidator.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>
#include <SmartGoldDCAPro/Risk/DailyRiskManager.mqh>
#include <SmartGoldDCAPro/Filters/SessionFilter.mqh>
#include <SmartGoldDCAPro/Trade/TradeStateMachine.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>
#include <SmartGoldDCAPro/Trade/BasketManager.mqh>
#include <SmartGoldDCAPro/Trade/EntryEngine.mqh>
#include <SmartGoldDCAPro/Trade/ExitEngine.mqh>
#include <SmartGoldDCAPro/Signal/SignalEngine.mqh>
#include <SmartGoldDCAPro/Signal/SignalCoordinator.mqh>
#include <SmartGoldDCAPro/Market/MarketState.mqh>
#include <SmartGoldDCAPro/Market/MarketAnalyzer.mqh>
#include <SmartGoldDCAPro/Risk/SmartLotCalculator.mqh>
#include <SmartGoldDCAPro/DCA/AdaptiveGridEngine.mqh>
#include <SmartGoldDCAPro/DCA/DCAEngine.mqh>
#include <SmartGoldDCAPro/Dashboard/Dashboard.mqh>

CLogger             g_log;
CTradeJournal       g_journal;
CConfigValidator    g_config;
CRiskManager        g_risk;
CDailyRiskManager   g_dailyRisk;
CSessionFilter      g_session;
CTradeStateMachine  g_state;
CPositionManager    g_positions;
COrderManager       g_orders;
CBasketManager      g_basket;
CSignalEngine       g_signalEngine;
CSignalCoordinator  g_signalCoordinator;
<<<<<<< HEAD
CMarketAnalyzer     g_marketAnalyzer;
CAdaptiveGridEngine g_adaptiveGrid;
CSmartLotCalculator g_smartLot;
=======
CMarketAnalyzer      g_marketAnalyzer;
CAdaptiveGridEngine  g_adaptiveGrid;
CSmartLotCalculator  g_smartLot;
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
CEntryEngine        g_entry;
CExitEngine         g_exit;
CDCAEngine          g_dca;
CDashboard          g_dashboard;

datetime g_lastSignalBar = 0;
datetime g_lastTradeTime = 0;
bool     g_ready         = false;

bool IsAllowedGoldSymbol()
{
   if(!InpRequireGoldSymbol)
      return true;

   return StringFind(_Symbol, "XAU") >= 0 ||
          StringFind(_Symbol, "GOLD") >= 0;
}

bool IsNewSignalBar()
{
<<<<<<< HEAD
   datetime barTime =
      iTime(_Symbol, InpSignalTimeframe, 0);

   if(barTime <= 0 ||
      barTime == g_lastSignalBar)
=======
   datetime barTime = iTime(_Symbol, InpSignalTimeframe, 0);

   if(barTime <= 0 || barTime == g_lastSignalBar)
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      return false;

   g_lastSignalBar = barTime;
   return true;
}

bool CooldownFinished()
{
   if(g_lastTradeTime <= 0)
      return true;

<<<<<<< HEAD
   return TimeCurrent() - g_lastTradeTime >=
          InpTradeCooldownSeconds;
=======
   return TimeCurrent() - g_lastTradeTime >= InpTradeCooldownSeconds;
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
}

bool EnvironmentAllowed()
{
   if(!g_session.IsAllowed())
      return false;

   if(g_dailyRisk.IsBlocked())
      return false;

   return true;
}

<<<<<<< HEAD
void RenderDashboard()
{
   g_dashboard.Render(
      g_positions,
      g_risk,
      g_state.Name(),
      g_dca.LastATRPoints(),
      g_dca.LastGridPoints(),
      g_dca.LastNextLot(),
      g_dca.LastMarginLevel(),
      g_dca.LastFreeMargin(),
      g_dca.LastRiskScore(),
      g_dca.ControlModeName(),
      g_dca.LastNextOrderNumber(),
      g_dca.LastSmartSafetyActive(),
      g_signalEngine.LastBuyScore(),
      g_signalEngine.LastSellScore(),
      g_signalEngine.LastADX(),
      g_signalEngine.LastRSI()
   );
}

=======
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
bool TryDCA()
{
   if(!InpEnableDCA || !CooldownFinished())
      return false;

   string reason;
   ENUM_POSITION_TYPE direction;
   double nextLot = 0.0;

<<<<<<< HEAD
   if(!g_dca.ShouldAddPosition(
         direction,
         nextLot,
         reason))
      return false;

   if(!g_risk.CanOpenTrade(
         nextLot,
         InpMaximumSpreadPoints,
         reason))
=======
   if(!g_dca.ShouldAddPosition(direction, nextLot, reason))
      return false;

   if(!g_risk.CanOpenTrade(nextLot, InpMaximumSpreadPoints, reason))
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
   {
      g_log.Warn("DCA blocked: " + reason);
      return false;
   }

   bool opened = false;

   if(direction == POSITION_TYPE_BUY)
<<<<<<< HEAD
   {
      opened = g_orders.OpenBuy(
         nextLot,
         0.0,
         0.0,
         "DCA BUY"
      );
   }
   else if(direction == POSITION_TYPE_SELL)
   {
      opened = g_orders.OpenSell(
         nextLot,
         0.0,
         0.0,
         "DCA SELL"
      );
   }
=======
      opened = g_orders.OpenBuy(nextLot, 0.0, 0.0, "DCA BUY");
   else if(direction == POSITION_TYPE_SELL)
      opened = g_orders.OpenSell(nextLot, 0.0, 0.0, "DCA SELL");
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

   if(opened)
   {
      g_lastTradeTime = TimeCurrent();
<<<<<<< HEAD

      g_journal.Write(
         "DCA_OPEN",
         "Mode=" + g_dca.ControlModeName() +
         ", order=" +
         IntegerToString(g_dca.LastNextOrderNumber()) +
         ", lot=" +
         DoubleToString(nextLot, 2) +
         ", safety=" +
         (g_dca.LastSmartSafetyActive() ? "ON" : "OFF")
      );
=======
      g_journal.Write("DCA_OPEN", "Lot=" + DoubleToString(nextLot, 2));
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
   }

   return opened;
}

int OnInit()
{
<<<<<<< HEAD
   g_log.Initialize(
      "SmartGoldDCAPro",
      LOG_INFO
   );

   g_journal.Initialize(
      InpEnableTradeJournal,
      InpTradeJournalFile
   );

   string validationReason;

   if(!g_config.Validate(validationReason))
   {
      g_log.Error(
         "Invalid configuration: " +
         validationReason
      );

=======
   g_log.Initialize("SmartGoldDCAPro", LOG_INFO);
   g_journal.Initialize(InpEnableTradeJournal, InpTradeJournalFile);

   string validationReason;
   if(!g_config.Validate(validationReason))
   {
      g_log.Error("Invalid configuration: " + validationReason);
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      return INIT_PARAMETERS_INCORRECT;
   }

   if(!IsAllowedGoldSymbol())
   {
<<<<<<< HEAD
      g_log.Error(
         "Attach the EA to an XAU/GOLD symbol."
      );

      return INIT_FAILED;
   }

   g_risk.Initialize(
      _Symbol,
      InpMaxEquityDrawdownPercent
   );

   g_dailyRisk.Initialize(
      InpMaxDailyLossMoney
   );

=======
      g_log.Error("Attach the EA to an XAU/GOLD symbol.");
      return INIT_FAILED;
   }

   g_risk.Initialize(_Symbol, InpMaxEquityDrawdownPercent);
   g_dailyRisk.Initialize(InpMaxDailyLossMoney);
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
   g_session.Initialize(
      InpEnableSessionFilter,
      InpSessionStartHour,
      InpSessionEndHour
   );

<<<<<<< HEAD
   g_positions.Initialize(
      _Symbol,
      InpMagicNumber
   );
=======
   g_positions.Initialize(_Symbol, InpMagicNumber);
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

   g_orders.Initialize(
      g_risk,
      _Symbol,
      InpMagicNumber,
      InpSlippagePoints,
      InpTradeComment
   );

<<<<<<< HEAD
   g_basket.Initialize(
      g_positions,
      g_orders
   );

   if(!g_signalEngine.Initialize(
         _Symbol,
         InpSignalTimeframe))
   {
      g_log.Error(
         "Signal engine initialization failed."
      );

      return INIT_FAILED;
   }

   g_signalCoordinator.Initialize(
      g_signalEngine
   );

=======
   g_basket.Initialize(g_positions, g_orders);

   if(!g_signalEngine.Initialize(_Symbol, InpSignalTimeframe))
   {
      g_log.Error("Signal engine initialization failed.");
      return INIT_FAILED;
   }

   g_signalCoordinator.Initialize(g_signalEngine);
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
   g_entry.Initialize(
      g_risk,
      g_orders,
      g_positions,
      g_signalCoordinator,
      g_log
   );

<<<<<<< HEAD
   g_exit.Initialize(
      g_basket,
      g_positions
   );
=======
   g_exit.Initialize(g_basket, g_positions);
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

   if(!g_marketAnalyzer.Initialize(
         _Symbol,
         InpSignalTimeframe,
         InpATRPeriod,
         InpHighVolatilityATRPoints))
   {
<<<<<<< HEAD
      g_log.Error(
         "Market analyzer initialization failed."
      );

=======
      g_log.Error("Market analyzer initialization failed.");
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      return INIT_FAILED;
   }

   g_adaptiveGrid.Initialize(
      InpUseAdaptiveGrid,
      InpDCADistancePoints,
      InpGridATRMultiplier,
      InpMinimumGridPoints,
      InpMaximumGridPoints
   );

   g_smartLot.Initialize(g_risk);

   g_dca.Initialize(
      g_positions,
      g_risk,
      g_marketAnalyzer,
      g_adaptiveGrid,
      g_smartLot
   );

   g_state.SetState(TRADE_STATE_IDLE);
   g_ready = true;

<<<<<<< HEAD
   string mode =
      InpDCAControlMode == DCA_CONTROL_MANUAL
      ? "MANUAL"
      : "SMART";

   g_journal.Write(
      "EA_INIT",
      "Version=1.40, mode=" + mode
   );

   g_log.Info(
      "Version 1.40 initialized on " +
      _Symbol +
      ", DCA mode=" +
      mode
   );
=======
   g_journal.Write("EA_INIT", "Version=1.30");
   g_log.Info("Version 1.30 initialized on " + _Symbol);
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   g_signalEngine.Release();
   g_marketAnalyzer.Release();
   g_dashboard.Clear();
<<<<<<< HEAD

   g_journal.Write(
      "EA_STOP",
      "Reason=" + IntegerToString(reason)
   );

   g_log.Info(
      "Stopped. Reason=" +
      IntegerToString(reason)
   );
=======
   g_journal.Write("EA_STOP", "Reason=" + IntegerToString(reason));
   g_log.Info("Stopped. Reason=" + IntegerToString(reason));
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
}

void OnTick()
{
   if(!g_ready)
      return;

   g_risk.UpdatePeakEquity();

   if(g_risk.IsEquityProtectionTriggered())
   {
      g_state.SetState(TRADE_STATE_BLOCKED);

      if(InpCloseBasketOnEquityProtection)
      {
         g_state.SetState(TRADE_STATE_EXIT);

<<<<<<< HEAD
         if(g_exit.EmergencyClose(
               "Equity protection"))
         {
            g_journal.Write(
               "EMERGENCY_EXIT",
               "Equity protection"
            );
         }
      }

      RenderDashboard();
=======
         if(g_exit.EmergencyClose("Equity protection"))
            g_journal.Write("EMERGENCY_EXIT", "Equity protection");
      }

      g_dashboard.Render(g_positions, g_risk, g_state.Name(), g_dca.LastATRPoints(), g_dca.LastGridPoints());
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      return;
   }

   if(g_dailyRisk.IsBlocked())
   {
      g_state.SetState(TRADE_STATE_BLOCKED);
<<<<<<< HEAD
      RenderDashboard();
=======
      g_dashboard.Render(g_positions, g_risk, g_state.Name(), g_dca.LastATRPoints(), g_dca.LastGridPoints());
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      return;
   }

   if(g_exit.Manage())
   {
      g_state.SetState(TRADE_STATE_EXIT);
<<<<<<< HEAD

      g_journal.Write(
         "BASKET_EXIT",
         "Profit target or stop reached"
      );

      RenderDashboard();
      return;
   }

   int positionCount =
      g_positions.CountAll();
=======
      g_journal.Write("BASKET_EXIT", "Profit target or stop reached");
      g_dashboard.Render(g_positions, g_risk, g_state.Name(), g_dca.LastATRPoints(), g_dca.LastGridPoints());
      return;
   }

   int positionCount = g_positions.CountAll();
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

   if(positionCount <= 0)
   {
      g_state.SetState(TRADE_STATE_IDLE);

      if(EnvironmentAllowed() &&
         IsNewSignalBar() &&
         CooldownFinished())
      {
         g_state.SetState(TRADE_STATE_ENTRY);

         if(g_entry.TryOpenInitial())
         {
            g_lastTradeTime = TimeCurrent();
<<<<<<< HEAD

            g_journal.Write(
               "INITIAL_ENTRY",
               "BUY score=" +
               DoubleToString(
                  g_signalEngine.LastBuyScore(),
                  1
               ) +
               ", SELL score=" +
               DoubleToString(
                  g_signalEngine.LastSellScore(),
                  1
               )
            );
=======
            g_journal.Write("INITIAL_ENTRY", "Opened");
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
         }
      }
   }
   else
   {
      g_state.SetState(TRADE_STATE_DCA);

      if(EnvironmentAllowed())
         TryDCA();
   }

<<<<<<< HEAD
   RenderDashboard();
=======
   g_dashboard.Render(g_positions, g_risk, g_state.Name(), g_dca.LastATRPoints(), g_dca.LastGridPoints());
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
}
