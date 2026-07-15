#ifndef SMARTGOLDDCAPRO_RISK_SMART_LOT_CALCULATOR_MQH
#define SMARTGOLDDCAPRO_RISK_SMART_LOT_CALCULATOR_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Smart Lot Calculator            |
//| Tính lot theo multiplier, drawdown và điều kiện margin           |
//+------------------------------------------------------------------+
class CSmartLotCalculator
{
private:
   CRiskManager *m_risk;

   // Hệ số giảm lot theo drawdown.
   double DrawdownFactor(
      const double drawdownPercent
   ) const
   {
      if(drawdownPercent >= 20.0)
         return 0.40;

      if(drawdownPercent >= 15.0)
         return 0.55;

      if(drawdownPercent >= 10.0)
         return 0.70;

      if(drawdownPercent >= 5.0)
         return 0.85;

      return 1.0;
   }

   // Hệ số giảm lot theo mức sử dụng margin.
   double MarginFactor() const
   {
      if(m_risk == NULL)
         return 1.0;

      double marginUsage =
         m_risk.MarginUsagePercent();

      if(marginUsage >= 80.0)
         return 0.0;

      if(marginUsage >= 70.0)
         return 0.40;

      if(marginUsage >= 60.0)
         return 0.60;

      if(marginUsage >= 50.0)
         return 0.80;

      return 1.0;
   }

public:
   CSmartLotCalculator()
   {
      m_risk = NULL;
   }

   // Kết nối Risk Manager.
   void Initialize(
      CRiskManager &risk
   )
   {
      m_risk = &risk;
   }

   bool IsInitialized() const
   {
      return m_risk != NULL;
   }

   // Chuẩn hóa lot bằng Risk Manager.
   double NormalizeLot(
      const double lot
   ) const
   {
      if(m_risk == NULL)
         return 0.0;

      return m_risk.NormalizeLot(lot);
   }

   // Tính lot kế tiếp theo drawdown được truyền vào.
   double CalculateNextLot(
      const double previousLot,
      const double multiplier,
      const double maximumLot,
      const double drawdownPercent
   ) const
   {
      if(m_risk == NULL)
         return 0.0;

      if(previousLot <= 0.0)
         return 0.0;

      if(multiplier <= 0.0)
         return 0.0;

      if(maximumLot <= 0.0)
         return 0.0;

      double marginFactor =
         MarginFactor();

      if(marginFactor <= 0.0)
         return 0.0;

      double nextLot =
         previousLot *
         multiplier *
         DrawdownFactor(drawdownPercent) *
         marginFactor;

      nextLot =
         MathMin(
            nextLot,
            maximumLot
         );

      return m_risk.NormalizeLot(
         nextLot
      );
   }

   // Phiên bản tự lấy drawdown từ Risk Manager.
   double CalculateNextLot(
      const double previousLot,
      const double multiplier,
      const double maximumLot
   ) const
   {
      if(m_risk == NULL)
         return 0.0;

      return CalculateNextLot(
         previousLot,
         multiplier,
         maximumLot,
         m_risk.CurrentDrawdownPercent()
      );
   }

   // Tính lot cố định nhưng vẫn chuẩn hóa theo symbol.
   double CalculateFixedLot(
      const double requestedLot,
      const double maximumLot
   ) const
   {
      if(m_risk == NULL)
         return 0.0;

      if(requestedLot <= 0.0 ||
         maximumLot <= 0.0)
      {
         return 0.0;
      }

      double lot =
         MathMin(
            requestedLot,
            maximumLot
         );

      return m_risk.NormalizeLot(lot);
   }

   // Kiểm tra margin trước khi cho phép DCA.
   bool IsMarginSafe(
      const double minimumMarginLevelPercent,
      const double minimumFreeMarginMoney,
      string &reason
   ) const
   {
      reason = "";

      if(m_risk == NULL)
      {
         reason =
            "Smart Lot Calculator is not initialized.";

         return false;
      }

      double freeMargin =
         m_risk.FreeMargin();

      double marginLevel =
         m_risk.MarginLevel();

      if(minimumFreeMarginMoney > 0.0 &&
         freeMargin <
         minimumFreeMarginMoney)
      {
         reason =
            "Free margin is too low. Current=" +
            DoubleToString(
               freeMargin,
               2
            ) +
            ", minimum=" +
            DoubleToString(
               minimumFreeMarginMoney,
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
            "Margin level is too low. Current=" +
            DoubleToString(
               marginLevel,
               2
            ) +
            "%, minimum=" +
            DoubleToString(
               minimumMarginLevelPercent,
               2
            ) +
            "%";

         return false;
      }

      reason =
         "Margin conditions are valid.";

      return true;
   }

   // Tính Risk Score trong khoảng 0–100.
   int CalculateRiskScore(
      const int openPositions,
      const int spreadPoints,
      const double atrPoints,
      const int maximumSpreadPoints,
      const double highVolatilityATRPoints
   ) const
   {
      double riskScore = 0.0;

      // Drawdown tối đa đóng góp 40 điểm.
      if(m_risk != NULL)
      {
         riskScore +=
            MathMin(
               40.0,
               m_risk.CurrentDrawdownPercent() *
               2.0
            );

         // Margin usage tối đa đóng góp 20 điểm.
         riskScore +=
            MathMin(
               20.0,
               m_risk.MarginUsagePercent() *
               0.25
            );
      }

      // Số lượng position tối đa đóng góp 20 điểm.
      riskScore +=
         MathMin(
            20.0,
            MathMax(
               0,
               openPositions
            ) *
            4.0
         );

      // Spread tối đa đóng góp 10 điểm.
      if(maximumSpreadPoints > 0)
      {
         double spreadRatio =
            (double)MathMax(
               0,
               spreadPoints
            ) /
            (double)maximumSpreadPoints;

         riskScore +=
            MathMin(
               10.0,
               spreadRatio *
               10.0
            );
      }

      // ATR tối đa đóng góp 10 điểm.
      if(highVolatilityATRPoints > 0.0)
      {
         double atrRatio =
            MathMax(
               0.0,
               atrPoints
            ) /
            highVolatilityATRPoints;

         riskScore +=
            MathMin(
               10.0,
               atrRatio *
               10.0
            );
      }

      riskScore =
         SGDPNormalizeScore(
            riskScore
         );

      return (int)MathRound(
         riskScore
      );
   }

   double CurrentMarginLevel() const
   {
      if(m_risk == NULL)
         return 0.0;

      return m_risk.MarginLevel();
   }

   double CurrentFreeMargin() const
   {
      if(m_risk == NULL)
         return 0.0;

      return m_risk.FreeMargin();
   }

   double CurrentDrawdownPercent() const
   {
      if(m_risk == NULL)
         return 0.0;

      return
         m_risk.CurrentDrawdownPercent();
   }
};

#endif