#ifndef SMARTGOLDDCAPRO_MARKET_STATE_MQH
#define SMARTGOLDDCAPRO_MARKET_STATE_MQH

struct SMarketState
{
   datetime timestamp;
   double   atrPoints;
   double   spreadPoints;
   double   bid;
   double   ask;
   bool     valid;
   bool     highVolatility;
};

#endif
