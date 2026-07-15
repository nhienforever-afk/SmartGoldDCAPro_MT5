#ifndef SMARTGOLDDCAPRO_MARKET_ANALYZER_MQH
#define SMARTGOLDDCAPRO_MARKET_ANALYZER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Market/MarketState.mqh>
#include <SmartGoldDCAPro/Market/TrendAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/MomentumAnalyzer.mqh>
#include <SmartGoldDCAPro/Market/VolatilityAnalyzer.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Market Analyzer                 |
//+------------------------------------------------------------------+
class CMarketAnalyzer
{
private:
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;

   CTrendAnalyzer      m_trend;
   CMomentumAnalyzer   m_momentum;
   CVolatilityAnalyzer m_volatility;

   double m_maximumSpreadPoints;

   double CalculateSpreadScore(
      const double spreadPoints
   ) const
   {
      if(m_maximumSpreadPoints <= 0.0)
         return 100.0;

      if(spreadPoints >=
         m_maximumSpreadPoints)
      {
         return 0.0;
      }

      double score =
         100.0 -
         (
            spreadPoints /
            m_maximumSpreadPoints
         ) *
         100.0;

      return SGDPNormalizeScore(score);
   }

public:
   CMarketAnalyzer()
   {
      m_symbol = _Symbol;
      m_timeframe = PERIOD_M15;
      m_maximumSpreadPoints = 80.0;
   }

   bool Initialize(
      const string symbol,
      const ENUM_TIMEFRAMES timeframe,
      const int fastEMAPeriod,
      const int slowEMAPeriod,
      const int rsiPeriod,
      const int atrPeriod,
      const double minimumATRPoints,
      const double highVolatilityATRPoints,
      const double maximumSpreadPoints
   )
   {
      Release();

      m_symbol = symbol;
      m_timeframe = timeframe;

      m_maximumSpreadPoints =
         MathMax(
            0.0,
            maximumSpreadPoints
         );

      bool trendReady =
         m_trend.Initialize(
            m_symbol,
            m_timeframe,
            fastEMAPeriod,
            slowEMAPeriod
         );

      bool momentumReady =
         m_momentum.Initialize(
            m_symbol,
            m_timeframe,
            rsiPeriod
         );

      bool volatilityReady =
         m_volatility.Initialize(
            m_symbol,
            m_timeframe,
            atrPeriod,
            minimumATRPoints,
            highVolatilityATRPoints
         );

      return
         trendReady &&
         momentumReady &&
         volatilityReady;
   }

   void Release()
   {
      m_trend.Release();
      m_momentum.Release();
      m_volatility.Release();
   }

   bool Read(
      SMarketAnalysis &analysis
   ) const
   {
      analysis.Reset();

      MqlTick tick;

      if(!SymbolInfoTick(
            m_symbol,
            tick
         ))
      {
         return false;
      }

      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
         return false;

      double fastEMA = 0.0;
      double slowEMA = 0.0;
      double rsiValue = 0.0;
      double atrPoints = 0.0;

      if(!m_trend.Read(
            fastEMA,
            slowEMA
         ))
      {
         return false;
      }

      if(!m_momentum.Read(
            rsiValue
         ))
      {
         return false;
      }

      if(!m_volatility.ReadATRPoints(
            atrPoints
         ))
      {
         return false;
      }

      analysis.timestamp =
         TimeCurrent();

      analysis.bid =
         tick.bid;

      analysis.ask =
         tick.ask;

      analysis.spreadPoints =
         (
            tick.ask -
            tick.bid
         ) /
         point;

      analysis.fastEMA =
         fastEMA;

      analysis.slowEMA =
         slowEMA;

      analysis.rsiValue =
         rsiValue;

      analysis.atrPoints =
         atrPoints;

      analysis.buyTrendScore =
         m_trend.BuyScore();

      analysis.sellTrendScore =
         m_trend.SellScore();

      analysis.buyMomentumScore =
         m_momentum.BuyScore();

      analysis.sellMomentumScore =
         m_momentum.SellScore();

      analysis.volatilityScore =
         m_volatility.Score();

      analysis.spreadScore =
         CalculateSpreadScore(
            analysis.spreadPoints
         );

      analysis.regime =
         m_trend.Regime();

      if(m_volatility.IsHighVolatility())
      {
         analysis.regime =
            MARKET_REGIME_HIGH_VOLATILITY;
      }

      analysis.valid = true;
      return true;
   }

   double BuyTrendScore() const
   {
      return m_trend.BuyScore();
   }

   double SellTrendScore() const
   {
      return m_trend.SellScore();
   }

   double BuyMomentumScore() const
   {
      return m_momentum.BuyScore();
   }

   double SellMomentumScore() const
   {
      return m_momentum.SellScore();
   }

   double VolatilityScore() const
   {
      return m_volatility.Score();
   }

   double CurrentATRPoints() const
   {
      double atrPoints = 0.0;

      if(!m_volatility.ReadATRPoints(
            atrPoints
         ))
      {
         return 0.0;
      }

      return atrPoints;
   }

   double CurrentSpreadPoints() const
   {
      MqlTick tick;

      if(!SymbolInfoTick(
            m_symbol,
            tick
         ))
      {
         return 0.0;
      }

      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
         return 0.0;

      return
         (
            tick.ask -
            tick.bid
         ) /
         point;
   }

   double SpreadScore() const
   {
      return CalculateSpreadScore(
         CurrentSpreadPoints()
      );
   }
};

#endif