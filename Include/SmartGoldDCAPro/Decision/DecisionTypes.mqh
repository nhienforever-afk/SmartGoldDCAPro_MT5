#ifndef SMARTGOLDDCAPRO_DECISION_TYPES_MQH
#define SMARTGOLDDCAPRO_DECISION_TYPES_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Decision Types                                 |
//+------------------------------------------------------------------+

// Trạng thái thị trường được Decision Layer sử dụng.
enum ENUM_MARKET_STATE
{
   MARKET_UNKNOWN = 0,
   MARKET_TREND_UP,
   MARKET_TREND_DOWN,
   MARKET_RANGE,
   MARKET_BREAKOUT
};

// Chất lượng của tín hiệu sau khi chấm điểm.
enum ENUM_SIGNAL_QUALITY
{
   SIGNAL_BAD = 0,
   SIGNAL_WEAK,
   SIGNAL_NORMAL,
   SIGNAL_GOOD,
   SIGNAL_EXCELLENT
};

// Dữ liệu làm việc hiện tại của Decision Engine.
struct DecisionContext
{
   ENUM_MARKET_STATE MarketState;

   double TrendScore;
   double MomentumScore;
   double VolumeScore;
   double VolatilityScore;

   double BuyScore;
   double SellScore;

   bool AllowBuy;
   bool AllowSell;

   datetime TimeStamp;

   // Constructor mặc định.
   DecisionContext()
   {
      Reset();
   }

   // Đưa toàn bộ dữ liệu về trạng thái ban đầu.
   void Reset()
   {
      MarketState = MARKET_UNKNOWN;

      TrendScore      = 0.0;
      MomentumScore   = 0.0;
      VolumeScore     = 0.0;
      VolatilityScore = 0.0;

      BuyScore  = 0.0;
      SellScore = 0.0;

      AllowBuy  = false;
      AllowSell = false;

      TimeStamp = TimeCurrent();
   }
};

#endif