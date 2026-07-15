#ifndef SMARTGOLDDCAPRO_DECISION_SCORE_MQH
#define SMARTGOLDDCAPRO_DECISION_SCORE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Decision Score                  |
//+------------------------------------------------------------------+
class CDecisionScore
{
private:
   double m_trendScore;
   double m_momentumScore;
   double m_signalScore;
   double m_volatilityScore;
   double m_spreadScore;

   double m_trendWeight;
   double m_momentumWeight;
   double m_signalWeight;
   double m_volatilityWeight;
   double m_spreadWeight;

public:
   CDecisionScore()
   {
      Reset();

      SetWeights(
         30.0,
         20.0,
         30.0,
         10.0,
         10.0
      );
   }

   void Reset()
   {
      m_trendScore      = 0.0;
      m_momentumScore   = 0.0;
      m_signalScore     = 0.0;
      m_volatilityScore = 0.0;
      m_spreadScore     = 0.0;
   }

   void SetWeights(
      const double trendWeight,
      const double momentumWeight,
      const double signalWeight,
      const double volatilityWeight,
      const double spreadWeight
   )
   {
      m_trendWeight =
         MathMax(
            0.0,
            trendWeight
         );

      m_momentumWeight =
         MathMax(
            0.0,
            momentumWeight
         );

      m_signalWeight =
         MathMax(
            0.0,
            signalWeight
         );

      m_volatilityWeight =
         MathMax(
            0.0,
            volatilityWeight
         );

      m_spreadWeight =
         MathMax(
            0.0,
            spreadWeight
         );
   }

   void SetScores(
      const double trendScore,
      const double momentumScore,
      const double signalScore,
      const double volatilityScore,
      const double spreadScore
   )
   {
      m_trendScore =
         SGDPNormalizeScore(
            trendScore
         );

      m_momentumScore =
         SGDPNormalizeScore(
            momentumScore
         );

      m_signalScore =
         SGDPNormalizeScore(
            signalScore
         );

      m_volatilityScore =
         SGDPNormalizeScore(
            volatilityScore
         );

      m_spreadScore =
         SGDPNormalizeScore(
            spreadScore
         );
   }

   double TotalWeight() const
   {
      return
         m_trendWeight +
         m_momentumWeight +
         m_signalWeight +
         m_volatilityWeight +
         m_spreadWeight;
   }

   double Calculate() const
   {
      double totalWeight =
         TotalWeight();

      if(totalWeight <= 0.0)
         return 0.0;

      double weightedScore =
         m_trendScore *
         m_trendWeight +
         m_momentumScore *
         m_momentumWeight +
         m_signalScore *
         m_signalWeight +
         m_volatilityScore *
         m_volatilityWeight +
         m_spreadScore *
         m_spreadWeight;

      return SGDPNormalizeScore(
         weightedScore /
         totalWeight
      );
   }

   double TrendScore() const
   {
      return m_trendScore;
   }

   double MomentumScore() const
   {
      return m_momentumScore;
   }

   double SignalScore() const
   {
      return m_signalScore;
   }

   double VolatilityScore() const
   {
      return m_volatilityScore;
   }

   double SpreadScore() const
   {
      return m_spreadScore;
   }

   double TrendWeight() const
   {
      return m_trendWeight;
   }

   double MomentumWeight() const
   {
      return m_momentumWeight;
   }

   double SignalWeight() const
   {
      return m_signalWeight;
   }

   double VolatilityWeight() const
   {
      return m_volatilityWeight;
   }

   double SpreadWeight() const
   {
      return m_spreadWeight;
   }
};

#endif