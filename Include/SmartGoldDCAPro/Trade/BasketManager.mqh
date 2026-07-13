#ifndef SMARTGOLDDCAPRO_BASKET_MANAGER_MQH
#define SMARTGOLDDCAPRO_BASKET_MANAGER_MQH
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>
class CBasketManager{
private:CPositionManager *m_positions;COrderManager *m_orders;
public:
 CBasketManager(){m_positions=NULL;m_orders=NULL;}
 void Initialize(CPositionManager &p,COrderManager &o){m_positions=&p;m_orders=&o;}
 bool CloseAll(const string reason){if(m_positions==NULL||m_orders==NULL)return false;bool had=m_positions.CountAll()>0,all=true;for(int pass=0;pass<3;++pass){int count=m_positions.CountAll();if(count<=0)break;for(int i=count-1;i>=0;--i){ulong t=m_positions.TicketAt(i);if(t>0&&!m_orders.ClosePosition(t))all=false;}}if(had)Print("Basket close: ",reason);return had&&all;}
 bool Manage(const double tp,const double sl){if(m_positions==NULL||m_positions.CountAll()<=0)return false;double p=m_positions.TotalProfit();if(tp>0.0&&p>=tp)return CloseAll("Basket take profit");if(sl>0.0&&p<=-sl)return CloseAll("Basket stop loss");return false;}
};
#endif
