#property strict
#property version "1.00"

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>

#include <SmartGoldDCAPro/Market/MarketState.mqh>
#include <SmartGoldDCAPro/Market/TrendAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MomentumAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/VolatilityAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MarketAnalyzer.mqh>

CTrendAnalyzer      g_testTrend;
CMomentumAnalyzer   g_testMomentum;
CVolatilityAnalyzer g_testVolatility;
CMarketAnalyzer     g_testMarket;

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
   int total  = 5;

   bool trendReady =
      g_testTrend.Initialize(
         _Symbol,
         InpSignalTimeframe,
         InpFastEMAPeriod,
         InpSlowEMAPeriod
      );

   PrintResult(
      "TrendAnalyzer initialized",
      trendReady
   );

   if(trendReady)
      passed++;

   bool momentumReady =
      g_testMomentum.Initialize(
         _Symbol,
         InpSignalTimeframe,
         InpRSIPeriod
      );

   PrintResult(
      "MomentumAnalyzer initialized",
      momentumReady
   );

   if(momentumReady)
      passed++;

   bool volatilityReady =
      g_testVolatility.Initialize(
         _Symbol,
         InpSignalTimeframe,
         InpATRPeriod,
         InpMinimumATRPoints,
         InpHighVolatilityATRPoints
      );

   PrintResult(
      "VolatilityAnalyzer initialized",
      volatilityReady
   );

   if(volatilityReady)
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

   SMarketAnalysis analysis;

   bool marketRead =
      marketReady &&
      g_testMarket.Read(
         analysis
      );

   PrintResult(
      "MarketAnalyzer read",
      marketRead
   );

   if(marketRead)
   {
      passed++;

      Print(
         "Market data | ",
         "Spread=",
         DoubleToString(
            analysis.spreadPoints,
            1
         ),
         " | ATR=",
         DoubleToString(
            analysis.atrPoints,
            1
         ),
         " | RSI=",
         DoubleToString(
            analysis.rsiValue,
            2
         ),
         " | BuyTrend=",
         DoubleToString(
            analysis.buyTrendScore,
            2
         ),
         " | SellTrend=",
         DoubleToString(
            analysis.sellTrendScore,
            2
         ),
         " | BuyMomentum=",
         DoubleToString(
            analysis.buyMomentumScore,
            2
         ),
         " | SellMomentum=",
         DoubleToString(
            analysis.sellMomentumScore,
            2
         ),
         " | Volatility=",
         DoubleToString(
            analysis.volatilityScore,
            2
         ),
         " | SpreadScore=",
         DoubleToString(
            analysis.spreadScore,
            2
         )
      );
   }

   Print(
      "Market Foundation Test Result: ",
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
   g_testTrend.Release();
   g_testMomentum.Release();
   g_testVolatility.Release();
   g_testMarket.Release();
}

void OnTick()
{
}