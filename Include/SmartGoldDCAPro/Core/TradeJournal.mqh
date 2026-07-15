#ifndef SMARTGOLDDCAPRO_CORE_TRADE_JOURNAL_MQH
#define SMARTGOLDDCAPRO_CORE_TRADE_JOURNAL_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Logger.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Trade Journal                   |
//| Ghi nhật ký hoạt động của EA vào tệp CSV                         |
//+------------------------------------------------------------------+
class CTradeJournal
{
private:
   bool     m_enabled;
   string   m_fileName;
   CLogger *m_logger;

   // Mở tệp journal với quyền đọc và ghi.
   int OpenJournalFile() const
   {
      return FileOpen(
         m_fileName,
         FILE_READ |
         FILE_WRITE |
         FILE_CSV |
         FILE_ANSI |
         FILE_SHARE_READ |
         FILE_SHARE_WRITE,
         ','
      );
   }

   // Tạo dòng tiêu đề nếu tệp còn trống.
   bool EnsureHeader()
   {
      if(!m_enabled)
         return true;

      int handle = OpenJournalFile();

      if(handle == INVALID_HANDLE)
      {
         if(m_logger != NULL)
         {
            m_logger.Error(
               "Cannot open trade journal file: " +
               m_fileName
            );
         }

         return false;
      }

      if(FileSize(handle) == 0)
      {
         FileWrite(
            handle,
            "Time",
            "Symbol",
            "Event",
            "Details"
         );

         FileFlush(handle);
      }

      FileClose(handle);
      return true;
   }

public:
   CTradeJournal()
   {
      m_enabled  = false;
      m_fileName = "SmartGoldDCAPro_Journal.csv";
      m_logger   = NULL;
   }

   // Khởi tạo journal theo đúng API hiện tại của EA.
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

   // Cho phép kết nối Logger sau khi khởi tạo.
   void SetLogger(
      CLogger &logger
   )
   {
      m_logger = &logger;
   }

   void SetEnabled(
      const bool enabled
   )
   {
      m_enabled = enabled;

      if(m_enabled)
         EnsureHeader();
   }

   bool IsEnabled() const
   {
      return m_enabled;
   }

   string FileName() const
   {
      return m_fileName;
   }

   // Ghi một sự kiện vào journal.
   bool Write(
      const string eventName,
      const string details
   )
   {
      if(!m_enabled)
         return true;

      int handle = OpenJournalFile();

      if(handle == INVALID_HANDLE)
      {
         if(m_logger != NULL)
         {
            m_logger.Error(
               "Cannot write trade journal file: " +
               m_fileName
            );
         }

         return false;
      }

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
         eventName,
         details
      );

      FileFlush(handle);
      FileClose(handle);

      return true;
   }

   // Ghi một giá trị double.
   bool WriteValue(
      const string eventName,
      const string label,
      const double value,
      const int digits = 2
   )
   {
      return Write(
         eventName,
         label +
         "=" +
         DoubleToString(
            value,
            digits
         )
      );
   }

   // Ghi một giá trị số nguyên.
   bool WriteInteger(
      const string eventName,
      const string label,
      const long value
   )
   {
      return Write(
         eventName,
         label +
         "=" +
         IntegerToString(
            (int)value
         )
      );
   }

   // Ghi kết quả giao dịch chuẩn hóa.
   bool WriteTradeResult(
      const string eventName,
      const STradeResult &result
   )
   {
      string details =
         "success=" +
         (result.success ? "true" : "false") +
         ", order=" +
         IntegerToString(
            (int)result.orderTicket
         ) +
         ", deal=" +
         IntegerToString(
            (int)result.dealTicket
         ) +
         ", retcode=" +
         IntegerToString(
            (int)result.retcode
         ) +
         ", message=" +
         result.message;

      return Write(
         eventName,
         details
      );
   }
};

#endif