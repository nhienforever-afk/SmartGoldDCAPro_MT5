#ifndef SMARTGOLDDCAPRO_SIGNAL_ENGINE_MQH
#define SMARTGOLDDCAPRO_SIGNAL_ENGINE_MQH
<<<<<<< HEAD

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Signal/SignalSnapshot.mqh>

class CSignalEngine
{
private:
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   int             m_fastHandle;
   int             m_slowHandle;
   int             m_rsiHandle;
   int             m_adxHandle;
   int             m_atrHandle;

   mutable SSignalSnapshot m_lastSnapshot;

   bool ReadValue(const int handle,
                  const int bufferIndex,
                  const int shift,
                  double &value) const
   {
      if(handle == INVALID_HANDLE)
         return false;

      double data[1];

      if(CopyBuffer(
            handle,
            bufferIndex,
            shift,
            1,
            data) != 1)
         return false;

      value = data[0];
      return true;
   }

   void ResetSnapshot() const
   {
      m_lastSnapshot.timestamp = TimeCurrent();
      m_lastSnapshot.buyScore  = 0.0;
      m_lastSnapshot.sellScore = 0.0;
      m_lastSnapshot.emaFast   = 0.0;
      m_lastSnapshot.emaSlow   = 0.0;
      m_lastSnapshot.rsi       = 0.0;
      m_lastSnapshot.adx       = 0.0;
      m_lastSnapshot.plusDI    = 0.0;
      m_lastSnapshot.minusDI   = 0.0;
      m_lastSnapshot.atrPoints = 0.0;
      m_lastSnapshot.valid     = false;
   }

public:
   CSignalEngine()
   {
      m_symbol     = _Symbol;
      m_timeframe  = PERIOD_M15;
      m_fastHandle = INVALID_HANDLE;
      m_slowHandle = INVALID_HANDLE;
      m_rsiHandle  = INVALID_HANDLE;
      m_adxHandle  = INVALID_HANDLE;
      m_atrHandle  = INVALID_HANDLE;
      ResetSnapshot();
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

      if(InpUseADXFilter)
      {
         m_adxHandle = iADX(
            m_symbol,
            m_timeframe,
            InpADXPeriod
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

      if(InpUseRSIFilter &&
         m_rsiHandle == INVALID_HANDLE)
         return false;

      if(InpUseADXFilter &&
         m_adxHandle == INVALID_HANDLE)
         return false;

      if(InpUseATRFilter &&
         m_atrHandle == INVALID_HANDLE)
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

      if(m_adxHandle != INVALID_HANDLE)
         IndicatorRelease(m_adxHandle);

      if(m_atrHandle != INVALID_HANDLE)
         IndicatorRelease(m_atrHandle);

      m_fastHandle = INVALID_HANDLE;
      m_slowHandle = INVALID_HANDLE;
      m_rsiHandle  = INVALID_HANDLE;
      m_adxHandle  = INVALID_HANDLE;
      m_atrHandle  = INVALID_HANDLE;
   }

   ENUM_TRADE_SIGNAL GetSignal() const
   {
      ResetSnapshot();

      double totalWeight = 0.0;
      double buyWeight   = 0.0;
      double sellWeight  = 0.0;

      if(InpUseATRFilter)
      {
         double atr = 0.0;

         if(!ReadValue(
               m_atrHandle,
               0,
               1,
               atr))
            return SIGNAL_NONE;

         double point =
            SymbolInfoDouble(
               m_symbol,
               SYMBOL_POINT
            );

         if(point <= 0.0)
            return SIGNAL_NONE;

         m_lastSnapshot.atrPoints =
            atr / point;

         if(InpMinimumATRPoints > 0.0 &&
            m_lastSnapshot.atrPoints <
            InpMinimumATRPoints)
            return SIGNAL_NONE;
      }

      if(InpUseEMAFilter)
      {
         if(!ReadValue(
               m_fastHandle,
               0,
               1,
               m_lastSnapshot.emaFast) ||
            !ReadValue(
               m_slowHandle,
               0,
               1,
               m_lastSnapshot.emaSlow))
            return SIGNAL_NONE;

         totalWeight += InpEMAWeight;

         if(m_lastSnapshot.emaFast >
            m_lastSnapshot.emaSlow)
            buyWeight += InpEMAWeight;
         else if(m_lastSnapshot.emaFast <
                 m_lastSnapshot.emaSlow)
            sellWeight += InpEMAWeight;
      }

      if(InpUseRSIFilter)
      {
         if(!ReadValue(
               m_rsiHandle,
               0,
               1,
               m_lastSnapshot.rsi))
            return SIGNAL_NONE;

         totalWeight += InpRSIWeight;

         if(m_lastSnapshot.rsi >=
            InpRSIBuyMinimum)
            buyWeight += InpRSIWeight;
         else if(m_lastSnapshot.rsi <=
                 InpRSISellMaximum)
            sellWeight += InpRSIWeight;
      }

      if(InpUseADXFilter)
      {
         if(!ReadValue(
               m_adxHandle,
               0,
               1,
               m_lastSnapshot.adx) ||
            !ReadValue(
               m_adxHandle,
               1,
               1,
               m_lastSnapshot.plusDI) ||
            !ReadValue(
               m_adxHandle,
               2,
               1,
               m_lastSnapshot.minusDI))
            return SIGNAL_NONE;

         totalWeight += InpADXWeight;

         if(m_lastSnapshot.adx >=
            InpMinimumADX)
         {
            if(m_lastSnapshot.plusDI >
               m_lastSnapshot.minusDI)
               buyWeight += InpADXWeight;
            else if(m_lastSnapshot.minusDI >
                    m_lastSnapshot.plusDI)
               sellWeight += InpADXWeight;
         }
      }

      if(totalWeight <= 0.0)
      {
         if(InpDirectionMode ==
            DIRECTION_BUY_ONLY)
         {
            m_lastSnapshot.buyScore = 100.0;
            m_lastSnapshot.valid = true;
            return SIGNAL_BUY;
         }

         if(InpDirectionMode ==
            DIRECTION_SELL_ONLY)
         {
            m_lastSnapshot.sellScore = 100.0;
            m_lastSnapshot.valid = true;
            return SIGNAL_SELL;
         }

         return SIGNAL_NONE;
      }

      m_lastSnapshot.buyScore =
         buyWeight / totalWeight * 100.0;

      m_lastSnapshot.sellScore =
         sellWeight / totalWeight * 100.0;

      m_lastSnapshot.valid = true;

      if(!InpUseWeightedSignal)
      {
         if(buyWeight >= totalWeight &&
            sellWeight <= 0.0)
            return SIGNAL_BUY;

         if(sellWeight >= totalWeight &&
            buyWeight <= 0.0)
            return SIGNAL_SELL;

         return SIGNAL_NONE;
      }

      double advantage =
         MathAbs(
            m_lastSnapshot.buyScore -
            m_lastSnapshot.sellScore
         );

      if(advantage <
         InpMinimumScoreAdvantage)
         return SIGNAL_NONE;

      if(m_lastSnapshot.buyScore >=
            InpMinimumSignalScore &&
         m_lastSnapshot.buyScore >
            m_lastSnapshot.sellScore)
         return SIGNAL_BUY;

      if(m_lastSnapshot.sellScore >=
            InpMinimumSignalScore &&
         m_lastSnapshot.sellScore >
            m_lastSnapshot.buyScore)
         return SIGNAL_SELL;

      return SIGNAL_NONE;
   }

   double LastBuyScore() const
   {
      return m_lastSnapshot.buyScore;
   }

   double LastSellScore() const
   {
      return m_lastSnapshot.sellScore;
   }

   double LastADX() const
   {
      return m_lastSnapshot.adx;
   }

   double LastRSI() const
   {
      return m_lastSnapshot.rsi;
   }

   bool LastSnapshotValid() const
   {
      return m_lastSnapshot.valid;
   }
};

=======
#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
class CSignalEngine{
private:string m_symbol;ENUM_TIMEFRAMES m_timeframe;int m_fast,m_slow,m_rsi,m_atr;
 bool ReadValue(const int handle,const int shift,double &value) const{double d[1];if(handle==INVALID_HANDLE)return false;if(CopyBuffer(handle,0,shift,1,d)!=1)return false;value=d[0];return true;}
public:
 CSignalEngine(){m_symbol=_Symbol;m_timeframe=PERIOD_M15;m_fast=m_slow=m_rsi=m_atr=INVALID_HANDLE;}
 bool Initialize(const string symbol,const ENUM_TIMEFRAMES tf){m_symbol=symbol;m_timeframe=tf;m_fast=iMA(m_symbol,m_timeframe,InpFastEMAPeriod,0,MODE_EMA,PRICE_CLOSE);m_slow=iMA(m_symbol,m_timeframe,InpSlowEMAPeriod,0,MODE_EMA,PRICE_CLOSE);m_rsi=iRSI(m_symbol,m_timeframe,InpRSIPeriod,PRICE_CLOSE);m_atr=iATR(m_symbol,m_timeframe,InpATRPeriod);return m_fast!=INVALID_HANDLE&&m_slow!=INVALID_HANDLE&&m_rsi!=INVALID_HANDLE&&m_atr!=INVALID_HANDLE;}
 void Release(){if(m_fast!=INVALID_HANDLE)IndicatorRelease(m_fast);if(m_slow!=INVALID_HANDLE)IndicatorRelease(m_slow);if(m_rsi!=INVALID_HANDLE)IndicatorRelease(m_rsi);if(m_atr!=INVALID_HANDLE)IndicatorRelease(m_atr);m_fast=m_slow=m_rsi=m_atr=INVALID_HANDLE;}
 ENUM_TRADE_SIGNAL GetSignal() const{double fast,slow,rsi,atr;if(!ReadValue(m_fast,1,fast)||!ReadValue(m_slow,1,slow)||!ReadValue(m_rsi,1,rsi)||!ReadValue(m_atr,1,atr))return SIGNAL_NONE;double point=SymbolInfoDouble(m_symbol,SYMBOL_POINT);if(point<=0.0)return SIGNAL_NONE;if(InpMinimumATRPoints>0.0&&atr/point<InpMinimumATRPoints)return SIGNAL_NONE;if(fast>slow&&rsi>=InpRSIBuyMinimum)return SIGNAL_BUY;if(fast<slow&&rsi<=InpRSISellMaximum)return SIGNAL_SELL;return SIGNAL_NONE;}
};
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
#endif
