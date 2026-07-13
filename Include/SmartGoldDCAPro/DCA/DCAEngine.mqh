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
   CPositionManager  *m_positions;
   CRiskManager      *m_risk;
   CMarketAnalyzer   *m_market;
   CAdaptiveGridEngine *m_grid;
   CSmartLotCalculator *m_lotCalculator;

   double m_lastGridPoints;
   double m_lastATRPoints;

public:
   CDCAEngine()
   {
      m_positions    = NULL;
      m_risk         = NULL;
      m_market       = NULL;
      m_grid         = NULL;
      m_lotCalculator = NULL;
      m_lastGridPoints = 0.0;
      m_lastATRPoints  = 0.0;
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

   bool ShouldAddPosition(ENUM_POSITION_TYPE &direction,
                          double &nextLot,
                          string &reason)
   {
      if(m_positions == NULL ||
         m_risk == NULL ||
         m_market == NULL ||
         m_grid == NULL ||
         m_lotCalculator == NULL)
      {
         reason = "DCA engine is not initialized.";
         return false;
      }

      int count = m_positions.CountAll();
      if(count <= 0)
      {
         reason = "No active basket.";
         return false;
      }

      if(count >= InpMaximumDCALevels)
      {
         reason = "Maximum DCA levels reached.";
         return false;
      }

      if(!m_positions.GetBasketDirection(direction))
      {
         reason = "Mixed BUY/SELL basket is not supported.";
         return false;
      }

      SMarketState marketState;
      if(!m_market.Read(marketState))
      {
         reason = "Market state is unavailable.";
         return false;
      }

      m_lastATRPoints  = marketState.atrPoints;
      m_lastGridPoints = m_grid.Calculate(marketState);

      if(InpBlockDCAInHighVolatility && marketState.highVolatility)
      {
         reason = "DCA blocked by high-volatility protection.";
         return false;
      }

      double lastPrice, lastVolume;
      datetime lastTime;
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

      double point = SymbolInfoDouble(m_positions.Symbol(), SYMBOL_POINT);
      if(point <= 0.0)
      {
         reason = "Invalid symbol point.";
         return false;
      }

      double adversePoints = 0.0;

      if(direction == POSITION_TYPE_BUY)
         adversePoints = (lastPrice - marketState.bid) / point;
      else
         adversePoints = (marketState.ask - lastPrice) / point;

      if(adversePoints < m_lastGridPoints)
      {
         reason =
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
      return true;
   }
};

#endif
