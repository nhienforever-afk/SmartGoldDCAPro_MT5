#property copyright "Copyright 2026 NhienForever"
#property version   "1.32"
#property strict
#property description "SmartGoldDCAPro - Smart/Manual DCA and configurable safety"

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
CMarketAnalyzer     g_marketAnalyzer;
CAdaptiveGridEngine g_adaptiveGrid;
CSmartLotCalculator g_smartLot;
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
   datetime barTime =
      iTime(_Symbol, InpSignalTimeframe, 0);

   if(barTime <= 0 ||
      barTime == g_lastSignalBar)
      return false;

   g_lastSignalBar = barTime;
   return true;
}

bool CooldownFinished()
{
   if(g_lastTradeTime <= 0)
      return true;

   return TimeCurrent() - g_lastTradeTime >=
          InpTradeCooldownSeconds;
}

bool EnvironmentAllowed()
{
   if(!g_session.IsAllowed())
      return false;

   if(g_dailyRisk.IsBlocked())
      return false;

   return true;
}

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
      g_dca.LastSmartSafetyActive()
   );
}

bool TryDCA()
{
   if(!InpEnableDCA || !CooldownFinished())
      return false;

   string reason;
   ENUM_POSITION_TYPE direction;
   double nextLot = 0.0;

   if(!g_dca.ShouldAddPosition(
         direction,
         nextLot,
         reason))
      return false;

   if(!g_risk.CanOpenTrade(
         nextLot,
         InpMaximumSpreadPoints,
         reason))
   {
      g_log.Warn("DCA blocked: " + reason);
      return false;
   }

   bool opened = false;

   if(direction == POSITION_TYPE_BUY)
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

   if(opened)
   {
      g_lastTradeTime = TimeCurrent();

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
   }

   return opened;
}

int OnInit()
{
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

      return INIT_PARAMETERS_INCORRECT;
   }

   if(!IsAllowedGoldSymbol())
   {
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

   g_session.Initialize(
      InpEnableSessionFilter,
      InpSessionStartHour,
      InpSessionEndHour
   );

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

   g_entry.Initialize(
      g_risk,
      g_orders,
      g_positions,
      g_signalCoordinator,
      g_log
   );

   g_exit.Initialize(
      g_basket,
      g_positions
   );

   if(!g_marketAnalyzer.Initialize(
         _Symbol,
         InpSignalTimeframe,
         InpATRPeriod,
         InpHighVolatilityATRPoints))
   {
      g_log.Error(
         "Market analyzer initialization failed."
      );

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

   string mode =
      InpDCAControlMode == DCA_CONTROL_MANUAL
      ? "MANUAL"
      : "SMART";

   g_journal.Write(
      "EA_INIT",
      "Version=1.32, mode=" + mode
   );

   g_log.Info(
      "Version 1.32 initialized on " +
      _Symbol +
      ", DCA mode=" +
      mode
   );

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   g_signalEngine.Release();
   g_marketAnalyzer.Release();
   g_dashboard.Clear();

   g_journal.Write(
      "EA_STOP",
      "Reason=" + IntegerToString(reason)
   );

   g_log.Info(
      "Stopped. Reason=" +
      IntegerToString(reason)
   );
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
      return;
   }

   if(g_dailyRisk.IsBlocked())
   {
      g_state.SetState(TRADE_STATE_BLOCKED);
      RenderDashboard();
      return;
   }

   if(g_exit.Manage())
   {
      g_state.SetState(TRADE_STATE_EXIT);

      g_journal.Write(
         "BASKET_EXIT",
         "Profit target or stop reached"
      );

      RenderDashboard();
      return;
   }

   int positionCount =
      g_positions.CountAll();

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

            g_journal.Write(
               "INITIAL_ENTRY",
               "Opened"
            );
         }
      }
   }
   else
   {
      g_state.SetState(TRADE_STATE_DCA);

      if(EnvironmentAllowed())
         TryDCA();
   }

   RenderDashboard();
}
