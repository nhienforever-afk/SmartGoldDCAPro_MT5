#ifndef SMARTGOLDDCAPRO_SMART_LOT_CALCULATOR_MQH
#define SMARTGOLDDCAPRO_SMART_LOT_CALCULATOR_MQH

#include <SmartGoldDCAPro/Core/RiskManager.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Smart Lot Calculator                           |
//+------------------------------------------------------------------+
class CSmartLotCalculator
{
private:
   CRiskManager *m_risk;

   double NormalizeLotForSymbol(
      const string symbol,
      const double lot
   ) const
   {
      double minimumLot =
         SymbolInfoDouble(
            symbol,
            SYMBOL_VOLUME_MIN
         );

      double maximumLot =
         SymbolInfoDouble(
            symbol,
            SYMBOL_VOLUME_MAX
         );

      double lotStep =
         SymbolInfoDouble(
            symbol,
            SYMBOL_VOLUME_STEP
         );

      if(minimumLot <= 0.0 ||
         maximumLot <= 0.0 ||
         lotStep <= 0.0)
      {
         return 0.0;
      }

      double normalizedLot =
         MathFloor(
            lot / lotStep
         ) * lotStep;

      normalizedLot =
         MathMax(
            minimumLot,
            normalizedLot
         );

      normalizedLot =
         MathMin(
            maximumLot,
            normalizedLot
         );

      int volumeDigits = 2;

      if(lotStep == 1.0)
         volumeDigits = 0;
      else if(lotStep == 0.1)
         volumeDigits = 1;
      else if(lotStep == 0.01)
         volumeDigits = 2;
      else if(lotStep == 0.001)
         volumeDigits = 3;

      return NormalizeDouble(
         normalizedLot,
         volumeDigits
      );
   }

   double DrawdownFactor() const
   {
      if(m_risk == NULL)
         return 1.0;

      double drawdown =
         m_risk.EquityDrawdownPercent();

      if(drawdown >= 20.0)
         return 0.50;

      if(drawdown >= 15.0)
         return 0.65;

      if(drawdown >= 10.0)
         return 0.80;

      if(drawdown >= 5.0)
         return 0.90;

      return 1.0;
   }

   double MarginFactor() const
   {
      if(m_risk == NULL)
         return 1.0;

      double usage =
         m_risk.MarginUsagePercent();

      if(usage >= 80.0)
         return 0.0;

      if(usage >= 70.0)
         return 0.50;

      if(usage >= 60.0)
         return 0.70;

      if(usage >= 50.0)
         return 0.85;

      return 1.0;
   }

public:
   CSmartLotCalculator()
   {
      m_risk = NULL;
   }

   void Initialize(
      CRiskManager &risk
   )
   {
      m_risk = &risk;
   }

   double CalculateNextLot(
      const string symbol,
      const double previousLot,
      const double multiplier,
      const double maximumLot
   ) const
   {
      if(previousLot <= 0.0 ||
         multiplier <= 0.0 ||
         maximumLot <= 0.0)
      {
         return 0.0;
      }

      double marginFactor =
         MarginFactor();

      if(marginFactor <= 0.0)
         return 0.0;

      double nextLot =
         previousLot *
         multiplier *
         DrawdownFactor() *
         marginFactor;

      nextLot =
         MathMin(
            nextLot,
            maximumLot
         );

      return NormalizeLotForSymbol(
         symbol,
         nextLot
      );
   }

   double NormalizeLot(
      const string symbol,
      const double lot
   ) const
   {
      return NormalizeLotForSymbol(
         symbol,
         lot
      );
   }

   bool IsMarginSafe(
      const double minimumMarginLevelPercent,
      const double minimumFreeMarginMoney,
      string &reason
   ) const
   {
      double freeMargin =
         AccountInfoDouble(
            ACCOUNT_MARGIN_FREE
         );

      double marginLevel =
         AccountInfoDouble(
            ACCOUNT_MARGIN_LEVEL
         );

      if(minimumFreeMarginMoney > 0.0 &&
         freeMargin <
         minimumFreeMarginMoney)
      {
         reason =
            "Free margin is too low: " +
            DoubleToString(
               freeMargin,
               2
            );

         return false;
      }

      if(minimumMarginLevelPercent > 0.0 &&
         marginLevel > 0.0 &&
         marginLevel <
         minimumMarginLevelPercent)
      {
         reason =
            "Margin level is too low: " +
            DoubleToString(
               marginLevel,
               2
            ) +
            "%";

         return false;
      }

      reason = "Margin conditions are valid.";
      return true;
   }

   int CalculateRiskScore(
      const int openPositions,
      const int spreadPoints,
      const double atrPoints,
      const int maximumSpreadPoints,
      const double highVolatilityATRPoints
   ) const
   {
      double score = 0.0;

      if(m_risk != NULL)
      {
         score +=
            MathMin(
               40.0,
               m_risk.EquityDrawdownPercent() *
               2.0
            );

         score +=
            MathMin(
               20.0,
               m_risk.MarginUsagePercent() *
               0.25
            );
      }

      score +=
         MathMin(
            20.0,
            openPositions *
            4.0
         );

      if(maximumSpreadPoints > 0)
      {
         score +=
            MathMin(
               10.0,
               (
                  (double)spreadPoints /
                  (double)maximumSpreadPoints
               ) *
               10.0
            );
      }

      if(highVolatilityATRPoints > 0.0)
      {
         score +=
            MathMin(
               10.0,
               (
                  atrPoints /
                  highVolatilityATRPoints
               ) *
               10.0
            );
      }

      score =
         MathMax(
            0.0,
            MathMin(
               100.0,
               score
            )
         );

      return (int)MathRound(score);
   }

   double CurrentMarginLevel() const
   {
      return AccountInfoDouble(
         ACCOUNT_MARGIN_LEVEL
      );
   }

   double CurrentFreeMargin() const
   {
      return AccountInfoDouble(
         ACCOUNT_MARGIN_FREE
      );
   }
};

#endif