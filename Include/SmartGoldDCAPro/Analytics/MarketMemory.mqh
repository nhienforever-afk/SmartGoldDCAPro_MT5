#ifndef SMARTGOLDDCAPRO_MARKET_MEMORY_MQH
#define SMARTGOLDDCAPRO_MARKET_MEMORY_MQH

#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro - Market Memory                                  |
//| Lưu snapshot gần nhất của Decision Engine                        |
//+------------------------------------------------------------------+
class CMarketMemory
{
private:
   DecisionSnapshot m_lastSnapshot;
   bool             m_hasSnapshot;

public:
   CMarketMemory()
   {
      Clear();
   }

   void Clear()
   {
      m_lastSnapshot.Reset();
      m_hasSnapshot = false;
   }

   void Store(const DecisionSnapshot &snapshot)
   {
      m_lastSnapshot = snapshot;
      m_hasSnapshot  = snapshot.Valid;
   }

   bool HasSnapshot() const
   {
      return m_hasSnapshot;
   }

   bool GetLastSnapshot(
      DecisionSnapshot &snapshot
   ) const
   {
      if(!m_hasSnapshot)
         return false;

      snapshot = m_lastSnapshot;
      return true;
   }

   DecisionSnapshot LastSnapshot() const
   {
      return m_lastSnapshot;
   }

   datetime LastTime() const
   {
      return m_lastSnapshot.TimeStamp;
   }

   string LastSymbol() const
   {
      return m_lastSnapshot.Symbol;
   }

   string LastDecision() const
   {
      return m_lastSnapshot.Decision;
   }

   string LastReason() const
   {
      return m_lastSnapshot.Reason;
   }

   string LastMarketStateName() const
   {
      return m_lastSnapshot.MarketStateName();
   }

   double LastBuyScore() const
   {
      return m_lastSnapshot.BuyScore;
   }

   double LastSellScore() const
   {
      return m_lastSnapshot.SellScore;
   }

   double LastBestScore() const
   {
      return m_lastSnapshot.BestScore();
   }

   double LastScoreAdvantage() const
   {
      return m_lastSnapshot.ScoreAdvantage();
   }

   bool LastAllowBuy() const
   {
      return m_lastSnapshot.AllowBuy;
   }

   bool LastAllowSell() const
   {
      return m_lastSnapshot.AllowSell;
   }

   bool LastApproved() const
   {
      return m_lastSnapshot.HasApprovedDirection();
   }
};

#endif