#ifndef SMARTGOLDDCAPRO_CONFIG_VALIDATOR_MQH
#define SMARTGOLDDCAPRO_CONFIG_VALIDATOR_MQH

#include <SmartGoldDCAPro/Core/Inputs.mqh>

class CConfigValidator
{
public:
   bool Validate(string &reason) const
   {
      if(InpMagicNumber <= 0)
      {
         reason = "Magic Number must be greater than zero.";
         return false;
      }

      if(InpInitialLot <= 0.0)
      {
         reason = "Initial lot must be greater than zero.";
         return false;
      }

      if(InpMaximumSpreadPoints < 0)
      {
         reason = "Maximum spread cannot be negative.";
         return false;
      }

      if(InpFastEMAPeriod <= 0 || InpSlowEMAPeriod <= 0)
      {
         reason = "EMA periods must be greater than zero.";
         return false;
      }

      if(InpFastEMAPeriod >= InpSlowEMAPeriod)
      {
         reason = "Fast EMA period must be smaller than Slow EMA period.";
         return false;
      }

      if(InpRSIPeriod <= 0 || InpATRPeriod <= 0)
      {
         reason = "RSI and ATR periods must be greater than zero.";
         return false;
      }

      if(InpMaximumDCALevels < 1)
      {
         reason = "Maximum DCA levels must be at least one.";
         return false;
      }

      if(InpEnableDCA && InpDCADistancePoints <= 0.0)
      {
         reason = "DCA distance must be greater than zero.";
         return false;
      }

      if(InpLotMultiplier < 1.0)
      {
         reason = "Lot multiplier must be at least 1.0.";
         return false;
      }

      if(InpMaximumLot < InpInitialLot)
      {
         reason = "Maximum lot cannot be smaller than initial lot.";
         return false;
      }

      if(InpUseAdaptiveGrid)
      {
         if(InpGridATRMultiplier <= 0.0)
         {
            reason = "Grid ATR multiplier must be greater than zero.";
            return false;
         }

         if(InpMinimumGridPoints <= 0.0 ||
            InpMaximumGridPoints < InpMinimumGridPoints)
         {
            reason = "Adaptive grid minimum/maximum values are invalid.";
            return false;
         }
      }

      if(InpMaxEquityDrawdownPercent < 0.0 ||
         InpMaxEquityDrawdownPercent > 100.0)
      {
         reason = "Maximum equity drawdown must be between 0 and 100.";
         return false;
      }

      reason = "OK";
      return true;
   }
};

#endif
