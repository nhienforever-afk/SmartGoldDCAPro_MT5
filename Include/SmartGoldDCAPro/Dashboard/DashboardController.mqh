#ifndef SMARTGOLDDCAPRO_DASHBOARD_CONTROLLER_MQH
#define SMARTGOLDDCAPRO_DASHBOARD_CONTROLLER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

#include <SmartGoldDCAPro/Market/MarketState.mqh>
#include <SmartGoldDCAPro/Market/MarketAnalyzer.mqh>

#include <SmartGoldDCAPro/Signal/SignalCoordinator.mqh>

#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>
#include <SmartGoldDCAPro/Decision/DecisionEngine.mqh>

#include <SmartGoldDCAPro/Trade/PositionManager.mqh>

#include <SmartGoldDCAPro/DCA/DCAEngine.mqh>

#include <SmartGoldDCAPro/Dashboard/DashboardData.mqh>
#include <SmartGoldDCAPro/Dashboard/DashboardRenderer.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Dashboard Controller            |
//| Collects module data and sends it to DashboardRenderer           |
//+------------------------------------------------------------------+
class CDashboardController
{
private:
   CMarketAnalyzer      *m_market;
   CSignalCoordinator   *m_signal;
   CDecisionEngine      *m_decision;
   CPositionManager     *m_positions;
   CDCAEngine           *m_dca;
   CRiskManager         *m_risk;
   CDashboardRenderer   *m_renderer;

   bool   m_initialized;
   string m_lastReason;

   //+----------------------------------------------------------------+
   //| Validate all required module connections                        |
   //+----------------------------------------------------------------+
   bool ModulesReady() const
   {
      return
         m_initialized &&
         m_market    != NULL &&
         m_signal    != NULL &&
         m_decision  != NULL &&
         m_positions != NULL &&
         m_dca       != NULL &&
         m_risk      != NULL &&
         m_renderer  != NULL;
   }

   //+----------------------------------------------------------------+
   //| Convert market regime to readable text                          |
   //+----------------------------------------------------------------+
   string MarketRegimeName(
      const ENUM_MARKET_REGIME regime
   ) const
   {
      switch(regime)
      {
         case MARKET_REGIME_TREND_UP:
            return "TREND UP";

         case MARKET_REGIME_TREND_DOWN:
            return "TREND DOWN";

         case MARKET_REGIME_RANGE:
            return "RANGE";

         case MARKET_REGIME_HIGH_VOLATILITY:
            return "HIGH VOLATILITY";

         case MARKET_REGIME_UNKNOWN:
            return "UNKNOWN";
      }

      return "UNKNOWN";
   }

   //+----------------------------------------------------------------+
   //| Describe current momentum direction                             |
   //+----------------------------------------------------------------+
   string MomentumName(
      const SMarketAnalysis &market
   ) const
   {
      if(market.buyMomentumScore >
         market.sellMomentumScore)
      {
         return "BUY";
      }

      if(market.sellMomentumScore >
         market.buyMomentumScore)
      {
         return "SELL";
      }

      return "NEUTRAL";
   }

   //+----------------------------------------------------------------+
   //| Describe current volatility                                     |
   //+----------------------------------------------------------------+
   string VolatilityName(
      const SMarketAnalysis &market
   ) const
   {
      if(market.regime ==
         MARKET_REGIME_HIGH_VOLATILITY)
      {
         return "HIGH";
      }

      if(market.volatilityScore >= 70.0)
         return "GOOD";

      if(market.volatilityScore >= 40.0)
         return "NORMAL";

      return "LOW";
   }

   //+----------------------------------------------------------------+
   //| Read current basket direction                                   |
   //+----------------------------------------------------------------+
   string BasketDirectionName() const
   {
      if(m_positions.CountAll() <= 0)
         return "NONE";

      ENUM_POSITION_TYPE direction =
         POSITION_TYPE_BUY;

      if(!m_positions.GetBasketDirection(
            direction
         ))
      {
         return "MIXED";
      }

      return
         SGDPPositionTypeName(
            direction
         );
   }

public:
   CDashboardController()
   {
      m_market =
         NULL;

      m_signal =
         NULL;

      m_decision =
         NULL;

      m_positions =
         NULL;

      m_dca =
         NULL;

      m_risk =
         NULL;

      m_renderer =
         NULL;

      m_initialized =
         false;

      m_lastReason =
         "Dashboard Controller is not initialized.";
   }

