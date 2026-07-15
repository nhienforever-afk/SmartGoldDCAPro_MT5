#property strict
#property version "1.00"

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/Logger.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>
#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>

#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>
#include <SmartGoldDCAPro/Trade/EntryRequest.mqh>
#include <SmartGoldDCAPro/Trade/EntryRequestBuilder.mqh>
#include <SmartGoldDCAPro/Trade/EntryEngine.mqh>

//+------------------------------------------------------------------+
//| Entry Foundation test objects                                    |
//+------------------------------------------------------------------+
CLogger              g_testLogger;
CRiskManager         g_testRisk;
CPositionManager     g_testPositions;
COrderManager        g_testOrders;
CEntryRequestBuilder g_testBuilder;
CEntryEngine         g_testEntry;

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
//| Create an approved BUY Decision Snapshot                         |
//+------------------------------------------------------------------+
SDecisionSnapshot CreateBuySnapshot()
{
   SDecisionSnapshot snapshot;
   snapshot.Reset();

   snapshot.timestamp =
      TimeCurrent();

   snapshot.action =
      DECISION_BUY;

   snapshot.reasonCode =
      DECISION_REASON_BUY_SCORE_APPROVED;

   snapshot.buyScore =
      82.0;

   snapshot.sellScore =
      28.0;

   snapshot.scoreAdvantage =
      54.0;

   snapshot.confidence =
      88.0;

   snapshot.quality =
      84.0;

   snapshot.marketRegime =
      MARKET_REGIME_TREND_UP;

   snapshot.sourceSignal =
      SIGNAL_BUY;

   snapshot.valid =
      true;

   snapshot.reason =
      "Synthetic BUY decision for Entry Foundation test.";

   return snapshot;
}

//+------------------------------------------------------------------+
//| Create an approved SELL Decision Snapshot                        |
//+------------------------------------------------------------------+
SDecisionSnapshot CreateSellSnapshot()
{
   SDecisionSnapshot snapshot;
   snapshot.Reset();

   snapshot.timestamp =
      TimeCurrent();

   snapshot.action =
      DECISION_SELL;

   snapshot.reasonCode =
      DECISION_REASON_SELL_SCORE_APPROVED;

   snapshot.buyScore =
      25.0;

   snapshot.sellScore =
      81.0;

   snapshot.scoreAdvantage =
      56.0;

   snapshot.confidence =
      87.0;

   snapshot.quality =
      83.0;

   snapshot.marketRegime =
      MARKET_REGIME_TREND_DOWN;

   snapshot.sourceSignal =
      SIGNAL_SELL;

   snapshot.valid =
      true;

   snapshot.reason =
      "Synthetic SELL decision for Entry Foundation test.";

   return snapshot;
}

