#ifndef SMARTGOLDDCAPRO_SIGNAL_SNAPSHOT_MQH
#define SMARTGOLDDCAPRO_SIGNAL_SNAPSHOT_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Signal Snapshot                 |
//+------------------------------------------------------------------+
struct SSignalSnapshot
{
   datetime          timestamp;
   ENUM_TRADE_SIGNAL signal;

   double buyScore;
   double sellScore;
   double scoreAdvantage;

   double emaBuyScore;
   double emaSellScore;

   double rsiBuyScore;
   double rsiSellScore;

   double adxScore;
   double atrScore;

   double fastEMA;
   double slowEMA;
   double rsiValue;
   double adxValue;
   double atrPoints;

   bool valid;
   string reason;

   void Reset()
   {
      timestamp      = 0;
      signal         = SIGNAL_NONE;

      buyScore       = 0.0;
      sellScore      = 0.0;
      scoreAdvantage = 0.0;

      emaBuyScore    = 0.0;
      emaSellScore   = 0.0;

      rsiBuyScore    = 0.0;
      rsiSellScore   = 0.0;

      adxScore       = 0.0;
      atrScore       = 0.0;

      fastEMA        = 0.0;
      slowEMA        = 0.0;
      rsiValue       = 0.0;
      adxValue       = 0.0;
      atrPoints      = 0.0;

      valid          = false;
      reason         = "No signal data";
   }

   bool HasSignal() const
   {
      return
         valid &&
         signal != SIGNAL_NONE;
   }

   string SignalName() const
   {
      return SGDPTradeSignalName(signal);
   }
};

#endif