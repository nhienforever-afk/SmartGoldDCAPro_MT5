#ifndef SMARTGOLDDCAPRO_RISK_MANAGER_MQH
#define SMARTGOLDDCAPRO_RISK_MANAGER_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Risk Manager                                   |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
   string m_symbol;

   double m_maxEquityDrawdownPercent;
   double m_maxMarginUsagePercent;
   double m_maxSpreadPoints;

   bool   m_equityProtectionTriggered;
   string m_lastReason;

   double ClampPercent(
      const double value
   ) const
   {
      if(value < 0.0)
         return 0.0;

      if(value > 100.0)
         return 100.0;

      return value;
   }

public:
   CRiskManager()
   {
      m_symbol = _Symbol;

      m_maxEquityDrawdownPercent = 30.0;
      m_maxMarginUsagePercent    = 70.0;
      m_maxSpreadPoints          = 100.0;

      m_equityProtectionTriggered = false;
      m_lastReason               = "";
   }

   void Initialize(
      const string symbol,
      const double maxEquityDrawdownPercent,
      const double maxMarginUsagePercent = 70.0,
      const double maxSpreadPoints = 100.0
   )
   {
      m_symbol = symbol;

      m_maxEquityDrawdownPercent =
         ClampPercent(
            maxEquityDrawdownPercent
         );

      m_maxMarginUsagePercent =
         ClampPercent(
            maxMarginUsagePercent
         );

      m_maxSpreadPoints =
         MathMax(
            0.0,
            maxSpreadPoints
         );

      ResetProtection();
   }

   void ResetProtection()
   {
      m_equityProtectionTriggered = false;
      m_lastReason                 = "";
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

   double EquityDrawdownPercent() const
   {
      double balance = Balance();
      double equity  = Equity();

      if(balance <= 0.0)
         return 0.0;

      double drawdown =
         (balance - equity) /
         balance *
         100.0;

      return MathMax(
         0.0,
         drawdown
      );
   }

   double MarginUsagePercent() const
   {
      double equity = Equity();
      double margin = Margin();

      if(equity <= 0.0)
         return 100.0;

      return
         margin /
         equity *
         100.0;
   }

   double SpreadPoints() const
   {
      MqlTick tick;

      if(!SymbolInfoTick(
            m_symbol,
            tick
         ))
      {
         return 0.0;
      }

      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
         return 0.0;

      return
         (tick.ask - tick.bid) /
         point;
   }

   bool CheckEquityProtection()
   {
      double drawdown =
         EquityDrawdownPercent();

      if(m_maxEquityDrawdownPercent <= 0.0)
         return true;

      if(drawdown >=
         m_maxEquityDrawdownPercent)
      {
         m_equityProtectionTriggered = true;

         m_lastReason =
            "Maximum equity drawdown reached: " +
            DoubleToString(
               drawdown,
               2
            ) +
            "%";

         return false;
      }

      return true;
   }

   bool CheckMarginUsage()
   {
      double marginUsage =
         MarginUsagePercent();

      if(m_maxMarginUsagePercent <= 0.0)
         return true;

      if(marginUsage >=
         m_maxMarginUsagePercent)
      {
         m_lastReason =
            "Maximum margin usage reached: " +
            DoubleToString(
               marginUsage,
               2
            ) +
            "%";

         return false;
      }

      return true;
   }

   bool CheckSpread()
   {
      double spread =
         SpreadPoints();

      if(m_maxSpreadPoints <= 0.0)
         return true;

      if(spread >
         m_maxSpreadPoints)
      {
         m_lastReason =
            "Spread too high: " +
            DoubleToString(
               spread,
               1
            ) +
            " points";

         return false;
      }

      return true;
   }

   bool CanTrade()
   {
      m_lastReason = "";

      if(!CheckEquityProtection())
         return false;

      if(!CheckMarginUsage())
         return false;

      if(!CheckSpread())
         return false;

      return true;
   }

   bool IsEquityProtectionTriggered() const
   {
      return m_equityProtectionTriggered;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   double MaxEquityDrawdownPercent() const
   {
      return m_maxEquityDrawdownPercent;
   }

   double MaxMarginUsagePercent() const
   {
      return m_maxMarginUsagePercent;
   }

   double MaxSpreadPoints() const
   {
      return m_maxSpreadPoints;
   }
};

#endif