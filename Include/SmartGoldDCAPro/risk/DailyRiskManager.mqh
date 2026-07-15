#ifndef SMARTGOLDDCAPRO_RISK_DAILY_RISK_MANAGER_MQH
#define SMARTGOLDDCAPRO_RISK_DAILY_RISK_MANAGER_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Daily Risk Manager              |
//| Theo dõi mức lỗ trong ngày và khóa giao dịch khi vượt giới hạn   |
//+------------------------------------------------------------------+
class CDailyRiskManager
{
private:
   double   m_maxDailyLossMoney;
   double   m_dayStartBalance;
   datetime m_dayStartTime;

   bool     m_blocked;
   string   m_lastReason;

   // Trả về thời điểm 00:00:00 của ngày chứa thời gian đầu vào.
   datetime StartOfDay(
      const datetime value
   ) const
   {
      MqlDateTime parts;

      if(!TimeToStruct(
            value,
            parts
         ))
      {
         return 0;
      }

      parts.hour = 0;
      parts.min  = 0;
      parts.sec  = 0;

      return StructToTime(parts);
   }

   // Kiểm tra đã chuyển sang ngày giao dịch mới chưa.
   bool IsNewTradingDay() const
   {
      if(m_dayStartTime <= 0)
         return true;

      datetime currentDay =
         StartOfDay(
            TimeCurrent()
         );

      datetime storedDay =
         StartOfDay(
            m_dayStartTime
         );

      return currentDay != storedDay;
   }

   // Đặt lại dữ liệu bảo vệ cho ngày mới.
   void ResetDay()
   {
      m_dayStartTime =
         TimeCurrent();

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

      m_blocked    = false;
      m_lastReason = "";
   }

   // Khởi tạo theo API được EA chính sử dụng.
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

   // Tự động cập nhật khi bước sang ngày mới.
   void RefreshDay()
   {
      if(IsNewTradingDay())
         ResetDay();
   }

   double DayStartBalance() const
   {
      return m_dayStartBalance;
   }

   datetime DayStartTime() const
   {
      return m_dayStartTime;
   }

   double MaximumDailyLossMoney() const
   {
      return m_maxDailyLossMoney;
   }

   // Lợi nhuận hiện tại so với balance đầu ngày.
   double CurrentDailyProfit()
   {
      RefreshDay();

      double currentEquity =
         AccountInfoDouble(
            ACCOUNT_EQUITY
         );

      return
         currentEquity -
         m_dayStartBalance;
   }

   // Giá trị lỗ trong ngày, luôn là số dương.
   double CurrentDailyLoss()
   {
      double dailyProfit =
         CurrentDailyProfit();

      if(dailyProfit >= 0.0)
         return 0.0;

      return -dailyProfit;
   }

   // Kiểm tra tài khoản có được phép tiếp tục giao dịch không.
   bool CanTrade()
   {
      RefreshDay();

      if(m_blocked)
         return false;

      m_lastReason = "";

      // Giá trị 0 nghĩa là tắt Daily Loss Protection.
      if(m_maxDailyLossMoney <= 0.0)
         return true;

      double dailyLoss =
         CurrentDailyLoss();

      if(dailyLoss <
         m_maxDailyLossMoney)
      {
         return true;
      }

      m_blocked = true;

      m_lastReason =
         "Daily loss protection triggered. Current loss=" +
         DoubleToString(
            dailyLoss,
            2
         ) +
         ", maximum=" +
         DoubleToString(
            m_maxDailyLossMoney,
            2
         );

      return false;
   }

   // API đang được EA chính sử dụng.
   bool IsBlocked()
   {
      CanTrade();
      return m_blocked;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   // Đặt lại bảo vệ thủ công.
   void ResetProtection()
   {
      ResetDay();
   }
};

#endif