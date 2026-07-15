#property strict
#property version "1.00"

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/Logger.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

#include <SmartGoldDCAPro/Risk/DailyRiskManager.mqh>

#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>
#include <SmartGoldDCAPro/Trade/BasketManager.mqh>
#include <SmartGoldDCAPro/Trade/ExitRequest.mqh>
#include <SmartGoldDCAPro/Trade/ExitEngine.mqh>

//+------------------------------------------------------------------+
//| Exit Foundation test objects                                     |
//+------------------------------------------------------------------+
CLogger           g_testLogger;
CRiskManager      g_testRisk;
CDailyRiskManager g_testDailyRisk;
CPositionManager  g_testPositions;
COrderManager     g_testOrders;
CBasketManager    g_testBasket;
CExitEngine       g_testExit;

//+------------------------------------------------------------------+
//| Print PASS or FAIL                                                |
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
//| Build a synthetic basket-close request                            |
//+------------------------------------------------------------------+
SExitRequest CreateSyntheticExitRequest(
   const ENUM_EXIT_REASON reasonCode,
   const bool urgent
)
{
   SExitRequest request;
   request.Reset();

   request.action =
      EXIT_ACTION_CLOSE_BASKET;

   request.reasonCode =
      reasonCode;

   request.positionTicket =
      0;

   request.basketProfit =
      -25.0;

   request.triggerValue =
      20.0;

   request.createdTime =
      TimeCurrent();

   request.reason =
      "Synthetic Exit Request for foundation test.";

   request.comment =
      SGDPExitReasonName(
         reasonCode
      );

   request.urgent =
      urgent;

   request.valid =
      true;

   return request;
}

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   Print(
      "========== EXIT FOUNDATION TEST START =========="
   );

   int passed = 0;
   int total  = 10;

   //==============================================================
   // TEST 1: Logger
   //==============================================================

   g_testLogger.Initialize(
      "ExitFoundationTest",
      SGDP_LOG_INFO,
      true
   );

   bool loggerReady =
      g_testLogger.IsEnabled();

   PrintTestResult(
      "Logger initialized",
      loggerReady
   );

   if(loggerReady)
      passed++;

   //==============================================================
   // TEST 2: Risk Manager
   //==============================================================

   g_testRisk.Initialize(
      _Symbol,
      InpMaxEquityDrawdownPercent
   );

   bool riskReady =
      g_testRisk.Symbol() == _Symbol;

   PrintTestResult(
      "RiskManager initialized",
      riskReady
   );

   if(riskReady)
      passed++;

   //==============================================================
   // TEST 3: Daily Risk Manager
   //==============================================================

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

   //==============================================================
   // TEST 4: Position and Order Managers
   //==============================================================

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
      "PositionManager and OrderManager initialized",
      tradeManagersReady
   );

   if(tradeManagersReady)
      passed++;

   //==============================================================
   // TEST 5: Basket Manager
   //==============================================================

   g_testBasket.Initialize(
      g_testPositions,
      g_testOrders
   );

   bool basketReady =
      g_testBasket.IsInitialized();

   PrintTestResult(
      "BasketManager initialized",
      basketReady
   );

   if(basketReady)
      passed++;

   //==============================================================
   // TEST 6: Exit Engine
   //==============================================================

   g_testExit.Initialize(
      g_testBasket,
      g_testPositions,
      g_testRisk,
      g_testDailyRisk,
      g_testLogger
   );

   bool exitReady =
      g_testExit.IsInitialized();

   PrintTestResult(
      "ExitEngine initialized",
      exitReady
   );

   if(exitReady)
      passed++;

   int positionsBefore =
      g_testPositions.CountAll();

   //==============================================================
   // TEST 7: No basket must be rejected safely
   //==============================================================

   SExitRequest evaluatedRequest;

   bool exitRequired =
      g_testExit.Evaluate(
         evaluatedRequest
      );

   bool noBasketRejected =
      !exitRequired &&
      !evaluatedRequest.IsValid() &&
      g_testExit.LastReason() ==
         "No active basket.";

   PrintTestResult(
      "No active basket rejected safely",
      noBasketRejected
   );

   if(noBasketRejected)
      passed++;

   //==============================================================
   // TEST 8: Synthetic basket-close request validation
   //==============================================================

   SExitRequest syntheticRequest =
      CreateSyntheticExitRequest(
         EXIT_REASON_BASKET_STOP_LOSS,
         true
      );

   bool syntheticValid =
      syntheticRequest.IsValid() &&
      syntheticRequest.IsBasketClose() &&
      syntheticRequest.IsEmergency() &&
      syntheticRequest.ActionName() ==
         "CLOSE_BASKET" &&
      syntheticRequest.ReasonName() ==
         "BASKET_STOP_LOSS";

   PrintTestResult(
      "Synthetic basket-close request is valid",
      syntheticValid
   );

   if(syntheticValid)
      passed++;

   //==============================================================
   // TEST 9: Empty request must be invalid
   //==============================================================

   SExitRequest emptyRequest;
   emptyRequest.Reset();

   bool emptyRejected =
      !emptyRequest.IsValid() &&
      !emptyRequest.IsBasketClose() &&
      !emptyRequest.IsPositionClose() &&
      !emptyRequest.IsEmergency();

   PrintTestResult(
      "Empty Exit Request rejected safely",
      emptyRejected
   );

   if(emptyRejected)
      passed++;

   //==============================================================
   // TEST 10: No position was closed or created
   //==============================================================

   int positionsAfter =
      g_testPositions.CountAll();

   bool accountUnchanged =
      positionsAfter ==
      positionsBefore;

   PrintTestResult(
      "Exit test did not change positions",
      accountUnchanged
   );

   if(accountUnchanged)
      passed++;

   //==============================================================
   // PRINT DETAILS
   //==============================================================

   Print(
      "Exit Foundation | ",
      "NoBasketReason=",
      g_testExit.LastReason(),
      " | SyntheticAction=",
      syntheticRequest.ActionName(),
      " | SyntheticReason=",
      syntheticRequest.ReasonName(),
      " | Emergency=",
      syntheticRequest.IsEmergency()
         ? "true"
         : "false"
   );

   Print(
      "Positions before=",
      positionsBefore,
      ", positions after=",
      positionsAfter
   );

   Print(
      "Exit Foundation Test Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(passed != total)
   {
      Print(
         "========== EXIT FOUNDATION TEST FAILED =========="
      );

      return INIT_FAILED;
   }

   Print(
      "========== EXIT FOUNDATION TEST PASSED =========="
   );

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| No trading actions                                                |
//+------------------------------------------------------------------+
void OnTick()
{
}