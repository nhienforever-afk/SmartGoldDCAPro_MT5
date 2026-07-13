#ifndef SMARTGOLDDCAPRO_EXIT_ENGINE_MQH
#define SMARTGOLDDCAPRO_EXIT_ENGINE_MQH

#include <SmartGoldDCAPro/Trade/BasketManager.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>

class CExitEngine
{
private:
   CBasketManager   *m_basket;
   CPositionManager *m_positions;

public:
   CExitEngine()
   {
      m_basket    = NULL;
      m_positions = NULL;
   }

   void Initialize(CBasketManager &basket,
                   CPositionManager &positions)
   {
      m_basket    = &basket;
      m_positions = &positions;
   }

   bool Manage()
   {
      if(m_basket == NULL || m_positions == NULL)
         return false;

      if(m_positions.CountAll() <= 0)
         return false;

      return m_basket.Manage(
         InpBasketTakeProfitMoney,
         InpBasketStopLossMoney
      );
   }

   bool EmergencyClose(const string reason)
   {
      if(m_basket == NULL)
         return false;

      return m_basket.CloseAll(reason);
   }
};

#endif
