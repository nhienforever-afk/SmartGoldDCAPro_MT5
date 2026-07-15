#property strict
#property version "1.00"

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Market/MarketState.mqh>
#include <SmartGoldDCAPro/DCA/AdaptiveGridEngine.mqh>

//+------------------------------------------------------------------+
//| Test object                                                      |
//+------------------------------------------------------------------+
CAdaptiveGridEngine g_testGrid;

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
//| Compare doubles with tolerance                                   |
//+------------------------------------------------------------------+
bool IsNear(
   const double firstValue,
   const double secondValue,
   const double tolerance = 0.01
)
{
   return
      MathAbs(
         firstValue -
         secondValue
      ) <= tolerance;
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print(
      "========== ADAPTIVE GRID FOUNDATION TEST START =========="
   );

   int passed = 0;
   int total  = 8;

   //==============================================================
   // TEST 1: Initialization
   //==============================================================

   bool initialized =
      g_testGrid.Initialize(
         100.0,
         3000.0,
         1.0,
         1.50,
         0.85,
         1.10
      );

   bool initializationValid =
      initialized &&
      g_testGrid.IsInitialized();

   PrintTestResult(
      "AdaptiveGridEngine initialized",
      initializationValid
   );

   if(initializationValid)
      passed++;

   //==============================================================
   // TEST 2: Minimum grid clamp
   // ATR=20, RANGE factor=0.85, spread=5
   // raw grid=22, expected clamp=100
   //==============================================================

   double minimumGrid =
      g_testGrid.CalculateFromValues(
         20.0,
         5.0,
         MARKET_REGIME_RANGE
      );

   bool minimumClampValid =
      IsNear(
         minimumGrid,
         100.0
      );

   PrintTestResult(
      "Minimum grid clamp",
      minimumClampValid
   );

   if(minimumClampValid)
      passed++;

   //==============================================================
   // TEST 3: Range regime calculation
   // ATR=500, RANGE factor=0.85, spread=20
   // expected=445
   //==============================================================

   double rangeGrid =
      g_testGrid.CalculateFromValues(
         500.0,
         20.0,
         MARKET_REGIME_RANGE
      );

   bool rangeGridValid =
      IsNear(
         rangeGrid,
         445.0
      );

   PrintTestResult(
      "Range regime grid calculation",
      rangeGridValid
   );

   if(rangeGridValid)
      passed++;

   //==============================================================
   // TEST 4: Trend regime calculation
   // ATR=500, TREND factor=1.10, spread=20
   // expected=570
   //==============================================================

   double trendGrid =
      g_testGrid.CalculateFromValues(
         500.0,
         20.0,
         MARKET_REGIME_TREND_UP
      );

   bool trendGridValid =
      IsNear(
         trendGrid,
         570.0
      );

   PrintTestResult(
      "Trend regime grid calculation",
      trendGridValid
   );

   if(trendGridValid)
      passed++;

   //==============================================================
   // TEST 5: High-volatility calculation
   // ATR=500, HIGH VOL factor=1.50, spread=20
   // expected=770
   //==============================================================

   double highVolatilityGrid =
      g_testGrid.CalculateFromValues(
         500.0,
         20.0,
         MARKET_REGIME_HIGH_VOLATILITY
      );

   bool highVolatilityValid =
      IsNear(
         highVolatilityGrid,
         770.0
      );

   PrintTestResult(
      "High-volatility grid calculation",
      highVolatilityValid
   );

   if(highVolatilityValid)
      passed++;

   //==============================================================
   // TEST 6: Maximum grid clamp
   // ATR=5000, HIGH VOL factor=1.50, spread=100
   // raw grid=7600, expected clamp=3000
   //==============================================================

   double maximumGrid =
      g_testGrid.CalculateFromValues(
         5000.0,
         100.0,
         MARKET_REGIME_HIGH_VOLATILITY
      );

   bool maximumClampValid =
      IsNear(
         maximumGrid,
         3000.0
      );

   PrintTestResult(
      "Maximum grid clamp",
      maximumClampValid
   );

   if(maximumClampValid)
      passed++;

   //==============================================================
   // TEST 7: Manual grid normalization
   //==============================================================

   double manualGrid =
      g_testGrid.ManualGrid(
         650.0
      );

   bool manualGridValid =
      IsNear(
         manualGrid,
         650.0
      );

   PrintTestResult(
      "Manual grid normalization",
      manualGridValid
   );

   if(manualGridValid)
      passed++;

   //==============================================================
   // TEST 8: Invalid ATR rejected
   //==============================================================

   double invalidGrid =
      g_testGrid.CalculateFromValues(
         0.0,
         20.0,
         MARKET_REGIME_RANGE
      );

   bool invalidATRRejected =
      IsNear(
         invalidGrid,
         0.0
      ) &&
      g_testGrid.LastReason() != "";

   PrintTestResult(
      "Invalid ATR rejected safely",
      invalidATRRejected
   );

   if(invalidATRRejected)
      passed++;

   //==============================================================
   // PRINT DETAILS
   //==============================================================

   Print(
      "Grid values | ",
      "Minimum=",
      DoubleToString(
         minimumGrid,
         1
      ),
      " | Range=",
      DoubleToString(
         rangeGrid,
         1
      ),
      " | Trend=",
      DoubleToString(
         trendGrid,
         1
      ),
      " | HighVolatility=",
      DoubleToString(
         highVolatilityGrid,
         1
      ),
      " | Maximum=",
      DoubleToString(
         maximumGrid,
         1
      ),
      " | Manual=",
      DoubleToString(
         manualGrid,
         1
      )
   );

   Print(
      "Adaptive Grid Foundation Test Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(passed != total)
   {
      Print(
         "========== ADAPTIVE GRID FOUNDATION TEST FAILED =========="
      );

      return INIT_FAILED;
   }

   Print(
      "========== ADAPTIVE GRID FOUNDATION TEST PASSED =========="
   );

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| No trading logic                                                 |
//+------------------------------------------------------------------+
void OnTick()
{
}