#ifndef SMARTGOLDDCAPRO_TRADE_ORDER_MANAGER_MQH
#define SMARTGOLDDCAPRO_TRADE_ORDER_MANAGER_MQH

#include <Trade/Trade.mqh>

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Order Manager                   |
//| Mở và đóng lệnh theo Symbol, Magic Number và Risk Manager        |
//+------------------------------------------------------------------+
class COrderManager
{
private:
   CTrade        m_trade;
   CRiskManager *m_risk;

   string        m_symbol;
   long          m_magicNumber;
   int           m_slippagePoints;
   string        m_defaultComment;

   STradeResult  m_lastResult;

   // Ghi lại kết quả cuối cùng từ CTrade.
   void CaptureTradeResult(
      const bool success
   )
   {
      m_lastResult.Reset();

      m_lastResult.success =
         success;

      m_lastResult.orderTicket =
         m_trade.ResultOrder();

      m_lastResult.dealTicket =
         m_trade.ResultDeal();

      m_lastResult.retcode =
         m_trade.ResultRetcode();

      m_lastResult.message =
         m_trade.ResultRetcodeDescription();
   }

   // Chuẩn hóa lot trước khi gửi lệnh.
   double PrepareLot(
      const double requestedLot
   ) const
   {
      if(m_risk == NULL)
         return 0.0;

      return m_risk.NormalizeLot(
         requestedLot
      );
   }

   // Chọn comment cho lệnh.
   string ResolveComment(
      const string customComment
   ) const
   {
      if(customComment != "")
         return customComment;

      return m_defaultComment;
   }

public:
   COrderManager()
   {
      m_risk            = NULL;
      m_symbol          = _Symbol;
      m_magicNumber     = 0;
      m_slippagePoints  = 20;
      m_defaultComment  = "SmartGoldDCAPro";

      m_lastResult.Reset();
   }

   // Khởi tạo đúng API đang được EA chính sử dụng.
   void Initialize(
      CRiskManager &risk,
      const string symbol,
      const long magicNumber,
      const int slippagePoints,
      const string comment
   )
   {
      m_risk = &risk;

      m_symbol =
         symbol;

      m_magicNumber =
         magicNumber;

      m_slippagePoints =
         MathMax(
            0,
            slippagePoints
         );

      if(comment != "")
         m_defaultComment = comment;

      m_trade.SetExpertMagicNumber(
         m_magicNumber
      );

      m_trade.SetDeviationInPoints(
         m_slippagePoints
      );

      m_trade.SetTypeFillingBySymbol(
         m_symbol
      );

      m_lastResult.Reset();
   }

   bool IsInitialized() const
   {
      return m_risk != NULL;
   }

   string Symbol() const
   {
      return m_symbol;
   }

   long MagicNumber() const
   {
      return m_magicNumber;
   }

   int SlippagePoints() const
   {
      return m_slippagePoints;
   }

   // Mở lệnh BUY.
   bool OpenBuy(
      const double requestedLot,
      const double stopLoss,
      const double takeProfit,
      const string comment
   )
   {
      m_lastResult.Reset();

      if(m_risk == NULL)
      {
         m_lastResult.message =
            "Order Manager is not initialized.";

         return false;
      }

      string reason;

      if(!m_risk.CanOpenTrade(
            requestedLot,
            0,
            reason
         ))
      {
         m_lastResult.message =
            reason;

         return false;
      }

      double lot =
         PrepareLot(
            requestedLot
         );

      if(lot <= 0.0)
      {
         m_lastResult.message =
            "BUY lot is invalid after normalization.";

         return false;
      }

      bool success =
         m_trade.Buy(
            lot,
            m_symbol,
            0.0,
            stopLoss,
            takeProfit,
            ResolveComment(comment)
         );

      CaptureTradeResult(
         success
      );

      return success;
   }

   // Mở lệnh SELL.
   bool OpenSell(
      const double requestedLot,
      const double stopLoss,
      const double takeProfit,
      const string comment
   )
   {
      m_lastResult.Reset();

      if(m_risk == NULL)
      {
         m_lastResult.message =
            "Order Manager is not initialized.";

         return false;
      }

      string reason;

      if(!m_risk.CanOpenTrade(
            requestedLot,
            0,
            reason
         ))
      {
         m_lastResult.message =
            reason;

         return false;
      }

      double lot =
         PrepareLot(
            requestedLot
         );

      if(lot <= 0.0)
      {
         m_lastResult.message =
            "SELL lot is invalid after normalization.";

         return false;
      }

      bool success =
         m_trade.Sell(
            lot,
            m_symbol,
            0.0,
            stopLoss,
            takeProfit,
            ResolveComment(comment)
         );

      CaptureTradeResult(
         success
      );

      return success;
   }

   // Đóng một position theo ticket.
   bool ClosePosition(
      const ulong ticket
   )
   {
      m_lastResult.Reset();

      if(ticket == 0)
      {
         m_lastResult.message =
            "Position ticket is invalid.";

         return false;
      }

      bool success =
         m_trade.PositionClose(
            ticket,
            m_slippagePoints
         );

      CaptureTradeResult(
         success
      );

      return success;
   }

   // Đóng position theo symbol.
   bool CloseSymbolPosition()
   {
      m_lastResult.Reset();

      if(m_symbol == "")
      {
         m_lastResult.message =
            "Order Manager symbol is empty.";

         return false;
      }

      bool success =
         m_trade.PositionClose(
            m_symbol,
            m_slippagePoints
         );

      CaptureTradeResult(
         success
      );

      return success;
   }

   // Sửa Stop Loss và Take Profit của position.
   bool ModifyPosition(
      const ulong ticket,
      const double stopLoss,
      const double takeProfit
   )
   {
      m_lastResult.Reset();

      if(ticket == 0)
      {
         m_lastResult.message =
            "Position ticket is invalid.";

         return false;
      }

      bool success =
         m_trade.PositionModify(
            ticket,
            stopLoss,
            takeProfit
         );

      CaptureTradeResult(
         success
      );

      return success;
   }

   // Trả về kết quả giao dịch cuối cùng.
   STradeResult LastResult() const
   {
      return m_lastResult;
   }

   bool LastSuccess() const
   {
      return m_lastResult.success;
   }

   uint LastRetcode() const
   {
      return m_lastResult.retcode;
   }

   string LastMessage() const
   {
      return m_lastResult.message;
   }

   ulong LastOrderTicket() const
   {
      return m_lastResult.orderTicket;
   }

   ulong LastDealTicket() const
   {
      return m_lastResult.dealTicket;
   }
};

#endif