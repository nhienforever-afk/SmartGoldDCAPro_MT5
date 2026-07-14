#ifndef SMARTGOLDDCAPRO_POSITION_MANAGER_MQH
#define SMARTGOLDDCAPRO_POSITION_MANAGER_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Position Manager                               |
//| Quản lý các position theo Symbol và Magic Number                 |
//+------------------------------------------------------------------+
class CPositionManager
{
private:
   string m_symbol;
   long   m_magicNumber;

   // Kiểm tra position đang được chọn có thuộc EA hay không.
   bool IsSelectedPositionManaged() const
   {
      string positionSymbol =
         PositionGetString(
            POSITION_SYMBOL
         );

      long positionMagic =
         PositionGetInteger(
            POSITION_MAGIC
         );

      if(positionSymbol != m_symbol)
         return false;

      if(positionMagic != m_magicNumber)
         return false;

      return true;
   }

   // Chọn position theo chỉ số trong danh sách position hiện tại.
   bool SelectPositionByIndex(
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

public:
   CPositionManager()
   {
      m_symbol      = _Symbol;
      m_magicNumber = 0;
   }

   // Khởi tạo bộ quản lý position.
   void Initialize(
      const string symbol,
      const long magicNumber
   )
   {
      m_symbol      = symbol;
      m_magicNumber = magicNumber;
   }

   // Symbol được quản lý.
   string Symbol() const
   {
      return m_symbol;
   }

   // Magic Number được quản lý.
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
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         count++;
      }

      return count;
   }

   // Đếm position BUY.
   int CountBuy() const
   {
      int count = 0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         ENUM_POSITION_TYPE type =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(type == POSITION_TYPE_BUY)
            count++;
      }

      return count;
   }

   // Đếm position SELL.
   int CountSell() const
   {
      int count = 0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         ENUM_POSITION_TYPE type =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(type == POSITION_TYPE_SELL)
            count++;
      }

      return count;
   }

   // Tổng khối lượng của tất cả position.
   double TotalVolume() const
   {
      double totalVolume = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         totalVolume +=
            PositionGetDouble(
               POSITION_VOLUME
            );
      }

      return totalVolume;
   }

   // Tổng khối lượng BUY.
   double TotalBuyVolume() const
   {
      double totalVolume = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         ENUM_POSITION_TYPE type =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(type != POSITION_TYPE_BUY)
            continue;

         totalVolume +=
            PositionGetDouble(
               POSITION_VOLUME
            );
      }

      return totalVolume;
   }

   // Tổng khối lượng SELL.
   double TotalSellVolume() const
   {
      double totalVolume = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         ENUM_POSITION_TYPE type =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(type != POSITION_TYPE_SELL)
            continue;

         totalVolume +=
            PositionGetDouble(
               POSITION_VOLUME
            );
      }

      return totalVolume;
   }

   // Tổng lợi nhuận thả nổi, bao gồm profit và swap.
   double TotalProfit() const
   {
      double totalProfit = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         totalProfit +=
            PositionGetDouble(
               POSITION_PROFIT
            );

         totalProfit +=
            PositionGetDouble(
               POSITION_SWAP
            );
      }

      return totalProfit;
   }

   // Tổng lợi nhuận BUY.
   double TotalBuyProfit() const
   {
      double totalProfit = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         ENUM_POSITION_TYPE type =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(type != POSITION_TYPE_BUY)
            continue;

         totalProfit +=
            PositionGetDouble(
               POSITION_PROFIT
            );

         totalProfit +=
            PositionGetDouble(
               POSITION_SWAP
            );
      }

      return totalProfit;
   }

   // Tổng lợi nhuận SELL.
   double TotalSellProfit() const
   {
      double totalProfit = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         ENUM_POSITION_TYPE type =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(type != POSITION_TYPE_SELL)
            continue;

         totalProfit +=
            PositionGetDouble(
               POSITION_PROFIT
            );

         totalProfit +=
            PositionGetDouble(
               POSITION_SWAP
            );
      }

      return totalProfit;
   }

   // Kiểm tra basket chỉ có một hướng BUY hoặc SELL.
   // Trả về false nếu không có position hoặc basket bị trộn BUY/SELL.
   bool GetBasketDirection(
      ENUM_POSITION_TYPE &direction
   ) const
   {
      bool hasDirection = false;

      direction = POSITION_TYPE_BUY;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         ENUM_POSITION_TYPE currentType =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(!hasDirection)
         {
            direction    = currentType;
            hasDirection = true;
            continue;
         }

         if(currentType != direction)
            return false;
      }

      return hasDirection;
   }

   // Lấy position được mở gần nhất.
   bool GetLatestPosition(
      double &lastPrice,
      double &lastVolume,
      ENUM_POSITION_TYPE &lastType,
      datetime &lastTime
   ) const
   {
      lastPrice  = 0.0;
      lastVolume = 0.0;
      lastType   = POSITION_TYPE_BUY;
      lastTime   = 0;

      bool found = false;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         datetime positionTime =
            (datetime)
            PositionGetInteger(
               POSITION_TIME
            );

         if(found &&
            positionTime < lastTime)
         {
            continue;
         }

         lastPrice =
            PositionGetDouble(
               POSITION_PRICE_OPEN
            );

         lastVolume =
            PositionGetDouble(
               POSITION_VOLUME
            );

         lastType =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         lastTime = positionTime;
         found    = true;
      }

      return found;
   }

   // Lấy giá mở trung bình có trọng số của toàn basket.
   double AverageOpenPrice() const
   {
      double weightedPrice = 0.0;
      double totalVolume   = 0.0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
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

   // Lấy giá mở trung bình của một hướng cụ thể.
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
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         ENUM_POSITION_TYPE currentType =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
               POSITION_TYPE
            );

         if(currentType != requiredType)
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

   // Kiểm tra EA có position đang mở không.
   bool HasPositions() const
   {
      return CountAll() > 0;
   }

   // Kiểm tra có BUY position hay không.
   bool HasBuyPositions() const
   {
      return CountBuy() > 0;
   }

   // Kiểm tra có SELL position hay không.
   bool HasSellPositions() const
   {
      return CountSell() > 0;
   }

   // Lấy ticket position mới nhất.
   ulong LatestTicket() const
   {
      ulong    latestTicket = 0;
      datetime latestTime   = 0;

      for(int index = 0;
          index < PositionsTotal();
          index++)
      {
         if(!SelectPositionByIndex(index))
            continue;

         if(!IsSelectedPositionManaged())
            continue;

         datetime positionTime =
            (datetime)
            PositionGetInteger(
               POSITION_TIME
            );

         if(latestTicket != 0 &&
            positionTime < latestTime)
         {
            continue;
         }

         latestTicket =
            (ulong)
            PositionGetInteger(
               POSITION_TICKET
            );

         latestTime = positionTime;
      }

      return latestTicket;
   }
};

#endif