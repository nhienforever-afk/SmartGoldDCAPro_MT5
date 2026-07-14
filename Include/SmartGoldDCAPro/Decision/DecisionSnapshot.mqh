#ifndef SMARTGOLDDCAPRO_DECISION_SNAPSHOT_MQH
#define SMARTGOLDDCAPRO_DECISION_SNAPSHOT_MQH

#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Decision Snapshot                              |
//| Lưu kết quả đánh giá gần nhất của Decision Engine                |
//+------------------------------------------------------------------+
struct DecisionSnapshot
{
   datetime          TimeStamp;
   string            Symbol;
   ENUM_MARKET_STATE MarketState;

   double BuyScore;
   double SellScore;

   double TrendScore;
   double MomentumScore;
   double VolumeScore;
   double VolatilityScore;
   double SpreadScore;

   bool AllowBuy;
   bool AllowSell;

   string Decision;
   string BuyQuality;
   string SellQuality;
   string Reason;

   bool Valid;

   // Khởi tạo toàn bộ dữ liệu về trạng thái mặc định.
   void Reset()
   {
      TimeStamp       = 0;
      Symbol          = "";
      MarketState     = MARKET_UNKNOWN;

      BuyScore        = 0.0;
      SellScore       = 0.0;

      TrendScore      = 0.0;
      MomentumScore   = 0.0;
      VolumeScore     = 0.0;
      VolatilityScore = 0.0;
      SpreadScore     = 0.0;

      AllowBuy        = false;
      AllowSell       = false;

      Decision        = "WAIT";
      BuyQuality      = "BAD";
      SellQuality     = "BAD";
      Reason          = "No decision data";

      Valid           = false;
   }

   // Trả về tên trạng thái thị trường để hiển thị Dashboard/Journal.
   string MarketStateName() const
   {
      switch(MarketState)
      {
         case MARKET_TREND_UP:
            return "TREND UP";

         case MARKET_TREND_DOWN:
            return "TREND DOWN";

         case MARKET_RANGE:
            return "RANGE";

         case MARKET_BREAKOUT:
            return "BREAKOUT";

         default:
            return "UNKNOWN";
      }
   }

   // Kiểm tra snapshot có cho phép bất kỳ hướng giao dịch nào không.
   bool HasApprovedDirection() const
   {
      return AllowBuy || AllowSell;
   }

   // Trả về điểm cao nhất giữa BUY và SELL.
   double BestScore() const
   {
      return MathMax(BuyScore, SellScore);
   }

   // Trả về chênh lệch tuyệt đối giữa BUY và SELL.
   double ScoreAdvantage() const
   {
      return MathAbs(BuyScore - SellScore);
   }
};

//+------------------------------------------------------------------+
//| Tạo snapshot mặc định                                            |
//+------------------------------------------------------------------+
DecisionSnapshot CreateEmptyDecisionSnapshot()
{
   DecisionSnapshot snapshot;
   snapshot.Reset();

   return snapshot;
}

#endif