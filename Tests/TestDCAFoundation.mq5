#property strict
#property version "1.00"

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

#include <SmartGoldDCAPro/Risk/SmartLotCalculator.mqh>

#include <SmartGoldDCAPro/Trade/PositionManager.mqh>

#include <SmartGoldDCAPro/Market/MarketState.mqh>
#include <SmartGoldDCAPro/Market/TrendAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MomentumAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/VolatilityAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MarketAnalyzer.mqh>

#include <SmartGoldDCAPro/DCA/AdaptiveGridEngine.mqh>
#include <SmartGoldDCAPro/DCA/DCAEngine.mqh>

//+------------------------------------------------------------------+
//| DCA Foundation test objects                                      |
//+------------------------------------------------------------------+
CRiskManager        g_testRisk;
CSmartLotCalculator g_testLotCalculator;
CPositionManager    g_testPositions;
CMarketAnalyzer     g_testMarket;
CAdaptiveGridEngine g_testGrid;
CDCAEngine          g_testDCA;

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
//| Validate DCA control mode name                                   |
//+------------------------------------------------------------------+
bool IsValidControlModeName(
   const string modeName
)
{
   return
      modeName == "MANUAL" ||
      modeName == "FIXED" ||
      modeName == "ADAPTIVE";
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print(
      "========== DCA FOUNDATION TEST START =========="
   );

   int passed = 0;
   int total  = 10;

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
      g_testPositions.Symbol() == _Symbol &&
      g_testPositions.MagicNumber() == InpMagicNumber;

   PrintTestResult(
      "PositionManager initialized",
      positionsReady
   );

   if(positionsReady)
      passed++;

   // Store the initial position count.
   int positionsBefore =
      g_testPositions.CountAll();

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
   // TEST 5: Adaptive Grid Engine
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

   bool gridInitialized =
      gridReady &&
      g_testGrid.IsInitialized();

   PrintTestResult(
      "AdaptiveGridEngine initialized",
      gridInitialized
   );

   if(gridInitialized)
      passed++;

   //==============================================================
   // TEST 6: DCA Engine
   //==============================================================

   g_testDCA.Initialize(
      g_testPositions,
      g_testRisk,
      g_testMarket,
      g_testGrid,
      g_testLotCalculator
   );

   bool dcaReady =
      g_testDCA.IsInitialized();

   PrintTestResult(
      "DCAEngine initialized",
      dcaReady
   );

   if(dcaReady)
      passed++;

   //==============================================================
   // TEST 7: Control mode name
   //==============================================================

   string controlMode =
      g_testDCA.ControlModeName();

   bool controlModeValid =
      IsValidControlModeName(
         controlMode
      );

   PrintTestResult(
      "DCA control mode is valid",
      controlModeValid
   );

   if(controlModeValid)
      passed++;

   //==============================================================
   // TEST 8: No basket must reject DCA safely
   //==============================================================

   ENUM_POSITION_TYPE direction =
      POSITION_TYPE_BUY;

   double nextLot =
      0.0;

   string dcaReason =
      "";

   bool shouldAdd =
      g_testDCA.ShouldAddPosition(
         direction,
         nextLot,
         dcaReason
      );

   bool noBasketRejected =
      !shouldAdd &&
      nextLot == 0.0 &&
      dcaReason == "No active basket.";

   PrintTestResult(
      "No active basket rejected safely",
      noBasketRejected
   );

   if(noBasketRejected)
      passed++;

   //==============================================================
   // TEST 9: Rejection state and diagnostic values
   //==============================================================

   bool rejectionStateValid =
      g_testDCA.LastReason() ==
         "No active basket." &&
      g_testDCA.LastNextLot() == 0.0 &&
      g_testDCA.LastGridPoints() == 0.0 &&
      g_testDCA.LastAdversePoints() == 0.0 &&
      g_testDCA.LastNextOrderNumber() == 0;

   PrintTestResult(
      "DCA rejection diagnostics are valid",
      rejectionStateValid
   );

   if(rejectionStateValid)
      passed++;

   //==============================================================
   // TEST 10: No position was created
   //==============================================================

   int positionsAfter =
      g_testPositions.CountAll();

   bool accountUnchanged =
      positionsAfter == positionsBefore;

   PrintTestResult(
      "DCA test did not open a position",
      accountUnchanged
   );

   if(accountUnchanged)
      passed++;

   //==============================================================
   // PRINT DETAILS
   //==============================================================

   Print(
      "DCA Foundation | ",
      "Mode=",
      controlMode,
      " | ShouldAdd=",
      shouldAdd ? "true" : "false",
      " | Direction=",
      SGDPPositionTypeName(
         direction
      ),
      " | NextLot=",
      DoubleToString(
         nextLot,
         2
      ),
      " | Grid=",
      DoubleToString(
         g_testDCA.LastGridPoints(),
         1
      ),
      " | Adverse=",
      DoubleToString(
         g_testDCA.LastAdversePoints(),
         1
      ),
      " | RiskScore=",
      IntegerToString(
         g_testDCA.LastRiskScore()
      ),
      " | Reason=",
      dcaReason
   );

   Print(
      "Positions before=",
      positionsBefore,
      ", positions after=",
      positionsAfter
   );

   Print(
      "DCA Foundation Test Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(passed != total)
   {
      Print(
         "========== DCA FOUNDATION TEST FAILED =========="
      );

      return INIT_FAILED;
   }

   Print(
      "========== DCA FOUNDATION TEST PASSED =========="
   );

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Release indicator resources                                      |
//+------------------------------------------------------------------+
void OnDeinit(
   const int reason
)
{
   g_testMarket.Release();

   Print(
      "DCA Foundation test stopped. Reason=",
      reason
   );
}

//+------------------------------------------------------------------+
//| No trading actions                                               |
//+------------------------------------------------------------------+
void OnTick()
{
}