#ifndef SMARTGOLDDCAPRO_SMART_LOT_CALCULATOR_MQH
#define SMARTGOLDDCAPRO_SMART_LOT_CALCULATOR_MQH

#include <SmartGoldDCAPro/Core/RiskManager.mqh>

class CSmartLotCalculator
{
private:
   CRiskManager *m_risk;

public:
   CSmartLotCalculator()
   {
      m_risk = NULL;
   }

   void Initialize(CRiskManager &risk)
   {
      m_risk = &risk;
   }

   double CalculateNextLot(const double previousLot,
                           const double multiplier,
                           const double maximumLot,
                           const double drawdownPercent) const
   {
      if(m_risk == NULL)
         return 0.0;

      double effectiveMultiplier = MathMax(1.0, multiplier);

      if(drawdownPercent >= 10.0)
         effectiveMultiplier = MathMin(effectiveMultiplier, 1.05);
      else if(drawdownPercent >= 5.0)
         effectiveMultiplier = MathMin(effectiveMultiplier, 1.15);

      double lot = previousLot * effectiveMultiplier;
      lot = MathMin(lot, maximumLot);

      return m_risk.NormalizeLot(lot);
   }
};

#endif
