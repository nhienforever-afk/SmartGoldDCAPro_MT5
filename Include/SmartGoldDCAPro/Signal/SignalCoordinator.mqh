#ifndef SMARTGOLDDCAPRO_SIGNAL_COORDINATOR_MQH
#define SMARTGOLDDCAPRO_SIGNAL_COORDINATOR_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Signal/SignalEngine.mqh>

class CSignalCoordinator
{
private:
   CSignalEngine *m_signalEngine;

public:
   CSignalCoordinator()
   {
      m_signalEngine = NULL;
   }

   void Initialize(CSignalEngine &signalEngine)
   {
      m_signalEngine = &signalEngine;
   }

   ENUM_TRADE_SIGNAL Resolve() const
   {
      if(m_signalEngine == NULL)
         return SIGNAL_NONE;

      ENUM_TRADE_SIGNAL signal = m_signalEngine.GetSignal();

      if(InpDirectionMode == DIRECTION_BUY_ONLY && signal != SIGNAL_BUY)
         return SIGNAL_NONE;

      if(InpDirectionMode == DIRECTION_SELL_ONLY && signal != SIGNAL_SELL)
         return SIGNAL_NONE;

      return signal;
   }
};

#endif
