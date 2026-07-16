#ifndef SMARTGOLDDCAPRO_DASHBOARD_RENDERER_MQH
#define SMARTGOLDDCAPRO_DASHBOARD_RENDERER_MQH

#include <SmartGoldDCAPro/Dashboard/DashboardData.mqh>

class CDashboardRenderer
{
private:

   long m_chartId;

   string m_name;

   bool m_initialized;

public:

   CDashboardRenderer()
   {
      m_chartId = 0;

      m_name = "SGDP_Dashboard";

      m_initialized = false;
   }

   bool Initialize(
      const long chartId = 0
   )
   {
      m_chartId = chartId;

      m_initialized = true;

      return true;
   }

   bool IsInitialized() const
   {
      return m_initialized;
   }

   void Release()
   {
      ObjectDelete(
         m_chartId,
         m_name
      );

      m_initialized = false;
   }

   void Hide()
   {
      ObjectDelete(
         m_chartId,
         m_name
      );
   }

   bool Update(
      const SDashboardData &data
   )
   {
      if(!m_initialized)
         return false;

      if(!data.IsValid())
         return false;

      string text;

      text =
         "SmartGoldDCAPro\n\n";

      text +=
         "Symbol : " +
         data.symbol +
         "\n";

      text +=
         "Trend : " +
         data.marketTrend +
         "\n";

      text +=
         "Signal : " +
         data.signal +
         "\n";

      text +=
         "Decision : " +
         data.decision +
         "\n";

      text +=
         "Basket : " +
         data.basketDirection +
         "\n";

      text +=
         "Orders : " +
         IntegerToString(
            data.basketOrders
         ) +
         "\n";

      text +=
         "Profit : " +
         DoubleToString(
            data.basketProfit,
            2
         ) +
         "\n";

      text +=
         "DCA : " +
         IntegerToString(
            data.dcaLevel
         ) +
         "\n";

      text +=
         "Risk : " +
         IntegerToString(
            data.riskScore
         ) +
         "\n";

      text +=
         "Balance : " +
         DoubleToString(
            data.balance,
            2
         ) +
         "\n";

      text +=
         "Equity : " +
         DoubleToString(
            data.equity,
            2
         ) +
         "\n";

      text +=
         "Margin : " +
         DoubleToString(
            data.marginLevel,
            1
         ) +
         "%";

      if(
         ObjectFind(
            m_chartId,
            m_name
         ) < 0
      )
      {
         ObjectCreate(
            m_chartId,
            m_name,
            OBJ_LABEL,
            0,
            0,
            0
         );

         ObjectSetInteger(
            m_chartId,
            m_name,
            OBJPROP_CORNER,
            CORNER_LEFT_UPPER
         );

         ObjectSetInteger(
            m_chartId,
            m_name,
            OBJPROP_XDISTANCE,
            15
         );

         ObjectSetInteger(
            m_chartId,
            m_name,
            OBJPROP_YDISTANCE,
            20
         );

         ObjectSetInteger(
            m_chartId,
            m_name,
            OBJPROP_FONTSIZE,
            10
         );

         ObjectSetString(
            m_chartId,
            m_name,
            OBJPROP_FONT,
            "Consolas"
         );
      }

      ObjectSetString(
         m_chartId,
         m_name,
         OBJPROP_TEXT,
         text
      );

      return true;
   }
};

#endif