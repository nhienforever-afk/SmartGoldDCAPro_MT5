#ifndef SMARTGOLDDCAPRO_MARKET_STATE_MQH
#define SMARTGOLDDCAPRO_MARKET_STATE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Market State                    |
//+------------------------------------------------------------------+
struct SMarketAnalysis
{
   datetime timestamp;

   double bid;
   double ask;
   double spreadPoints;

   double atrPoints;
   double adxValue;
   double rsiValue;

   double fastEMA;
   double slowEMA;

   double buyTrendScore;
   double sellTrendScore;

   double buyMomentumScore;
   double sellMomentumScore;

   double volatilityScore;
   double spreadScore;

   ENUM_MARKET_REGIME regime;

   bool valid;

   void Reset()
   {
      timestamp = 0;

      bid = 0.0;
      ask = 0.0;
      spreadPoints = 0.0;

      atrPoints = 0.0;
      adxValue = 0.0;
      rsiValue = 0.0;

      fastEMA = 0.0;
      slowEMA = 0.0;

      buyTrendScore = 0.0;
      sellTrendScore = 0.0;

      buyMomentumScore = 0.0;
      sellMomentumScore = 0.0;

      volatilityScore = 0.0;
      spreadScore = 0.0;

      regime = MARKET_REGIME_UNKNOWN;

      valid = false;
   }
};

#endif