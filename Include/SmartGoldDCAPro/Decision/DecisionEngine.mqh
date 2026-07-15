#ifndef SMARTGOLDDCAPRO_DECISION_ENGINE_MQH
#define SMARTGOLDDCAPRO_DECISION_ENGINE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>
#include <SmartGoldDCAPro/Decision/DecisionScore.mqh>
#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>

#include <SmartGoldDCAPro/Analytics/MarketMemory.mqh>
#include <SmartGoldDCAPro/Signal/SignalCoordinator.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Decision Engine                 |
//| Phase 4: Context, Score, Decision Logic and Market Memory        |
//+------------------------------------------------------------------+
class CDecisionEngine
{
private:
   CDecisionScore m_buyScore;
   CDecisionScore m_sellScore;

   CMarketMemory m_memory;

   SDecisionContext  m_context;
   SDecisionSnapshot m_snapshot;

   double m_minimumDecisionScore;
   double m_minimumAdvantage;

   bool m_initialized;

   //+----------------------------------------------------------------+
   //| Build Decision Context from Signal Coordinator                  |
   //+----------------------------------------------------------------+
   bool BuildContext(
      CSignalCoordinator &coordinator
   )
   {
      m_context.Reset();

      if(!coordinator.IsInitialized())
         return false;

      if(!coordinator.Evaluate())
         return false;

      SSignalSnapshot signalSnapshot =
         coordinator.LastSignalSnapshot();

      SMarketAnalysis marketAnalysis =
         coordinator.LastMarketAnalysis();

      if(!signalSnapshot.valid)
         return false;

      if(!marketAnalysis.valid)
         return false;

      m_context.timestamp =
         TimeCurrent();

      m_context.signal =
         signalSnapshot.signal;

      m_context.marketRegime =
         marketAnalysis.regime;

      m_context.signalBuyScore =
         SGDPNormalizeScore(
            signalSnapshot.buyScore
         );

      m_context.signalSellScore =
         SGDPNormalizeScore(
            signalSnapshot.sellScore
         );

      m_context.trendBuyScore =
         SGDPNormalizeScore(
            marketAnalysis.buyTrendScore
         );

      m_context.trendSellScore =
         SGDPNormalizeScore(
            marketAnalysis.sellTrendScore
         );

      m_context.momentumBuyScore =
         SGDPNormalizeScore(
            marketAnalysis.buyMomentumScore
         );

      m_context.momentumSellScore =
         SGDPNormalizeScore(
            marketAnalysis.sellMomentumScore
         );

      m_context.volatilityScore =
         SGDPNormalizeScore(
            marketAnalysis.volatilityScore
         );

      m_context.spreadScore =
         SGDPNormalizeScore(
            marketAnalysis.spreadScore
         );

      m_context.atrPoints =
         MathMax(
            0.0,
            marketAnalysis.atrPoints
         );

      m_context.spreadPoints =
         MathMax(
            0.0,
            marketAnalysis.spreadPoints
         );

      m_context.signalValid =
         signalSnapshot.valid;

      m_context.marketValid =
         marketAnalysis.valid;

      return m_context.IsValid();
   }

   //+----------------------------------------------------------------+
   //| Copy Context data into Decision Snapshot                        |
   //+----------------------------------------------------------------+
   void BuildSnapshot()
   {
      m_snapshot.Reset();

      m_snapshot.timestamp =
         m_context.timestamp;

      m_snapshot.marketRegime =
         m_context.marketRegime;

      m_snapshot.sourceSignal =
         m_context.signal;

      m_snapshot.buyTrendScore =
         m_context.trendBuyScore;

      m_snapshot.sellTrendScore =
         m_context.trendSellScore;

      m_snapshot.buyMomentumScore =
         m_context.momentumBuyScore;

      m_snapshot.sellMomentumScore =
         m_context.momentumSellScore;

      m_snapshot.buySignalScore =
         m_context.signalBuyScore;

      m_snapshot.sellSignalScore =
         m_context.signalSellScore;

      m_snapshot.volatilityScore =
         m_context.volatilityScore;

      m_snapshot.spreadScore =
         m_context.spreadScore;

      m_snapshot.atrPoints =
         m_context.atrPoints;

      m_snapshot.spreadPoints =
         m_context.spreadPoints;

      m_snapshot.action =
         DECISION_WAIT;

      m_snapshot.reasonCode =
         DECISION_REASON_NONE;

      m_snapshot.valid = true;
   }

   //+----------------------------------------------------------------+
   //| Calculate BUY and SELL scores                                   |
   //+----------------------------------------------------------------+
   void CalculateScores()
   {
      m_buyScore.Reset();
      m_sellScore.Reset();

      m_buyScore.SetScores(
         m_context.trendBuyScore,
         m_context.momentumBuyScore,
         m_context.signalBuyScore,
         m_context.volatilityScore,
         m_context.spreadScore
      );

      m_sellScore.SetScores(
         m_context.trendSellScore,
         m_context.momentumSellScore,
         m_context.signalSellScore,
         m_context.volatilityScore,
         m_context.spreadScore
      );

      m_snapshot.buyScore =
         m_buyScore.Calculate();

      m_snapshot.sellScore =
         m_sellScore.Calculate();

      m_snapshot.scoreAdvantage =
         MathAbs(
            m_snapshot.buyScore -
            m_snapshot.sellScore
         );
   }

