#ifndef SMARTGOLDDCAPRO_CORE_TYPES_MQH
#define SMARTGOLDDCAPRO_CORE_TYPES_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Common Types                    |
//+------------------------------------------------------------------+

// Trạng thái hoạt động tổng thể của EA.
enum ENUM_EA_STATUS
{
   EA_STATUS_STOPPED = 0,
   EA_STATUS_INITIALIZING,
   EA_STATUS_READY,
   EA_STATUS_TRADING,
   EA_STATUS_BLOCKED,
   EA_STATUS_ERROR
};

// Trạng thái xử lý giao dịch hiện tại.
enum ENUM_TRADE_STATE
{
   TRADE_STATE_IDLE = 0,
   TRADE_STATE_ENTRY,
   TRADE_STATE_MANAGE,
   TRADE_STATE_DCA,
   TRADE_STATE_EXIT,
   TRADE_STATE_BLOCKED
};

// Hướng tín hiệu giao dịch.
enum ENUM_TRADE_SIGNAL
{
   SIGNAL_NONE = 0,
   SIGNAL_BUY,
   SIGNAL_SELL
};

// Chế độ tính lot.
enum ENUM_LOT_MODE
{
   LOT_MODE_FIXED = 0,
   LOT_MODE_MULTIPLIER,
   LOT_MODE_MANUAL,
   LOT_MODE_SMART_RISK
};

// Chế độ tính khoảng cách DCA.
enum ENUM_DCA_CONTROL_MODE
{
   DCA_CONTROL_FIXED = 0,
   DCA_CONTROL_ADAPTIVE,
   DCA_CONTROL_MANUAL
};

// Trạng thái thị trường nền tảng.
enum ENUM_MARKET_REGIME
{
   MARKET_REGIME_UNKNOWN = 0,
   MARKET_REGIME_TREND_UP,
   MARKET_REGIME_TREND_DOWN,
   MARKET_REGIME_RANGE,
   MARKET_REGIME_HIGH_VOLATILITY
};

// Mức độ log.
enum ENUM_SGDP_LOG_LEVEL
{
   SGDP_LOG_DEBUG = 0,
   SGDP_LOG_INFO,
   SGDP_LOG_WARNING,
   SGDP_LOG_ERROR
};

// Dữ liệu thị trường được chia sẻ giữa các module.
struct SMarketState
{
   datetime          timestamp;
   double            bid;
   double            ask;
   double            spreadPoints;
   double            atrPoints;
   bool              highVolatility;
   bool              valid;
   ENUM_MARKET_REGIME regime;

   void Reset()
   {
      timestamp      = 0;
      bid            = 0.0;
      ask            = 0.0;
      spreadPoints   = 0.0;
      atrPoints      = 0.0;
      highVolatility = false;
      valid          = false;
      regime         = MARKET_REGIME_UNKNOWN;
   }
};

// Thông tin tóm tắt về basket hiện tại.
struct SBasketSnapshot
{
   int                positionCount;
   int                buyCount;
   int                sellCount;
   double             totalVolume;
   double             totalProfit;
   double             averagePrice;
   bool               mixedDirection;
   ENUM_POSITION_TYPE direction;
   bool               valid;

   void Reset()
   {
      positionCount  = 0;
      buyCount       = 0;
      sellCount      = 0;
      totalVolume    = 0.0;
      totalProfit    = 0.0;
      averagePrice   = 0.0;
      mixedDirection = false;
      direction      = POSITION_TYPE_BUY;
      valid          = false;
   }
};

// Kết quả thực hiện một yêu cầu giao dịch.
struct STradeResult
{
   bool   success;
   ulong  orderTicket;
   ulong  dealTicket;
   uint   retcode;
   string message;

   void Reset()
   {
      success     = false;
      orderTicket = 0;
      dealTicket  = 0;
      retcode     = 0;
      message     = "";
   }
};

// Thông tin vị thế mới nhất trong basket.
struct SLatestPosition
{
   ulong              ticket;
   double             openPrice;
   double             volume;
   ENUM_POSITION_TYPE type;
   datetime           openTime;
   bool               valid;

   void Reset()
   {
      ticket    = 0;
      openPrice = 0.0;
      volume    = 0.0;
      type      = POSITION_TYPE_BUY;
      openTime  = 0;
      valid     = false;
   }
};

// Giới hạn một giá trị double trong khoảng cho trước.
double SGDPClampDouble(
   const double value,
   const double minimumValue,
   const double maximumValue
)
{
   if(value < minimumValue)
      return minimumValue;

   if(value > maximumValue)
      return maximumValue;

   return value;
}

// Chuẩn hóa điểm về khoảng 0–100.
double SGDPNormalizeScore(
   const double value
)
{
   return SGDPClampDouble(
      value,
      0.0,
      100.0
   );
}

// Trả về tên hướng vị thế.
string SGDPPositionTypeName(
   const ENUM_POSITION_TYPE type
)
{
   if(type == POSITION_TYPE_BUY)
      return "BUY";

   if(type == POSITION_TYPE_SELL)
      return "SELL";

   return "UNKNOWN";
}

// Trả về tên tín hiệu.
string SGDPTradeSignalName(
   const ENUM_TRADE_SIGNAL signal
)
{
   if(signal == SIGNAL_BUY)
      return "BUY";

   if(signal == SIGNAL_SELL)
      return "SELL";

   return "NONE";
}

// Trả về tên trạng thái giao dịch.
string SGDPTradeStateName(
   const ENUM_TRADE_STATE state
)
{
   switch(state)
   {
      case TRADE_STATE_IDLE:
         return "IDLE";

      case TRADE_STATE_ENTRY:
         return "ENTRY";

      case TRADE_STATE_MANAGE:
         return "MANAGE";

      case TRADE_STATE_DCA:
         return "DCA";

      case TRADE_STATE_EXIT:
         return "EXIT";

      case TRADE_STATE_BLOCKED:
         return "BLOCKED";
   }

   return "UNKNOWN";
}

#endif