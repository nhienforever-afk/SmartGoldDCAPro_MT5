#ifndef SMARTGOLDDCAPRO_TRADE_STATE_MACHINE_MQH
#define SMARTGOLDDCAPRO_TRADE_STATE_MACHINE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Trade State Machine             |
//| Quản lý trạng thái hoạt động hiện tại của EA                     |
//+------------------------------------------------------------------+
class CTradeStateMachine
{
private:
   ENUM_TRADE_STATE m_currentState;
   ENUM_TRADE_STATE m_previousState;

   datetime m_lastChangeTime;
   string   m_lastReason;

   bool IsValidTransition(
      const ENUM_TRADE_STATE fromState,
      const ENUM_TRADE_STATE toState
   ) const
   {
      // Luôn cho phép giữ nguyên trạng thái hiện tại.
      if(fromState == toState)
         return true;

      // Có thể chuyển sang BLOCKED hoặc EXIT từ mọi trạng thái.
      if(toState == TRADE_STATE_BLOCKED ||
         toState == TRADE_STATE_EXIT)
      {
         return true;
      }

      switch(fromState)
      {
         case TRADE_STATE_IDLE:
         {
            return
               toState == TRADE_STATE_ENTRY ||
               toState == TRADE_STATE_MANAGE ||
               toState == TRADE_STATE_DCA;
         }

         case TRADE_STATE_ENTRY:
         {
            return
               toState == TRADE_STATE_IDLE ||
               toState == TRADE_STATE_MANAGE ||
               toState == TRADE_STATE_DCA;
         }

         case TRADE_STATE_MANAGE:
         {
            return
               toState == TRADE_STATE_IDLE ||
               toState == TRADE_STATE_DCA;
         }

         case TRADE_STATE_DCA:
         {
            return
               toState == TRADE_STATE_IDLE ||
               toState == TRADE_STATE_MANAGE;
         }

         case TRADE_STATE_EXIT:
         {
            return
               toState == TRADE_STATE_IDLE ||
               toState == TRADE_STATE_BLOCKED;
         }

         case TRADE_STATE_BLOCKED:
         {
            return
               toState == TRADE_STATE_IDLE;
         }
      }

      return false;
   }

public:
   CTradeStateMachine()
   {
      m_currentState  = TRADE_STATE_IDLE;
      m_previousState = TRADE_STATE_IDLE;

      m_lastChangeTime = TimeCurrent();
      m_lastReason     = "Initialized";
   }

   void Initialize(
      const ENUM_TRADE_STATE initialState =
         TRADE_STATE_IDLE
   )
   {
      m_currentState  = initialState;
      m_previousState = initialState;

      m_lastChangeTime = TimeCurrent();
      m_lastReason     = "State machine initialized";
   }

   bool SetState(
      const ENUM_TRADE_STATE newState,
      const string reason = ""
   )
   {
      if(!IsValidTransition(
            m_currentState,
            newState
         ))
      {
         m_lastReason =
            "Invalid state transition: " +
            SGDPTradeStateName(
               m_currentState
            ) +
            " -> " +
            SGDPTradeStateName(
               newState
            );

         return false;
      }

      if(newState == m_currentState)
      {
         if(reason != "")
            m_lastReason = reason;

         return true;
      }

      m_previousState =
         m_currentState;

      m_currentState =
         newState;

      m_lastChangeTime =
         TimeCurrent();

      if(reason != "")
      {
         m_lastReason = reason;
      }
      else
      {
         m_lastReason =
            "State changed: " +
            SGDPTradeStateName(
               m_previousState
            ) +
            " -> " +
            SGDPTradeStateName(
               m_currentState
            );
      }

      return true;
   }

   ENUM_TRADE_STATE CurrentState() const
   {
      return m_currentState;
   }

   ENUM_TRADE_STATE PreviousState() const
   {
      return m_previousState;
   }

   // Tương thích với source EA cũ.
   string Name() const
   {
      return SGDPTradeStateName(
         m_currentState
      );
   }

   string CurrentStateName() const
   {
      return SGDPTradeStateName(
         m_currentState
      );
   }

   string PreviousStateName() const
   {
      return SGDPTradeStateName(
         m_previousState
      );
   }

   datetime LastChangeTime() const
   {
      return m_lastChangeTime;
   }

   int SecondsInCurrentState() const
   {
      if(m_lastChangeTime <= 0)
         return 0;

      return (int)(
         TimeCurrent() -
         m_lastChangeTime
      );
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   bool IsState(
      const ENUM_TRADE_STATE state
   ) const
   {
      return m_currentState == state;
   }

   bool IsIdle() const
   {
      return IsState(
         TRADE_STATE_IDLE
      );
   }

   bool IsEntry() const
   {
      return IsState(
         TRADE_STATE_ENTRY
      );
   }

   bool IsManaging() const
   {
      return IsState(
         TRADE_STATE_MANAGE
      );
   }

   bool IsDCA() const
   {
      return IsState(
         TRADE_STATE_DCA
      );
   }

   bool IsExit() const
   {
      return IsState(
         TRADE_STATE_EXIT
      );
   }

   bool IsBlocked() const
   {
      return IsState(
         TRADE_STATE_BLOCKED
      );
   }

   bool CanOpenInitialTrade() const
   {
      return
         m_currentState == TRADE_STATE_IDLE ||
         m_currentState == TRADE_STATE_ENTRY;
   }

   bool CanManageBasket() const
   {
      return
         m_currentState == TRADE_STATE_MANAGE ||
         m_currentState == TRADE_STATE_DCA ||
         m_currentState == TRADE_STATE_EXIT;
   }

   bool CanAddDCA() const
   {
      return
         m_currentState == TRADE_STATE_MANAGE ||
         m_currentState == TRADE_STATE_DCA;
   }

   bool IsTradingBlocked() const
   {
      return
         m_currentState == TRADE_STATE_BLOCKED ||
         m_currentState == TRADE_STATE_EXIT;
   }

   void Reset(
      const string reason = "State machine reset"
   )
   {
      m_previousState =
         m_currentState;

      m_currentState =
         TRADE_STATE_IDLE;

      m_lastChangeTime =
         TimeCurrent();

      m_lastReason =
         reason;
   }

   void Block(
      const string reason
   )
   {
      SetState(
         TRADE_STATE_BLOCKED,
         reason
      );
   }

   void BeginEntry(
      const string reason = "Entry started"
   )
   {
      SetState(
         TRADE_STATE_ENTRY,
         reason
      );
   }

   void BeginManage(
      const string reason = "Basket management started"
   )
   {
      SetState(
         TRADE_STATE_MANAGE,
         reason
      );
   }

   void BeginDCA(
      const string reason = "DCA management started"
   )
   {
      SetState(
         TRADE_STATE_DCA,
         reason
      );
   }

   void BeginExit(
      const string reason = "Basket exit started"
   )
   {
      SetState(
         TRADE_STATE_EXIT,
         reason
      );
   }

   void ReturnToIdle(
      const string reason = "Returned to idle"
   )
   {
      SetState(
         TRADE_STATE_IDLE,
         reason
      );
   }
};

#endif