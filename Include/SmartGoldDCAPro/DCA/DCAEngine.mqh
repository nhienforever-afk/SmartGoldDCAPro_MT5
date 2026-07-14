#ifndef SMARTGOLDDCAPRO_DCA_ENGINE_MQH
#define SMARTGOLDDCAPRO_DCA_ENGINE_MQH

#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>
#include <SmartGoldDCAPro/Risk/SmartLotCalculator.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Market/MarketAnalyzer.mqh>
#include <SmartGoldDCAPro/DCA/AdaptiveGridEngine.mqh>

class CDCAEngine
{
private:
<<<<<<< HEAD
   CPositionManager     *m_positions;
   CRiskManager         *m_risk;
   CMarketAnalyzer      *m_market;
   CAdaptiveGridEngine  *m_grid;
   CSmartLotCalculator  *m_lotCalculator;

   double m_lastGridPoints;
   double m_lastATRPoints;
   double m_lastNextLot;
   double m_lastMarginLevel;
   double m_lastFreeMargin;
   int    m_lastRiskScore;
   int    m_lastNextOrderNumber;
   bool   m_lastSmartSafetyActive;

   bool IsSmartSafetyActive(const int nextOrderNumber) const
   {
      if(!InpEnableSmartSafety)
         return false;

      return nextOrderNumber >= InpSmartSafetyStartOrder;
   }

   double CalculateBaseLot(const double lastVolume,
                           const bool smartSafetyActive) const
   {
      if(InpDCAControlMode == DCA_CONTROL_MANUAL)
         return m_risk.NormalizeLot(InpManualDCALot);

      if(smartSafetyActive)
      {
         return m_lotCalculator.CalculateNextLot(
            lastVolume,
            InpLotMultiplier,
            InpMaximumLot,
            m_risk.CurrentDrawdownPercent()
         );
      }

      double lot = lastVolume * InpLotMultiplier;
      lot = MathMin(lot, InpMaximumLot);

      return m_risk.NormalizeLot(lot);
   }
=======
   CPositionManager  *m_positions;
   CRiskManager      *m_risk;
   CMarketAnalyzer   *m_market;
   CAdaptiveGridEngine *m_grid;
   CSmartLotCalculator *m_lotCalculator;

   double m_lastGridPoints;
   double m_lastATRPoints;
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

public:
   CDCAEngine()
   {
<<<<<<< HEAD
      m_positions              = NULL;
      m_risk                   = NULL;
      m_market                 = NULL;
      m_grid                   = NULL;
      m_lotCalculator          = NULL;
      m_lastGridPoints         = 0.0;
      m_lastATRPoints          = 0.0;
      m_lastNextLot            = 0.0;
      m_lastMarginLevel        = 0.0;
      m_lastFreeMargin         = 0.0;
      m_lastRiskScore          = 0;
      m_lastNextOrderNumber    = 0;
      m_lastSmartSafetyActive  = false;
=======
      m_positions    = NULL;
      m_risk         = NULL;
      m_market       = NULL;
      m_grid         = NULL;
      m_lotCalculator = NULL;
      m_lastGridPoints = 0.0;
      m_lastATRPoints  = 0.0;
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
   }

   void Initialize(CPositionManager &positions,
                   CRiskManager &risk,
                   CMarketAnalyzer &market,
                   CAdaptiveGridEngine &grid,
                   CSmartLotCalculator &lotCalculator)
   {
      m_positions     = &positions;
      m_risk          = &risk;
      m_market        = &market;
      m_grid          = &grid;
      m_lotCalculator = &lotCalculator;
   }

   double LastGridPoints() const
   {
      return m_lastGridPoints;
   }

   double LastATRPoints() const
   {
      return m_lastATRPoints;
   }

<<<<<<< HEAD
   double LastNextLot() const
   {
      return m_lastNextLot;
   }

   double LastMarginLevel() const
   {
      return m_lastMarginLevel;
   }

   double LastFreeMargin() const
   {
      return m_lastFreeMargin;
   }

   int LastRiskScore() const
   {
      return m_lastRiskScore;
   }

   int LastNextOrderNumber() const
   {
      return m_lastNextOrderNumber;
   }

   bool LastSmartSafetyActive() const
   {
      return m_lastSmartSafetyActive;
   }

