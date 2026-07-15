#ifndef SMARTGOLDDCAPRO_FILTERS_SESSION_FILTER_MQH
#define SMARTGOLDDCAPRO_FILTERS_SESSION_FILTER_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Session Filter                  |
//| Kiểm soát khung giờ cho phép mở lệnh mới                         |
//+------------------------------------------------------------------+
class CSessionFilter
{
private:
   bool   m_enabled;
   int    m_startHour;
   int    m_endHour;
   string m_lastReason;

   int NormalizeHour(
      const int hour
   ) const
   {
      if(hour < 0)
         return 0;

      if(hour > 23)
         return 23;

      return hour;
   }

public:
   CSessionFilter()
   {
      m_enabled    = false;
      m_startHour  = 0;
      m_endHour    = 23;
      m_lastReason = "";
   }

   // Khởi tạo đúng API mà EA chính đang sử dụng.
   void Initialize(
      const bool enabled,
      const int startHour,
      const int endHour
   )
   {
      m_enabled   = enabled;
      m_startHour = NormalizeHour(startHour);
      m_endHour   = NormalizeHour(endHour);

      m_lastReason = "";
   }

   void SetEnabled(
      const bool enabled
   )
   {
      m_enabled = enabled;
   }

   bool IsEnabled() const
   {
      return m_enabled;
   }

   int StartHour() const
   {
      return m_startHour;
   }

   int EndHour() const
   {
      return m_endHour;
   }

   // Kiểm tra một giờ cụ thể có nằm trong session hay không.
   bool IsHourAllowed(
      const int hour
   ) const
   {
      int normalizedHour =
         NormalizeHour(hour);

      // Start == End được hiểu là cho phép cả ngày.
      if(m_startHour == m_endHour)
         return true;

      // Session bình thường, ví dụ 07:00 đến 22:00.
      if(m_startHour < m_endHour)
      {
         return
            normalizedHour >= m_startHour &&
            normalizedHour < m_endHour;
      }

      // Session đi qua nửa đêm, ví dụ 22:00 đến 06:00.
      return
         normalizedHour >= m_startHour ||
         normalizedHour < m_endHour;
   }

   // API chính được EA sử dụng.
   bool IsAllowed()
   {
      m_lastReason = "";

      if(!m_enabled)
         return true;

      MqlDateTime timeParts;

      if(!TimeToStruct(
            TimeCurrent(),
            timeParts
         ))
      {
         m_lastReason =
            "Cannot read current server time.";

         return false;
      }

      if(IsHourAllowed(timeParts.hour))
         return true;

      m_lastReason =
         "Trading session is closed. Current hour=" +
         IntegerToString(timeParts.hour) +
         ", allowed=" +
         IntegerToString(m_startHour) +
         "-" +
         IntegerToString(m_endHour);

      return false;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   string SessionName() const
   {
      if(!m_enabled)
         return "DISABLED";

      return
         IntegerToString(m_startHour) +
         ":00-" +
         IntegerToString(m_endHour) +
         ":00";
   }
};

#endif