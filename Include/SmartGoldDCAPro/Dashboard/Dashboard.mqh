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
<<<<<<< HEAD
               const double gridPoints = 0.0,
               const double nextLot = 0.0,
               const double marginLevel = 0.0,
               const double freeMargin = 0.0,
               const int riskScore = 0,
               const string controlMode = "SMART",
               const int nextOrderNumber = 0,
               const bool smartSafetyActive = false,
               const double buyScore = 0.0,
               const double sellScore = 0.0,
               const double adxValue = 0.0,
               const double rsiValue = 0.0)
   {
      string riskText = "SAFE";

      if(riskScore >= 70)
         riskText = "DANGER";
      else if(riskScore >= 40)
         riskText = "WARNING";

      string marginText = "N/A";

      if(marginLevel > 0.0)
         marginText =
            DoubleToString(marginLevel, 1) + "%";

      string safetyText =
         smartSafetyActive ? "ACTIVE" : "STANDBY";

      string text =
         "SmartGoldDCAPro v1.40\n" +
         "State: " + status + "\n" +
         "DCA Mode: " + controlMode + "\n" +
         "Smart Safety: " + safetyText + "\n" +
         "Next Order: #" +
            IntegerToString(nextOrderNumber) + "\n" +
         "BUY Score: " +
            DoubleToString(buyScore, 1) + "%\n" +
         "SELL Score: " +
            DoubleToString(sellScore, 1) + "%\n" +
         "RSI: " +
            DoubleToString(rsiValue, 1) + "\n" +
         "ADX: " +
            DoubleToString(adxValue, 1) + "\n" +
         "Symbol: " + positions.Symbol() + "\n" +
         "Positions: " +
            IntegerToString(positions.CountAll()) + "\n" +
         "Volume: " +
            DoubleToString(positions.TotalVolume(), 2) + "\n" +
         "Basket P/L: " +
            DoubleToString(positions.TotalProfit(), 2) + "\n" +
         "Spread: " +
            IntegerToString(risk.CurrentSpreadPoints()) +
            " pts\n" +
         "ATR: " +
            DoubleToString(atrPoints, 1) + " pts\n" +
         "DCA Distance: " +
            DoubleToString(gridPoints, 1) + " pts\n" +
         "Next Lot: " +
            DoubleToString(nextLot, 2) + "\n" +
         "Margin Level: " +
            marginText + "\n" +
         "Free Margin: " +
            DoubleToString(freeMargin, 2) + "\n" +
         "Risk Score: " +
            IntegerToString(riskScore) +
            "/100 " + riskText + "\n" +
         "Equity DD: " +
            DoubleToString(
               risk.CurrentDrawdownPercent(),
               2
            ) +
            "%";
=======
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
>>>>>>> a6502552adb3f6daad7bbaab71976b01460fd24e

      Comment(text);
   }

   void Clear()
   {
      Comment("");
   }
};

#endif
