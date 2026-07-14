#ifndef SMARTGOLDDCAPRO_DECISION_SCORE_MQH
#define SMARTGOLDDCAPRO_DECISION_SCORE_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Decision Score                                 |
//| Tổng hợp các điểm phân tích thành một điểm quyết định 0-100      |
//+------------------------------------------------------------------+
class CDecisionScore
{
private:
   double m_trendScore;
   double m_momentumScore;
   double m_volumeScore;
   double m_volatilityScore;
   double m_spreadScore;

   double m_trendWeight;
   double m_momentumWeight;
   double m_volumeWeight;
   double m_volatilityWeight;
   double m_spreadWeight;

   double NormalizeScore(const double value) const
   {
      if(value < 0.0)
         return 0.0;

      if(value > 100.0)
         return 100.0;

      return value;
   }

   double NormalizeWeight(const double value) const
   {
      if(value < 0.0)
         return 0.0;

      return value;
   }

public:
   CDecisionScore()
   {
      Reset();

      // Trọng số mặc định.
      m_trendWeight      = 35.0;
      m_momentumWeight   = 25.0;
      m_volumeWeight     = 10.0;
      m_volatilityWeight = 20.0;
      m_spreadWeight     = 10.0;
   }

   void Reset()
   {
      m_trendScore      = 0.0;
      m_momentumScore   = 0.0;
      m_volumeScore     = 0.0;
      m_volatilityScore = 0.0;
      m_spreadScore     = 0.0;
   }

   void SetWeights(
      const double trendWeight,
      const double momentumWeight,
      const double volumeWeight,
      const double volatilityWeight,
      const double spreadWeight
   )
   {
      m_trendWeight =
         NormalizeWeight(trendWeight);

      m_momentumWeight =
         NormalizeWeight(momentumWeight);

      m_volumeWeight =
         NormalizeWeight(volumeWeight);

      m_volatilityWeight =
         NormalizeWeight(volatilityWeight);

      m_spreadWeight =
         NormalizeWeight(spreadWeight);
   }

   void SetScores(
      const double trendScore,
      const double momentumScore,
      const double volumeScore,
      const double volatilityScore,
      const double spreadScore
   )
   {
      m_trendScore =
         NormalizeScore(trendScore);

      m_momentumScore =
         NormalizeScore(momentumScore);

      m_volumeScore =
         NormalizeScore(volumeScore);

      m_volatilityScore =
         NormalizeScore(volatilityScore);

      m_spreadScore =
         NormalizeScore(spreadScore);
   }

   double Total() const
   {
      double totalWeight =
         m_trendWeight +
         m_momentumWeight +
         m_volumeWeight +
         m_volatilityWeight +
         m_spreadWeight;

      if(totalWeight <= 0.0)
         return 0.0;

      double weightedScore =
         m_trendScore *
            m_trendWeight +
         m_momentumScore *
            m_momentumWeight +
         m_volumeScore *
            m_volumeWeight +
         m_volatilityScore *
            m_volatilityWeight +
         m_spreadScore *
            m_spreadWeight;

      return NormalizeScore(
         weightedScore / totalWeight
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

   double VolumeScore() const
   {
      return m_volumeScore;
   }

   double VolatilityScore() const
   {
      return m_volatilityScore;
   }

   double SpreadScore() const
   {
      return m_spreadScore;
   }

   string QualityName() const
   {
      double score = Total();

      if(score >= 85.0)
         return "EXCELLENT";

      if(score >= 70.0)
         return "GOOD";

      if(score >= 55.0)
         return "NORMAL";

      if(score >= 40.0)
         return "WEAK";

      return "BAD";
   }

   bool IsApproved(
      const double minimumScore
   ) const
   {
      return Total() >=
             NormalizeScore(minimumScore);
   }
};

#endif