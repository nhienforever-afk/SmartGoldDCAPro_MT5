#property strict
#property version "1.00"

#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>
#include <SmartGoldDCAPro/Decision/DecisionScore.mqh>
#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>
#include <SmartGoldDCAPro/Analytics/MarketMemory.mqh>
#include <SmartGoldDCAPro/Decision/DecisionEngine.mqh>

//+------------------------------------------------------------------+
//| Test objects                                                     |
//+------------------------------------------------------------------+
CDecisionEngine g_decision;

//+------------------------------------------------------------------+
//| Print snapshot                                                   |
//+------------------------------------------------------------------+
void PrintSnapshot(
   const string testName,
   const DecisionSnapshot &snapshot
)
{
   Print(
      "[", testName, "] ",
      "Decision=", snapshot.Decision,
      " | BUY=", DoubleToString(snapshot.BuyScore, 2),
      " | SELL=", DoubleToString(snapshot.SellScore, 2),
      " | Advantage=",
      DoubleToString(snapshot.ScoreAdvantage(), 2),
      " | BuyQuality=", snapshot.BuyQuality,
      " | SellQuality=", snapshot.SellQuality,
      " | Market=", snapshot.MarketStateName(),
      " | Reason=", snapshot.Reason
   );
}

//+------------------------------------------------------------------+
//| Test BUY decision                                                |
//+------------------------------------------------------------------+
bool TestBuyDecision()
{
   g_decision.Clear();

   g_decision.Initialize(
      65.0,
      10.0
   );

   g_decision.SetWeights(
      35.0,  // Trend
      25.0,  // Momentum
      10.0,  // Volume
      20.0,  // Volatility
      10.0   // Spread
   );

   g_decision.SetMarketState(
      MARKET_TREND_UP
   );

   g_decision.Evaluate(
      _Symbol,

      90.0,  // BUY trend
      15.0,  // SELL trend

      80.0,  // BUY momentum
      20.0,  // SELL momentum

      70.0,  // BUY volume
      30.0,  // SELL volume

      75.0,  // Volatility
      90.0   // Spread
   );

   DecisionSnapshot snapshot =
      g_decision.LastSnapshot();

   PrintSnapshot(
      "BUY TEST",
      snapshot
   );

   return
      snapshot.Valid &&
      snapshot.AllowBuy &&
      !snapshot.AllowSell &&
      snapshot.Decision == "BUY";
}

//+------------------------------------------------------------------+
//| Test SELL decision                                               |
//+------------------------------------------------------------------+
bool TestSellDecision()
{
   g_decision.Clear();

   g_decision.Initialize(
      65.0,
      10.0
   );

   g_decision.SetWeights(
      35.0,
      25.0,
      10.0,
      20.0,
      10.0
   );

   g_decision.SetMarketState(
      MARKET_TREND_DOWN
   );

   g_decision.Evaluate(
      _Symbol,

      15.0,  // BUY trend
      90.0,  // SELL trend

      20.0,  // BUY momentum
      80.0,  // SELL momentum

      30.0,  // BUY volume
      70.0,  // SELL volume

      75.0,  // Volatility
      90.0   // Spread
   );

   DecisionSnapshot snapshot =
      g_decision.LastSnapshot();

   PrintSnapshot(
      "SELL TEST",
      snapshot
   );

   return
      snapshot.Valid &&
      !snapshot.AllowBuy &&
      snapshot.AllowSell &&
      snapshot.Decision == "SELL";
}

//+------------------------------------------------------------------+
//| Test WAIT decision                                               |
//+------------------------------------------------------------------+
bool TestWaitDecision()
{
   g_decision.Clear();

   g_decision.Initialize(
      65.0,
      10.0
   );

   g_decision.SetWeights(
      35.0,
      25.0,
      10.0,
      20.0,
      10.0
   );

   g_decision.SetMarketState(
      MARKET_RANGE
   );

   g_decision.Evaluate(
      _Symbol,

      55.0,  // BUY trend
      52.0,  // SELL trend

      50.0,  // BUY momentum
      48.0,  // SELL momentum

      50.0,  // BUY volume
      50.0,  // SELL volume

      60.0,  // Volatility
      80.0   // Spread
   );

   DecisionSnapshot snapshot =
      g_decision.LastSnapshot();

   PrintSnapshot(
      "WAIT TEST",
      snapshot
   );

   return
      snapshot.Valid &&
      !snapshot.AllowBuy &&
      !snapshot.AllowSell &&
      snapshot.Decision == "WAIT";
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   int passed = 0;
   int total  = 3;

   if(TestBuyDecision())
   {
      passed++;
      Print("[PASS] BUY decision");
   }
   else
   {
      Print("[FAIL] BUY decision");
   }

   if(TestSellDecision())
   {
      passed++;
      Print("[PASS] SELL decision");
   }
   else
   {
      Print("[FAIL] SELL decision");
   }

   if(TestWaitDecision())
   {
      passed++;
      Print("[PASS] WAIT decision");
   }
   else
   {
      Print("[FAIL] WAIT decision");
   }

   Print(
      "Decision Layer Test Result: ",
      IntegerToString(passed),
      "/",
      IntegerToString(total),
      " passed."
   );

   if(passed != total)
      return INIT_FAILED;

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| No tick logic required                                           |
//+------------------------------------------------------------------+
void OnTick()
{
}