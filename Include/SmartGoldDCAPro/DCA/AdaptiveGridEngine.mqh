#ifndef SMARTGOLDDCAPRO_DCA_ADAPTIVE_GRID_ENGINE_MQH
#define SMARTGOLDDCAPRO_DCA_ADAPTIVE_GRID_ENGINE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Market/MarketState.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Adaptive Grid Engine            |
//| Calculates DCA grid distance from ATR and market conditions      |
//+------------------------------------------------------------------+
class CAdaptiveGridEngine
{
private:
   double m_minimumGridPoints;
   double m_maximumGridPoints;
   double m_atrMultiplier;

   double m_highVolatilityMultiplier;
   double m_rangeMultiplier;
   double m_trendMultiplier;

   double m_lastGridPoints;
   string m_lastReason;

   bool m_initialized;

   //+----------------------------------------------------------------+
   //| Clamp grid distance to configured limits                       |
   //+----------------------------------------------------------------+
   double ClampGrid(
      const double gridPoints
   ) const
   {
      return MathMax(
         m_minimumGridPoints,
         MathMin(
            m_maximumGridPoints,
            gridPoints
         )
      );
   }

   //+----------------------------------------------------------------+
   //| Return multiplier for current market regime                    |
   //+----------------------------------------------------------------+
   double RegimeMultiplier(
      const ENUM_MARKET_REGIME regime
   ) const
   {
      switch(regime)
      {
         case MARKET_REGIME_HIGH_VOLATILITY:
            return m_highVolatilityMultiplier;

         case MARKET_REGIME_RANGE:
            return m_rangeMultiplier;

         case MARKET_REGIME_TREND_UP:
         case MARKET_REGIME_TREND_DOWN:
            return m_trendMultiplier;

         case MARKET_REGIME_UNKNOWN:
            return 1.0;
      }

      return 1.0;
   }

public:
   CAdaptiveGridEngine()
   {
      m_minimumGridPoints =
         100.0;

      m_maximumGridPoints =
         3000.0;

      m_atrMultiplier =
         1.0;

      m_highVolatilityMultiplier =
         1.50;

      m_rangeMultiplier =
         0.85;

      m_trendMultiplier =
         1.10;

      m_lastGridPoints =
         0.0;

      m_lastReason =
         "Adaptive Grid Engine is not initialized.";

      m_initialized =
         false;
   }

   //+----------------------------------------------------------------+
   //| Initialize Adaptive Grid parameters                            |
   //+----------------------------------------------------------------+
   bool Initialize(
      const double minimumGridPoints,
      const double maximumGridPoints,
      const double atrMultiplier,
      const double highVolatilityMultiplier = 1.50,
      const double rangeMultiplier = 0.85,
      const double trendMultiplier = 1.10
   )
   {
      if(minimumGridPoints <= 0.0)
      {
         m_lastReason =
            "Minimum grid points must be greater than zero.";

         m_initialized =
            false;

         return false;
      }

      if(maximumGridPoints <
         minimumGridPoints)
      {
         m_lastReason =
            "Maximum grid points must be greater than or equal to minimum grid points.";

         m_initialized =
            false;

         return false;
      }

      if(atrMultiplier <= 0.0)
      {
         m_lastReason =
            "ATR multiplier must be greater than zero.";

         m_initialized =
            false;

         return false;
      }

      m_minimumGridPoints =
         minimumGridPoints;

      m_maximumGridPoints =
         maximumGridPoints;

      m_atrMultiplier =
         atrMultiplier;

      m_highVolatilityMultiplier =
         MathMax(
            0.10,
            highVolatilityMultiplier
         );

      m_rangeMultiplier =
         MathMax(
            0.10,
            rangeMultiplier
         );

      m_trendMultiplier =
         MathMax(
            0.10,
            trendMultiplier
         );

      m_lastGridPoints =
         0.0;

      m_lastReason =
         "Adaptive Grid Engine initialized.";

      m_initialized =
         true;

      return true;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   //+----------------------------------------------------------------+
   //| Calculate adaptive grid from complete Market Analysis          |
   //+----------------------------------------------------------------+
   double Calculate(
      const SMarketAnalysis &market
   )
   {
      m_lastGridPoints =
         0.0;

      if(!m_initialized)
      {
         m_lastReason =
            "Adaptive Grid Engine is not initialized.";

         return 0.0;
      }

      if(!market.valid)
      {
         m_lastReason =
            "Market Analysis is invalid.";

         return 0.0;
      }

      if(market.atrPoints <= 0.0)
      {
         m_lastReason =
            "ATR points must be greater than zero.";

         return 0.0;
      }

      double baseGrid =
         market.atrPoints *
         m_atrMultiplier;

      double regimeFactor =
         RegimeMultiplier(
            market.regime
         );

      double spreadAdjustment =
         MathMax(
            0.0,
            market.spreadPoints
         );

      double calculatedGrid =
         baseGrid *
         regimeFactor +
         spreadAdjustment;

      m_lastGridPoints =
         ClampGrid(
            calculatedGrid
         );

      m_lastReason =
         "Adaptive grid calculated. ATR=" +
         DoubleToString(
            market.atrPoints,
            1
         ) +
         ", regime=" +
         IntegerToString(
            (int)market.regime
         ) +
         ", spread=" +
         DoubleToString(
            market.spreadPoints,
            1
         ) +
         ", grid=" +
         DoubleToString(
            m_lastGridPoints,
            1
         ) +
         ".";

      return m_lastGridPoints;
   }

   //+----------------------------------------------------------------+
   //| Calculate directly from ATR and market regime                  |
   //| Useful for isolated tests                                      |
   //+----------------------------------------------------------------+
   double CalculateFromValues(
      const double atrPoints,
      const double spreadPoints,
      const ENUM_MARKET_REGIME regime
   )
   {
      SMarketAnalysis market;
      market.Reset();

      market.atrPoints =
         atrPoints;

      market.spreadPoints =
         MathMax(
            0.0,
            spreadPoints
         );

      market.regime =
         regime;

      market.valid =
         true;

      return Calculate(
         market
      );
   }

   //+----------------------------------------------------------------+
   //| Manual grid mode helper                                        |
   //+----------------------------------------------------------------+
   double ManualGrid(
      const double requestedGridPoints
   )
   {
      if(!m_initialized)
      {
         m_lastReason =
            "Adaptive Grid Engine is not initialized.";

         m_lastGridPoints =
            0.0;

         return 0.0;
      }

      if(requestedGridPoints <= 0.0)
      {
         m_lastReason =
            "Requested manual grid must be greater than zero.";

         m_lastGridPoints =
            0.0;

         return 0.0;
      }

      m_lastGridPoints =
         ClampGrid(
            requestedGridPoints
         );

      m_lastReason =
         "Manual grid normalized to " +
         DoubleToString(
            m_lastGridPoints,
            1
         ) +
         " points.";

      return m_lastGridPoints;
   }

   double LastGridPoints() const
   {
      return m_lastGridPoints;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   double MinimumGridPoints() const
   {
      return m_minimumGridPoints;
   }

   double MaximumGridPoints() const
   {
      return m_maximumGridPoints;
   }

   double ATRMultiplier() const
   {
      return m_atrMultiplier;
   }

   void Reset()
   {
      m_lastGridPoints =
         0.0;

      m_lastReason =
         "Adaptive Grid Engine reset.";
   }
};

#endif