#ifndef SMARTGOLDDCAPRO_DECISION_ENGINE_MQH
#define SMARTGOLDDCAPRO_DECISION_ENGINE_MQH

#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>
#include <SmartGoldDCAPro/Decision/DecisionScore.mqh>
#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>
#include <SmartGoldDCAPro/Analytics/MarketMemory.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Decision Engine                                |
//| Tổng hợp điểm và tạo quyết định BUY / SELL / WAIT                |
//+------------------------------------------------------------------+
class CDecisionEngine
{
private:
   DecisionContext m_context;

   CDecisionScore  m_buyDecisionScore;
   CDecisionScore  m_sellDecisionScore;

   CMarketMemory   m_memory;

   double          m_minimumDecisionScore;
   double          m_minimumScoreAdvantage;

   // Giới hạn điểm trong khoảng 0 đến 100.
   double NormalizeScore(
      const double value
   ) const
   {
      if(value < 0.0)
         return 0.0;

      if(value > 100.0)
         return 100.0;

      return value;
   }

   // Tạo snapshot từ dữ liệu hiện tại.
   DecisionSnapshot BuildSnapshot(
      const string symbol,
      const double spreadScore,
      const string reason
   ) const
   {
      DecisionSnapshot snapshot;

      snapshot.Reset();

      snapshot.TimeStamp   = TimeCurrent();
      snapshot.Symbol      = symbol;
      snapshot.MarketState = m_context.MarketState;

      snapshot.BuyScore  = m_context.BuyScore;
      snapshot.SellScore = m_context.SellScore;

      snapshot.TrendScore =
         m_context.TrendScore;

      snapshot.MomentumScore =
         m_context.MomentumScore;

      snapshot.VolumeScore =
         m_context.VolumeScore;

      snapshot.VolatilityScore =
         m_context.VolatilityScore;

      snapshot.SpreadScore =
         NormalizeScore(spreadScore);

      snapshot.AllowBuy =
         m_context.AllowBuy;

      snapshot.AllowSell =
         m_context.AllowSell;

      snapshot.Decision =
         DecisionName();

      snapshot.BuyQuality =
         m_buyDecisionScore.QualityName();

      snapshot.SellQuality =
         m_sellDecisionScore.QualityName();

      snapshot.Reason = reason;
      snapshot.Valid  = true;

      return snapshot;
   }

public:
   CDecisionEngine()
   {
      m_minimumDecisionScore  = 65.0;
      m_minimumScoreAdvantage = 10.0;

      Reset();
   }

   // Khởi tạo ngưỡng quyết định.
   void Initialize(
      const double minimumDecisionScore,
      const double minimumScoreAdvantage
   )
   {
      m_minimumDecisionScore =
         NormalizeScore(
            minimumDecisionScore
         );

      m_minimumScoreAdvantage =
         NormalizeScore(
            minimumScoreAdvantage
         );

      Reset();
   }

   // Xóa dữ liệu đánh giá hiện tại.
   void Reset()
   {
      m_context.MarketState =
         MARKET_UNKNOWN;

      m_context.TrendScore =
         0.0;

      m_context.MomentumScore =
         0.0;

      m_context.VolumeScore =
         0.0;

      m_context.VolatilityScore =
         0.0;

      m_context.BuyScore =
         0.0;

      m_context.SellScore =
         0.0;

      m_context.AllowBuy =
         false;

      m_context.AllowSell =
         false;

      m_context.TimeStamp =
         TimeCurrent();

      m_buyDecisionScore.Reset();
      m_sellDecisionScore.Reset();
   }

   // Xóa cả Decision Engine và Market Memory.
   void Clear()
   {
      Reset();
      m_memory.Clear();
   }

   // Đặt trạng thái thị trường.
   void SetMarketState(
      const ENUM_MARKET_STATE marketState
   )
   {
      m_context.MarketState =
         marketState;
   }

   // Cấu hình trọng số chung cho BUY và SELL.
   void SetWeights(
      const double trendWeight,
      const double momentumWeight,
      const double volumeWeight,
      const double volatilityWeight,
      const double spreadWeight
   )
   {
      m_buyDecisionScore.SetWeights(
         trendWeight,
         momentumWeight,
         volumeWeight,
         volatilityWeight,
         spreadWeight
      );

      m_sellDecisionScore.SetWeights(
         trendWeight,
         momentumWeight,
         volumeWeight,
         volatilityWeight,
         spreadWeight
      );
   }

