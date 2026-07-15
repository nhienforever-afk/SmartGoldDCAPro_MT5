#ifndef SMARTGOLDDCAPRO_SIGNAL_ENGINE_MQH
#define SMARTGOLDDCAPRO_SIGNAL_ENGINE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Signal/SignalSnapshot.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Signal Engine                   |
//+------------------------------------------------------------------+
class CSignalEngine
{
private:
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;

   int m_fastEMAHandle;
   int m_slowEMAHandle;
   int m_rsiHandle;
   int m_adxHandle;
   int m_atrHandle;

   SSignalSnapshot m_lastSnapshot;

   bool ReadBufferValue(
      const int handle,
      const int bufferIndex,
      double &value
   ) const
   {
      value = 0.0;

      if(handle == INVALID_HANDLE)
         return false;

      double buffer[1];

      if(CopyBuffer(
            handle,
            bufferIndex,
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

   double EMAAlignmentScore(
      const double fastEMA,
      const double slowEMA
   ) const
   {
      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
         return 0.0;

      double distancePoints =
         MathAbs(
            fastEMA -
            slowEMA
         ) /
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

   double RSIBuyScore(
      const double rsiValue
   ) const
   {
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

   double RSISellScore(
      const double rsiValue
   ) const
   {
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

   double ADXScore(
      const double adxValue
   ) const
   {
      if(adxValue <= 0.0)
         return 0.0;

      return SGDPNormalizeScore(
         adxValue *
         2.0
      );
   }

   double ATRScore(
      const double atrPoints
   ) const
   {
      if(atrPoints <= 0.0)
         return 0.0;

      if(atrPoints <
         InpMinimumATRPoints)
      {
         return SGDPNormalizeScore(
            (
               atrPoints /
               MathMax(
                  1.0,
                  InpMinimumATRPoints
               )
            ) *
            50.0
         );
      }

      if(atrPoints >=
         InpHighVolatilityATRPoints)
      {
         return 20.0;
      }

      return 80.0;
   }

   double WeightedScore(
      const double emaScore,
      const double rsiScore,
      const double adxScore
   ) const
   {
      double totalWeight = 0.0;
      double totalScore  = 0.0;

      if(InpUseEMAFilter)
      {
         totalWeight +=
            MathMax(
               0.0,
               InpEMAWeight
            );

         totalScore +=
            emaScore *
            MathMax(
               0.0,
               InpEMAWeight
            );
      }

      if(InpUseRSIFilter)
      {
         totalWeight +=
            MathMax(
               0.0,
               InpRSIWeight
            );

         totalScore +=
            rsiScore *
            MathMax(
               0.0,
               InpRSIWeight
            );
      }

      if(InpUseADXFilter)
      {
         totalWeight +=
            MathMax(
               0.0,
               InpADXWeight
            );

         totalScore +=
            adxScore *
            MathMax(
               0.0,
               InpADXWeight
            );
      }

      if(totalWeight <= 0.0)
         return 0.0;

      return SGDPNormalizeScore(
         totalScore /
         totalWeight
      );
   }

public:
   CSignalEngine()
   {
      m_symbol    = _Symbol;
      m_timeframe = PERIOD_M15;

      m_fastEMAHandle = INVALID_HANDLE;
      m_slowEMAHandle = INVALID_HANDLE;
      m_rsiHandle     = INVALID_HANDLE;
      m_adxHandle     = INVALID_HANDLE;
      m_atrHandle     = INVALID_HANDLE;

      m_lastSnapshot.Reset();
   }

   bool Initialize(
      const string symbol,
      const ENUM_TIMEFRAMES timeframe
   )
   {
      Release();

      m_symbol    = symbol;
      m_timeframe = timeframe;

      m_fastEMAHandle =
         iMA(
            m_symbol,
            m_timeframe,
            InpFastEMAPeriod,
            0,
            MODE_EMA,
            PRICE_CLOSE
         );

      m_slowEMAHandle =
         iMA(
            m_symbol,
            m_timeframe,
            InpSlowEMAPeriod,
            0,
            MODE_EMA,
            PRICE_CLOSE
         );

      m_rsiHandle =
         iRSI(
            m_symbol,
            m_timeframe,
            InpRSIPeriod,
            PRICE_CLOSE
         );

      m_adxHandle =
         iADX(
            m_symbol,
            m_timeframe,
            InpADXPeriod
         );

      m_atrHandle =
         iATR(
            m_symbol,
            m_timeframe,
            InpATRPeriod
         );

      bool emaReady =
         m_fastEMAHandle != INVALID_HANDLE &&
         m_slowEMAHandle != INVALID_HANDLE;

      bool rsiReady =
         m_rsiHandle != INVALID_HANDLE;

      bool adxReady =
         m_adxHandle != INVALID_HANDLE;

      bool atrReady =
         m_atrHandle != INVALID_HANDLE;

      if(InpUseEMAFilter &&
         !emaReady)
      {
         return false;
      }

      if(InpUseRSIFilter &&
         !rsiReady)
      {
         return false;
      }

      if(InpUseADXFilter &&
         !adxReady)
      {
         return false;
      }

      if(InpUseATRFilter &&
         !atrReady)
      {
         return false;
      }

      return true;
   }

   void Release()
   {
      if(m_fastEMAHandle != INVALID_HANDLE)
         IndicatorRelease(m_fastEMAHandle);

      if(m_slowEMAHandle != INVALID_HANDLE)
         IndicatorRelease(m_slowEMAHandle);

      if(m_rsiHandle != INVALID_HANDLE)
         IndicatorRelease(m_rsiHandle);

      if(m_adxHandle != INVALID_HANDLE)
         IndicatorRelease(m_adxHandle);

      if(m_atrHandle != INVALID_HANDLE)
         IndicatorRelease(m_atrHandle);

      m_fastEMAHandle = INVALID_HANDLE;
      m_slowEMAHandle = INVALID_HANDLE;
      m_rsiHandle     = INVALID_HANDLE;
      m_adxHandle     = INVALID_HANDLE;
      m_atrHandle     = INVALID_HANDLE;

      m_lastSnapshot.Reset();
   }

   bool Evaluate()
   {
      m_lastSnapshot.Reset();

      double fastEMA  = 0.0;
      double slowEMA  = 0.0;
      double rsiValue = 50.0;
      double adxValue = 0.0;
      double atrValue = 0.0;

      if(InpUseEMAFilter)
      {
         if(!ReadBufferValue(
               m_fastEMAHandle,
               0,
               fastEMA
            ))
         {
            m_lastSnapshot.reason =
               "Cannot read Fast EMA.";

            return false;
         }

         if(!ReadBufferValue(
               m_slowEMAHandle,
               0,
               slowEMA
            ))
         {
            m_lastSnapshot.reason =
               "Cannot read Slow EMA.";

            return false;
         }
      }

      if(InpUseRSIFilter)
      {
         if(!ReadBufferValue(
               m_rsiHandle,
               0,
               rsiValue
            ))
         {
            m_lastSnapshot.reason =
               "Cannot read RSI.";

            return false;
         }
      }

      if(InpUseADXFilter)
      {
         if(!ReadBufferValue(
               m_adxHandle,
               0,
               adxValue
            ))
         {
            m_lastSnapshot.reason =
               "Cannot read ADX.";

            return false;
         }
      }

      if(InpUseATRFilter)
      {
         if(!ReadBufferValue(
               m_atrHandle,
               0,
               atrValue
            ))
         {
            m_lastSnapshot.reason =
               "Cannot read ATR.";

            return false;
         }
      }

      double point =
         SymbolInfoDouble(
            m_symbol,
            SYMBOL_POINT
         );

      if(point <= 0.0)
      {
         m_lastSnapshot.reason =
            "Invalid symbol point.";

         return false;
      }

      double atrPoints =
         atrValue /
         point;

      double emaScore =
         EMAAlignmentScore(
            fastEMA,
            slowEMA
         );

      m_lastSnapshot.timestamp =
         TimeCurrent();

      m_lastSnapshot.fastEMA =
         fastEMA;

      m_lastSnapshot.slowEMA =
         slowEMA;

      m_lastSnapshot.rsiValue =
         rsiValue;

      m_lastSnapshot.adxValue =
         adxValue;

      m_lastSnapshot.atrPoints =
         atrPoints;

      if(InpUseEMAFilter)
      {
         if(fastEMA > slowEMA)
            m_lastSnapshot.emaBuyScore =
               emaScore;
         else if(fastEMA < slowEMA)
            m_lastSnapshot.emaSellScore =
               emaScore;
      }

      if(InpUseRSIFilter)
      {
         m_lastSnapshot.rsiBuyScore =
            RSIBuyScore(
               rsiValue
            );

         m_lastSnapshot.rsiSellScore =
            RSISellScore(
               rsiValue
            );
      }

      if(InpUseADXFilter)
      {
         m_lastSnapshot.adxScore =
            ADXScore(
               adxValue
            );
      }
      else
      {
         m_lastSnapshot.adxScore =
            100.0;
      }

      if(InpUseATRFilter)
      {
         m_lastSnapshot.atrScore =
            ATRScore(
               atrPoints
            );
      }
      else
      {
         m_lastSnapshot.atrScore =
            100.0;
      }

      double buyScore =
         WeightedScore(
            m_lastSnapshot.emaBuyScore,
            m_lastSnapshot.rsiBuyScore,
            m_lastSnapshot.adxScore
         );

      double sellScore =
         WeightedScore(
            m_lastSnapshot.emaSellScore,
            m_lastSnapshot.rsiSellScore,
            m_lastSnapshot.adxScore
         );

      if(InpUseATRFilter)
      {
         buyScore =
            (
               buyScore * 0.80 +
               m_lastSnapshot.atrScore *
               0.20
            );

         sellScore =
            (
               sellScore * 0.80 +
               m_lastSnapshot.atrScore *
               0.20
            );
      }

      m_lastSnapshot.buyScore =
         SGDPNormalizeScore(
            buyScore
         );

      m_lastSnapshot.sellScore =
         SGDPNormalizeScore(
            sellScore
         );

      m_lastSnapshot.scoreAdvantage =
         MathAbs(
            m_lastSnapshot.buyScore -
            m_lastSnapshot.sellScore
         );

      m_lastSnapshot.signal =
         SIGNAL_NONE;

      m_lastSnapshot.reason =
         "Signal score is below threshold.";

      if(m_lastSnapshot.scoreAdvantage <
         InpMinimumScoreAdvantage)
      {
         m_lastSnapshot.reason =
            "BUY and SELL scores are too close.";
      }
      else if(m_lastSnapshot.buyScore >=
                 InpMinimumSignalScore &&
              m_lastSnapshot.buyScore >
                 m_lastSnapshot.sellScore)
      {
         m_lastSnapshot.signal =
            SIGNAL_BUY;

         m_lastSnapshot.reason =
            "BUY signal approved.";
      }
      else if(m_lastSnapshot.sellScore >=
                 InpMinimumSignalScore &&
              m_lastSnapshot.sellScore >
                 m_lastSnapshot.buyScore)
      {
         m_lastSnapshot.signal =
            SIGNAL_SELL;

         m_lastSnapshot.reason =
            "SELL signal approved.";
      }

      m_lastSnapshot.valid = true;
      return true;
   }

   ENUM_TRADE_SIGNAL GetSignal()
   {
      if(!Evaluate())
         return SIGNAL_NONE;

      return m_lastSnapshot.signal;
   }

   SSignalSnapshot LastSnapshot() const
   {
      return m_lastSnapshot;
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
      return m_lastSnapshot.adxValue;
   }

   double LastRSI() const
   {
      return m_lastSnapshot.rsiValue;
   }

   double LastATRPoints() const
   {
      return m_lastSnapshot.atrPoints;
   }

   string LastReason() const
   {
      return m_lastSnapshot.reason;
   }
};

#endif