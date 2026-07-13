#ifndef SMARTGOLDDCAPRO_DASHBOARD_MQH
#define SMARTGOLDDCAPRO_DASHBOARD_MQH

#include <SmartGoldDCAPro/Core/RiskManager.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>

class CDashboard
{
public:
   void Render(CPositionManager &positions,
               CRiskManager &risk,
               const string status,
               const double atrPoints = 0.0,
               const double gridPoints = 0.0)
   {
      string text =
         "SmartGoldDCAPro v1.30\n" +
         "State: " + status + "\n" +
         "Symbol: " + positions.Symbol() + "\n" +
         "Positions: " + IntegerToString(positions.CountAll()) + "\n" +
         "Volume: " + DoubleToString(positions.TotalVolume(), 2) + "\n" +
         "Basket P/L: " + DoubleToString(positions.TotalProfit(), 2) + "\n" +
         "Spread: " + IntegerToString(risk.CurrentSpreadPoints()) + " pts\n" +
         "ATR: " + DoubleToString(atrPoints, 1) + " pts\n" +
         "Adaptive Grid: " + DoubleToString(gridPoints, 1) + " pts\n" +
         "Equity DD: " + DoubleToString(risk.CurrentDrawdownPercent(), 2) + "%";

      Comment(text);
   }

   void Clear()
   {
      Comment("");
   }
};

#endif
