#ifndef SMARTGOLDDCAPRO_LOGGER_MQH
#define SMARTGOLDDCAPRO_LOGGER_MQH

enum ENUM_LOG_LEVEL
{
   LOG_DEBUG = 0,
   LOG_INFO  = 1,
   LOG_WARN  = 2,
   LOG_ERROR = 3
};

class CLogger
{
private:
   ENUM_LOG_LEVEL m_minLevel;
   string         m_prefix;

   string LevelName(const ENUM_LOG_LEVEL level) const
   {
      switch(level)
      {
         case LOG_DEBUG: return "DEBUG";
         case LOG_INFO:  return "INFO";
         case LOG_WARN:  return "WARN";
         case LOG_ERROR: return "ERROR";
      }
      return "INFO";
   }

public:
   CLogger()
   {
      m_minLevel = LOG_INFO;
      m_prefix   = "SmartGoldDCAPro";
   }

   void Initialize(const string prefix, const ENUM_LOG_LEVEL minLevel)
   {
      m_prefix   = prefix;
      m_minLevel = minLevel;
   }

   void Write(const ENUM_LOG_LEVEL level, const string message) const
   {
      if(level < m_minLevel)
         return;

      Print("[", m_prefix, "][", LevelName(level), "] ", message);
   }

   void Info(const string message) const  { Write(LOG_INFO, message);  }
   void Warn(const string message) const  { Write(LOG_WARN, message);  }
   void Error(const string message) const { Write(LOG_ERROR, message); }
};

#endif
