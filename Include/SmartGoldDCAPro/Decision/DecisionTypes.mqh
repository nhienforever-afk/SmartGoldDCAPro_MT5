#ifndef SMARTGOLDDCAPRO_DECISION_TYPES_MQH
#define SMARTGOLDDCAPRO_DECISION_TYPES_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Decision Types                  |
//+------------------------------------------------------------------+

enum ENUM_DECISION_ACTION
{
   DECISION_WAIT = 0,
   DECISION_BUY,
   DECISION_SELL,
   DECISION_BLOCK
};

enum ENUM_DECISION_REASON
{
   DECISION_REASON_NONE = 0,
   DECISION_REASON_BUY_SCORE_APPROVED,
   DECISION_REASON_SELL_SCORE_APPROVED,
   DECISION_REASON_SCORE_TOO_LOW,
   DECISION_REASON_ADVANTAGE_TOO_LOW,
   DECISION_REASON_HIGH_VOLATILITY,
   DECISION_REASON_SPREAD_TOO_HIGH,
   DECISION_REASON_MARKET_DATA_INVALID,
   DECISION_REASON_SIGNAL_DATA_INVALID,
   DECISION_REASON_MEMORY_BLOCKED
};

struct SDecisionContext
{
   datetime timestamp;

   ENUM_TRADE_SIGNAL signal;
   ENUM_MARKET_REGIME marketRegime;

   double signalBuyScore;
   double signalSellScore;

   double trendBuyScore;
   double trendSellScore;

   double momentumBuyScore;
   double momentumSellScore;

   double volatilityScore;
   double spreadScore;

   double atrPoints;
   double spreadPoints;

   bool signalValid;
   bool marketValid;

   void Reset()
   {
      timestamp = 0;

      signal       = SIGNAL_NONE;
      marketRegime = MARKET_REGIME_UNKNOWN;

      signalBuyScore  = 0.0;
      signalSellScore = 0.0;

      trendBuyScore  = 0.0;
      trendSellScore = 0.0;

      momentumBuyScore  = 0.0;
      momentumSellScore = 0.0;

      volatilityScore = 0.0;
      spreadScore     = 0.0;

      atrPoints    = 0.0;
      spreadPoints = 0.0;

      signalValid = false;
      marketValid = false;
   }

   bool IsValid() const
   {
      return
         signalValid &&
         marketValid;
   }
};

string SGDPDecisionActionName(
   const ENUM_DECISION_ACTION action
)
{
   switch(action)
   {
      case DECISION_BUY:
         return "BUY";

      case DECISION_SELL:
         return "SELL";

      case DECISION_BLOCK:
         return "BLOCK";

      case DECISION_WAIT:
         return "WAIT";
   }

   return "UNKNOWN";
}

string SGDPDecisionReasonName(
   const ENUM_DECISION_REASON reason
)
{
   switch(reason)
   {
      case DECISION_REASON_BUY_SCORE_APPROVED:
         return "BUY_SCORE_APPROVED";

      case DECISION_REASON_SELL_SCORE_APPROVED:
         return "SELL_SCORE_APPROVED";

      case DECISION_REASON_SCORE_TOO_LOW:
         return "SCORE_TOO_LOW";

      case DECISION_REASON_ADVANTAGE_TOO_LOW:
         return "ADVANTAGE_TOO_LOW";

      case DECISION_REASON_HIGH_VOLATILITY:
         return "HIGH_VOLATILITY";

      case DECISION_REASON_SPREAD_TOO_HIGH:
         return "SPREAD_TOO_HIGH";

      case DECISION_REASON_MARKET_DATA_INVALID:
         return "MARKET_DATA_INVALID";

      case DECISION_REASON_SIGNAL_DATA_INVALID:
         return "SIGNAL_DATA_INVALID";

      case DECISION_REASON_MEMORY_BLOCKED:
         return "MEMORY_BLOCKED";

      case DECISION_REASON_NONE:
         return "NONE";
   }

   return "UNKNOWN";
}

#endif