   //+----------------------------------------------------------------+
   //| Calculate confidence                                            |
   //+----------------------------------------------------------------+
   double CalculateConfidence() const
   {
      double bestScore =
         MathMax(
            m_snapshot.buyScore,
            m_snapshot.sellScore
         );

      double advantageComponent =
         SGDPNormalizeScore(
            m_snapshot.scoreAdvantage *
            2.0
         );

      double confidence =
         bestScore *
         0.70 +
         advantageComponent *
         0.30;

      return SGDPNormalizeScore(
         confidence
      );
   }

   //+----------------------------------------------------------------+
   //| Calculate overall decision quality                              |
   //+----------------------------------------------------------------+
   double CalculateQuality() const
   {
      double bestDirectionalScore =
         MathMax(
            m_snapshot.buyScore,
            m_snapshot.sellScore
         );

      double environmentScore =
         (
            m_context.volatilityScore +
            m_context.spreadScore
         ) /
         2.0;

      double quality =
         bestDirectionalScore *
         0.60 +
         m_snapshot.confidence *
         0.25 +
         environmentScore *
         0.15;

      return SGDPNormalizeScore(
         quality
      );
   }

   //+----------------------------------------------------------------+
   //| Block current decision                                          |
   //+----------------------------------------------------------------+
   void SetBlockedDecision(
      const ENUM_DECISION_REASON reasonCode,
      const string reason,
      const bool memoryBlocked = false
   )
   {
      m_snapshot.action =
         DECISION_BLOCK;

      m_snapshot.reasonCode =
         reasonCode;

      m_snapshot.reason =
         reason;

      m_snapshot.memoryBlocked =
         memoryBlocked;

      m_snapshot.valid = true;
   }

   //+----------------------------------------------------------------+
   //| Set WAIT decision                                               |
   //+----------------------------------------------------------------+
   void SetWaitDecision(
      const ENUM_DECISION_REASON reasonCode,
      const string reason
   )
   {
      m_snapshot.action =
         DECISION_WAIT;

      m_snapshot.reasonCode =
         reasonCode;

      m_snapshot.reason =
         reason;

      m_snapshot.memoryBlocked =
         false;

      m_snapshot.valid = true;
   }

   //+----------------------------------------------------------------+
   //| Evaluate final BUY / SELL / WAIT / BLOCK decision              |
   //+----------------------------------------------------------------+
   void EvaluateDecision()
   {
      //==============================================================
      // HARD BLOCKS
      //==============================================================

      if(m_context.marketRegime ==
         MARKET_REGIME_HIGH_VOLATILITY)
      {
         SetBlockedDecision(
            DECISION_REASON_HIGH_VOLATILITY,
            "Decision blocked by high market volatility."
         );

         return;
      }

      if(m_context.spreadScore <= 0.0)
      {
         SetBlockedDecision(
            DECISION_REASON_SPREAD_TOO_HIGH,
            "Decision blocked because spread score is zero."
         );

         return;
      }

      //==============================================================
      // SCORE VALIDATION
      //==============================================================

      double bestScore =
         MathMax(
            m_snapshot.buyScore,
            m_snapshot.sellScore
         );

      if(bestScore <
         m_minimumDecisionScore)
      {
         SetWaitDecision(
            DECISION_REASON_SCORE_TOO_LOW,
            "Best decision score is below minimum threshold."
         );

         return;
      }

      if(m_snapshot.scoreAdvantage <
         m_minimumAdvantage)
      {
         SetWaitDecision(
            DECISION_REASON_ADVANTAGE_TOO_LOW,
            "BUY and SELL score advantage is too low."
         );

         return;
      }

      //==============================================================
      // BUY DECISION
      //==============================================================

      if(m_snapshot.buyScore >
         m_snapshot.sellScore)
      {
         if(m_context.signal != SIGNAL_BUY)
         {
            SetWaitDecision(
               DECISION_REASON_SCORE_TOO_LOW,
               "BUY score is strongest but source signal is not BUY."
            );

            return;
         }

         string memoryReason;

         if(m_memory.IsDecisionBlocked(
               DECISION_BUY,
               m_snapshot.buyScore,
               m_snapshot.sellScore,
               memoryReason
            ))
         {
            SetBlockedDecision(
               DECISION_REASON_MEMORY_BLOCKED,
               memoryReason,
               true
            );

            return;
         }

         m_snapshot.action =
            DECISION_BUY;

         m_snapshot.reasonCode =
            DECISION_REASON_BUY_SCORE_APPROVED;

         m_snapshot.reason =
            "BUY decision approved.";

         m_snapshot.memoryBlocked =
            false;

         m_snapshot.valid = true;

         m_memory.Remember(
            DECISION_BUY,
            m_snapshot.buyScore,
            m_snapshot.sellScore
         );

         return;
      }

      //==============================================================
      // SELL DECISION
      //==============================================================

      if(m_snapshot.sellScore >
         m_snapshot.buyScore)
      {
         if(m_context.signal != SIGNAL_SELL)
         {
            SetWaitDecision(
               DECISION_REASON_SCORE_TOO_LOW,
               "SELL score is strongest but source signal is not SELL."
            );

            return;
         }

         string memoryReason;

         if(m_memory.IsDecisionBlocked(
               DECISION_SELL,
               m_snapshot.buyScore,
               m_snapshot.sellScore,
               memoryReason
            ))
         {
            SetBlockedDecision(
               DECISION_REASON_MEMORY_BLOCKED,
               memoryReason,
               true
            );

            return;
         }

         m_snapshot.action =
            DECISION_SELL;

         m_snapshot.reasonCode =
            DECISION_REASON_SELL_SCORE_APPROVED;

         m_snapshot.reason =
            "SELL decision approved.";

         m_snapshot.memoryBlocked =
            false;

         m_snapshot.valid = true;

         m_memory.Remember(
            DECISION_SELL,
            m_snapshot.buyScore,
            m_snapshot.sellScore
         );

         return;
      }

      SetWaitDecision(
         DECISION_REASON_ADVANTAGE_TOO_LOW,
         "BUY and SELL scores are equal."
      );
   }

public:
   CDecisionEngine()
   {
      m_initialized = false;

      m_minimumDecisionScore =
         70.0;

      m_minimumAdvantage =
         10.0;

      m_context.Reset();
      m_snapshot.Reset();
   }

