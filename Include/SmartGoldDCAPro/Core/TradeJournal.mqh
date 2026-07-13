#ifndef SMARTGOLDDCAPRO_TRADE_JOURNAL_MQH
#define SMARTGOLDDCAPRO_TRADE_JOURNAL_MQH

class CTradeJournal
{
private:
   string m_fileName;
   bool   m_enabled;

public:
   CTradeJournal()
   {
      m_fileName = "SmartGoldDCAPro_Journal.csv";
      m_enabled  = true;
   }

   void Initialize(const bool enabled,
                   const string fileName = "SmartGoldDCAPro_Journal.csv")
   {
      m_enabled  = enabled;
      m_fileName = fileName;
   }

   bool Write(const string eventName,
              const string details)
   {
      if(!m_enabled)
         return true;

      int handle = FileOpen(
         m_fileName,
         FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ,
         ';'
      );

      if(handle == INVALID_HANDLE)
      {
         Print("TradeJournal: cannot open file. Error=", GetLastError());
         return false;
      }

      FileSeek(handle, 0, SEEK_END);

      FileWrite(
         handle,
         TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
         _Symbol,
         eventName,
         details
      );

      FileClose(handle);
      return true;
   }
};

#endif
