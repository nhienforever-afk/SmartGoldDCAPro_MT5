#ifndef SMARTGOLDDCAPRO_ORDER_MANAGER_MQH
#define SMARTGOLDDCAPRO_ORDER_MANAGER_MQH
#include <Trade/Trade.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>
class COrderManager{
private:
 CTrade m_trade; CRiskManager *m_risk; string m_symbol; string m_comment;
 bool ResultSucceeded() const{uint c=m_trade.ResultRetcode();return c==TRADE_RETCODE_DONE||c==TRADE_RETCODE_DONE_PARTIAL||c==TRADE_RETCODE_PLACED;}
public:
 COrderManager(){m_risk=NULL;m_symbol=_Symbol;m_comment="SmartGoldDCAPro";}
 void Initialize(CRiskManager &risk,const string symbol,const long magic,const int slippage,const string comment){m_risk=&risk;m_symbol=symbol;m_comment=comment;m_trade.SetExpertMagicNumber((ulong)magic);m_trade.SetDeviationInPoints(slippage);m_trade.SetTypeFillingBySymbol(symbol);}
 bool OpenBuy(const double requestedLot,const double sl,const double tp,const string note){if(m_risk==NULL)return false;double lot=m_risk.NormalizeLot(requestedLot);ResetLastError();bool sent=m_trade.Buy(lot,m_symbol,0.0,sl,tp,m_comment+" "+note);if(!sent||!ResultSucceeded()){Print("BUY failed. Error=",GetLastError()," retcode=",m_trade.ResultRetcode()," ",m_trade.ResultRetcodeDescription());return false;}Print("BUY opened. Lot=",DoubleToString(lot,2)," deal=",m_trade.ResultDeal());return true;}
 bool OpenSell(const double requestedLot,const double sl,const double tp,const string note){if(m_risk==NULL)return false;double lot=m_risk.NormalizeLot(requestedLot);ResetLastError();bool sent=m_trade.Sell(lot,m_symbol,0.0,sl,tp,m_comment+" "+note);if(!sent||!ResultSucceeded()){Print("SELL failed. Error=",GetLastError()," retcode=",m_trade.ResultRetcode()," ",m_trade.ResultRetcodeDescription());return false;}Print("SELL opened. Lot=",DoubleToString(lot,2)," deal=",m_trade.ResultDeal());return true;}
 bool ClosePosition(const ulong ticket){if(ticket==0)return false;ResetLastError();bool sent=m_trade.PositionClose(ticket);if(!sent||!ResultSucceeded()){Print("Close failed. Ticket=",ticket," error=",GetLastError()," retcode=",m_trade.ResultRetcode()," ",m_trade.ResultRetcodeDescription());return false;}return true;}
};
#endif
