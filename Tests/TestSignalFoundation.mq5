#property strict
#property version "1.00"

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

CSignalEngine      g_testSignal;
CMarketAnalyzer    g_testMarket;
CSignalCoordinator g_testCoordinator;

void PrintResult(
   const string testName,
   const bool passed
)
{
   Print(
      passed ? "[PASS] " : "[FAIL] ",
      testName
   );
}

int OnInit()
{
   int passed = 0;
   int total  = 4;

   bool signalReady =
      g_testSignal.Initialize(
         _Symbol,
         InpSignalTimeframe
      );

   PrintResult(
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

   PrintResult(
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

   PrintResult(
      "SignalCoordinator initialized",
      coordinatorReady
   );

   if(coordinatorReady)
      passed++;

   bool evaluated =
      coordinatorReady &&
      g_testCoordinator.Evaluate();

   PrintResult(
      "SignalCoordinator evaluate",
      evaluated
   );

   if(evaluated)
   {
      passed++;

      Print(
         "Signal Layer | ",
         "Signal=",
         g_testCoordinator.LastSignalName(),
         " | BuyScore=",
         DoubleToString(
            g_testCoordinator.LastBuyScore(),
            2
         ),
         " | SellScore=",
         DoubleToString(
            g_testCoordinator.LastSellScore(),
            2
         ),
         " | Advantage=",
         DoubleToString(
            g_testCoordinator.LastScoreAdvantage(),
            2
         ),
         " | ATR=",
         DoubleToString(
            g_testCoordinator.LastATRPoints(),
            1
         ),
         " | Spread=",
         DoubleToString(
            g_testCoordinator.LastSpreadPoints(),
            1
         ),
         " | Reason=",
         g_testCoordinator.LastReason()
      );
   }

   Print(
      "Signal Foundation Test Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(passed != total)
      return INIT_FAILED;

   return INIT_SUCCEEDED;
}

void OnDeinit(
   const int reason
)
{
   g_testSignal.Release();
   g_testMarket.Release();
}

void OnTick()
{
}