#ifndef SMARTGOLDDCAPRO_SIGNAL_ENGINE_MQH
#define SMARTGOLDDCAPRO_SIGNAL_ENGINE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>

class CSignalEngine
{
private:
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   int             m_fastHandle;
   int             m_slowHandle;
   int             m_rsiHandle;
   int             m_atrHandle;

   bool ReadValue(const int handle,
                  const int shift,
                  double &value) const
   {
      if(handle == INVALID_HANDLE)
         return false;

      double data[1];

      if(CopyBuffer(handle, 0, shift, 1, data) != 1)
         return false;

      value = data[0];
      return true;
   }

public:
   CSignalEngine()
   {
      m_symbol      = _Symbol;
      m_timeframe   = PERIOD_M15;
      m_fastHandle  = INVALID_HANDLE;
      m_slowHandle  = INVALID_HANDLE;
      m_rsiHandle   = INVALID_HANDLE;
      m_atrHandle   = INVALID_HANDLE;
   }

   bool Initialize(const string symbol,
                   const ENUM_TIMEFRAMES timeframe)
   {
      m_symbol    = symbol;
      m_timeframe = timeframe;

      if(InpUseEMAFilter)
      {
         m_fastHandle = iMA(
            m_symbol,
            m_timeframe,
            InpFastEMAPeriod,
            0,
            MODE_EMA,
            PRICE_CLOSE
         );

         m_slowHandle = iMA(
            m_symbol,
            m_timeframe,
            InpSlowEMAPeriod,
            0,
            MODE_EMA,
            PRICE_CLOSE
         );
      }

      if(InpUseRSIFilter)
      {
         m_rsiHandle = iRSI(
            m_symbol,
            m_timeframe,
            InpRSIPeriod,
            PRICE_CLOSE
         );
      }

      if(InpUseATRFilter)
      {
         m_atrHandle = iATR(
            m_symbol,
            m_timeframe,
            InpATRPeriod
         );
      }

      if(InpUseEMAFilter &&
         (m_fastHandle == INVALID_HANDLE ||
          m_slowHandle == INVALID_HANDLE))
         return false;

      if(InpUseRSIFilter && m_rsiHandle == INVALID_HANDLE)
         return false;

      if(InpUseATRFilter && m_atrHandle == INVALID_HANDLE)
         return false;

      return true;
   }

   void Release()
   {
      if(m_fastHandle != INVALID_HANDLE)
         IndicatorRelease(m_fastHandle);

      if(m_slowHandle != INVALID_HANDLE)
         IndicatorRelease(m_slowHandle);

      if(m_rsiHandle != INVALID_HANDLE)
         IndicatorRelease(m_rsiHandle);

      if(m_atrHandle != INVALID_HANDLE)
         IndicatorRelease(m_atrHandle);

      m_fastHandle = INVALID_HANDLE;
      m_slowHandle = INVALID_HANDLE;
      m_rsiHandle  = INVALID_HANDLE;
      m_atrHandle  = INVALID_HANDLE;
   }

   ENUM_TRADE_SIGNAL GetSignal() const
   {
      bool buyAllowed  = true;
      bool sellAllowed = true;

      if(InpUseATRFilter)
      {
         double atr = 0.0;

         if(!ReadValue(m_atrHandle, 1, atr))
            return SIGNAL_NONE;

         double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);

         if(point <= 0.0)
            return SIGNAL_NONE;

         if(InpMinimumATRPoints > 0.0 &&
            atr / point < InpMinimumATRPoints)
            return SIGNAL_NONE;
      }

      if(InpUseEMAFilter)
      {
         double fast = 0.0;
         double slow = 0.0;

         if(!ReadValue(m_fastHandle, 1, fast) ||
            !ReadValue(m_slowHandle, 1, slow))
            return SIGNAL_NONE;

         buyAllowed  = buyAllowed  && (fast > slow);
         sellAllowed = sellAllowed && (fast < slow);
      }

      if(InpUseRSIFilter)
      {
         double rsi = 0.0;

         if(!ReadValue(m_rsiHandle, 1, rsi))
            return SIGNAL_NONE;

         buyAllowed  = buyAllowed  && (rsi >= InpRSIBuyMinimum);
         sellAllowed = sellAllowed && (rsi <= InpRSISellMaximum);
      }

      if(!InpUseEMAFilter && !InpUseRSIFilter)
      {
         if(InpDirectionMode == DIRECTION_BUY_ONLY)
            return SIGNAL_BUY;

         if(InpDirectionMode == DIRECTION_SELL_ONLY)
            return SIGNAL_SELL;

         return SIGNAL_NONE;
      }

      if(buyAllowed && !sellAllowed)
         return SIGNAL_BUY;

      if(sellAllowed && !buyAllowed)
         return SIGNAL_SELL;

      return SIGNAL_NONE;
   }
};

#endif
