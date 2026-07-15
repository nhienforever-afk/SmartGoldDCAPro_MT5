#ifndef SMARTGOLDDCAPRO_CORE_LOGGER_MQH
#define SMARTGOLDDCAPRO_CORE_LOGGER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Logger                          |
//+------------------------------------------------------------------+
class CLogger
{
private:
   string              m_name;
   ENUM_SGDP_LOG_LEVEL m_minimumLevel;
   bool                m_enabled;

   string LevelName(
      const ENUM_SGDP_LOG_LEVEL level
   ) const
   {
      switch(level)
      {
         case SGDP_LOG_DEBUG:
            return "DEBUG";

         case SGDP_LOG_INFO:
            return "INFO";

         case SGDP_LOG_WARNING:
            return "WARNING";

         case SGDP_LOG_ERROR:
            return "ERROR";
      }

      return "UNKNOWN";
   }

   bool CanWrite(
      const ENUM_SGDP_LOG_LEVEL level
   ) const
   {
      if(!m_enabled)
         return false;

      return level >= m_minimumLevel;
   }

   void WriteInternal(
      const ENUM_SGDP_LOG_LEVEL level,
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
      m_minimumLevel = SGDP_LOG_INFO;
      m_enabled      = true;
   }

   void Initialize(
      const string name,
      const ENUM_SGDP_LOG_LEVEL minimumLevel = SGDP_LOG_INFO,
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
      const ENUM_SGDP_LOG_LEVEL level
   )
   {
      m_minimumLevel = level;
   }

   ENUM_SGDP_LOG_LEVEL MinimumLevel() const
   {
      return m_minimumLevel;
   }

   void Debug(
      const string message
   ) const
   {
      WriteInternal(
         SGDP_LOG_DEBUG,
         message
      );
   }

   void Info(
      const string message
   ) const
   {
      WriteInternal(
         SGDP_LOG_INFO,
         message
      );
   }

   void Warn(
      const string message
   ) const
   {
      WriteInternal(
         SGDP_LOG_WARNING,
         message
      );
   }

   void Error(
      const string message
   ) const
   {
      WriteInternal(
         SGDP_LOG_ERROR,
         message
      );
   }
};

#endif