#ifndef SMARTGOLDDCAPRO_SIGNAL_SNAPSHOT_MQH
#define SMARTGOLDDCAPRO_SIGNAL_SNAPSHOT_MQH

struct SSignalSnapshot
{
   datetime timestamp;
   double   buyScore;
   double   sellScore;
   double   emaFast;
   double   emaSlow;
   double   rsi;
   double   adx;
   double   plusDI;
   double   minusDI;
   double   atrPoints;
   bool     valid;
};

#endif
