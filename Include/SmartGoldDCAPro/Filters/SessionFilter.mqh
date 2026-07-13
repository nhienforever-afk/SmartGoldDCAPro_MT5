#ifndef SMARTGOLDDCAPRO_SESSION_FILTER_MQH
#define SMARTGOLDDCAPRO_SESSION_FILTER_MQH

class CSessionFilter
{
private:
   int m_startHour;
   int m_endHour;
   bool m_enabled;

public:
   CSessionFilter()
   {
      m_enabled   = false;
      m_startHour = 0;
      m_endHour   = 23;
   }

   void Initialize(const bool enabled,
                   const int startHour,
                   const int endHour)
   {
      m_enabled   = enabled;
      m_startHour = MathMax(0, MathMin(23, startHour));
      m_endHour   = MathMax(0, MathMin(23, endHour));
   }

   bool IsAllowed() const
   {
      if(!m_enabled)
         return true;

      MqlDateTime now;
      TimeToStruct(TimeCurrent(), now);

      if(m_startHour <= m_endHour)
         return (now.hour >= m_startHour && now.hour <= m_endHour);

      return (now.hour >= m_startHour || now.hour <= m_endHour);
   }
};

#endif
