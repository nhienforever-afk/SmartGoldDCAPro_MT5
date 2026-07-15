#ifndef SMARTGOLDDCAPRO_MARKET_VOLATILITY_ANALYZER_MQH
#define SMARTGOLDDCAPRO_MARKET_VOLATILITY_ANALYZER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Volatility Analyzer             |
//+------------------------------------------------------------------+
class CVolatilityAnalyzer
{
private:
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;

   int    m_atrPeriod;
   double m_minimumATRPoints;
   double m_highVolatilityATRPoints;

   int m_atrHandle;

   bool ReadATRValue(
      double &atrValue
   ) const
   {
      atrValue = 0.0;

      if(m_atrHandle == INVALID_HANDLE)
         return false;

      double buffer[1];

      if(CopyBuffer(
            m_atrHandle,
            0,
            1,
            1,
            buffer
         ) != 1)
      {
         return false;
      }

      atrValue = buffer[0];
      return true;
   }

public:
   CVolatilityAnalyzer()
   {
      m_symbol = _Symbol;
      m_timeframe = PERIOD_M15;

      m_atrPeriod = 14;
      m_minimumATRPoints = 100.0;
      m_highVolatilityATRPoints = 800.0;

      m_atrHandle = INVALID_HANDLE;
   }

   bool Initialize(
      const string symbol,
      const ENUM_TIMEFRAMES timeframe,
      const int atrPeriod,
      const double minimumATRPoints,
      const double highVolatilityATRPoints
   )
   {
      Release();

      m_symbol = symbol;
      m_timeframe = timeframe;

      m_atrPeriod = atrPeriod;
      m_minimumATRPoints =
         MathMax(
            0.0,
            minimumATRPoints
         );

      m_highVolatilityATRPoints =
         MathMax(
            m_minimumATRPoints,
            highVolatilityATRPoints
         );

      if(m_atrPeriod <= 0)
         return false;

      m_atrHandle = iATR(
         m_symbol,
         m_timeframe,
         m_atrPeriod
      );

      return m_atrHandle != INVALID_HANDLE;
   }

   void Release()
   {
      if(m_atrHandle != INVALID_HANDLE)
         IndicatorRelease(m_atrHandle);

      m_atrHandle = INVALID_HANDLE;
   }

   bool ReadATRPoints(
      double &atrPoints
   ) const
   {
      atrPoints = 0.0;

      double atrValue = 0.0;

      if(!ReadATRValue(atrValue))
         return false;

      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
         return false;

      atrPoints =
         atrValue /
         point;

      return true;
   }

   double Score() const
   {
      double atrPoints = 0.0;

      if(!ReadATRPoints(atrPoints))
         return 0.0;

      if(atrPoints <
         m_minimumATRPoints)
      {
         return SGDPNormalizeScore(
            (
               atrPoints /
               MathMax(
                  1.0,
                  m_minimumATRPoints
               )
            ) *
            50.0
         );
      }

      if(atrPoints >=
         m_highVolatilityATRPoints)
      {
         return 20.0;
      }

      double usableRange =
         m_highVolatilityATRPoints -
         m_minimumATRPoints;

      if(usableRange <= 0.0)
         return 80.0;

      double progress =
         (
            atrPoints -
            m_minimumATRPoints
         ) /
         usableRange;

      return SGDPNormalizeScore(
         80.0 -
         progress *
         30.0
      );
   }

   bool IsHighVolatility() const
   {
      double atrPoints = 0.0;

      if(!ReadATRPoints(atrPoints))
         return false;

      return
         atrPoints >=
         m_highVolatilityATRPoints;
   }

   double MinimumATRPoints() const
   {
      return m_minimumATRPoints;
   }

   double HighVolatilityATRPoints() const
   {
      return m_highVolatilityATRPoints;
   }
};

#endif