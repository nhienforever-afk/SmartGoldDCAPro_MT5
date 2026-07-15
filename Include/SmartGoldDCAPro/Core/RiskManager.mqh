#ifndef SMARTGOLDDCAPRO_CORE_RISK_MANAGER_MQH
#define SMARTGOLDDCAPRO_CORE_RISK_MANAGER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Risk Manager                    |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
   string m_symbol;

   double m_peakEquity;
   double m_maxEquityDrawdownPercent;

   bool   m_equityProtectionTriggered;
   string m_lastReason;

   // Tính số chữ số lot dựa trên volume step.
   int VolumeDigits(
      const double volumeStep
   ) const
   {
      if(volumeStep >= 1.0)
         return 0;

      if(volumeStep >= 0.1)
         return 1;

      if(volumeStep >= 0.01)
         return 2;

      if(volumeStep >= 0.001)
         return 3;

      return 4;
   }

public:
   CRiskManager()
   {
      m_symbol = _Symbol;

      m_peakEquity =
         AccountInfoDouble(
            ACCOUNT_EQUITY
         );

      m_maxEquityDrawdownPercent = 0.0;

      m_equityProtectionTriggered = false;
      m_lastReason                 = "";
   }

   // Khởi tạo theo đúng API đang được EA chính sử dụng.
   void Initialize(
      const string symbol,
      const double maxEquityDrawdownPercent
   )
   {
      m_symbol = symbol;

      m_maxEquityDrawdownPercent =
         SGDPClampDouble(
            maxEquityDrawdownPercent,
            0.0,
            100.0
         );

      m_peakEquity =
         AccountInfoDouble(
            ACCOUNT_EQUITY
         );

      m_equityProtectionTriggered = false;
      m_lastReason                 = "";
   }

   string Symbol() const
   {
      return m_symbol;
   }

   double Balance() const
   {
      return AccountInfoDouble(
         ACCOUNT_BALANCE
      );
   }

   double Equity() const
   {
      return AccountInfoDouble(
         ACCOUNT_EQUITY
      );
   }

   double Margin() const
   {
      return AccountInfoDouble(
         ACCOUNT_MARGIN
      );
   }

   double FreeMargin() const
   {
      return AccountInfoDouble(
         ACCOUNT_MARGIN_FREE
      );
   }

   double MarginLevel() const
   {
      return AccountInfoDouble(
         ACCOUNT_MARGIN_LEVEL
      );
   }

   // Cập nhật equity cao nhất kể từ khi EA khởi động.
   void UpdatePeakEquity()
   {
      double currentEquity = Equity();

      if(currentEquity > m_peakEquity)
         m_peakEquity = currentEquity;

      if(m_peakEquity <= 0.0)
         m_peakEquity = currentEquity;
   }

   double PeakEquity() const
   {
      return m_peakEquity;
   }

   // Drawdown tính từ peak equity.
   double CurrentDrawdownPercent() const
   {
      double currentEquity = Equity();

      if(m_peakEquity <= 0.0)
         return 0.0;

      double drawdown =
         (
            m_peakEquity -
            currentEquity
         ) /
         m_peakEquity *
         100.0;

      return MathMax(
         0.0,
         drawdown
      );
   }

   // Alias để SmartLotCalculator có thể sử dụng.
   double EquityDrawdownPercent() const
   {
      return CurrentDrawdownPercent();
   }

   double MarginUsagePercent() const
   {
      double currentEquity = Equity();
      double currentMargin = Margin();

      if(currentEquity <= 0.0)
         return 100.0;

      return
         currentMargin /
         currentEquity *
         100.0;
   }

   int CurrentSpreadPoints() const
   {
      MqlTick tick;

      if(!SymbolInfoTick(
            m_symbol,
            tick
         ))
      {
         return 0;
      }

      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
         return 0;

      return (int)MathRound(
         (
            tick.ask -
            tick.bid
         ) /
         point
      );
   }

   // Kiểm tra và ghi nhận trạng thái Equity Protection.
   bool IsEquityProtectionTriggered()
   {
      if(m_equityProtectionTriggered)
         return true;

      if(m_maxEquityDrawdownPercent <= 0.0)
         return false;

      double drawdown =
         CurrentDrawdownPercent();

      if(drawdown <
         m_maxEquityDrawdownPercent)
      {
         return false;
      }

      m_equityProtectionTriggered = true;

      m_lastReason =
         "Equity protection triggered. Drawdown=" +
         DoubleToString(
            drawdown,
            2
         ) +
         "%, maximum=" +
         DoubleToString(
            m_maxEquityDrawdownPercent,
            2
         ) +
         "%";

      return true;
   }

   void ResetEquityProtection()
   {
      m_peakEquity =
         AccountInfoDouble(
            ACCOUNT_EQUITY
         );

      m_equityProtectionTriggered = false;
      m_lastReason                 = "";
   }

   // Chuẩn hóa lot theo quy định của symbol.
   double NormalizeLot(
      const double lot
   ) const
   {
      double minimumLot =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_VOLUME_MIN
         );

      double maximumLot =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_VOLUME_MAX
         );

      double volumeStep =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_VOLUME_STEP
         );

      if(minimumLot <= 0.0 ||
         maximumLot <= 0.0 ||
         volumeStep <= 0.0)
      {
         return 0.0;
      }

      double normalizedLot =
         MathFloor(
            lot /
            volumeStep
         ) *
         volumeStep;

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

      return NormalizeDouble(
         normalizedLot,
         VolumeDigits(volumeStep)
      );
   }

   // Kiểm tra điều kiện trước khi mở lệnh.
   bool CanOpenTrade(
      const double requestedLot,
      const int maximumSpreadPoints,
      string &reason
   )
   {
      reason       = "";
      m_lastReason = "";

      if(IsEquityProtectionTriggered())
      {
         reason = m_lastReason;
         return false;
      }

      if(requestedLot <= 0.0)
      {
         reason =
            "Requested lot must be greater than zero.";

         m_lastReason = reason;
         return false;
      }

      double normalizedLot =
         NormalizeLot(
            requestedLot
         );

      if(normalizedLot <= 0.0)
      {
         reason =
            "Requested lot cannot be normalized for symbol.";

         m_lastReason = reason;
         return false;
      }

      int spreadPoints =
         CurrentSpreadPoints();

      if(maximumSpreadPoints > 0 &&
         spreadPoints >
         maximumSpreadPoints)
      {
         reason =
            "Spread is too high. Current=" +
            IntegerToString(
               spreadPoints
            ) +
            ", maximum=" +
            IntegerToString(
               maximumSpreadPoints
            );

         m_lastReason = reason;
         return false;
      }

      double freeMargin =
         FreeMargin();

      if(freeMargin <= 0.0)
      {
         reason =
            "Free margin is not available.";

         m_lastReason = reason;
         return false;
      }

      reason = "Trade conditions are valid.";
      return true;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   double MaximumEquityDrawdownPercent() const
   {
      return m_maxEquityDrawdownPercent;
   }
};

#endif