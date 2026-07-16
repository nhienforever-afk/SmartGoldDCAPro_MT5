#property copyright "Copyright 2026 NhienForever"
#property version   "2.00"
#property strict
#property description "SmartGoldDCAPro Framework v2.0 - Integrated EA"

//==================================================================
// Core
//==================================================================

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/Logger.mqh>
#include <SmartGoldDCAPro/Core/TradeJournal.mqh>
#include <SmartGoldDCAPro/Core/ConfigValidator.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

//==================================================================
// Risk and Filters
//==================================================================

#include <SmartGoldDCAPro/Risk/DailyRiskManager.mqh>
#include <SmartGoldDCAPro/Risk/SmartLotCalculator.mqh>
#include <SmartGoldDCAPro/Filters/SessionFilter.mqh>

//==================================================================
// Market
//==================================================================

#include <SmartGoldDCAPro/Market/MarketState.mqh>
#include <SmartGoldDCAPro/Market/TrendAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MomentumAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/VolatilityAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MarketAnalyzer.mqh>

//==================================================================
// Signal
//==================================================================

#include <SmartGoldDCAPro/Signal/SignalSnapshot.mqh>
#include <SmartGoldDCAPro/Signal/SignalEngine.mqh>
#include <SmartGoldDCAPro/Signal/SignalCoordinator.mqh>

//==================================================================
// Decision
//==================================================================

#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>
#include <SmartGoldDCAPro/Decision/DecisionScore.mqh>
#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>
#include <SmartGoldDCAPro/Analytics/MarketMemory.mqh>
#include <SmartGoldDCAPro/Decision/DecisionEngine.mqh>

//==================================================================
// Trade
//==================================================================

#include <SmartGoldDCAPro/Trade/TradeStateMachine.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>
#include <SmartGoldDCAPro/Trade/BasketManager.mqh>

#include <SmartGoldDCAPro/Trade/EntryRequest.mqh>
#include <SmartGoldDCAPro/Trade/EntryRequestBuilder.mqh>
#include <SmartGoldDCAPro/Trade/EntryEngine.mqh>

#include <SmartGoldDCAPro/Trade/ExitRequest.mqh>
#include <SmartGoldDCAPro/Trade/ExitEngine.mqh>

//==================================================================
// DCA
//==================================================================

#include <SmartGoldDCAPro/DCA/AdaptiveGridEngine.mqh>
#include <SmartGoldDCAPro/DCA/DCAEngine.mqh>

//==================================================================
// Dashboard
//==================================================================

#include <SmartGoldDCAPro/Dashboard/DashboardData.mqh>
#include <SmartGoldDCAPro/Dashboard/DashboardRenderer.mqh>
#include <SmartGoldDCAPro/Dashboard/DashboardController.mqh>

//==================================================================
// Global framework objects
//==================================================================

CLogger             g_log;
CTradeJournal       g_journal;
CConfigValidator    g_config;

CRiskManager        g_risk;
CDailyRiskManager   g_dailyRisk;
CSmartLotCalculator g_smartLot;
CSessionFilter      g_session;

CTradeStateMachine  g_state;
CPositionManager    g_positions;
COrderManager       g_orders;
CBasketManager      g_basket;

CMarketAnalyzer     g_marketAnalyzer;

CSignalEngine       g_signalEngine;
CSignalCoordinator  g_signalCoordinator;

CDecisionEngine     g_decision;

CEntryRequestBuilder g_entryBuilder;
CEntryEngine         g_entry;

CAdaptiveGridEngine g_adaptiveGrid;
CDCAEngine          g_dca;

CExitEngine         g_exit;

CDashboardRenderer   g_dashboardRenderer;
CDashboardController g_dashboardController;

//==================================================================
// Runtime state
//==================================================================

datetime g_lastSignalBar =
   0;

datetime g_lastDCATime =
   0;

bool g_ready =
   false;

//+------------------------------------------------------------------+
//| Validate chart symbol                                            |
//+------------------------------------------------------------------+
bool IsAllowedGoldSymbol()
{
   if(!InpRequireGoldSymbol)
      return true;

   return
      StringFind(
         _Symbol,
         "XAU"
      ) >= 0 ||
      StringFind(
         _Symbol,
         "GOLD"
      ) >= 0;
}

