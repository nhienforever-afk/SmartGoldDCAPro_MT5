#ifndef SMARTGOLDDCAPRO_SIGNAL_COORDINATOR_MQH
#define SMARTGOLDDCAPRO_SIGNAL_COORDINATOR_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Signal/SignalEngine.mqh>
#include <SmartGoldDCAPro/Signal/SignalSnapshot.mqh>
#include <SmartGoldDCAPro/Market/MarketAnalyzer.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Signal Coordinator              |
//| Kết hợp Signal Engine và Market Analyzer                         |
//+------------------------------------------------------------------+
class CSignalCoordinator
{
private:
   CSignalEngine   *m_signalEngine;
   CMarketAnalyzer *m_marketAnalyzer;

   SSignalSnapshot  m_lastSignal;
   SMarketAnalysis  m_lastMarket;

   ENUM_TRADE_SIGNAL m_lastApprovedSignal;
   string            m_lastReason;

public:
   CSignalCoordinator()
   {
      m_signalEngine      = NULL;
      m_marketAnalyzer    = NULL;
      m_lastApprovedSignal = SIGNAL_NONE;
      m_lastReason         = "Coordinator not initialized.";

      m_lastSignal.Reset();
      m_lastMarket.Reset();
   }

   void Initialize(
      CSignalEngine &signalEngine,
      CMarketAnalyzer &marketAnalyzer
   )
   {
      m_signalEngine   = &signalEngine;
      m_marketAnalyzer = &marketAnalyzer;

      Reset();
   }

   void Reset()
   {
      m_lastSignal.Reset();
      m_lastMarket.Reset();

      m_lastApprovedSignal = SIGNAL_NONE;
      m_lastReason         = "No coordinated signal.";
   }

   bool IsInitialized() const
   {
      return
         m_signalEngine != NULL &&
         m_marketAnalyzer != NULL;
   }

   bool Evaluate()
   {
      Reset();

      if(!IsInitialized())
      {
         m_lastReason =
            "Signal Coordinator is not initialized.";

         return false;
      }

      if(!m_signalEngine.Evaluate())
      {
         m_lastReason =
            "Signal Engine failed: " +
            m_signalEngine.LastReason();

         return false;
      }

      m_lastSignal =
         m_signalEngine.LastSnapshot();

      if(!m_marketAnalyzer.Read(
            m_lastMarket
         ))
      {
         m_lastReason =
            "Market Analyzer cannot read market data.";

         return false;
      }

      if(!m_lastSignal.valid ||
         !m_lastMarket.valid)
      {
         m_lastReason =
            "Signal or market snapshot is invalid.";

         return false;
      }

      ENUM_TRADE_SIGNAL rawSignal =
         m_lastSignal.signal;

      if(rawSignal == SIGNAL_NONE)
      {
         m_lastReason =
            m_lastSignal.reason;

         return true;
      }

      if(m_lastMarket.regime ==
         MARKET_REGIME_HIGH_VOLATILITY)
      {
         m_lastReason =
            "Signal blocked by high volatility.";

         return true;
      }

      if(m_lastMarket.spreadScore <= 0.0)
      {
         m_lastReason =
            "Signal blocked by spread.";

         return true;
      }

      if(rawSignal == SIGNAL_BUY)
      {
         if(m_lastMarket.buyTrendScore <
            m_lastMarket.sellTrendScore)
         {
            m_lastReason =
               "BUY signal conflicts with market trend.";

            return true;
         }

         if(m_lastMarket.buyMomentumScore <
            m_lastMarket.sellMomentumScore)
         {
            m_lastReason =
               "BUY signal conflicts with momentum.";

            return true;
         }

         m_lastApprovedSignal =
            SIGNAL_BUY;

         m_lastReason =
            "BUY signal approved by Market Analyzer.";

         return true;
      }

      if(rawSignal == SIGNAL_SELL)
      {
         if(m_lastMarket.sellTrendScore <
            m_lastMarket.buyTrendScore)
         {
            m_lastReason =
               "SELL signal conflicts with market trend.";

            return true;
         }

         if(m_lastMarket.sellMomentumScore <
            m_lastMarket.buyMomentumScore)
         {
            m_lastReason =
               "SELL signal conflicts with momentum.";

            return true;
         }

         m_lastApprovedSignal =
            SIGNAL_SELL;

         m_lastReason =
            "SELL signal approved by Market Analyzer.";

         return true;
      }

      m_lastReason =
         "Unsupported signal.";

      return true;
   }

   ENUM_TRADE_SIGNAL GetSignal()
   {
      if(!Evaluate())
         return SIGNAL_NONE;

      return m_lastApprovedSignal;
   }

   ENUM_TRADE_SIGNAL LastSignal() const
   {
      return m_lastApprovedSignal;
   }

   SSignalSnapshot LastSignalSnapshot() const
   {
      return m_lastSignal;
   }

   SMarketAnalysis LastMarketAnalysis() const
   {
      return m_lastMarket;
   }

   double LastBuyScore() const
   {
      return m_lastSignal.buyScore;
   }

   double LastSellScore() const
   {
      return m_lastSignal.sellScore;
   }

   double LastScoreAdvantage() const
   {
      return m_lastSignal.scoreAdvantage;
   }

   double LastATRPoints() const
   {
      return m_lastMarket.atrPoints;
   }

   double LastSpreadPoints() const
   {
      return m_lastMarket.spreadPoints;
   }

   ENUM_MARKET_REGIME LastMarketRegime() const
   {
      return m_lastMarket.regime;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   string LastSignalName() const
   {
      return SGDPTradeSignalName(
         m_lastApprovedSignal
      );
   }
};

#endif