   // Đánh giá và tạo quyết định.
   void Evaluate(
      const string symbol,
      const double buyTrendScore,
      const double sellTrendScore,
      const double buyMomentumScore,
      const double sellMomentumScore,
      const double buyVolumeScore,
      const double sellVolumeScore,
      const double volatilityScore,
      const double spreadScore
   )
   {
      double normalizedBuyTrend =
         NormalizeScore(
            buyTrendScore
         );

      double normalizedSellTrend =
         NormalizeScore(
            sellTrendScore
         );

      double normalizedBuyMomentum =
         NormalizeScore(
            buyMomentumScore
         );

      double normalizedSellMomentum =
         NormalizeScore(
            sellMomentumScore
         );

      double normalizedBuyVolume =
         NormalizeScore(
            buyVolumeScore
         );

      double normalizedSellVolume =
         NormalizeScore(
            sellVolumeScore
         );

      double normalizedVolatility =
         NormalizeScore(
            volatilityScore
         );

      double normalizedSpread =
         NormalizeScore(
            spreadScore
         );

      m_context.TrendScore =
         MathMax(
            normalizedBuyTrend,
            normalizedSellTrend
         );

      m_context.MomentumScore =
         MathMax(
            normalizedBuyMomentum,
            normalizedSellMomentum
         );

      m_context.VolumeScore =
         MathMax(
            normalizedBuyVolume,
            normalizedSellVolume
         );

      m_context.VolatilityScore =
         normalizedVolatility;

      m_context.TimeStamp =
         TimeCurrent();

      m_buyDecisionScore.SetScores(
         normalizedBuyTrend,
         normalizedBuyMomentum,
         normalizedBuyVolume,
         normalizedVolatility,
         normalizedSpread
      );

      m_sellDecisionScore.SetScores(
         normalizedSellTrend,
         normalizedSellMomentum,
         normalizedSellVolume,
         normalizedVolatility,
         normalizedSpread
      );

      m_context.BuyScore =
         m_buyDecisionScore.Total();

      m_context.SellScore =
         m_sellDecisionScore.Total();

      m_context.AllowBuy  = false;
      m_context.AllowSell = false;

      double scoreDifference =
         MathAbs(
            m_context.BuyScore -
            m_context.SellScore
         );

      string reason =
         "Decision score is below threshold.";

      if(scoreDifference <
         m_minimumScoreAdvantage)
      {
         reason =
            "BUY and SELL scores are too close.";

         DecisionSnapshot snapshot =
            BuildSnapshot(
               symbol,
               normalizedSpread,
               reason
            );

         m_memory.Store(snapshot);
         return;
      }

      if(m_context.BuyScore >=
            m_minimumDecisionScore &&
         m_context.BuyScore >
            m_context.SellScore)
      {
         m_context.AllowBuy = true;

         reason =
            "BUY score approved.";

         DecisionSnapshot snapshot =
            BuildSnapshot(
               symbol,
               normalizedSpread,
               reason
            );

         m_memory.Store(snapshot);
         return;
      }

      if(m_context.SellScore >=
            m_minimumDecisionScore &&
         m_context.SellScore >
            m_context.BuyScore)
      {
         m_context.AllowSell = true;

         reason =
            "SELL score approved.";

         DecisionSnapshot snapshot =
            BuildSnapshot(
               symbol,
               normalizedSpread,
               reason
            );

         m_memory.Store(snapshot);
         return;
      }

      DecisionSnapshot snapshot =
         BuildSnapshot(
            symbol,
            normalizedSpread,
            reason
         );

      m_memory.Store(snapshot);
   }

   DecisionContext GetContext() const
   {
      return m_context;
   }

   DecisionSnapshot LastSnapshot() const
   {
      return m_memory.LastSnapshot();
   }

   bool HasSnapshot() const
   {
      return m_memory.HasSnapshot();
   }

   double BuyScore() const
   {
      return m_context.BuyScore;
   }

   double SellScore() const
   {
      return m_context.SellScore;
   }

   double ScoreAdvantage() const
   {
      return MathAbs(
         m_context.BuyScore -
         m_context.SellScore
      );
   }

   bool AllowBuy() const
   {
      return m_context.AllowBuy;
   }

   bool AllowSell() const
   {
      return m_context.AllowSell;
   }

   string DecisionName() const
   {
      if(m_context.AllowBuy)
         return "BUY";

      if(m_context.AllowSell)
         return "SELL";

      return "WAIT";
   }

   string BuyQualityName() const
   {
      return
         m_buyDecisionScore.QualityName();
   }

   string SellQualityName() const
   {
      return
         m_sellDecisionScore.QualityName();
   }

   string LastReason() const
   {
      return m_memory.LastReason();
   }

   string LastMarketStateName() const
   {
      return
         m_memory.LastMarketStateName();
   }
};

#endif