//+------------------------------------------------------------------+
//| Detect a new bar on the configured signal timeframe              |
//+------------------------------------------------------------------+
bool IsNewSignalBar()
{
   datetime currentBar =
      iTime(
         _Symbol,
         InpSignalTimeframe,
         0
      );

   if(currentBar <= 0)
      return false;

   if(currentBar ==
      g_lastSignalBar)
   {
      return false;
   }

   g_lastSignalBar =
      currentBar;

   return true;
}

//+------------------------------------------------------------------+
//| Check DCA cooldown                                               |
//+------------------------------------------------------------------+
bool DCACooldownFinished()
{
   if(InpTradeCooldownSeconds <= 0)
      return true;

   if(g_lastDCATime <= 0)
      return true;

   return
      (
         TimeCurrent() -
         g_lastDCATime
      ) >=
      InpTradeCooldownSeconds;
}

//+------------------------------------------------------------------+
//| Check whether normal trading operations are permitted            |
//+------------------------------------------------------------------+
bool EnvironmentAllowed(
   string &reason
)
{
   reason =
      "";

   if(!g_session.IsAllowed())
   {
      reason =
         "Trading session is closed.";

      return false;
   }

   if(g_dailyRisk.IsBlocked())
   {
      reason =
         g_dailyRisk.LastReason();

      return false;
   }

   if(g_risk.IsEquityProtectionTriggered())
   {
      reason =
         g_risk.LastReason();

      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Update the read-only Dashboard                                   |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   if(!g_dashboardController.IsInitialized())
      return;

   if(!g_dashboardController.Update())
   {
      g_log.Warn(
         "Dashboard update failed: " +
         g_dashboardController.LastReason()
      );
   }
}

//+------------------------------------------------------------------+
//| Evaluate and submit a DCA order                                  |
//+------------------------------------------------------------------+
bool TryDCA()
{
   if(!InpEnableDCA)
      return false;

   if(!DCACooldownFinished())
      return false;

   ENUM_POSITION_TYPE direction =
      POSITION_TYPE_BUY;

   double nextLot =
      0.0;

   string reason =
      "";

   if(!g_dca.ShouldAddPosition(
         direction,
         nextLot,
         reason
      ))
   {
      return false;
   }

   if(!g_risk.CanOpenTrade(
         nextLot,
         InpMaximumSpreadPoints,
         reason
      ))
   {
      g_log.Warn(
         "DCA blocked: " +
         reason
      );

      return false;
   }

   bool opened =
      false;

   if(direction ==
      POSITION_TYPE_BUY)
   {
      opened =
         g_orders.OpenBuy(
            nextLot,
            0.0,
            0.0,
            "DCA BUY"
         );
   }
   else if(direction ==
           POSITION_TYPE_SELL)
   {
      opened =
         g_orders.OpenSell(
            nextLot,
            0.0,
            0.0,
            "DCA SELL"
         );
   }

   if(!opened)
   {
      g_log.Error(
         "DCA order failed: " +
         g_orders.LastMessage()
      );

      return false;
   }

   g_lastDCATime =
      TimeCurrent();

   g_journal.Write(
      "DCA_OPEN",
      "Direction=" +
      SGDPPositionTypeName(
         direction
      ) +
      ", order=" +
      IntegerToString(
         g_dca.LastNextOrderNumber()
      ) +
      ", lot=" +
      DoubleToString(
         nextLot,
         2
      ) +
      ", grid=" +
      DoubleToString(
         g_dca.LastGridPoints(),
         1
      ) +
      ", safety=" +
      (
         g_dca.LastSmartSafetyActive()
         ? "ON"
         : "OFF"
      )
   );

   return true;
}

//+------------------------------------------------------------------+
//| Initialize SmartGoldDCAPro                                       |
//+------------------------------------------------------------------+
int OnInit()
{
   g_ready =
      false;

   //==============================================================
   // Logger and Journal
   //==============================================================

   g_log.Initialize(
      "SmartGoldDCAPro",
      SGDP_LOG_INFO,
      true
   );

   g_journal.Initialize(
      InpEnableTradeJournal,
      InpTradeJournalFile
   );

   g_log.Info(
      "SmartGoldDCAPro Framework v2.0 initialization started."
   );

   //==============================================================
   // Configuration
   //==============================================================

   string validationReason =
      "";

   if(!g_config.Validate(
         validationReason
      ))
   {
      g_log.Error(
         "Invalid configuration: " +
         validationReason
      );

      return
         INIT_PARAMETERS_INCORRECT;
   }

   if(!IsAllowedGoldSymbol())
   {
      g_log.Error(
         "Attach SmartGoldDCAPro to an XAU or GOLD symbol."
      );

      return
         INIT_FAILED;
   }

   //==============================================================
   // Core risk and filters
   //==============================================================

   g_risk.Initialize(
      _Symbol,
      InpMaxEquityDrawdownPercent
   );

   g_dailyRisk.Initialize(
      InpMaxDailyLossMoney
   );

   g_smartLot.Initialize(
      g_risk
   );

   g_session.Initialize(
      InpEnableSessionFilter,
      InpSessionStartHour,
      InpSessionEndHour
   );

   //==============================================================
   // Trade foundation
   //==============================================================

   g_positions.Initialize(
      _Symbol,
      InpMagicNumber
   );

   g_orders.Initialize(
      g_risk,
      _Symbol,
      InpMagicNumber,
      InpSlippagePoints,
      InpTradeComment
   );

   g_basket.Initialize(
      g_positions,
      g_orders
   );

   //==============================================================
   // Market Layer
   //==============================================================

   if(!g_marketAnalyzer.Initialize(
         _Symbol,
         InpSignalTimeframe,
         InpFastEMAPeriod,
         InpSlowEMAPeriod,
         InpRSIPeriod,
         InpATRPeriod,
         InpMinimumATRPoints,
         InpHighVolatilityATRPoints,
         InpMaximumSpreadPoints
      ))
   {
      g_log.Error(
         "MarketAnalyzer initialization failed."
      );

      return
         INIT_FAILED;
   }

   //==============================================================
   // Signal Layer
   //==============================================================

   if(!g_signalEngine.Initialize(
         _Symbol,
         InpSignalTimeframe
      ))
   {
      g_log.Error(
         "SignalEngine initialization failed."
      );

      return
         INIT_FAILED;
   }

   g_signalCoordinator.Initialize(
      g_signalEngine,
      g_marketAnalyzer
   );

   if(!g_signalCoordinator.IsInitialized())
   {
      g_log.Error(
         "SignalCoordinator initialization failed."
      );

      return
         INIT_FAILED;
   }

   //==============================================================
   // Decision Layer
   //==============================================================

   if(!g_decision.Initialize(
         InpMinimumSignalScore,
         InpMinimumScoreAdvantage,
         InpTradeCooldownSeconds,
         5.0
      ))
   {
      g_log.Error(
         "DecisionEngine initialization failed."
      );

      return
         INIT_FAILED;
   }

   //==============================================================
   // Entry Layer
   //==============================================================

   g_entryBuilder.Initialize(
      g_risk
   );

   g_entry.Initialize(
      g_risk,
      g_orders,
      g_positions,
      g_entryBuilder,
      g_log
   );

   if(!g_entryBuilder.IsInitialized() ||
      !g_entry.IsInitialized())
   {
      g_log.Error(
         "Entry Layer initialization failed."
      );

      return
         INIT_FAILED;
   }

   //==============================================================
   // DCA Layer
   //==============================================================

   if(!g_adaptiveGrid.Initialize(
         InpMinimumGridPoints,
         InpMaximumGridPoints,
         InpGridATRMultiplier,
         1.50,
         0.85,
         1.10
      ))
   {
      g_log.Error(
         "AdaptiveGridEngine initialization failed: " +
         g_adaptiveGrid.LastReason()
      );

      return
         INIT_FAILED;
   }

   g_dca.Initialize(
      g_positions,
      g_risk,
      g_marketAnalyzer,
      g_adaptiveGrid,
      g_smartLot
   );

   if(!g_dca.IsInitialized())
   {
      g_log.Error(
         "DCAEngine initialization failed."
      );

      return
         INIT_FAILED;
   }

   //==============================================================
   // Exit Layer
   //==============================================================

   g_exit.Initialize(
      g_basket,
      g_positions,
      g_risk,
      g_dailyRisk,
      g_log
   );

   if(!g_exit.IsInitialized())
   {
      g_log.Error(
         "ExitEngine initialization failed."
      );

      return
         INIT_FAILED;
   }

   //==============================================================
   // Dashboard Layer
   //==============================================================

   if(!g_dashboardRenderer.Initialize())
   {
      g_log.Error(
         "DashboardRenderer initialization failed."
      );

      return
         INIT_FAILED;
   }

   g_dashboardController.Initialize(
      g_marketAnalyzer,
      g_signalCoordinator,
      g_decision,
      g_positions,
      g_dca,
      g_risk,
      g_dashboardRenderer
   );

   if(!g_dashboardController.IsInitialized())
   {
      g_log.Error(
         "DashboardController initialization failed."
      );

      return
         INIT_FAILED;
   }

   //==============================================================
   // Runtime state
   //==============================================================

   g_state.SetState(
      TRADE_STATE_IDLE
   );

   g_lastSignalBar =
      0;

   g_lastDCATime =
      0;

   g_ready =
      true;

   g_journal.Write(
      "EA_INIT",
      "Version=2.00, symbol=" +
      _Symbol +
      ", DCA mode=" +
      g_dca.ControlModeName()
   );

   g_log.Info(
      "SmartGoldDCAPro Framework v2.0 initialized successfully on " +
      _Symbol +
      "."
   );

   UpdateDashboard();

   return
      INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Release SmartGoldDCAPro resources                                |
//+------------------------------------------------------------------+
void OnDeinit(
   const int reason
)
{
   g_ready =
      false;

   g_dashboardController.Release();

   g_signalEngine.Release();
   g_marketAnalyzer.Release();

   g_journal.Write(
      "EA_STOP",
      "Reason=" +
      IntegerToString(
         reason
      )
   );

   g_log.Info(
      "SmartGoldDCAPro stopped. Reason=" +
      IntegerToString(
         reason
      )
   );
}

//+------------------------------------------------------------------+
//| Main EA processing                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!g_ready)
      return;

   //==============================================================
   // 1. Refresh risk state
   //==============================================================

   g_risk.UpdatePeakEquity();

   int positionCount =
      g_positions.CountAll();

   //==============================================================
   // 2. Exit management has the highest priority
   //==============================================================

   if(positionCount > 0)
   {
      if(g_exit.Manage())
      {
         g_state.SetState(
            TRADE_STATE_EXIT
         );

         g_journal.Write(
            "BASKET_EXIT",
            g_exit.LastReason()
         );

         UpdateDashboard();
         return;
      }
   }

   //==============================================================
   // 3. Block Entry and DCA when environment is unsafe
   //==============================================================

   string environmentReason =
      "";

   bool environmentAllowed =
      EnvironmentAllowed(
         environmentReason
      );

   if(!environmentAllowed)
   {
      g_state.SetState(
         TRADE_STATE_BLOCKED
      );

      UpdateDashboard();
      return;
   }

   // Refresh count in case Exit closed the basket.
   positionCount =
      g_positions.CountAll();

   //==============================================================
   // 4. Existing basket: evaluate DCA
   //==============================================================

   if(positionCount > 0)
   {
      g_state.SetState(
         TRADE_STATE_DCA
      );

      TryDCA();

      UpdateDashboard();
      return;
   }

   //==============================================================
   // 5. Empty basket: evaluate initial Entry on a new signal bar
   //==============================================================

   g_state.SetState(
      TRADE_STATE_IDLE
   );

   if(!IsNewSignalBar())
   {
      UpdateDashboard();
      return;
   }

   if(!g_decision.Evaluate(
         g_signalCoordinator
      ))
   {
      g_log.Warn(
         "Decision evaluation failed: " +
         g_decision.Reason()
      );

      UpdateDashboard();
      return;
   }

   SDecisionSnapshot decisionSnapshot =
      g_decision.Snapshot();

   if(!decisionSnapshot.HasTradeDecision())
   {
      UpdateDashboard();
      return;
   }

   g_state.SetState(
      TRADE_STATE_ENTRY
   );

   if(g_entry.TryOpenInitial(
         g_decision
      ))
   {
      g_journal.Write(
         "INITIAL_ENTRY",
         "Action=" +
         g_entry.LastActionName() +
         ", lot=" +
         DoubleToString(
            g_entry.LastLot(),
            2
         ) +
         ", reason=" +
         g_entry.LastReason()
      );
   }
   else
   {
      g_log.Warn(
         "Initial Entry was not executed: " +
         g_entry.LastReason()
      );
   }

   //==============================================================
   // 6. Update Dashboard
   //==============================================================

   UpdateDashboard();
}