   //+----------------------------------------------------------------+
   //| Connect Dashboard dependencies                                  |
   //+----------------------------------------------------------------+
   void Initialize(
      CMarketAnalyzer &market,
      CSignalCoordinator &signal,
      CDecisionEngine &decision,
      CPositionManager &positions,
      CDCAEngine &dca,
      CRiskManager &risk,
      CDashboardRenderer &renderer
   )
   {
      m_market =
         &market;

      m_signal =
         &signal;

      m_decision =
         &decision;

      m_positions =
         &positions;

      m_dca =
         &dca;

      m_risk =
         &risk;

      m_renderer =
         &renderer;

      m_initialized =
         true;

      m_lastReason =
         "Dashboard Controller initialized.";
   }

   bool IsInitialized() const
   {
      return ModulesReady();
   }

   //+----------------------------------------------------------------+
   //| Build Dashboard data without drawing                           |
   //+----------------------------------------------------------------+
   bool BuildData(
      SDashboardData &data
   )
   {
      data.Reset();

      if(!ModulesReady())
      {
         m_lastReason =
            "Dashboard Controller dependencies are not initialized.";

         return false;
      }

      SMarketAnalysis marketAnalysis;
      marketAnalysis.Reset();

      bool marketAvailable =
         m_market.Read(
            marketAnalysis
         );

      SDecisionSnapshot decisionSnapshot =
         m_decision.Snapshot();

      data.symbol =
         m_positions.Symbol();

      if(data.symbol == "")
         data.symbol = _Symbol;

      data.serverTime =
         TimeCurrent();

      //==============================================================
      // Market
      //==============================================================

      if(marketAvailable &&
         marketAnalysis.valid)
      {
         data.marketTrend =
            MarketRegimeName(
               marketAnalysis.regime
            );

         data.marketMomentum =
            MomentumName(
               marketAnalysis
            );

         data.marketVolatility =
            VolatilityName(
               marketAnalysis
            );

         data.spreadPoints =
            marketAnalysis.spreadPoints;
      }
      else
      {
         data.marketTrend =
            "UNAVAILABLE";

         data.marketMomentum =
            "UNAVAILABLE";

         data.marketVolatility =
            "UNAVAILABLE";

         data.spreadPoints =
            0.0;
      }

      //==============================================================
      // Signal
      //==============================================================

      data.signal =
         m_signal.LastSignalName();

      data.buySignalScore =
         m_signal.LastBuyScore();

      data.sellSignalScore =
         m_signal.LastSellScore();

      //==============================================================
      // Decision
      //==============================================================

      if(decisionSnapshot.valid)
      {
         data.decision =
            decisionSnapshot.ActionName();

         data.confidence =
            DoubleToString(
               decisionSnapshot.confidence,
               1
            ) +
            "%";

         data.quality =
            decisionSnapshot.QualityName();
      }
      else
      {
         data.decision =
            "WAIT";

         data.confidence =
            "0.0%";

         data.quality =
            "UNKNOWN";
      }

      //==============================================================
      // Basket
      //==============================================================

      data.basketDirection =
         BasketDirectionName();

      data.basketOrders =
         m_positions.CountAll();

      data.basketProfit =
         m_positions.TotalProfit();

      //==============================================================
      // DCA
      //==============================================================

      data.dcaLevel =
         data.basketOrders;

      data.gridPoints =
         m_dca.LastGridPoints();

      data.riskScore =
         m_dca.LastRiskScore();

      //==============================================================
      // Account
      //==============================================================

      data.balance =
         AccountInfoDouble(
            ACCOUNT_BALANCE
         );

      data.equity =
         AccountInfoDouble(
            ACCOUNT_EQUITY
         );

      data.freeMargin =
         AccountInfoDouble(
            ACCOUNT_MARGIN_FREE
         );

      data.marginLevel =
         AccountInfoDouble(
            ACCOUNT_MARGIN_LEVEL
         );

      data.drawdownPercent =
         m_risk.CurrentDrawdownPercent();

      data.valid =
         true;

      if(!data.IsValid())
      {
         m_lastReason =
            "Generated Dashboard data is invalid.";

         return false;
      }

      m_lastReason =
         "Dashboard data built successfully.";

      return true;
   }

   //+----------------------------------------------------------------+
   //| Build data and update Renderer                                  |
   //+----------------------------------------------------------------+
   bool Update()
   {
      SDashboardData data;

      if(!BuildData(data))
         return false;

      if(!m_renderer.Update(data))
      {
         m_lastReason =
            "Dashboard Renderer update failed.";

         return false;
      }

      m_lastReason =
         "Dashboard updated successfully.";

      return true;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   void Hide()
   {
      if(m_renderer != NULL)
         m_renderer.Hide();
   }

   void Release()
   {
      if(m_renderer != NULL)
         m_renderer.Release();

      m_initialized =
         false;

      m_lastReason =
         "Dashboard Controller released.";
   }
};

#endif