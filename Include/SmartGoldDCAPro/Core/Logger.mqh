#ifndef SMARTGOLDDCAPRO_LOGGER_MQH
#define SMARTGOLDDCAPRO_LOGGER_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Logger                                         |
//+------------------------------------------------------------------+

enum ENUM_LOG_LEVEL
{
   LOG_DEBUG = 0,
   LOG_INFO,
   LOG_WARNING,
   LOG_ERROR
};

class CLogger
{
private:
   string         m_name;
   ENUM_LOG_LEVEL m_minimumLevel;
   bool           m_enabled;

   string LevelName(
      const ENUM_LOG_LEVEL level
   ) const
   {
      switch(level)
      {
         case LOG_DEBUG:
            return "DEBUG";

         case LOG_INFO:
            return "INFO";

         case LOG_WARNING:
            return "WARNING";

         case LOG_ERROR:
            return "ERROR";
      }

      return "UNKNOWN";
   }

   bool CanWrite(
      const ENUM_LOG_LEVEL level
   ) const
   {
      if(!m_enabled)
         return false;

      return level >= m_minimumLevel;
   }

   void Write(
      const ENUM_LOG_LEVEL level,
      const string message
   ) const
   {
      if(!CanWrite(level))
         return;

      Print(
         "[",
         m_name,
         "][",
         LevelName(level),
         "] ",
         message
      );
   }

public:
   CLogger()
   {
      m_name         = "SmartGoldDCAPro";
      m_minimumLevel = LOG_INFO;
      m_enabled      = true;
   }

   void Initialize(
      const string name,
      const ENUM_LOG_LEVEL minimumLevel = LOG_INFO,
      const bool enabled = true
   )
   {
      m_name         = name;
      m_minimumLevel = minimumLevel;
      m_enabled      = enabled;
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

   void SetMinimumLevel(
      const ENUM_LOG_LEVEL level
   )
   {
      m_minimumLevel = level;
   }

   ENUM_LOG_LEVEL MinimumLevel() const
   {
      return m_minimumLevel;
   }

   void Debug(
      const string message
   ) const
   {
      Write(
         LOG_DEBUG,
         message
      );
   }

   void Info(
      const string message
   ) const
   {
      Write(
         LOG_INFO,
         message
      );
   }

   void Warn(
      const string message
   ) const
   {
      Write(
         LOG_WARNING,
         message
      );
   }

   void Error(
      const string message
   ) const
   {
      Write(
         LOG_ERROR,
         message
      );
   }
};

#endif