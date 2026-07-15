#ifndef SMARTGOLDDCAPRO_TRADE_BASKET_MANAGER_MQH
#define SMARTGOLDDCAPRO_TRADE_BASKET_MANAGER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Basket Manager                  |
//| Quản lý và đóng toàn bộ basket theo Symbol và Magic Number       |
//+------------------------------------------------------------------+
class CBasketManager
{
private:
   CPositionManager *m_positions;
   COrderManager    *m_orders;

   string m_lastReason;

public:
   CBasketManager()
   {
      m_positions = NULL;
      m_orders    = NULL;

      m_lastReason = "";
   }

   // Khởi tạo đúng cấu trúc đang dùng trong EA chính.
   void Initialize(
      CPositionManager &positions,
      COrderManager &orders
   )
   {
      m_positions = &positions;
      m_orders    = &orders;

      m_lastReason = "";
   }

   bool IsInitialized() const
   {
      return
         m_positions != NULL &&
         m_orders != NULL;
   }

   int PositionCount() const
   {
      if(m_positions == NULL)
         return 0;

      return m_positions.CountAll();
   }

   bool HasBasket() const
   {
      return PositionCount() > 0;
   }

   double TotalProfit() const
   {
      if(m_positions == NULL)
         return 0.0;

      return m_positions.TotalProfit();
   }

   double TotalVolume() const
   {
      if(m_positions == NULL)
         return 0.0;

      return m_positions.TotalVolume();
   }

   double AverageOpenPrice() const
   {
      if(m_positions == NULL)
         return 0.0;

      return m_positions.AverageOpenPrice();
   }

   bool GetDirection(
      ENUM_POSITION_TYPE &direction
   ) const
   {
      if(m_positions == NULL)
         return false;

      return m_positions.GetBasketDirection(
         direction
      );
   }

   bool GetSnapshot(
      SBasketSnapshot &snapshot
   ) const
   {
      snapshot.Reset();

      if(m_positions == NULL)
         return false;

      return m_positions.GetBasketSnapshot(
         snapshot
      );
   }

   // Kiểm tra basket đã đạt Take Profit theo tiền hay chưa.
   bool HasReachedTakeProfit(
      const double takeProfitMoney
   ) const
   {
      if(takeProfitMoney <= 0.0)
         return false;

      if(!HasBasket())
         return false;

      return
         TotalProfit() >=
         takeProfitMoney;
   }

   // Kiểm tra basket đã đạt Stop Loss theo tiền hay chưa.
   bool HasReachedStopLoss(
      const double stopLossMoney
   ) const
   {
      if(stopLossMoney <= 0.0)
         return false;

      if(!HasBasket())
         return false;

      return
         TotalProfit() <=
         -stopLossMoney;
   }

   // Kiểm tra basket có cần đóng theo TP hoặc SL không.
   bool ShouldClose(
      const double takeProfitMoney,
      const double stopLossMoney,
      string &reason
   ) const
   {
      reason = "";

      if(!HasBasket())
      {
         reason = "No active basket.";
         return false;
      }

      double profit =
         TotalProfit();

      if(takeProfitMoney > 0.0 &&
         profit >= takeProfitMoney)
      {
         reason =
            "Basket Take Profit reached. Profit=" +
            DoubleToString(
               profit,
               2
            );

         return true;
      }

      if(stopLossMoney > 0.0 &&
         profit <= -stopLossMoney)
      {
         reason =
            "Basket Stop Loss reached. Profit=" +
            DoubleToString(
               profit,
               2
            );

         return true;
      }

      reason =
         "Basket exit conditions are not reached.";

      return false;
   }

   // Đóng toàn bộ position thuộc EA.
   bool CloseAll(
      const string closeReason = "Close basket"
   )
   {
      m_lastReason = "";

      if(!IsInitialized())
      {
         m_lastReason =
            "Basket Manager is not initialized.";

         return false;
      }

      if(!HasBasket())
      {
         m_lastReason =
            "No active basket.";

         return true;
      }

      bool allClosed = true;

      // Lặp ngược để danh sách position có thể thay đổi trong lúc đóng.
      for(int index = PositionsTotal() - 1;
          index >= 0;
          index--)
      {
         ulong ticket =
            PositionGetTicket(index);

         if(ticket == 0)
            continue;

         if(!PositionSelectByTicket(ticket))
            continue;

         string positionSymbol =
            PositionGetString(
               POSITION_SYMBOL
            );

         long positionMagic =
            PositionGetInteger(
               POSITION_MAGIC
            );

         if(positionSymbol !=
            m_positions.Symbol())
         {
            continue;
         }

         if(positionMagic !=
            m_positions.MagicNumber())
         {
            continue;
         }

         if(!m_orders.ClosePosition(ticket))
         {
            allClosed = false;

            m_lastReason =
               "Cannot close position #" +
               IntegerToString(
                  (int)ticket
               ) +
               ". " +
               m_orders.LastMessage();
         }
      }

      if(allClosed)
      {
         m_lastReason =
            closeReason;
      }

      return allClosed;
   }

   // Đóng basket nếu đạt TP hoặc SL.
   bool ManageExit(
      const double takeProfitMoney,
      const double stopLossMoney,
      string &reason
   )
   {
      reason = "";

      if(!ShouldClose(
            takeProfitMoney,
            stopLossMoney,
            reason
         ))
      {
         return false;
      }

      string triggerReason =
         reason;

      bool closed =
         CloseAll(
            triggerReason
         );

      if(!closed)
      {
         reason =
            "Basket close failed. " +
            m_lastReason;

         return false;
      }

      reason = triggerReason;
      return true;
   }

   string LastReason() const
   {
      return m_lastReason;
   }
};

#endif