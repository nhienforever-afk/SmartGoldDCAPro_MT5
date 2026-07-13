#ifndef SMARTGOLDDCAPRO_MARKET_ANALYZER_MQH
#define SMARTGOLDDCAPRO_MARKET_ANALYZER_MQH

#include <SmartGoldDCAPro/Market/MarketState.mqh>

class CMarketAnalyzer
{
private:
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   int             m_atrPeriod;
   int             m_atrHandle;
   double          m_highVolatilityATRPoints;

   bool ReadATR(double &atrValue) const
   {
      if(m_atrHandle == INVALID_HANDLE)
         return false;

      double buffer[1];
      if(CopyBuffer(m_atrHandle, 0, 1, 1, buffer) != 1)
         return false;

      atrValue = buffer[0];
      return true;
   }

public:
   CMarketAnalyzer()
   {
      m_symbol                  = _Symbol;
      m_timeframe               = PERIOD_M15;
      m_atrPeriod               = 14;
      m_atrHandle               = INVALID_HANDLE;
      m_highVolatilityATRPoints = 800.0;
   }

   bool Initialize(const string symbol,
                   const ENUM_TIMEFRAMES timeframe,
                   const int atrPeriod,
                   const double highVolatilityATRPoints)
   {
      m_symbol                  = symbol;
      m_timeframe               = timeframe;
      m_atrPeriod               = MathMax(1, atrPeriod);
      m_highVolatilityATRPoints = MathMax(0.0, highVolatilityATRPoints);

      m_atrHandle = iATR(m_symbol, m_timeframe, m_atrPeriod);
      return (m_atrHandle != INVALID_HANDLE);
   }

   void Release()
   {
      if(m_atrHandle != INVALID_HANDLE)
         IndicatorRelease(m_atrHandle);

      m_atrHandle = INVALID_HANDLE;
   }

   bool Read(SMarketState &state) const
   {
      state.timestamp      = TimeCurrent();
      state.atrPoints      = 0.0;
      state.spreadPoints   = 0.0;
      state.bid            = 0.0;
      state.ask            = 0.0;
      state.valid          = false;
      state.highVolatility = false;

      MqlTick tick;
      if(!SymbolInfoTick(m_symbol, tick))
         return false;

      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point <= 0.0)
         return false;

      double atrValue = 0.0;
      if(!ReadATR(atrValue))
         return false;

      state.bid          = tick.bid;
      state.ask          = tick.ask;
      state.atrPoints    = atrValue / point;
      state.spreadPoints = (tick.ask - tick.bid) / point;
      state.highVolatility =
         (m_highVolatilityATRPoints > 0.0 &&
          state.atrPoints >= m_highVolatilityATRPoints);
      state.valid = true;

      return true;
   }
};

#endif
