#ifndef SMARTGOLDDCAPRO_DAILY_RISK_MANAGER_MQH
#define SMARTGOLDDCAPRO_DAILY_RISK_MANAGER_MQH

class CDailyRiskManager
{
private:
   datetime m_dayStart;
   double   m_startBalance;
   double   m_maxDailyLossMoney;

   datetime CurrentDayStart() const
   {
      MqlDateTime value;
      TimeToStruct(TimeCurrent(), value);
      value.hour = 0;
      value.min  = 0;
      value.sec  = 0;
      return StructToTime(value);
   }

   void ResetIfNewDay()
   {
      datetime today = CurrentDayStart();
      if(today != m_dayStart)
      {
         m_dayStart     = today;
         m_startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      }
   }

public:
   CDailyRiskManager()
   {
      m_dayStart          = 0;
      m_startBalance      = 0.0;
      m_maxDailyLossMoney = 0.0;
   }

   void Initialize(const double maxDailyLossMoney)
   {
      m_dayStart          = CurrentDayStart();
      m_startBalance      = AccountInfoDouble(ACCOUNT_BALANCE);
      m_maxDailyLossMoney = MathMax(0.0, maxDailyLossMoney);
   }

   double CurrentDailyResult()
   {
      ResetIfNewDay();
      return AccountInfoDouble(ACCOUNT_EQUITY) - m_startBalance;
   }

   bool IsBlocked()
   {
      ResetIfNewDay();

      if(m_maxDailyLossMoney <= 0.0)
         return false;

      return CurrentDailyResult() <= -m_maxDailyLossMoney;
   }
};

#endif
