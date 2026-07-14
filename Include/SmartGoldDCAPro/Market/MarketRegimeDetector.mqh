#ifndef SMARTGOLDDCAPRO_MARKET_REGIME_DETECTOR_MQH
#define SMARTGOLDDCAPRO_MARKET_REGIME_DETECTOR_MQH
#include <SmartGoldDCAPro/Core/Types.mqh>
class CMarketRegimeDetector{public:ENUM_MARKET_REGIME Detect(const double atr,const double adx,const double lowATR,const double highATR,const double trendADX)const{if(atr<=0)return MARKET_UNKNOWN;if(atr>=highATR)return MARKET_HIGH_VOLATILITY;if(atr<=lowATR)return MARKET_LOW_VOLATILITY;if(adx>=trendADX)return MARKET_TRENDING;return MARKET_SIDEWAY;}string Name(const ENUM_MARKET_REGIME r)const{switch(r){case MARKET_LOW_VOLATILITY:return "LOW VOLATILITY";case MARKET_SIDEWAY:return "SIDEWAY";case MARKET_TRENDING:return "TRENDING";case MARKET_HIGH_VOLATILITY:return "HIGH VOLATILITY";default:return "UNKNOWN";}}};
#endif
