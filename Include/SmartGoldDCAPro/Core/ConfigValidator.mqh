#ifndef SMARTGOLDDCAPRO_CORE_CONFIG_VALIDATOR_MQH
#define SMARTGOLDDCAPRO_CORE_CONFIG_VALIDATOR_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Configuration Validator         |
//+------------------------------------------------------------------+
class CConfigValidator
{
private:
   bool Fail(
      string &reason,
      const string message
   ) const
   {
      reason = message;
      return false;
   }

public:
   bool Validate(
      string &reason
   ) const
   {
      reason = "";

      //==============================================================
      // GENERAL
      //==============================================================

      if(InpMagicNumber <= 0)
      {
         return Fail(
            reason,
            "Magic Number must be greater than zero."
         );
      }

      if(InpTradeComment == "")
      {
         return Fail(
            reason,
            "Trade comment cannot be empty."
         );
      }

      if(InpTradeCooldownSeconds < 0)
      {
         return Fail(
            reason,
            "Trade cooldown cannot be negative."
         );
      }

      //==============================================================
      // EXECUTION
      //==============================================================

      if(InpInitialLot <= 0.0)
      {
         return Fail(
            reason,
            "Initial lot must be greater than zero."
         );
      }

      if(InpMaximumSpreadPoints < 0)
      {
         return Fail(
            reason,
            "Maximum spread cannot be negative."
         );
      }

      if(InpSlippagePoints < 0)
      {
         return Fail(
            reason,
            "Slippage cannot be negative."
         );
      }

      //==============================================================
      // EMA
      //==============================================================

      if(InpUseEMAFilter)
      {
         if(InpFastEMAPeriod <= 0 ||
            InpSlowEMAPeriod <= 0)
         {
            return Fail(
               reason,
               "EMA periods must be greater than zero."
            );
         }

         if(InpFastEMAPeriod >=
            InpSlowEMAPeriod)
         {
            return Fail(
               reason,
               "Fast EMA period must be smaller than Slow EMA period."
            );
         }

         if(InpEMAWeight < 0.0)
         {
            return Fail(
               reason,
               "EMA weight cannot be negative."
            );
         }
      }

      //==============================================================
      // RSI
      //==============================================================

      if(InpUseRSIFilter)
      {
         if(InpRSIPeriod <= 0)
         {
            return Fail(
               reason,
               "RSI period must be greater than zero."
            );
         }

         if(InpRSIBuyMinimum < 0.0 ||
            InpRSIBuyMinimum > 100.0)
         {
            return Fail(
               reason,
               "RSI BUY threshold must be between 0 and 100."
            );
         }

         if(InpRSISellMaximum < 0.0 ||
            InpRSISellMaximum > 100.0)
         {
            return Fail(
               reason,
               "RSI SELL threshold must be between 0 and 100."
            );
         }

         if(InpRSIWeight < 0.0)
         {
            return Fail(
               reason,
               "RSI weight cannot be negative."
            );
         }
      }

      //==============================================================
      // ADX
      //==============================================================

      if(InpUseADXFilter)
      {
         if(InpADXPeriod <= 0)
         {
            return Fail(
               reason,
               "ADX period must be greater than zero."
            );
         }

         if(InpMinimumADX < 0.0 ||
            InpMinimumADX > 100.0)
         {
            return Fail(
               reason,
               "Minimum ADX must be between 0 and 100."
            );
         }

         if(InpADXWeight < 0.0)
         {
            return Fail(
               reason,
               "ADX weight cannot be negative."
            );
         }
      }

      //==============================================================
      // ATR
      //==============================================================

      if(InpATRPeriod <= 0)
      {
         return Fail(
            reason,
            "ATR period must be greater than zero."
         );
      }

      if(InpMinimumATRPoints < 0.0)
      {
         return Fail(
            reason,
            "Minimum ATR points cannot be negative."
         );
      }

      if(InpHighVolatilityATRPoints <= 0.0)
      {
         return Fail(
            reason,
            "High-volatility ATR threshold must be greater than zero."
         );
      }

      //==============================================================
      // WEIGHTED SIGNAL
      //==============================================================

      if(InpUseWeightedSignal)
      {
         if(InpMinimumSignalScore < 0.0 ||
            InpMinimumSignalScore > 100.0)
         {
            return Fail(
               reason,
               "Minimum signal score must be between 0 and 100."
            );
         }

         if(InpMinimumScoreAdvantage < 0.0 ||
            InpMinimumScoreAdvantage > 100.0)
         {
            return Fail(
               reason,
               "Minimum score advantage must be between 0 and 100."
            );
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
            return Fail(
               reason,
               "Weighted Signal requires at least one enabled indicator with a positive weight."
            );
         }
      }

      //==============================================================
      // DCA
      //==============================================================

      if(InpMaximumDCALevels < 1)
      {
         return Fail(
            reason,
            "Maximum DCA levels must be at least one."
         );
      }

      if(InpEnableDCA)
      {
         if(InpDCAControlMode ==
            DCA_CONTROL_FIXED)
         {
            if(InpDCADistancePoints <= 0.0)
            {
               return Fail(
                  reason,
                  "Fixed DCA distance must be greater than zero."
               );
            }
         }

         if(InpDCAControlMode ==
            DCA_CONTROL_ADAPTIVE)
         {
            if(InpGridATRMultiplier <= 0.0)
            {
               return Fail(
                  reason,
                  "Adaptive Grid ATR multiplier must be greater than zero."
               );
            }

            if(InpMinimumGridPoints <= 0.0)
            {
               return Fail(
                  reason,
                  "Minimum grid points must be greater than zero."
               );
            }

            if(InpMaximumGridPoints <
               InpMinimumGridPoints)
            {
               return Fail(
                  reason,
                  "Maximum grid points cannot be smaller than minimum grid points."
               );
            }
         }

         if(InpDCAControlMode ==
            DCA_CONTROL_MANUAL)
         {
            if(InpManualDCADistancePoints <= 0.0)
            {
               return Fail(
                  reason,
                  "Manual DCA distance must be greater than zero."
               );
            }

            if(InpManualDCALot <= 0.0)
            {
               return Fail(
                  reason,
                  "Manual DCA lot must be greater than zero."
               );
            }

            if(InpManualInitialLot <= 0.0)
            {
               return Fail(
                  reason,
                  "Manual initial lot must be greater than zero."
               );
            }
         }
      }

      //==============================================================
      // LOT CONTROL
      //==============================================================

      if(InpLotMultiplier < 1.0)
      {
         return Fail(
            reason,
            "Lot multiplier must be at least 1.0."
         );
      }

      if(InpMaximumLot <= 0.0)
      {
         return Fail(
            reason,
            "Maximum lot must be greater than zero."
         );
      }

      if(InpMaximumLot <
         InpInitialLot)
      {
         return Fail(
            reason,
            "Maximum lot cannot be smaller than initial lot."
         );
      }

      //==============================================================
      // SMART SAFETY
      //==============================================================

      if(InpEnableSmartSafety)
      {
         if(InpSmartSafetyStartOrder < 2)
         {
            return Fail(
               reason,
               "Smart Safety start order must be at least 2."
            );
         }

         if(InpSmartSafetyStartOrder >
            InpMaximumDCALevels)
         {
            return Fail(
               reason,
               "Smart Safety start order cannot exceed maximum DCA levels."
            );
         }
      }

      //==============================================================
      // MARGIN AND RISK
      //==============================================================

      if(InpMinimumMarginLevelPercent < 0.0)
      {
         return Fail(
            reason,
            "Minimum margin level cannot be negative."
         );
      }

      if(InpMinimumFreeMarginMoney < 0.0)
      {
         return Fail(
            reason,
            "Minimum free margin cannot be negative."
         );
      }

      if(InpMaximumRiskScoreForDCA < 0 ||
         InpMaximumRiskScoreForDCA > 100)
      {
         return Fail(
            reason,
            "Maximum DCA Risk Score must be between 0 and 100."
         );
      }

      //==============================================================
      // BASKET EXIT
      //==============================================================

      if(InpBasketTakeProfitMoney < 0.0)
      {
         return Fail(
            reason,
            "Basket Take Profit cannot be negative."
         );
      }

      if(InpBasketStopLossMoney < 0.0)
      {
         return Fail(
            reason,
            "Basket Stop Loss cannot be negative."
         );
      }

      //==============================================================
      // ACCOUNT PROTECTION
      //==============================================================

      if(InpMaxEquityDrawdownPercent < 0.0 ||
         InpMaxEquityDrawdownPercent > 100.0)
      {
         return Fail(
            reason,
            "Maximum equity drawdown must be between 0 and 100."
         );
      }

      if(InpMaxDailyLossMoney < 0.0)
      {
         return Fail(
            reason,
            "Maximum daily loss cannot be negative."
         );
      }

      //==============================================================
      // SESSION FILTER
      //==============================================================

      if(InpSessionStartHour < 0 ||
         InpSessionStartHour > 23)
      {
         return Fail(
            reason,
            "Session start hour must be between 0 and 23."
         );
      }

      if(InpSessionEndHour < 0 ||
         InpSessionEndHour > 23)
      {
         return Fail(
            reason,
            "Session end hour must be between 0 and 23."
         );
      }

      //==============================================================
      // JOURNAL
      //==============================================================

      if(InpEnableTradeJournal &&
         InpTradeJournalFile == "")
      {
         return Fail(
            reason,
            "Trade Journal filename cannot be empty when Journal is enabled."
         );
      }

      reason = "Configuration is valid.";
      return true;
   }
};

#endif