   string ControlModeName() const
   {
      if(InpDCAControlMode == DCA_CONTROL_MANUAL)
         return "MANUAL";

      return "SMART";
   }

=======
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
   bool ShouldAddPosition(ENUM_POSITION_TYPE &direction,
                          double &nextLot,
                          string &reason)
   {
<<<<<<< HEAD
      m_lastNextLot = 0.0;

=======
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      if(m_positions == NULL ||
         m_risk == NULL ||
         m_market == NULL ||
         m_grid == NULL ||
         m_lotCalculator == NULL)
      {
         reason = "DCA engine is not initialized.";
         return false;
      }

<<<<<<< HEAD
      int positionCount = m_positions.CountAll();

      if(positionCount <= 0)
=======
      int count = m_positions.CountAll();
      if(count <= 0)
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      {
         reason = "No active basket.";
         return false;
      }

<<<<<<< HEAD
      if(positionCount >= InpMaximumDCALevels)
=======
      if(count >= InpMaximumDCALevels)
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      {
         reason = "Maximum DCA levels reached.";
         return false;
      }

<<<<<<< HEAD
      m_lastNextOrderNumber   = positionCount + 1;
      m_lastSmartSafetyActive =
         IsSmartSafetyActive(m_lastNextOrderNumber);

=======
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      if(!m_positions.GetBasketDirection(direction))
      {
         reason = "Mixed BUY/SELL basket is not supported.";
         return false;
      }

      SMarketState marketState;
<<<<<<< HEAD

=======
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      if(!m_market.Read(marketState))
      {
         reason = "Market state is unavailable.";
         return false;
      }

<<<<<<< HEAD
      m_lastATRPoints = marketState.atrPoints;

      if(InpDCAControlMode == DCA_CONTROL_MANUAL)
         m_lastGridPoints = InpManualDCADistancePoints;
      else
         m_lastGridPoints = m_grid.Calculate(marketState);

      m_lastMarginLevel =
         m_lotCalculator.GetCurrentMarginLevel();

      m_lastFreeMargin =
         m_lotCalculator.GetCurrentFreeMargin();

      m_lastRiskScore =
         m_lotCalculator.CalculateRiskScore(
            positionCount,
            (int)MathRound(marketState.spreadPoints),
            marketState.atrPoints,
            InpMaximumSpreadPoints,
            InpHighVolatilityATRPoints
         );

      if(m_lastSmartSafetyActive &&
         InpSmartSafetyUseRiskScore &&
         m_lastRiskScore > InpMaximumRiskScoreForDCA)
      {
         reason =
            "DCA blocked by smart risk score. Current=" +
            IntegerToString(m_lastRiskScore) +
            ", maximum=" +
            IntegerToString(InpMaximumRiskScoreForDCA);

         return false;
      }

      if(m_lastSmartSafetyActive &&
         InpSmartSafetyUseHighVolatilityBlock &&
         InpBlockDCAInHighVolatility &&
         marketState.highVolatility)
      {
         reason =
            "DCA blocked by smart high-volatility protection.";

         return false;
      }

      if(m_lastSmartSafetyActive &&
         InpSmartSafetyUseMarginProtection)
      {
         string marginReason;

         if(!m_lotCalculator.IsMarginSafe(
               InpMinimumMarginLevelPercent,
               InpMinimumFreeMarginMoney,
               marginReason))
         {
            reason = "DCA blocked: " + marginReason;
            return false;
         }
      }

      double lastPrice  = 0.0;
      double lastVolume = 0.0;
      datetime lastTime = 0;
=======
      m_lastATRPoints  = marketState.atrPoints;
      m_lastGridPoints = m_grid.Calculate(marketState);

      if(InpBlockDCAInHighVolatility && marketState.highVolatility)
      {
         reason = "DCA blocked by high-volatility protection.";
         return false;
      }

      double lastPrice, lastVolume;
      datetime lastTime;
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      ENUM_POSITION_TYPE lastType;

      if(!m_positions.GetLatestPosition(
            lastPrice,
            lastVolume,
            lastType,
            lastTime))
      {
         reason = "Cannot read latest position.";
         return false;
      }

<<<<<<< HEAD
      double point =
         SymbolInfoDouble(
            m_positions.Symbol(),
            SYMBOL_POINT
         );

=======
      double point = SymbolInfoDouble(m_positions.Symbol(), SYMBOL_POINT);
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      if(point <= 0.0)
      {
         reason = "Invalid symbol point.";
         return false;
      }

      double adversePoints = 0.0;

      if(direction == POSITION_TYPE_BUY)
<<<<<<< HEAD
      {
         adversePoints =
            (lastPrice - marketState.bid) / point;
      }
      else
      {
         adversePoints =
            (marketState.ask - lastPrice) / point;
      }
=======
         adversePoints = (lastPrice - marketState.bid) / point;
      else
         adversePoints = (marketState.ask - lastPrice) / point;
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

      if(adversePoints < m_lastGridPoints)
      {
         reason =
<<<<<<< HEAD
            "DCA distance not reached. Current=" +
            DoubleToString(adversePoints, 1) +
            ", required=" +
            DoubleToString(m_lastGridPoints, 1);

         return false;
      }

      nextLot =
         CalculateBaseLot(
            lastVolume,
            m_lastSmartSafetyActive
         );

      m_lastNextLot = nextLot;

      if(nextLot <= 0.0)
      {
         reason =
            "Next DCA lot was blocked by lot or safety protection.";

         return false;
      }

      reason =
         "DCA conditions are valid. Mode=" +
         ControlModeName() +
         ", smart safety=" +
         (m_lastSmartSafetyActive ? "ON" : "OFF");

=======
            "Adaptive grid not reached. Current=" +
            DoubleToString(adversePoints, 1) +
            ", required=" +
            DoubleToString(m_lastGridPoints, 1);
         return false;
      }

      nextLot = m_lotCalculator.CalculateNextLot(
         lastVolume,
         InpLotMultiplier,
         InpMaximumLot,
         m_risk.CurrentDrawdownPercent()
      );

      if(nextLot <= 0.0)
      {
         reason = "Invalid next DCA lot.";
         return false;
      }

      reason = "Adaptive DCA condition met.";
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e
      return true;
   }
};

#endif
