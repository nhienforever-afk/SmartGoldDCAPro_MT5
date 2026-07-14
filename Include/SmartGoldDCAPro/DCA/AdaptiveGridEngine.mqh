#ifndef SMARTGOLDDCAPRO_ADAPTIVE_GRID_ENGINE_MQH
#define SMARTGOLDDCAPRO_ADAPTIVE_GRID_ENGINE_MQH

#include <SmartGoldDCAPro/Market/MarketState.mqh>

class CAdaptiveGridEngine
{
private:
   bool   m_enabled;
   double m_fixedDistancePoints;
   double m_atrMultiplier;
   double m_minimumGridPoints;
   double m_maximumGridPoints;

public:
   CAdaptiveGridEngine()
   {
      m_enabled             = true;
      m_fixedDistancePoints = 500.0;
      m_atrMultiplier       = 1.50;
      m_minimumGridPoints   = 200.0;
      m_maximumGridPoints   = 1200.0;
   }

   void Initialize(const bool enabled,
                   const double fixedDistancePoints,
                   const double atrMultiplier,
                   const double minimumGridPoints,
                   const double maximumGridPoints)
   {
      m_enabled             = enabled;
      m_fixedDistancePoints = MathMax(1.0, fixedDistancePoints);
      m_atrMultiplier       = MathMax(0.01, atrMultiplier);
      m_minimumGridPoints   = MathMax(1.0, minimumGridPoints);
      m_maximumGridPoints   = MathMax(m_minimumGridPoints, maximumGridPoints);
   }

   double Calculate(const SMarketState &state) const
   {
      if(!m_enabled || !state.valid || state.atrPoints <= 0.0)
         return m_fixedDistancePoints;

      double distance = state.atrPoints * m_atrMultiplier;
      distance = MathMax(m_minimumGridPoints, distance);
      distance = MathMin(m_maximumGridPoints, distance);

      return distance;
   }
};

#endif
