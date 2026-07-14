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

      if(InpTradeCooldownSeconds < 0)
      {
         reason = "Trade cooldown cannot be negative.";
         return false;
      }

      if(InpMaximumSpreadPoints < 0 || InpSlippagePoints < 0)
      {
         reason = "Spread and slippage values cannot be negative.";
         return false;
      }

      if(InpUseEMAFilter)
      {
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
      }

      if(InpUseRSIFilter)
      {
         if(InpRSIPeriod <= 0)
         {
            reason = "RSI period must be greater than zero.";
            return false;
         }

         if(InpRSIBuyMinimum < 0.0 || InpRSIBuyMinimum > 100.0 ||
            InpRSISellMaximum < 0.0 || InpRSISellMaximum > 100.0)
         {
            reason = "RSI thresholds must be between 0 and 100.";
            return false;
         }
      }

      if(InpUseADXFilter)
      {
         if(InpADXPeriod <= 0)
         {
            reason = "ADX period must be greater than zero.";
            return false;
         }

         if(InpMinimumADX < 0.0 || InpMinimumADX > 100.0)
         {
            reason = "Minimum ADX must be between 0 and 100.";
            return false;
         }
      }

      if(InpATRPeriod <= 0)
      {
         reason = "ATR period must be greater than zero.";
         return false;
      }

      if(InpUseATRFilter && InpMinimumATRPoints < 0.0)
      {
         reason = "Minimum ATR points cannot be negative.";
         return false;
      }

      if(InpDirectionMode == DIRECTION_AUTO &&
         !InpUseEMAFilter &&
         !InpUseRSIFilter &&
         !InpUseADXFilter)
      {
         reason = "AUTO direction requires at least one directional indicator.";
         return false;
      }

      if(InpUseWeightedSignal)
      {
         if(InpMinimumSignalScore < 0.0 || InpMinimumSignalScore > 100.0)
         {
            reason = "Minimum signal score must be between 0 and 100.";
            return false;
         }

         if(InpMinimumScoreAdvantage < 0.0 || InpMinimumScoreAdvantage > 100.0)
         {
            reason = "Minimum score advantage must be between 0 and 100.";
            return false;
         }

         if(InpEMAWeight < 0.0 || InpRSIWeight < 0.0 || InpADXWeight < 0.0)
         {
            reason = "Indicator weights cannot be negative.";
            return false;
         }

         double enabledWeight = 0.0;

         if(InpUseEMAFilter)
            enabledWeight += InpEMAWeight;

         if(InpUseRSIFilter)
            enabledWeight += InpRSIWeight;

         if(InpUseADXFilter)
            enabledWeight += InpADXWeight;

         if(enabledWeight <= 0.0)
         {
            reason = "Weighted signal requires a positive enabled indicator weight.";
            return false;
         }
      }

      if(InpMaximumDCALevels < 1)
      {
         reason = "Maximum DCA levels must be at least one.";
         return false;
      }

      if(InpDCAControlMode == DCA_CONTROL_SMART)
      {
         if(InpInitialLot <= 0.0 || InpMaximumLot <= 0.0)
         {
            reason = "Smart mode lot values must be greater than zero.";
            return false;
         }

         if(InpMaximumLot < InpInitialLot)
         {
            reason = "Maximum lot cannot be smaller than initial lot.";
            return false;
         }

         if(InpLotMultiplier < 1.0)
         {
            reason = "Lot multiplier must be at least 1.0.";
            return false;
         }

         if(!InpUseAdaptiveGrid && InpDCADistancePoints <= 0.0)
         {
            reason = "Fixed DCA distance must be greater than zero.";
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
      }
      else
      {
         if(InpManualInitialLot <= 0.0 ||
            InpManualDCALot <= 0.0 ||
            InpManualDCADistancePoints <= 0.0)
         {
            reason = "Manual mode lot and DCA distance must be greater than zero.";
            return false;
         }
      }

      if(InpEnableSmartSafety)
      {
         if(InpSmartSafetyStartOrder < 2)
         {
            reason = "Smart safety start order must be at least 2.";
            return false;
         }

         if(InpSmartSafetyStartOrder > InpMaximumDCALevels)
         {
            reason = "Smart safety start order cannot exceed maximum DCA levels.";
            return false;
         }
      }

      if(InpMinimumMarginLevelPercent < 0.0)
      {
         reason = "Minimum margin level cannot be negative.";
         return false;
      }

      if(InpMinimumFreeMarginMoney < 0.0)
      {
         reason = "Minimum free margin cannot be negative.";
         return false;
      }

      if(InpMaximumRiskScoreForDCA < 0 ||
         InpMaximumRiskScoreForDCA > 100)
      {
         reason = "Maximum DCA risk score must be between 0 and 100.";
         return false;
      }

      if(InpMaxEquityDrawdownPercent < 0.0 ||
         InpMaxEquityDrawdownPercent > 100.0)
      {
         reason = "Maximum equity drawdown must be between 0 and 100.";
         return false;
      }

      if(InpSessionStartHour < 0 || InpSessionStartHour > 23 ||
         InpSessionEndHour < 0 || InpSessionEndHour > 23)
      {
         reason = "Session hours must be between 0 and 23.";
         return false;
      }

      if(InpMaxDailyLossMoney < 0.0)
      {
         reason = "Maximum daily loss cannot be negative.";
         return false;
      }

      reason = "OK";
      return true;
   }
};

#endif
