#ifndef SMARTGOLDDCAPRO_RISK_MANAGER_MQH
#define SMARTGOLDDCAPRO_RISK_MANAGER_MQH
class CRiskManager{
private:
 string m_symbol; double m_peakEquity; double m_maxDrawdownPercent;
 int VolumeDigits(double step) const{ if(step>=1.0)return 0; if(step>=0.1)return 1; if(step>=0.01)return 2; if(step>=0.001)return 3; return 4; }
public:
 CRiskManager(){m_symbol=_Symbol;m_peakEquity=0.0;m_maxDrawdownPercent=0.0;}
 void Initialize(const string symbol,const double maxDD){m_symbol=symbol;m_maxDrawdownPercent=MathMax(0.0,maxDD);m_peakEquity=AccountInfoDouble(ACCOUNT_EQUITY);}
 void UpdatePeakEquity(){double e=AccountInfoDouble(ACCOUNT_EQUITY);if(e>m_peakEquity)m_peakEquity=e;}
 double CurrentDrawdownPercent() const{double e=AccountInfoDouble(ACCOUNT_EQUITY);if(m_peakEquity<=0.0)return 0.0;return MathMax(0.0,(m_peakEquity-e)/m_peakEquity*100.0);}
 bool IsEquityProtectionTriggered() const{if(m_maxDrawdownPercent<=0.0)return false;return CurrentDrawdownPercent()>=m_maxDrawdownPercent;}
 double NormalizeLot(double lot) const{double minLot=SymbolInfoDouble(m_symbol,SYMBOL_VOLUME_MIN),maxLot=SymbolInfoDouble(m_symbol,SYMBOL_VOLUME_MAX),step=SymbolInfoDouble(m_symbol,SYMBOL_VOLUME_STEP);if(step<=0.0)step=0.01;lot=MathMax(minLot,MathMin(maxLot,lot));lot=MathFloor((lot+1e-10)/step)*step;return NormalizeDouble(lot,VolumeDigits(step));}
 int CurrentSpreadPoints() const{MqlTick tick;if(!SymbolInfoTick(m_symbol,tick))return 2147483647;double point=SymbolInfoDouble(m_symbol,SYMBOL_POINT);if(point<=0.0)return 2147483647;return (int)MathRound((tick.ask-tick.bid)/point);}
 bool CanOpenTrade(const double requestedLot,const int maxSpread,string &reason) const{
  if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){reason="Terminal trading is disabled.";return false;}
  if(!MQLInfoInteger(MQL_TRADE_ALLOWED)){reason="EA trading is disabled.";return false;}
  if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)){reason="Account trading is not allowed.";return false;}
  if(IsEquityProtectionTriggered()){reason="Equity protection is active.";return false;}
  double lot=NormalizeLot(requestedLot);if(lot<=0.0){reason="Invalid lot size.";return false;}
  int spread=CurrentSpreadPoints();if(maxSpread>0 && spread>maxSpread){reason="Spread is too high: "+IntegerToString(spread);return false;}
  reason="OK";return true;
 }
};
#endif
