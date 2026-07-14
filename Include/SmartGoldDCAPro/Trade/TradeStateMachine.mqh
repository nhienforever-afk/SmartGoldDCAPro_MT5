#ifndef SMARTGOLDDCAPRO_TRADE_STATE_MACHINE_MQH
#define SMARTGOLDDCAPRO_TRADE_STATE_MACHINE_MQH

enum ENUM_TRADE_ENGINE_STATE
{
   TRADE_STATE_IDLE = 0,
   TRADE_STATE_ENTRY,
   TRADE_STATE_DCA,
   TRADE_STATE_RECOVERY,
   TRADE_STATE_EXIT,
   TRADE_STATE_BLOCKED
};

class CTradeStateMachine
{
private:
   ENUM_TRADE_ENGINE_STATE m_state;
   datetime                m_changedAt;

public:
   CTradeStateMachine()
   {
      m_state     = TRADE_STATE_IDLE;
      m_changedAt = TimeCurrent();
   }

   void SetState(const ENUM_TRADE_ENGINE_STATE state)
   {
      if(state == m_state)
         return;

      m_state     = state;
      m_changedAt = TimeCurrent();
   }

   ENUM_TRADE_ENGINE_STATE GetState() const
   {
      return m_state;
   }

   datetime ChangedAt() const
   {
      return m_changedAt;
   }

   string Name() const
   {
      switch(m_state)
      {
         case TRADE_STATE_IDLE:     return "IDLE";
         case TRADE_STATE_ENTRY:    return "ENTRY";
         case TRADE_STATE_DCA:      return "DCA";
         case TRADE_STATE_RECOVERY: return "RECOVERY";
         case TRADE_STATE_EXIT:     return "EXIT";
         case TRADE_STATE_BLOCKED:  return "BLOCKED";
      }

      return "UNKNOWN";
   }
};

#endif
