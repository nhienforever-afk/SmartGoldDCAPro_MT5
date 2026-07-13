#ifndef SMARTGOLDDCAPRO_INPUTS_MQH
#define SMARTGOLDDCAPRO_INPUTS_MQH
input group "=== GENERAL ==="
input long InpMagicNumber=260713;
input string InpTradeComment="SmartGoldDCAPro";
input bool InpAllowNewTrades=true;
input bool InpRequireGoldSymbol=true;
input ENUM_DIRECTION_MODE InpDirectionMode=DIRECTION_AUTO;
input int InpTradeCooldownSeconds=20;
input group "=== EXECUTION ==="
input double InpInitialLot=0.01;
input int InpMaximumSpreadPoints=80;
input int InpSlippagePoints=30;
input group "=== SIGNAL ==="
input ENUM_TIMEFRAMES InpSignalTimeframe=PERIOD_M15;
input int InpFastEMAPeriod=20;
input int InpSlowEMAPeriod=50;
input int InpRSIPeriod=14;
input double InpRSIBuyMinimum=52.0;
input double InpRSISellMaximum=48.0;
input int InpATRPeriod=14;
input double InpMinimumATRPoints=100.0;
input group "=== DCA ==="
input bool InpEnableDCA=true;
input int InpMaximumDCALevels=6;
input double InpDCADistancePoints=500.0;
input double InpLotMultiplier=1.30;
input double InpMaximumLot=1.00;
input group "=== BASKET EXIT (ACCOUNT CURRENCY) ==="
input double InpBasketTakeProfitMoney=10.0;
input double InpBasketStopLossMoney=50.0;
input group "=== ACCOUNT PROTECTION ==="
input double InpMaxEquityDrawdownPercent=15.0;
input bool InpCloseBasketOnEquityProtection=true;

input group "=== JOURNAL ==="
input bool                InpEnableTradeJournal            = true;
input string              InpTradeJournalFile              = "SmartGoldDCAPro_Journal.csv";


input group "=== ADAPTIVE GRID ==="
input bool                InpUseAdaptiveGrid               = true;
input double              InpGridATRMultiplier             = 1.50;
input double              InpMinimumGridPoints             = 200.0;
input double              InpMaximumGridPoints             = 1200.0;
input double              InpHighVolatilityATRPoints       = 800.0;
input bool                InpBlockDCAInHighVolatility      = true;

#endif
