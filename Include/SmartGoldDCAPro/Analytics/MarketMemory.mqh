#ifndef SMARTGOLDDCAPRO_ANALYTICS_MARKET_MEMORY_MQH
#define SMARTGOLDDCAPRO_ANALYTICS_MARKET_MEMORY_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Market Memory                   |
//| Ghi nhớ quyết định gần nhất và hạn chế lặp tín hiệu quá nhanh     |
//+------------------------------------------------------------------+
class CMarketMemory
{
private:
   ENUM_DECISION_ACTION m_lastAction;
   datetime             m_lastDecisionTime;

   int    m_minimumRepeatSeconds;
   double m_minimumScoreImprovement;

   double m_lastBuyScore;
   double m_lastSellScore;

   bool   m_hasMemory;
   string m_lastReason;

public:
   CMarketMemory()
   {
      m_lastAction       = DECISION_WAIT;
      m_lastDecisionTime = 0;

      m_minimumRepeatSeconds   = 20;
      m_minimumScoreImprovement = 5.0;

      m_lastBuyScore  = 0.0;
      m_lastSellScore = 0.0;

      m_hasMemory = false;
      m_lastReason = "No market memory.";
   }

   void Initialize(
      const int minimumRepeatSeconds,
      const double minimumScoreImprovement
   )
   {
      m_minimumRepeatSeconds =
         MathMax(
            0,
            minimumRepeatSeconds
         );

      m_minimumScoreImprovement =
         MathMax(
            0.0,
            minimumScoreImprovement
         );

      Reset();
   }

   void Reset()
   {
      m_lastAction       = DECISION_WAIT;
      m_lastDecisionTime = 0;

      m_lastBuyScore  = 0.0;
      m_lastSellScore = 0.0;

      m_hasMemory  = false;
      m_lastReason = "Market memory reset.";
   }

   bool HasMemory() const
   {
      return m_hasMemory;
   }

   ENUM_DECISION_ACTION LastAction() const
   {
      return m_lastAction;
   }

   datetime LastDecisionTime() const
   {
      return m_lastDecisionTime;
   }

   int SecondsSinceLastDecision() const
   {
      if(!m_hasMemory ||
         m_lastDecisionTime <= 0)
      {
         return 0;
      }

      return (int)(
         TimeCurrent() -
         m_lastDecisionTime
      );
   }

   double LastBuyScore() const
   {
      return m_lastBuyScore;
   }

   double LastSellScore() const
   {
      return m_lastSellScore;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   // Kiểm tra quyết định mới có bị chặn vì lặp lại quá nhanh không.
   bool IsDecisionBlocked(
      const ENUM_DECISION_ACTION newAction,
      const double newBuyScore,
      const double newSellScore,
      string &reason
   )
   {
      reason       = "";
      m_lastReason = "";

      if(!m_hasMemory)
         return false;

      if(newAction != m_lastAction)
         return false;

      if(newAction != DECISION_BUY &&
         newAction != DECISION_SELL)
      {
         return false;
      }

      int elapsedSeconds =
         SecondsSinceLastDecision();

      if(elapsedSeconds >=
         m_minimumRepeatSeconds)
      {
         return false;
      }

      double previousScore = 0.0;
      double currentScore  = 0.0;

      if(newAction == DECISION_BUY)
      {
         previousScore = m_lastBuyScore;
         currentScore  = newBuyScore;
      }
      else
      {
         previousScore = m_lastSellScore;
         currentScore  = newSellScore;
      }

      double scoreImprovement =
         currentScore -
         previousScore;

      if(scoreImprovement >=
         m_minimumScoreImprovement)
      {
         return false;
      }

      reason =
         "Repeated " +
         SGDPDecisionActionName(newAction) +
         " decision blocked. Elapsed=" +
         IntegerToString(elapsedSeconds) +
         "s, score improvement=" +
         DoubleToString(
            scoreImprovement,
            2
         );

      m_lastReason = reason;
      return true;
   }

   // Ghi nhớ quyết định vừa được chấp thuận.
   void Remember(
      const ENUM_DECISION_ACTION action,
      const double buyScore,
      const double sellScore
   )
   {
      m_lastAction =
         action;

      m_lastBuyScore =
         SGDPNormalizeScore(
            buyScore
         );

      m_lastSellScore =
         SGDPNormalizeScore(
            sellScore
         );

      m_lastDecisionTime =
         TimeCurrent();

      m_hasMemory =
         action == DECISION_BUY ||
         action == DECISION_SELL;

      m_lastReason =
         "Remembered " +
         SGDPDecisionActionName(action) +
         " decision.";
   }

   void Forget()
   {
      Reset();
   }

   int MinimumRepeatSeconds() const
   {
      return m_minimumRepeatSeconds;
   }

   double MinimumScoreImprovement() const
   {
      return m_minimumScoreImprovement;
   }
};

#endif