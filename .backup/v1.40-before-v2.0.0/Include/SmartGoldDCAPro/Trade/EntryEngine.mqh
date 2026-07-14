#ifndef SMARTGOLDDCAPRO_ENTRY_ENGINE_MQH
#define SMARTGOLDDCAPRO_ENTRY_ENGINE_MQH

#include <SmartGoldDCAPro/Core/Logger.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Signal/SignalCoordinator.mqh>

class CEntryEngine
{
private:
   CRiskManager       *m_risk;
   COrderManager      *m_orders;
   CPositionManager   *m_positions;
   CSignalCoordinator *m_signals;
   CLogger            *m_log;

   double GetInitialLot() const
   {
      if(InpDCAControlMode == DCA_CONTROL_MANUAL)
         return InpManualInitialLot;

      return InpInitialLot;
   }

public:
   CEntryEngine()
   {
      m_risk      = NULL;
      m_orders    = NULL;
      m_positions = NULL;
      m_signals   = NULL;
      m_log       = NULL;
   }

   void Initialize(CRiskManager &risk,
                   COrderManager &orders,
                   CPositionManager &positions,
                   CSignalCoordinator &signals,
                   CLogger &logger)
   {
      m_risk      = &risk;
      m_orders    = &orders;
      m_positions = &positions;
      m_signals   = &signals;
      m_log       = &logger;
   }

   bool TryOpenInitial()
   {
      if(m_risk == NULL ||
         m_orders == NULL ||
         m_positions == NULL ||
         m_signals == NULL)
         return false;

      if(!InpAllowNewTrades || m_positions.CountAll() > 0)
         return false;

      double lot = GetInitialLot();
      string reason;

      if(!m_risk.CanOpenTrade(
            lot,
            InpMaximumSpreadPoints,
            reason))
      {
         if(m_log != NULL)
            m_log.Warn("Entry blocked: " + reason);

         return false;
      }

      ENUM_TRADE_SIGNAL signal = m_signals.Resolve();

      if(signal == SIGNAL_BUY)
         return m_orders.OpenBuy(
            lot,
            0.0,
            0.0,
            "Initial BUY"
         );

      if(signal == SIGNAL_SELL)
         return m_orders.OpenSell(
            lot,
            0.0,
            0.0,
            "Initial SELL"
         );

      return false;
   }
};

#endif
