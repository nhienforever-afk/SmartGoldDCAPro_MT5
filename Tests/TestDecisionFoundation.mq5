#property strict
#property version "1.10"

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>

#include <SmartGoldDCAPro/Market/MarketState.mqh>
#include <SmartGoldDCAPro/Market/TrendAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MomentumAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/VolatilityAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MarketAnalyzer.mqh>

#include <SmartGoldDCAPro/Signal/SignalSnapshot.mqh>
#include <SmartGoldDCAPro/Signal/SignalEngine.mqh>
#include <SmartGoldDCAPro/Signal/SignalCoordinator.mqh>

#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>
#include <SmartGoldDCAPro/Decision/DecisionScore.mqh>
#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>
#include <SmartGoldDCAPro/Analytics/MarketMemory.mqh>
#include <SmartGoldDCAPro/Decision/DecisionEngine.mqh>

//+------------------------------------------------------------------+
//| Test objects                                                     |
//+------------------------------------------------------------------+
CSignalEngine      g_testSignal;
CMarketAnalyzer    g_testMarket;
CSignalCoordinator g_testCoordinator;
CDecisionEngine    g_testDecision;

bool g_initializationPassed = false;
bool g_testCompleted        = false;

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
//| Validate score range                                             |
//+------------------------------------------------------------------+
bool IsValidScore(
   const double value
)
{
   return
      value >= 0.0 &&
      value <= 100.0;
}

//+------------------------------------------------------------------+
//| Validate Decision action                                         |
//+------------------------------------------------------------------+
bool IsValidDecisionAction(
   const ENUM_DECISION_ACTION action
)
{
   return
      action == DECISION_BUY ||
      action == DECISION_SELL ||
      action == DECISION_WAIT ||
      action == DECISION_BLOCK;
}

//+------------------------------------------------------------------+
//| Initialize modules only                                          |
//+------------------------------------------------------------------+
int OnInit()
{
   Print(
      "========== DECISION FOUNDATION TEST START =========="
   );

   int passed = 0;
   int total  = 4;

   bool signalReady =
      g_testSignal.Initialize(
         _Symbol,
         InpSignalTimeframe
      );

   PrintTestResult(
      "SignalEngine initialized",
      signalReady
   );

   if(signalReady)
      passed++;

   bool marketReady =
      g_testMarket.Initialize(
         _Symbol,
         InpSignalTimeframe,
         InpFastEMAPeriod,
         InpSlowEMAPeriod,
         InpRSIPeriod,
         InpATRPeriod,
         InpMinimumATRPoints,
         InpHighVolatilityATRPoints,
         InpMaximumSpreadPoints
      );

   PrintTestResult(
      "MarketAnalyzer initialized",
      marketReady
   );

   if(marketReady)
      passed++;

   g_testCoordinator.Initialize(
      g_testSignal,
      g_testMarket
   );

   bool coordinatorReady =
      g_testCoordinator.IsInitialized();

   PrintTestResult(
      "SignalCoordinator initialized",
      coordinatorReady
   );

   if(coordinatorReady)
      passed++;

   bool decisionReady =
      g_testDecision.Initialize(
         InpMinimumSignalScore,
         InpMinimumScoreAdvantage,
         InpTradeCooldownSeconds,
         5.0
      );

   bool decisionInitialized =
      decisionReady &&
      g_testDecision.IsInitialized();

   PrintTestResult(
      "DecisionEngine initialized",
      decisionInitialized
   );

   if(decisionInitialized)
      passed++;

   g_initializationPassed =
      passed == total;

   Print(
      "Initialization Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(!g_initializationPassed)
      return INIT_FAILED;

   Print(
      "Initialization complete. Waiting for first market tick..."
   );

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Run Decision test after market data becomes available            |
//+------------------------------------------------------------------+
void OnTick()
{
   if(g_testCompleted)
      return;

   if(!g_initializationPassed)
      return;

   // Ensure enough historical bars exist for all indicators.
   int requiredBars =
      MathMax(
         InpSlowEMAPeriod,
         MathMax(
            InpRSIPeriod,
            MathMax(
               InpADXPeriod,
               InpATRPeriod
            )
         )
      ) + 10;

   int availableBars =
      Bars(
         _Symbol,
         InpSignalTimeframe
      );

   if(availableBars < requiredBars)
   {
      Print(
         "Waiting for historical bars. Available=",
         availableBars,
         ", required=",
         requiredBars
      );

      return;
   }

   bool evaluated =
      g_testDecision.Evaluate(
         g_testCoordinator
      );

   PrintTestResult(
      "DecisionEngine Evaluate Phase 4",
      evaluated
   );

   SDecisionContext context =
      g_testDecision.Context();

   SDecisionSnapshot snapshot =
      g_testDecision.Snapshot();

   bool decisionValid =
      evaluated &&
      context.IsValid() &&
      snapshot.valid &&
      IsValidDecisionAction(
         snapshot.action
      ) &&
      IsValidScore(
         snapshot.buyScore
      ) &&
      IsValidScore(
         snapshot.sellScore
      ) &&
      IsValidScore(
         snapshot.scoreAdvantage
      ) &&
      IsValidScore(
         snapshot.confidence
      ) &&
      IsValidScore(
         snapshot.quality
      ) &&
      snapshot.reason != "";

   PrintTestResult(
      "Decision Context, scores and action valid",
      decisionValid
   );

   Print(
      "Decision Phase 4 | ",
      "Action=",
      snapshot.ActionName(),
      " | ReasonCode=",
      snapshot.ReasonName(),
      " | SourceSignal=",
      SGDPTradeSignalName(
         snapshot.sourceSignal
      ),
      " | BuyScore=",
      DoubleToString(
         snapshot.buyScore,
         2
      ),
      " | SellScore=",
      DoubleToString(
         snapshot.sellScore,
         2
      ),
      " | Advantage=",
      DoubleToString(
         snapshot.scoreAdvantage,
         2
      ),
      " | Confidence=",
      DoubleToString(
         snapshot.confidence,
         2
      ),
      " | Quality=",
      DoubleToString(
         snapshot.quality,
         2
      ),
      " | QualityName=",
      snapshot.QualityName(),
      " | ATR=",
      DoubleToString(
         snapshot.atrPoints,
         1
      ),
      " | Spread=",
      DoubleToString(
         snapshot.spreadPoints,
         1
      ),
      " | MemoryBlocked=",
      snapshot.memoryBlocked
         ? "true"
         : "false",
      " | Reason=",
      snapshot.reason
   );

   int passed = 4;

   if(evaluated)
      passed++;

   if(decisionValid)
      passed++;

   Print(
      "Decision Foundation Phase 4 Test Result: ",
      IntegerToString(passed),
      "/6 passed."
   );

   if(passed == 6)
   {
      Print(
         "========== DECISION FOUNDATION TEST PASSED =========="
      );
   }
   else
   {
      Print(
         "========== DECISION FOUNDATION TEST FAILED =========="
      );
   }

   g_testCompleted = true;
}

//+------------------------------------------------------------------+
//| Release indicator resources                                      |
//+------------------------------------------------------------------+
void OnDeinit(
   const int reason
)
{
   g_testSignal.Release();
   g_testMarket.Release();

   Print(
      "Decision Foundation test stopped. Reason=",
      reason
   );
}