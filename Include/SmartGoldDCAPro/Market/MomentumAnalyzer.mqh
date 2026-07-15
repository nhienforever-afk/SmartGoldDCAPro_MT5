#ifndef SMARTGOLDDCAPRO_MARKET_MOMENTUM_ANALYZER_MQH
#define SMARTGOLDDCAPRO_MARKET_MOMENTUM_ANALYZER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Momentum Analyzer               |
//+------------------------------------------------------------------+
class CMomentumAnalyzer
{
private:
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;

   int m_rsiPeriod;
   int m_rsiHandle;

   bool ReadRSI(
      double &rsiValue
   ) const
   {
      rsiValue = 0.0;

      if(m_rsiHandle == INVALID_HANDLE)
         return false;

      double buffer[1];

      if(CopyBuffer(
            m_rsiHandle,
            0,
            1,
            1,
            buffer
         ) != 1)
      {
         return false;
      }

      rsiValue = buffer[0];
      return true;
   }

public:
   CMomentumAnalyzer()
   {
      m_symbol = _Symbol;
      m_timeframe = PERIOD_M15;

      m_rsiPeriod = 14;
      m_rsiHandle = INVALID_HANDLE;
   }

   bool Initialize(
      const string symbol,
      const ENUM_TIMEFRAMES timeframe,
      const int rsiPeriod
   )
   {
      Release();

      m_symbol = symbol;
      m_timeframe = timeframe;
      m_rsiPeriod = rsiPeriod;

      if(m_rsiPeriod <= 0)
         return false;

      m_rsiHandle = iRSI(
         m_symbol,
         m_timeframe,
         m_rsiPeriod,
         PRICE_CLOSE
      );

      return m_rsiHandle != INVALID_HANDLE;
   }

   void Release()
   {
      if(m_rsiHandle != INVALID_HANDLE)
         IndicatorRelease(m_rsiHandle);

      m_rsiHandle = INVALID_HANDLE;
   }

   bool Read(
      double &rsiValue
   ) const
   {
      return ReadRSI(
         rsiValue
      );
   }

   double BuyScore() const
   {
      double rsiValue = 0.0;

      if(!ReadRSI(
            rsiValue
         ))
      {
         return 0.0;
      }

      if(rsiValue <= 50.0)
         return 0.0;

      return SGDPNormalizeScore(
         (
            rsiValue -
            50.0
         ) *
         2.0
      );
   }

   double SellScore() const
   {
      double rsiValue = 0.0;

      if(!ReadRSI(
            rsiValue
         ))
      {
         return 0.0;
      }

      if(rsiValue >= 50.0)
         return 0.0;

      return SGDPNormalizeScore(
         (
            50.0 -
            rsiValue
         ) *
         2.0
      );
   }
};

#endif