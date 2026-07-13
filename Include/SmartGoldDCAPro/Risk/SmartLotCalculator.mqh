#ifndef SMARTGOLDDCAPRO_SMART_LOT_CALCULATOR_MQH
#define SMARTGOLDDCAPRO_SMART_LOT_CALCULATOR_MQH

#include <SmartGoldDCAPro/Core/RiskManager.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Smart Lot Calculator v2                        |
//+------------------------------------------------------------------+
class CSmartLotCalculator
{
private:
   CRiskManager *m_risk;

   // Reduce lot growth when equity is below balance.
   double GetEquityFactor() const
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

      if(balance <= 0.0)
         return 0.50;

      double factor = equity / balance;

      // Do not increase lot due to equity factor.
      factor = MathMin(factor, 1.0);

      // Never reduce below 50% only from this factor.
      factor = MathMax(factor, 0.50);

      return factor;
   }

   // Reduce lot growth as drawdown becomes larger.
   double GetDrawdownMultiplier(const double requestedMultiplier,
                                const double drawdownPercent) const
   {
      double multiplier = MathMax(1.0, requestedMultiplier);

      if(drawdownPercent >= 15.0)
         return 1.00;

      if(drawdownPercent >= 10.0)
         return MathMin(multiplier, 1.05);

      if(drawdownPercent >= 5.0)
         return MathMin(multiplier, 1.15);

      return multiplier;
   }

   // Reduce lot when margin level becomes unsafe.
   double GetMarginFactor() const
   {
      double marginLevel =
         AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

      // No margin is currently used.
      if(marginLevel <= 0.0)
         return 1.0;

      if(marginLevel < 150.0)
         return 0.0;

      if(marginLevel < 200.0)
         return 0.50;

      if(marginLevel < 300.0)
         return 0.75;

      return 1.0;
   }

public:
   CSmartLotCalculator()
   {
      m_risk = NULL;
   }

   void Initialize(CRiskManager &risk)
   {
      m_risk = &risk;
   }

   // Main lot calculation used by the DCA engine.
   double CalculateNextLot(const double previousLot,
                           const double requestedMultiplier,
                           const double maximumLot,
                           const double drawdownPercent) const
   {
      if(m_risk == NULL)
         return 0.0;

      if(previousLot <= 0.0 || maximumLot <= 0.0)
         return 0.0;

      double multiplier =
         GetDrawdownMultiplier(
            requestedMultiplier,
            drawdownPercent
         );

      double marginFactor = GetMarginFactor();

      // Margin is too dangerous: block next DCA.
      if(marginFactor <= 0.0)
         return 0.0;

      double equityFactor = GetEquityFactor();

      double nextLot =
         previousLot *
         multiplier *
         equityFactor *
         marginFactor;

      // Never make the next DCA lot smaller than the previous lot.
      // Risk control is achieved by reducing the multiplier toward 1.0.
      nextLot = MathMax(previousLot, nextLot);

      nextLot = MathMin(nextLot, maximumLot);

      return m_risk.NormalizeLot(nextLot);
   }

   // Check margin conditions before opening a new order.
   bool IsMarginSafe(const double minimumMarginLevelPercent,
                     const double minimumFreeMarginMoney,
                     string &reason) const
   {
      double marginLevel =
         AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

      double freeMargin =
         AccountInfoDouble(ACCOUNT_MARGIN_FREE);

      if(minimumFreeMarginMoney > 0.0 &&
         freeMargin < minimumFreeMarginMoney)
      {
         reason =
            "Free margin is too low. Current=" +
            DoubleToString(freeMargin, 2);

         return false;
      }

      // A value of zero may mean no margin is currently used.
      if(marginLevel > 0.0 &&
         minimumMarginLevelPercent > 0.0 &&
         marginLevel < minimumMarginLevelPercent)
      {
         reason =
            "Margin level is too low. Current=" +
            DoubleToString(marginLevel, 2) +
            "%";

         return false;
      }

      reason = "Margin conditions are valid.";
      return true;
   }

   // Risk score: 0 = safe, 100 = extreme danger.
   int CalculateRiskScore(const int openPositions,
                          const int spreadPoints,
                          const double atrPoints,
                          const int maximumSpreadPoints,
                          const double highVolatilityATRPoints) const
   {
      double score = 0.0;

      double drawdown = 0.0;

      if(m_risk != NULL)
         drawdown = m_risk.CurrentDrawdownPercent();

      // Drawdown contributes up to 40 points.
      score += MathMin(40.0, drawdown * 2.0);

      // Number of open positions contributes up to 20 points.
      score += MathMin(20.0, openPositions * 4.0);

      // Spread contributes up to 20 points.
      if(maximumSpreadPoints > 0)
      {
         double spreadRatio =
            (double)spreadPoints /
            (double)maximumSpreadPoints;

         score += MathMin(20.0, spreadRatio * 20.0);
      }

      // ATR volatility contributes up to 20 points.
      if(highVolatilityATRPoints > 0.0)
      {
         double atrRatio =
            atrPoints /
            highVolatilityATRPoints;

         score += MathMin(20.0, atrRatio * 20.0);
      }

      score = MathMax(0.0, MathMin(100.0, score));

      return (int)MathRound(score);
   }

   double GetCurrentMarginLevel() const
   {
      return AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   }

   double GetCurrentFreeMargin() const
   {
      return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   }
};

#endif