//+------------------------------------------------------------------+
//| Create a WAIT Decision Snapshot                                  |
//+------------------------------------------------------------------+
SDecisionSnapshot CreateWaitSnapshot()
{
   SDecisionSnapshot snapshot;
   snapshot.Reset();

   snapshot.timestamp =
      TimeCurrent();

   snapshot.action =
      DECISION_WAIT;

   snapshot.reasonCode =
      DECISION_REASON_SCORE_TOO_LOW;

   snapshot.buyScore =
      45.0;

   snapshot.sellScore =
      42.0;

   snapshot.scoreAdvantage =
      3.0;

   snapshot.confidence =
      35.0;

   snapshot.quality =
      40.0;

   snapshot.valid =
      true;

   snapshot.reason =
      "Synthetic WAIT decision for Entry Foundation test.";

   return snapshot;
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print(
      "========== ENTRY FOUNDATION TEST START =========="
   );

   int passed = 0;
   int total  = 9;

   //==============================================================
   // TEST 1: Logger
   //==============================================================

   g_testLogger.Initialize(
      "EntryFoundationTest",
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
   // TEST 3: Position and Order Managers
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
   // TEST 4: Entry Request Builder
   //==============================================================

   g_testBuilder.Initialize(
      g_testRisk
   );

   bool builderReady =
      g_testBuilder.IsInitialized();

   PrintTestResult(
      "EntryRequestBuilder initialized",
      builderReady
   );

   if(builderReady)
      passed++;

   //==============================================================
   // TEST 5: Entry Engine
   //==============================================================

   g_testEntry.Initialize(
      g_testRisk,
      g_testOrders,
      g_testPositions,
      g_testBuilder,
      g_testLogger
   );

   bool entryReady =
      g_testEntry.IsInitialized();

   PrintTestResult(
      "EntryEngine initialized",
      entryReady
   );

   if(entryReady)
      passed++;

   // Store position count before all logic tests.
   int positionsBefore =
      g_testPositions.CountAll();

   //==============================================================
   // TEST 6: Build BUY Entry Request
   //==============================================================

   SDecisionSnapshot buySnapshot =
      CreateBuySnapshot();

   SEntryRequest buyRequest;

   bool buyBuilt =
      g_testBuilder.BuildFromSnapshot(
         buySnapshot,
         InpInitialLot,
         0.0,
         0.0,
         "Entry Test BUY",
         buyRequest
      );

   bool buyRequestValid =
      buyBuilt &&
      buyRequest.IsValid() &&
      buyRequest.IsBuy() &&
      buyRequest.action == DECISION_BUY &&
      buyRequest.positionType == POSITION_TYPE_BUY &&
      buyRequest.lot > 0.0;

   PrintTestResult(
      "BUY Entry Request built and validated",
      buyRequestValid
   );

   if(buyRequestValid)
      passed++;

   //==============================================================
   // TEST 7: Build SELL Entry Request
   //==============================================================

   SDecisionSnapshot sellSnapshot =
      CreateSellSnapshot();

   SEntryRequest sellRequest;

   bool sellBuilt =
      g_testBuilder.BuildFromSnapshot(
         sellSnapshot,
         InpInitialLot,
         0.0,
         0.0,
         "Entry Test SELL",
         sellRequest
      );

   bool sellRequestValid =
      sellBuilt &&
      sellRequest.IsValid() &&
      sellRequest.IsSell() &&
      sellRequest.action == DECISION_SELL &&
      sellRequest.positionType == POSITION_TYPE_SELL &&
      sellRequest.lot > 0.0;

   PrintTestResult(
      "SELL Entry Request built and validated",
      sellRequestValid
   );

   if(sellRequestValid)
      passed++;

   //==============================================================
   // TEST 8: WAIT Decision must be rejected
   //==============================================================

   SDecisionSnapshot waitSnapshot =
      CreateWaitSnapshot();

   SEntryRequest waitRequest;

   bool waitBuilt =
      g_testBuilder.BuildFromSnapshot(
         waitSnapshot,
         InpInitialLot,
         0.0,
         0.0,
         "Entry Test WAIT",
         waitRequest
      );

   bool waitRejected =
      !waitBuilt &&
      !waitRequest.IsValid() &&
      g_testBuilder.LastReason() != "";

   PrintTestResult(
      "WAIT Decision rejected safely",
      waitRejected
   );

   if(waitRejected)
      passed++;

   //==============================================================
   // TEST 9: Invalid request must not be executable
   //==============================================================

   SEntryRequest invalidRequest;
   invalidRequest.Reset();

   string validationReason;

   bool invalidCanExecute =
      g_testEntry.CanExecute(
         invalidRequest,
         validationReason
      );

   int positionsAfter =
      g_testPositions.CountAll();

   bool invalidRejectedSafely =
      !invalidCanExecute &&
      validationReason != "" &&
      positionsAfter == positionsBefore;

   PrintTestResult(
      "Invalid Entry Request rejected without opening position",
      invalidRejectedSafely
   );

   if(invalidRejectedSafely)
      passed++;

   //==============================================================
   // PRINT DETAILS
   //==============================================================

   Print(
      "BUY Request | ",
      "Valid=",
      buyRequest.IsValid() ? "true" : "false",
      " | Action=",
      buyRequest.ActionName(),
      " | PositionType=",
      buyRequest.PositionTypeName(),
      " | Lot=",
      DoubleToString(
         buyRequest.lot,
         2
      ),
      " | Score=",
      DoubleToString(
         buyRequest.decisionScore,
         2
      ),
      " | Confidence=",
      DoubleToString(
         buyRequest.confidence,
         2
      ),
      " | Quality=",
      DoubleToString(
         buyRequest.quality,
         2
      )
   );

   Print(
      "SELL Request | ",
      "Valid=",
      sellRequest.IsValid() ? "true" : "false",
      " | Action=",
      sellRequest.ActionName(),
      " | PositionType=",
      sellRequest.PositionTypeName(),
      " | Lot=",
      DoubleToString(
         sellRequest.lot,
         2
      ),
      " | Score=",
      DoubleToString(
         sellRequest.decisionScore,
         2
      ),
      " | Confidence=",
      DoubleToString(
         sellRequest.confidence,
         2
      ),
      " | Quality=",
      DoubleToString(
         sellRequest.quality,
         2
      )
   );

   Print(
      "WAIT rejection reason: ",
      g_testBuilder.LastReason()
   );

   Print(
      "Invalid request rejection reason: ",
      validationReason
   );

   Print(
      "Positions before=",
      positionsBefore,
      ", positions after=",
      positionsAfter
   );

   Print(
      "Entry Foundation Test Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(passed != total)
   {
      Print(
         "========== ENTRY FOUNDATION TEST FAILED =========="
      );

      return INIT_FAILED;
   }

   Print(
      "========== ENTRY FOUNDATION TEST PASSED =========="
   );

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| No trading actions                                               |
//+------------------------------------------------------------------+
void OnTick()
{
}