#ifndef SMARTGOLDDCAPRO_DASHBOARD_RENDERER_MQH
#define SMARTGOLDDCAPRO_DASHBOARD_RENDERER_MQH

#include <SmartGoldDCAPro/Dashboard/DashboardData.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Dashboard Renderer              |
//| Displays Dashboard data using the native MT5 chart Comment       |
//+------------------------------------------------------------------+
class CDashboardRenderer
{
private:
   long m_chartId;
   bool m_initialized;

public:
   CDashboardRenderer()
   {
      m_chartId =
         0;

      m_initialized =
         false;
   }

   //+----------------------------------------------------------------+
   //| Initialize Renderer                                            |
   //+----------------------------------------------------------------+
   bool Initialize(
      const long chartId = 0
   )
   {
      m_chartId =
         chartId;

      m_initialized =
         true;

      return true;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   //+----------------------------------------------------------------+
   //| Remove Dashboard text                                          |
   //+----------------------------------------------------------------+
   void Hide()
   {
      Comment("");

      ChartRedraw(
         m_chartId
      );
   }

   //+----------------------------------------------------------------+
   //| Release Renderer                                               |
   //+----------------------------------------------------------------+
   void Release()
   {
      Hide();

      m_initialized =
         false;
   }

   //+----------------------------------------------------------------+
   //| Update Dashboard                                               |
   //+----------------------------------------------------------------+
   bool Update(
      const SDashboardData &data
   )
   {
      if(!m_initialized)
         return false;

      if(!data.IsValid())
         return false;

      string text =
         "SMARTGOLDDCAPRO v2.0\n"
         "--------------------------------\n";

      text +=
         "Symbol       : " +
         data.symbol +
         "\n";

      text +=
         "Trend        : " +
         data.marketTrend +
         "\n";

      text +=
         "Momentum     : " +
         data.marketMomentum +
         "\n";

      text +=
         "Volatility   : " +
         data.marketVolatility +
         "\n";

      text +=
         "Spread       : " +
         DoubleToString(
            data.spreadPoints,
            1
         ) +
         "\n";

      text +=
         "--------------------------------\n";

      text +=
         "Signal       : " +
         data.signal +
         "\n";

      text +=
         "BUY Score    : " +
         DoubleToString(
            data.buySignalScore,
            1
         ) +
         "\n";

      text +=
         "SELL Score   : " +
         DoubleToString(
            data.sellSignalScore,
            1
         ) +
         "\n";

      text +=
         "Decision     : " +
         data.decision +
         "\n";

      text +=
         "Confidence   : " +
         data.confidence +
         "\n";

      text +=
         "Quality      : " +
         data.quality +
         "\n";

      text +=
         "--------------------------------\n";

      text +=
         "Basket       : " +
         data.basketDirection +
         "\n";

      text +=
         "Orders       : " +
         IntegerToString(
            data.basketOrders
         ) +
         "\n";

      text +=
         "Profit       : " +
         DoubleToString(
            data.basketProfit,
            2
         ) +
         "\n";

      text +=
         "DCA Level    : " +
         IntegerToString(
            data.dcaLevel
         ) +
         "\n";

      text +=
         "Grid         : " +
         DoubleToString(
            data.gridPoints,
            1
         ) +
         "\n";

      text +=
         "Risk Score   : " +
         IntegerToString(
            data.riskScore
         ) +
         "\n";

      text +=
         "--------------------------------\n";

      text +=
         "Balance      : " +
         DoubleToString(
            data.balance,
            2
         ) +
         "\n";

      text +=
         "Equity       : " +
         DoubleToString(
            data.equity,
            2
         ) +
         "\n";

      text +=
         "Free Margin  : " +
         DoubleToString(
            data.freeMargin,
            2
         ) +
         "\n";

      text +=
         "Margin Level : " +
         DoubleToString(
            data.marginLevel,
            1
         ) +
         "%\n";

      text +=
         "Drawdown     : " +
         DoubleToString(
            data.drawdownPercent,
            2
         ) +
         "%";

      Comment(text);

      ChartRedraw(
         m_chartId
      );

      return true;
   }
};

#endif