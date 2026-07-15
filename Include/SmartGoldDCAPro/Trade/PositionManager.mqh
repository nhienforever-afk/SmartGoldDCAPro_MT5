#ifndef SMARTGOLDDCAPRO_TRADE_POSITION_MANAGER_MQH
#define SMARTGOLDDCAPRO_TRADE_POSITION_MANAGER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Position Manager                |
//| Quản lý position theo Symbol và Magic Number                     |
//+------------------------------------------------------------------+
class CPositionManager
{
private:
   string m_symbol;
   long   m_magicNumber;

   // Chọn position theo vị trí trong danh sách hiện tại.
   bool SelectByIndex(
      const int index
   ) const
   {
      if(index < 0 ||
         index >= PositionsTotal())
      {
         return false;
      }

      ulong ticket =
         PositionGetTicket(index);

      if(ticket == 0)
         return false;

      return PositionSelectByTicket(ticket);
   }

   // Kiểm tra position đang được chọn có thuộc EA hay không.
   bool IsSelectedManagedPosition() const
   {
      string selectedSymbol =
         PositionGetString(
            POSITION_SYMBOL
         );

      long selectedMagic =
         PositionGetInteger(
            POSITION_MAGIC
         );

      return
         selectedSymbol == m_symbol &&
         selectedMagic == m_magicNumber;
   }

   bool IsSelectedType(
      const ENUM_POSITION_TYPE requiredType
   ) const
   {
      ENUM_POSITION_TYPE currentType =
         (ENUM_POSITION_TYPE)
         PositionGetInteger(
            POSITION_TYPE
         );

      return currentType == requiredType;
   }

public:
   CPositionManager()
   {
      m_symbol      = _Symbol;
      m_magicNumber = 0;
   }

   // Khởi tạo đúng API đang được EA chính sử dụng.
   void Initialize(
      const string symbol,
      const long magicNumber
   )
   {
      m_symbol      = symbol;
      m_magicNumber = magicNumber;
   }

   string Symbol() const
   {
      return m_symbol;
   }

   long MagicNumber() const
   {
      return m_magicNumber;
   }

   // Đếm toàn bộ position thuộc Symbol và Magic Number.
   int CountAll() const
   {
      int count = 0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         count++;
      }

