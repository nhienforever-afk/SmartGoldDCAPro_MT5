#ifndef SMARTGOLDDCAPRO_DASHBOARD_DATA_MQH
#define SMARTGOLDDCAPRO_DASHBOARD_DATA_MQH

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Dashboard Data                                |
//| Data Transfer Object for Dashboard                              |
//+------------------------------------------------------------------+

struct SDashboardData
{
   //==============================================================
   // General
   //==============================================================

   string symbol;

   datetime serverTime;

   bool valid;

   //==============================================================
   // Market
   //==============================================================

   string marketTrend;

   string marketMomentum;

   string marketVolatility;

   double spreadPoints;

   //==============================================================
   // Signal
   //==============================================================

   string signal;

   double buySignalScore;

   double sellSignalScore;

   //==============================================================
   // Decision
   //==============================================================

   string decision;

   string confidence;

   string quality;

   //==============================================================
   // Basket
   //==============================================================

   string basketDirection;

   int basketOrders;

   double basketProfit;

   //==============================================================
   // DCA
   //==============================================================

   int dcaLevel;

   double gridPoints;

   int riskScore;

   //==============================================================
   // Account
   //==============================================================

   double balance;

   double equity;

   double freeMargin;

   double marginLevel;

   double drawdownPercent;

   //==============================================================
   // Reset
   //==============================================================

   void Reset()
   {
      symbol = "";

      serverTime = 0;

      valid = false;

      marketTrend = "";

      marketMomentum = "";

      marketVolatility = "";

      spreadPoints = 0.0;

      signal = "";

      buySignalScore = 0.0;

      sellSignalScore = 0.0;

      decision = "";

      confidence = "";

      quality = "";

      basketDirection = "";

      basketOrders = 0;

      basketProfit = 0.0;

      dcaLevel = 0;

      gridPoints = 0.0;

      riskScore = 0;

      balance = 0.0;

      equity = 0.0;

      freeMargin = 0.0;

      marginLevel = 0.0;

      drawdownPercent = 0.0;
   }

   //==============================================================
   // Validate
   //==============================================================

   bool IsValid() const
   {
      if(!valid)
         return false;

      if(symbol == "")
         return false;

      if(serverTime <= 0)
         return false;

      return true;
   }
};

#endif