#ifndef SMARTGOLDDCAPRO_SIGNAL_ENGINE_MQH
#define SMARTGOLDDCAPRO_SIGNAL_ENGINE_MQH
#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
class CSignalEngine{
private:string m_symbol;ENUM_TIMEFRAMES m_timeframe;int m_fast,m_slow,m_rsi,m_atr;
 bool ReadValue(const int handle,const int shift,double &value) const{double d[1];if(handle==INVALID_HANDLE)return false;if(CopyBuffer(handle,0,shift,1,d)!=1)return false;value=d[0];return true;}
public:
 CSignalEngine(){m_symbol=_Symbol;m_timeframe=PERIOD_M15;m_fast=m_slow=m_rsi=m_atr=INVALID_HANDLE;}
 bool Initialize(const string symbol,const ENUM_TIMEFRAMES tf){m_symbol=symbol;m_timeframe=tf;m_fast=iMA(m_symbol,m_timeframe,InpFastEMAPeriod,0,MODE_EMA,PRICE_CLOSE);m_slow=iMA(m_symbol,m_timeframe,InpSlowEMAPeriod,0,MODE_EMA,PRICE_CLOSE);m_rsi=iRSI(m_symbol,m_timeframe,InpRSIPeriod,PRICE_CLOSE);m_atr=iATR(m_symbol,m_timeframe,InpATRPeriod);return m_fast!=INVALID_HANDLE&&m_slow!=INVALID_HANDLE&&m_rsi!=INVALID_HANDLE&&m_atr!=INVALID_HANDLE;}
 void Release(){if(m_fast!=INVALID_HANDLE)IndicatorRelease(m_fast);if(m_slow!=INVALID_HANDLE)IndicatorRelease(m_slow);if(m_rsi!=INVALID_HANDLE)IndicatorRelease(m_rsi);if(m_atr!=INVALID_HANDLE)IndicatorRelease(m_atr);m_fast=m_slow=m_rsi=m_atr=INVALID_HANDLE;}
 ENUM_TRADE_SIGNAL GetSignal() const{double fast,slow,rsi,atr;if(!ReadValue(m_fast,1,fast)||!ReadValue(m_slow,1,slow)||!ReadValue(m_rsi,1,rsi)||!ReadValue(m_atr,1,atr))return SIGNAL_NONE;double point=SymbolInfoDouble(m_symbol,SYMBOL_POINT);if(point<=0.0)return SIGNAL_NONE;if(InpMinimumATRPoints>0.0&&atr/point<InpMinimumATRPoints)return SIGNAL_NONE;if(fast>slow&&rsi>=InpRSIBuyMinimum)return SIGNAL_BUY;if(fast<slow&&rsi<=InpRSISellMaximum)return SIGNAL_SELL;return SIGNAL_NONE;}
};
#endif