      return count;
   }

   int CountByType(
      const ENUM_POSITION_TYPE requiredType
   ) const
   {
      int count = 0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         if(!IsSelectedType(requiredType))
            continue;

         count++;
      }

      return count;
   }

   int CountBuy() const
   {
      return CountByType(
         POSITION_TYPE_BUY
      );
   }

   int CountSell() const
   {
      return CountByType(
         POSITION_TYPE_SELL
      );
   }

   bool HasPositions() const
   {
      return CountAll() > 0;
   }

   bool HasBuyPositions() const
   {
      return CountBuy() > 0;
   }

   bool HasSellPositions() const
   {
      return CountSell() > 0;
   }

   double TotalVolume() const
   {
      double total = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         total +=
            PositionGetDouble(
               POSITION_VOLUME
            );
      }

      return total;
   }

   double TotalVolumeByType(
      const ENUM_POSITION_TYPE requiredType
   ) const
   {
      double total = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         if(!IsSelectedType(requiredType))
            continue;

         total +=
            PositionGetDouble(
               POSITION_VOLUME
            );
      }

      return total;
   }

   double TotalBuyVolume() const
   {
      return TotalVolumeByType(
         POSITION_TYPE_BUY
      );
   }

   double TotalSellVolume() const
   {
      return TotalVolumeByType(
         POSITION_TYPE_SELL
      );
   }

   double TotalProfit() const
   {
      double total = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         total +=
            PositionGetDouble(
               POSITION_PROFIT
            );

         total +=
            PositionGetDouble(
               POSITION_SWAP
            );
      }

      return total;
   }

   double TotalProfitByType(
      const ENUM_POSITION_TYPE requiredType
   ) const
   {
      double total = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         if(!IsSelectedType(requiredType))
            continue;

         total +=
            PositionGetDouble(
               POSITION_PROFIT
            );

         total +=
            PositionGetDouble(
               POSITION_SWAP
            );
      }

      return total;
   }

   double TotalBuyProfit() const
   {
      return TotalProfitByType(
         POSITION_TYPE_BUY
      );
   }

   double TotalSellProfit() const
   {
      return TotalProfitByType(
         POSITION_TYPE_SELL
      );
   }

   double AverageOpenPrice() const
   {
      double weightedPrice = 0.0;
      double totalVolume   = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         double volume =
            PositionGetDouble(
               POSITION_VOLUME
            );

         double openPrice =
            PositionGetDouble(
               POSITION_PRICE_OPEN
            );

         weightedPrice +=
            openPrice * volume;

         totalVolume += volume;
      }

      if(totalVolume <= 0.0)
         return 0.0;

      return weightedPrice / totalVolume;
   }

   double AverageOpenPriceByType(
      const ENUM_POSITION_TYPE requiredType
   ) const
   {
      double weightedPrice = 0.0;
      double totalVolume   = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         if(!IsSelectedType(requiredType))
            continue;

         double volume =
            PositionGetDouble(
               POSITION_VOLUME
            );

         double openPrice =
            PositionGetDouble(
               POSITION_PRICE_OPEN
            );

         weightedPrice +=
            openPrice * volume;

         totalVolume += volume;
      }

      if(totalVolume <= 0.0)
         return 0.0;

      return weightedPrice / totalVolume;
   }

   // Trả về false nếu basket trống hoặc đang trộn BUY và SELL.
   bool GetBasketDirection(
      ENUM_POSITION_TYPE &direction
   ) const
   {
      bool found = false;

      direction = POSITION_TYPE_BUY;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         ENUM_POSITION_TYPE currentType =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(!found)
         {
            direction = currentType;
            found     = true;
            continue;
         }

         if(currentType != direction)
            return false;
      }

      return found;
   }

   // Lấy position mới nhất theo API cũ.
   bool GetLatestPosition(
      double &lastPrice,
      double &lastVolume,
      ENUM_POSITION_TYPE &lastType,
      datetime &lastTime
   ) const
   {
      SLatestPosition latest;

      if(!GetLatestPosition(latest))
         return false;

      lastPrice  = latest.openPrice;
      lastVolume = latest.volume;
      lastType   = latest.type;
      lastTime   = latest.openTime;

      return true;
   }

   // Lấy position mới nhất theo struct mới.
   bool GetLatestPosition(
      SLatestPosition &latest
   ) const
   {
      latest.Reset();

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectByIndex(index))
            continue;

         if(!IsSelectedManagedPosition())
            continue;

         datetime currentTime =
            (datetime)
            PositionGetInteger(
               POSITION_TIME
            );

         if(latest.valid &&
            currentTime < latest.openTime)
         {
            continue;
         }

         latest.ticket =
            (ulong)
            PositionGetInteger(
               POSITION_TICKET
            );

         latest.openPrice =
            PositionGetDouble(
               POSITION_PRICE_OPEN
            );

         latest.volume =
            PositionGetDouble(
               POSITION_VOLUME
            );

         latest.type =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         latest.openTime = currentTime;
         latest.valid    = true;
      }

      return latest.valid;
   }

   ulong LatestTicket() const
   {
      SLatestPosition latest;

      if(!GetLatestPosition(latest))
         return 0;

      return latest.ticket;
   }

   // Tạo snapshot basket chuẩn hóa cho Dashboard và Risk.
   bool GetBasketSnapshot(
      SBasketSnapshot &snapshot
   ) const
   {
      snapshot.Reset();

      snapshot.positionCount =
         CountAll();

      if(snapshot.positionCount <= 0)
         return false;

      snapshot.buyCount =
         CountBuy();

      snapshot.sellCount =
         CountSell();

      snapshot.totalVolume =
         TotalVolume();

      snapshot.totalProfit =
         TotalProfit();

      snapshot.averagePrice =
         AverageOpenPrice();

      snapshot.mixedDirection =
         snapshot.buyCount > 0 &&
         snapshot.sellCount > 0;

      if(snapshot.buyCount > 0 &&
         snapshot.sellCount == 0)
      {
         snapshot.direction =
            POSITION_TYPE_BUY;
      }
      else if(snapshot.sellCount > 0 &&
              snapshot.buyCount == 0)
      {
         snapshot.direction =
            POSITION_TYPE_SELL;
      }

      snapshot.valid = true;
      return true;
   }
};

#endif