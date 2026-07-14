#ifndef SMARTGOLDDCAPRO_DAILY_RISK_MANAGER_MQH
#define SMARTGOLDDCAPRO_DAILY_RISK_MANAGER_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Daily Risk Manager                             |
//+------------------------------------------------------------------+
class CDailyRiskManager
{
private:
   double   m_maxDailyLossMoney;
   double   m_dayStartBalance;
   datetime m_dayStartTime;
   bool     m_blocked;
   string   m_lastReason;

   datetime StartOfDay(
      const datetime value
   ) const
   {
      MqlDateTime parts;
      TimeToStruct(value, parts);

      parts.hour = 0;
      parts.min  = 0;
      parts.sec  = 0;

      return StructToTime(parts);
   }

   bool IsNewTradingDay() const
   {
      return
         StartOfDay(TimeCurrent()) !=
         StartOfDay(m_dayStartTime);
   }

   void ResetDay()
   {
      m_dayStartTime    = TimeCurrent();
      m_dayStartBalance =
         AccountInfoDouble(
            ACCOUNT_BALANCE
         );

      m_blocked    = false;
      m_lastReason = "";
   }

public:
   CDailyRiskManager()
   {
      m_maxDailyLossMoney = 0.0;
      m_dayStartBalance   = 0.0;
      m_dayStartTime      = 0;
      m_blocked           = false;
      m_lastReason        = "";
   }

   void Initialize(
      const double maxDailyLossMoney
   )
   {
      m_maxDailyLossMoney =
         MathMax(
            0.0,
            maxDailyLossMoney
         );

      ResetDay();
   }

   void RefreshDay()
   {
      if(m_dayStartTime == 0 ||
         IsNewTradingDay())
      {
         ResetDay();
      }
   }

   double CurrentDailyProfit() const
   {
      double currentEquity =
         AccountInfoDouble(
            ACCOUNT_EQUITY
         );

      return
         currentEquity -
         m_dayStartBalance;
   }

   double CurrentDailyLoss() const
   {
      double profit =
         CurrentDailyProfit();

      if(profit >= 0.0)
         return 0.0;

      return -profit;
   }

   bool CanTrade()
   {
      RefreshDay();

      m_lastReason = "";

      if(m_maxDailyLossMoney <= 0.0)
         return true;

      double dailyLoss =
         CurrentDailyLoss();

      if(dailyLoss >=
         m_maxDailyLossMoney)
      {
         m_blocked = true;

         m_lastReason =
            "Maximum daily loss reached: " +
            DoubleToString(
               dailyLoss,
               2
            );

         return false;
      }

      return !m_blocked;
   }

   bool IsBlocked()
   {
      RefreshDay();
      CanTrade();

      return m_blocked;
   }

   void ResetProtection()
   {
      ResetDay();
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   double MaxDailyLossMoney() const
   {
      return m_maxDailyLossMoney;
   }

   double DayStartBalance() const
   {
      return m_dayStartBalance;
   }

   datetime DayStartTime() const
   {
      return m_dayStartTime;
   }
};

#endif