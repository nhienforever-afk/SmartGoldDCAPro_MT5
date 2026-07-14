#ifndef SMARTGOLDDCAPRO_TRADE_JOURNAL_MQH
#define SMARTGOLDDCAPRO_TRADE_JOURNAL_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Trade Journal                                  |
//+------------------------------------------------------------------+
class CTradeJournal
{
private:
   bool   m_enabled;
   string m_fileName;

   string EscapeCsv(
      const string value
   ) const
   {
      string result = value;

      StringReplace(
         result,
         "\"",
         "\"\""
      );

      return "\"" + result + "\"";
   }

   bool EnsureHeader()
   {
      if(!m_enabled)
         return true;

      int handle = FileOpen(
         m_fileName,
         FILE_READ |
         FILE_WRITE |
         FILE_CSV |
         FILE_ANSI |
         FILE_SHARE_READ |
         FILE_SHARE_WRITE,
         ','
      );

      if(handle == INVALID_HANDLE)
         return false;

      if(FileSize(handle) == 0)
      {
         FileWrite(
            handle,
            "Time",
            "Symbol",
            "Event",
            "Details"
         );
      }

      FileClose(handle);
      return true;
   }

public:
   CTradeJournal()
   {
      m_enabled  = false;
      m_fileName = "SmartGoldDCAPro_Journal.csv";
   }

   bool Initialize(
      const bool enabled,
      const string fileName
   )
   {
      m_enabled = enabled;

      if(fileName != "")
         m_fileName = fileName;

      return EnsureHeader();
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

   string FileName() const
   {
      return m_fileName;
   }

   bool Write(
      const string eventName,
      const string details
   )
   {
      if(!m_enabled)
         return true;

      int handle = FileOpen(
         m_fileName,
         FILE_READ |
         FILE_WRITE |
         FILE_CSV |
         FILE_ANSI |
         FILE_SHARE_READ |
         FILE_SHARE_WRITE,
         ','
      );

      if(handle == INVALID_HANDLE)
         return false;

      FileSeek(
         handle,
         0,
         SEEK_END
      );

      FileWrite(
         handle,
         TimeToString(
            TimeCurrent(),
            TIME_DATE | TIME_SECONDS
         ),
         _Symbol,
         EscapeCsv(eventName),
         EscapeCsv(details)
      );

      FileClose(handle);
      return true;
   }

   bool WriteValue(
      const string eventName,
      const string label,
      const double value,
      const int digits = 2
   )
   {
      return Write(
         eventName,
         label + "=" +
         DoubleToString(
            value,
            digits
         )
      );
   }

   bool WriteInteger(
      const string eventName,
      const string label,
      const long value
   )
   {
      return Write(
         eventName,
         label + "=" +
         IntegerToString(
            (int)value
         )
      );
   }
};

#endif