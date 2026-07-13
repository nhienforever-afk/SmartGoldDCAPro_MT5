#ifndef SMARTGOLDDCAPRO_POSITION_MANAGER_MQH
#define SMARTGOLDDCAPRO_POSITION_MANAGER_MQH
class CPositionManager{
private:
 string m_symbol; long m_magic;
 bool SelectManagedByIndex(const int index) const{ulong ticket=PositionGetTicket(index);if(ticket==0 || !PositionSelectByTicket(ticket))return false;return PositionGetString(POSITION_SYMBOL)==m_symbol && PositionGetInteger(POSITION_MAGIC)==m_magic;}
public:
 CPositionManager(){m_symbol=_Symbol;m_magic=0;}
 void Initialize(const string symbol,const long magic){m_symbol=symbol;m_magic=magic;}
 string Symbol() const{return m_symbol;}
 int CountAll() const{int c=0;for(int i=PositionsTotal()-1;i>=0;--i)if(SelectManagedByIndex(i))c++;return c;}
 int CountType(const ENUM_POSITION_TYPE type) const{int c=0;for(int i=PositionsTotal()-1;i>=0;--i){if(!SelectManagedByIndex(i))continue;if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==type)c++;}return c;}
 double TotalProfit() const{double v=0.0;for(int i=PositionsTotal()-1;i>=0;--i){if(!SelectManagedByIndex(i))continue;v+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);}return v;}
 double TotalVolume() const{double v=0.0;for(int i=PositionsTotal()-1;i>=0;--i)if(SelectManagedByIndex(i))v+=PositionGetDouble(POSITION_VOLUME);return v;}
 bool GetBasketDirection(ENUM_POSITION_TYPE &direction) const{int b=CountType(POSITION_TYPE_BUY),s=CountType(POSITION_TYPE_SELL);if(b>0&&s==0){direction=POSITION_TYPE_BUY;return true;}if(s>0&&b==0){direction=POSITION_TYPE_SELL;return true;}return false;}
 bool GetLatestPosition(double &openPrice,double &volume,ENUM_POSITION_TYPE &type,datetime &openTime) const{bool found=false;openTime=0;for(int i=PositionsTotal()-1;i>=0;--i){if(!SelectManagedByIndex(i))continue;datetime t=(datetime)PositionGetInteger(POSITION_TIME);if(!found||t>=openTime){found=true;openTime=t;openPrice=PositionGetDouble(POSITION_PRICE_OPEN);volume=PositionGetDouble(POSITION_VOLUME);type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);}}return found;}
 ulong TicketAt(const int managedIndex) const{int cur=0;for(int i=PositionsTotal()-1;i>=0;--i){if(!SelectManagedByIndex(i))continue;if(cur==managedIndex)return (ulong)PositionGetInteger(POSITION_TICKET);cur++;}return 0;}
};
#endif
