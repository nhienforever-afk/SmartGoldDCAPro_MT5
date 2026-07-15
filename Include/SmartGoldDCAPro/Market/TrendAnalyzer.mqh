#ifndef SMARTGOLDDCAPRO_MARKET_TREND_ANALYZER_MQH
#define SMARTGOLDDCAPRO_MARKET_TREND_ANALYZER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Trend Analyzer                  |
//+------------------------------------------------------------------+
class CTrendAnalyzer
{
private:
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;

   int m_fastPeriod;
   int m_slowPeriod;

   int m_fastHandle;
   int m_slowHandle;

   bool ReadValue(
      const int handle,
      double &value
   ) const
   {
      value = 0.0;

      if(handle == INVALID_HANDLE)
         return false;

      double buffer[1];

      if(CopyBuffer(
            handle,
            0,
            1,
            1,
            buffer
         ) != 1)
      {
         return false;
      }

      value = buffer[0];
      return true;
   }

public:
   CTrendAnalyzer()
   {
      m_symbol = _Symbol;
      m_timeframe = PERIOD_M15;

      m_fastPeriod = 20;
      m_slowPeriod = 50;

      m_fastHandle = INVALID_HANDLE;
      m_slowHandle = INVALID_HANDLE;
   }

   bool Initialize(
      const string symbol,
      const ENUM_TIMEFRAMES timeframe,
      const int fastPeriod,
      const int slowPeriod
   )
   {
      Release();

      m_symbol = symbol;
      m_timeframe = timeframe;

      m_fastPeriod = fastPeriod;
      m_slowPeriod = slowPeriod;

      if(m_fastPeriod <= 0 ||
         m_slowPeriod <= 0 ||
         m_fastPeriod >= m_slowPeriod)
      {
         return false;
      }

      m_fastHandle = iMA(
         m_symbol,
         m_timeframe,
         m_fastPeriod,
         0,
         MODE_EMA,
         PRICE_CLOSE
      );

      m_slowHandle = iMA(
         m_symbol,
         m_timeframe,
         m_slowPeriod,
         0,
         MODE_EMA,
         PRICE_CLOSE
      );

      return
         m_fastHandle != INVALID_HANDLE &&
         m_slowHandle != INVALID_HANDLE;
   }

   void Release()
   {
      if(m_fastHandle != INVALID_HANDLE)
         IndicatorRelease(m_fastHandle);

      if(m_slowHandle != INVALID_HANDLE)
         IndicatorRelease(m_slowHandle);

      m_fastHandle = INVALID_HANDLE;
      m_slowHandle = INVALID_HANDLE;
   }

   bool Read(
      double &fastEMA,
      double &slowEMA
   ) const
   {
      if(!ReadValue(
            m_fastHandle,
            fastEMA
         ))
      {
         return false;
      }

      if(!ReadValue(
            m_slowHandle,
            slowEMA
         ))
      {
         return false;
      }

      return true;
   }

   double BuyScore() const
   {
      double fastEMA = 0.0;
      double slowEMA = 0.0;

      if(!Read(
            fastEMA,
            slowEMA
         ))
      {
         return 0.0;
      }

      if(fastEMA <= slowEMA)
         return 0.0;

      double difference =
         MathAbs(
            fastEMA -
            slowEMA
         );

      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
         return 0.0;

      double distancePoints =
         difference /
         point;

      return SGDPNormalizeScore(
         50.0 +
         MathMin(
            50.0,
            distancePoints /
            10.0
         )
      );
   }

   double SellScore() const
   {
      double fastEMA = 0.0;
      double slowEMA = 0.0;

      if(!Read(
            fastEMA,
            slowEMA
         ))
      {
         return 0.0;
      }

      if(fastEMA >= slowEMA)
         return 0.0;

      double difference =
         MathAbs(
            fastEMA -
            slowEMA
         );

      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
         return 0.0;

      double distancePoints =
         difference /
         point;

      return SGDPNormalizeScore(
         50.0 +
         MathMin(
            50.0,
            distancePoints /
            10.0
         )
      );
   }

   ENUM_MARKET_REGIME Regime() const
   {
      double buyScore = BuyScore();
      double sellScore = SellScore();

      if(buyScore >= 60.0 &&
         buyScore > sellScore)
      {
         return MARKET_REGIME_TREND_UP;
      }

      if(sellScore >= 60.0 &&
         sellScore > buyScore)
      {
         return MARKET_REGIME_TREND_DOWN;
      }

      return MARKET_REGIME_RANGE;
   }
};

#endif