   //+----------------------------------------------------------------+
   //| Initialize Decision Engine                                      |
   //+----------------------------------------------------------------+
   bool Initialize(
      const double minimumDecisionScore,
      const double minimumAdvantage,
      const int repeatSeconds,
      const double scoreImprovement
   )
   {
      m_minimumDecisionScore =
         SGDPNormalizeScore(
            minimumDecisionScore
         );

      m_minimumAdvantage =
         MathMax(
            0.0,
            minimumAdvantage
         );

      m_memory.Initialize(
         repeatSeconds,
         scoreImprovement
      );

      m_buyScore.Reset();
      m_sellScore.Reset();

      m_context.Reset();
      m_snapshot.Reset();

      m_initialized = true;

      return true;
   }

   //+----------------------------------------------------------------+
   //| Reset Decision Engine                                           |
   //+----------------------------------------------------------------+
   void Reset()
   {
      m_buyScore.Reset();
      m_sellScore.Reset();

      m_memory.Reset();

      m_context.Reset();
      m_snapshot.Reset();
   }

   //+----------------------------------------------------------------+
   //| Evaluate complete Phase 4 Decision                              |
   //+----------------------------------------------------------------+
   bool Evaluate(
      CSignalCoordinator &coordinator
   )
   {
      m_context.Reset();
      m_snapshot.Reset();

      if(!m_initialized)
      {
         SetBlockedDecision(
            DECISION_REASON_SIGNAL_DATA_INVALID,
            "Decision Engine is not initialized."
         );

         return false;
      }

      if(!BuildContext(coordinator))
      {
         SetBlockedDecision(
            DECISION_REASON_SIGNAL_DATA_INVALID,
            "Cannot build a valid Decision Context."
         );

         return false;
      }

      BuildSnapshot();
      CalculateScores();

      m_snapshot.confidence =
         CalculateConfidence();

      m_snapshot.quality =
         CalculateQuality();

      EvaluateDecision();

      return true;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   SDecisionSnapshot Snapshot() const
   {
      return m_snapshot;
   }

   SDecisionContext Context() const
   {
      return m_context;
   }

   ENUM_DECISION_ACTION Action() const
   {
      return m_snapshot.action;
   }

   double BuyScore() const
   {
      return m_snapshot.buyScore;
   }

   double SellScore() const
   {
      return m_snapshot.sellScore;
   }

   double Advantage() const
   {
      return m_snapshot.scoreAdvantage;
   }

   double Confidence() const
   {
      return m_snapshot.confidence;
   }

   double Quality() const
   {
      return m_snapshot.quality;
   }

   string QualityName() const
   {
      return m_snapshot.QualityName();
   }

   string Reason() const
   {
      return m_snapshot.reason;
   }

   ENUM_DECISION_REASON ReasonCode() const
   {
      return m_snapshot.reasonCode;
   }

   bool IsTradeApproved() const
   {
      return m_snapshot.HasTradeDecision();
   }

   bool IsBlocked() const
   {
      return m_snapshot.IsBlocked();
   }

   double MinimumDecisionScore() const
   {
      return m_minimumDecisionScore;
   }

   double MinimumAdvantage() const
   {
      return m_minimumAdvantage;
   }

   CMarketMemory Memory() const
   {
      return m_memory;
   }

   void ResetMemory()
   {
      m_memory.Reset();
   }
};

#endif