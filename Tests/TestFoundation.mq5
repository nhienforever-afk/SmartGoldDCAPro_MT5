#property strict
#property version "1.00"

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/Logger.mqh>
#include <SmartGoldDCAPro/Core/TradeJournal.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>
#include <SmartGoldDCAPro/Core/ConfigValidator.mqh>

#include <SmartGoldDCAPro/Risk/DailyRiskManager.mqh>
#include <SmartGoldDCAPro/Risk/SmartLotCalculator.mqh>

#include <SmartGoldDCAPro/Filters/SessionFilter.mqh>

#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>
#include <SmartGoldDCAPro/Trade/BasketManager.mqh>
#include <SmartGoldDCAPro/Trade/TradeStateMachine.mqh>

//+------------------------------------------------------------------+
//| Foundation test objects                                          |
//+------------------------------------------------------------------+
CLogger             g_testLogger;
CTradeJournal       g_testJournal;
CRiskManager        g_testRisk;
CConfigValidator    g_testConfig;
CDailyRiskManager   g_testDailyRisk;
CSmartLotCalculator g_testSmartLot;
CSessionFilter      g_testSession;
CPositionManager    g_testPositions;
COrderManager       g_testOrders;
CBasketManager      g_testBasket;
CTradeStateMachine  g_testState;

//+------------------------------------------------------------------+
//| Print PASS or FAIL                                               |
//+------------------------------------------------------------------+
void PrintTestResult(
   const string testName,
   const bool passed
)
{
   Print(
      passed ? "[PASS] " : "[FAIL] ",
      testName
   );
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   int passed = 0;
   int total  = 8;

   // 1. Logger
   g_testLogger.Initialize(
      "FoundationTest",
      SGDP_LOG_INFO,
      true
   );

   g_testLogger.Info(
      "Foundation test started."
   );

   PrintTestResult(
      "Logger initialized",
      g_testLogger.IsEnabled()
   );

   if(g_testLogger.IsEnabled())
      passed++;

   // 2. Configuration
   string validationReason;

   bool configValid =
      g_testConfig.Validate(
         validationReason
      );

   Print(
      "Configuration: ",
      validationReason
   );

   PrintTestResult(
      "ConfigValidator",
      configValid
   );

   if(configValid)
      passed++;

   // 3. Risk Manager
   g_testRisk.Initialize(
      _Symbol,
      InpMaxEquityDrawdownPercent
   );

   g_testRisk.UpdatePeakEquity();

   bool riskReady =
      g_testRisk.Symbol() == _Symbol &&
      g_testRisk.PeakEquity() >= 0.0;

   PrintTestResult(
      "RiskManager initialized",
      riskReady
   );

   if(riskReady)
      passed++;

   // 4. Daily Risk Manager
   g_testDailyRisk.Initialize(
      InpMaxDailyLossMoney
   );

   bool dailyRiskReady =
      g_testDailyRisk.DayStartTime() > 0;

   PrintTestResult(
      "DailyRiskManager initialized",
      dailyRiskReady
   );

   if(dailyRiskReady)
      passed++;

   // 5. Session Filter
   g_testSession.Initialize(
      InpEnableSessionFilter,
      InpSessionStartHour,
      InpSessionEndHour
   );

   bool sessionReady =
      g_testSession.SessionName() != "";

   PrintTestResult(
      "SessionFilter initialized",
      sessionReady
   );

   if(sessionReady)
      passed++;

   // 6. Position and Order managers
   g_testPositions.Initialize(
      _Symbol,
      InpMagicNumber
   );

   g_testOrders.Initialize(
      g_testRisk,
      _Symbol,
      InpMagicNumber,
      InpSlippagePoints,
      InpTradeComment
   );

   bool tradeManagersReady =
      g_testPositions.Symbol() == _Symbol &&
      g_testOrders.IsInitialized();

   PrintTestResult(
      "PositionManager and OrderManager",
      tradeManagersReady
   );

   if(tradeManagersReady)
      passed++;

   // 7. Basket and Smart Lot
   g_testBasket.Initialize(
      g_testPositions,
      g_testOrders
   );

   g_testSmartLot.Initialize(
      g_testRisk
   );

   bool basketRiskReady =
      g_testBasket.IsInitialized() &&
      g_testSmartLot.IsInitialized();

   PrintTestResult(
      "BasketManager and SmartLotCalculator",
      basketRiskReady
   );

   if(basketRiskReady)
      passed++;

   // 8. State Machine
   g_testState.Initialize(
      TRADE_STATE_IDLE
   );

   bool stateReady =
      g_testState.IsIdle() &&
      g_testState.Name() == "IDLE";

   PrintTestResult(
      "TradeStateMachine",
      stateReady
   );

   if(stateReady)
      passed++;

   Print(
      "Foundation Test Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(passed != total)
      return INIT_FAILED;

   g_testLogger.Info(
      "Foundation test completed successfully."
   );

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| No trading logic is required                                     |
//+------------------------------------------------------------------+
void OnTick()
{
}