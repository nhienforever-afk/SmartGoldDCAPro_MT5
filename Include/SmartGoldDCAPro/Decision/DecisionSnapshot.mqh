#ifndef SMARTGOLDDCAPRO_DECISION_SNAPSHOT_MQH
#define SMARTGOLDDCAPRO_DECISION_SNAPSHOT_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Decision Snapshot               |
//+------------------------------------------------------------------+
struct SDecisionSnapshot
{
   datetime timestamp;

   ENUM_DECISION_ACTION action;
   ENUM_DECISION_REASON reasonCode;

   double buyScore;
   double sellScore;
   double scoreAdvantage;

   double confidence;
   double quality;

   double buyTrendScore;
   double sellTrendScore;

   double buyMomentumScore;
   double sellMomentumScore;

   double buySignalScore;
   double sellSignalScore;

   double volatilityScore;
   double spreadScore;

   double atrPoints;
   double spreadPoints;

   ENUM_MARKET_REGIME marketRegime;
   ENUM_TRADE_SIGNAL  sourceSignal;

   bool valid;
   bool memoryBlocked;

   string reason;

   void Reset()
   {
      timestamp = 0;

      action     = DECISION_WAIT;
      reasonCode = DECISION_REASON_NONE;

      buyScore       = 0.0;
      sellScore      = 0.0;
      scoreAdvantage = 0.0;

      confidence = 0.0;
      quality    = 0.0;

      buyTrendScore  = 0.0;
      sellTrendScore = 0.0;

      buyMomentumScore  = 0.0;
      sellMomentumScore = 0.0;

      buySignalScore  = 0.0;
      sellSignalScore = 0.0;

      volatilityScore = 0.0;
      spreadScore     = 0.0;

      atrPoints    = 0.0;
      spreadPoints = 0.0;

      marketRegime = MARKET_REGIME_UNKNOWN;
      sourceSignal = SIGNAL_NONE;

      valid         = false;
      memoryBlocked = false;

      reason =
         "Decision has not been evaluated.";
   }

   bool HasTradeDecision() const
   {
      return
         valid &&
         (
            action == DECISION_BUY ||
            action == DECISION_SELL
         );
   }

   bool IsBlocked() const
   {
      return
         valid &&
         action == DECISION_BLOCK;
   }

   string ActionName() const
   {
      return
         SGDPDecisionActionName(
            action
         );
   }

   string ReasonName() const
   {
      return
         SGDPDecisionReasonName(
            reasonCode
         );
   }

   string QualityName() const
   {
      if(quality >= 90.0)
         return "EXCELLENT";

      if(quality >= 80.0)
         return "STRONG";

      if(quality >= 70.0)
         return "GOOD";

      if(quality >= 55.0)
         return "WEAK";

      return "POOR";
   }
};

#endif