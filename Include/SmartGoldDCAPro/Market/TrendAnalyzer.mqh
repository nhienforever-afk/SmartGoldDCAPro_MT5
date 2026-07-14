#ifndef SMARTGOLDDCAPRO_TREND_ANALYZER_MQH
#define SMARTGOLDDCAPRO_TREND_ANALYZER_MQH
#include <SmartGoldDCAPro/Core/Types.mqh>
class CTrendAnalyzer
{
private:
 int m_higherFast,m_higherSlow,m_confirmFast,m_confirmSlow;
 bool ReadMA(const int h,double &v)const{if(h==INVALID_HANDLE)return false;double d[1];if(CopyBuffer(h,0,1,1,d)!=1)return false;v=d[0];return true;}
 ENUM_TREND_DIRECTION Dir(const double f,const double s)const{if(f>s)return TREND_BULLISH;if(f<s)return TREND_BEARISH;return TREND_NEUTRAL;}
public:
 CTrendAnalyzer(){m_higherFast=m_higherSlow=m_confirmFast=m_confirmSlow=INVALID_HANDLE;}
 bool Initialize(const string symbol,const ENUM_TIMEFRAMES higherTF,const ENUM_TIMEFRAMES confirmTF,const int fastPeriod,const int slowPeriod){m_higherFast=iMA(symbol,higherTF,fastPeriod,0,MODE_EMA,PRICE_CLOSE);m_higherSlow=iMA(symbol,higherTF,slowPeriod,0,MODE_EMA,PRICE_CLOSE);m_confirmFast=iMA(symbol,confirmTF,fastPeriod,0,MODE_EMA,PRICE_CLOSE);m_confirmSlow=iMA(symbol,confirmTF,slowPeriod,0,MODE_EMA,PRICE_CLOSE);return m_higherFast!=INVALID_HANDLE&&m_higherSlow!=INVALID_HANDLE&&m_confirmFast!=INVALID_HANDLE&&m_confirmSlow!=INVALID_HANDLE;}
 void Release(){if(m_higherFast!=INVALID_HANDLE)IndicatorRelease(m_higherFast);if(m_higherSlow!=INVALID_HANDLE)IndicatorRelease(m_higherSlow);if(m_confirmFast!=INVALID_HANDLE)IndicatorRelease(m_confirmFast);if(m_confirmSlow!=INVALID_HANDLE)IndicatorRelease(m_confirmSlow);m_higherFast=m_higherSlow=m_confirmFast=m_confirmSlow=INVALID_HANDLE;}
 bool Analyze(ENUM_TREND_DIRECTION &direction,double &alignment)const{double hf=0,hs=0,cf=0,cs=0;if(!ReadMA(m_higherFast,hf)||!ReadMA(m_higherSlow,hs)||!ReadMA(m_confirmFast,cf)||!ReadMA(m_confirmSlow,cs)){direction=TREND_NEUTRAL;alignment=0;return false;}ENUM_TREND_DIRECTION hd=Dir(hf,hs),cd=Dir(cf,cs);if(hd==cd&&hd!=TREND_NEUTRAL){direction=hd;alignment=100;return true;}if(hd!=TREND_NEUTRAL){direction=hd;alignment=50;return true;}direction=cd;alignment=(cd==TREND_NEUTRAL?0:50);return true;}
 double TrendScore()
{
   SMarketState state;

   if(!Read(state))
      return 0;

   if(state.highVolatility)
      return 25;

   return 80;
}

double VolatilityScore()
{
   SMarketState state;

   if(!Read(state))
      return 0;

   if(state.highVolatility)
      return 20;

   return 80;
}

double SpreadScore()
{
   SMarketState state;

   if(!Read(state))
      return 0;

   if(state.spreadPoints > 40)
      return 15;

   return 90;
};
#endif
