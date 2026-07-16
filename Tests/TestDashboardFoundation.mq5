#property strict
#property version "1.00"

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

#include <SmartGoldDCAPro/Risk/SmartLotCalculator.mqh>

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

#include <SmartGoldDCAPro/Trade/PositionManager.mqh>

#include <SmartGoldDCAPro/DCA/AdaptiveGridEngine.mqh>
#include <SmartGoldDCAPro/DCA/DCAEngine.mqh>

#include <SmartGoldDCAPro/Dashboard/DashboardData.mqh>
#include <SmartGoldDCAPro/Dashboard/DashboardRenderer.mqh>
#include <SmartGoldDCAPro/Dashboard/DashboardController.mqh>

//+------------------------------------------------------------------+
//| Dashboard Foundation test objects                                |
//+------------------------------------------------------------------+
CRiskManager         g_testRisk;
CSmartLotCalculator  g_testLotCalculator;
CPositionManager     g_testPositions;

CMarketAnalyzer      g_testMarket;
CSignalEngine        g_testSignal;
CSignalCoordinator   g_testCoordinator;
CDecisionEngine      g_testDecision;

CAdaptiveGridEngine  g_testGrid;
CDCAEngine           g_testDCA;

CDashboardRenderer   g_testRenderer;
CDashboardController g_testDashboard;

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
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print(
      "========== DASHBOARD FOUNDATION TEST START =========="
   );

   int passed = 0;
   int total  = 9;

   //==============================================================
   // TEST 1: Risk Manager
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
   // TEST 2: Position Manager
   //==============================================================

   g_testPositions.Initialize(
      _Symbol,
      InpMagicNumber
   );

   bool positionsReady =
      g_testPositions.Symbol() == _Symbol;

   PrintTestResult(
      "PositionManager initialized",
      positionsReady
   );

   if(positionsReady)
      passed++;

   //==============================================================
   // TEST 3: Smart Lot Calculator
   //==============================================================

   g_testLotCalculator.Initialize(
      g_testRisk
   );

   bool lotCalculatorReady =
      g_testLotCalculator.IsInitialized();

   PrintTestResult(
      "SmartLotCalculator initialized",
      lotCalculatorReady
   );

   if(lotCalculatorReady)
      passed++;

   //==============================================================
   // TEST 4: Market Analyzer
   //==============================================================

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

   //==============================================================
   // TEST 5: Signal Engine and Coordinator
   //==============================================================

   bool signalReady =
      g_testSignal.Initialize(
         _Symbol,
         InpSignalTimeframe
      );

   g_testCoordinator.Initialize(
      g_testSignal,
      g_testMarket
   );

   bool signalLayerReady =
      signalReady &&
      g_testCoordinator.IsInitialized();

   PrintTestResult(
      "Signal Layer initialized",
      signalLayerReady
   );

   if(signalLayerReady)
      passed++;

   //==============================================================
   // TEST 6: Decision Engine
   //==============================================================

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

   //==============================================================
   // TEST 7: Adaptive Grid and DCA Engine
   //==============================================================

   bool gridReady =
      g_testGrid.Initialize(
         InpMinimumGridPoints,
         InpMaximumGridPoints,
         InpGridATRMultiplier,
         1.50,
         0.85,
         1.10
      );

   g_testDCA.Initialize(
      g_testPositions,
      g_testRisk,
      g_testMarket,
      g_testGrid,
      g_testLotCalculator
   );

   bool dcaLayerReady =
      gridReady &&
      g_testGrid.IsInitialized() &&
      g_testDCA.IsInitialized();

   PrintTestResult(
      "DCA Layer initialized",
      dcaLayerReady
   );

   if(dcaLayerReady)
      passed++;

   //==============================================================
   // TEST 8: Dashboard Renderer
   //==============================================================

   bool rendererReady =
      g_testRenderer.Initialize();

   bool rendererInitialized =
      rendererReady &&
      g_testRenderer.IsInitialized();

   PrintTestResult(
      "DashboardRenderer initialized",
      rendererInitialized
   );

   if(rendererInitialized)
      passed++;

   //==============================================================
   // TEST 9: Dashboard Controller
   //==============================================================

   g_testDashboard.Initialize(
      g_testMarket,
      g_testCoordinator,
      g_testDecision,
      g_testPositions,
      g_testDCA,
      g_testRisk,
      g_testRenderer
   );

   bool dashboardReady =
      g_testDashboard.IsInitialized();

   PrintTestResult(
      "DashboardController initialized",
      dashboardReady
   );

   if(dashboardReady)
      passed++;

   g_initializationPassed =
      passed == total;

   Print(
      "Dashboard Initialization Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(!g_initializationPassed)
      return INIT_FAILED;

   Print(
      "Dashboard initialized. Waiting for market data..."
   );

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Run Dashboard test when indicator data becomes available         |
//+------------------------------------------------------------------+
void OnTick()
{
   if(g_testCompleted)
      return;

   if(!g_initializationPassed)
      return;

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

   //==============================================================
   // TEST 10: Decision Evaluation
   //==============================================================

   bool decisionEvaluated =
      g_testDecision.Evaluate(
         g_testCoordinator
      );

   PrintTestResult(
      "Decision evaluated for Dashboard",
      decisionEvaluated
   );

   if(!decisionEvaluated)
   {
      Print(
         "Decision evaluation failed: ",
         g_testDecision.Reason()
      );

      return;
   }

   //==============================================================
   // TEST 11: Dashboard Data
   //==============================================================

   SDashboardData dashboardData;

   bool dataBuilt =
      g_testDashboard.BuildData(
         dashboardData
      );

   bool dataValid =
      dataBuilt &&
      dashboardData.IsValid() &&
      dashboardData.symbol != "" &&
      dashboardData.serverTime > 0;

   PrintTestResult(
      "Dashboard data built and validated",
      dataValid
   );

   //==============================================================
   // TEST 12: Dashboard Rendering
   //==============================================================

   bool dashboardUpdated =
      dataValid &&
      g_testDashboard.Update();

   PrintTestResult(
      "Dashboard rendered on chart",
      dashboardUpdated
   );

   Print(
      "Dashboard Data | ",
      "Symbol=",
      dashboardData.symbol,
      " | Trend=",
      dashboardData.marketTrend,
      " | Momentum=",
      dashboardData.marketMomentum,
      " | Volatility=",
      dashboardData.marketVolatility,
      " | Signal=",
      dashboardData.signal,
      " | Decision=",
      dashboardData.decision,
      " | Confidence=",
      dashboardData.confidence,
      " | Quality=",
      dashboardData.quality,
      " | Basket=",
      dashboardData.basketDirection,
      " | Orders=",
      IntegerToString(
         dashboardData.basketOrders
      ),
      " | Profit=",
      DoubleToString(
         dashboardData.basketProfit,
         2
      ),
      " | DCA=",
      IntegerToString(
         dashboardData.dcaLevel
      ),
      " | Risk=",
      IntegerToString(
         dashboardData.riskScore
      ),
      " | Drawdown=",
      DoubleToString(
         dashboardData.drawdownPercent,
         2
      ),
      "%"
   );

   int passed = 9;

   if(decisionEvaluated)
      passed++;

   if(dataValid)
      passed++;

   if(dashboardUpdated)
      passed++;

   Print(
      "Dashboard Foundation Test Result: ",
      IntegerToString(passed),
      "/12 passed."
   );

   if(passed == 12)
   {
      Print(
         "========== DASHBOARD FOUNDATION TEST PASSED =========="
      );
   }
   else
   {
      Print(
         "========== DASHBOARD FOUNDATION TEST FAILED =========="
      );
   }

   g_testCompleted = true;
}

//+------------------------------------------------------------------+
//| Release resources                                                |
//+------------------------------------------------------------------+
void OnDeinit(
   const int reason
)
{
   g_testDashboard.Release();

   g_testSignal.Release();
   g_testMarket.Release();

   Print(
      "Dashboard Foundation test stopped. Reason=",
      reason
   );
}