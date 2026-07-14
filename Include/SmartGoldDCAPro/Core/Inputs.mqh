#ifndef SMARTGOLDDCAPRO_INPUTS_MQH
#define SMARTGOLDDCAPRO_INPUTS_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

input group "=== GENERAL ==="
input long                InpMagicNumber             = 260713;
input string              InpTradeComment            = "SmartGoldDCAPro";
input bool                InpAllowNewTrades          = true;
input bool                InpRequireGoldSymbol       = true;
input ENUM_DIRECTION_MODE InpDirectionMode           = DIRECTION_AUTO;
input int                 InpTradeCooldownSeconds    = 20;

input group "=== EXECUTION ==="
input double              InpInitialLot              = 0.01;
input int                 InpMaximumSpreadPoints     = 80;
input int                 InpSlippagePoints          = 30;

input group "=== INDICATOR SWITCHES ==="
input bool                InpUseEMAFilter            = true;
input bool                InpUseRSIFilter            = true;
input bool                InpUseADXFilter            = false;
input bool                InpUseATRFilter            = true;

input group "=== SIGNAL BUILDER ==="
input bool                InpUseWeightedSignal       = true;
input double              InpMinimumSignalScore      = 65.0;
input double              InpMinimumScoreAdvantage  = 10.0;
input double              InpEMAWeight               = 40.0;
input double              InpRSIWeight               = 25.0;
input double              InpADXWeight               = 35.0;

input group "=== SIGNAL PARAMETERS ==="
input ENUM_TIMEFRAMES     InpSignalTimeframe         = PERIOD_M15;
input int                 InpFastEMAPeriod           = 20;
input int                 InpSlowEMAPeriod           = 50;
input int                 InpRSIPeriod               = 14;
input double              InpRSIBuyMinimum           = 52.0;
input double              InpRSISellMaximum          = 48.0;
input int                 InpADXPeriod               = 14;
input double              InpMinimumADX              = 20.0;
input int                 InpATRPeriod               = 14;
input double              InpMinimumATRPoints        = 100.0;

input group "=== DCA CONTROL MODE ==="
input ENUM_DCA_CONTROL_MODE InpDCAControlMode        = DCA_CONTROL_SMART;
input bool                  InpEnableDCA              = true;
input int                   InpMaximumDCALevels       = 6;

input group "=== SMART DCA MODE ==="
input double              InpDCADistancePoints       = 500.0;
input double              InpLotMultiplier           = 1.30;
input double              InpMaximumLot              = 1.00;
input bool                InpUseAdaptiveGrid         = true;
input double              InpGridATRMultiplier       = 1.50;
input double              InpMinimumGridPoints       = 200.0;
input double              InpMaximumGridPoints       = 1200.0;
input double              InpHighVolatilityATRPoints = 800.0;
input bool                InpBlockDCAInHighVolatility = true;

input group "=== MANUAL DCA MODE ==="
input double              InpManualInitialLot        = 0.01;
input double              InpManualDCALot            = 0.01;
input double              InpManualDCADistancePoints = 500.0;

input group "=== SMART SAFETY ACTIVATION ==="
input bool                InpEnableSmartSafety                  = true;
input int                 InpSmartSafetyStartOrder              = 3;
input bool                InpSmartSafetyUseRiskScore            = true;
input bool                InpSmartSafetyUseMarginProtection     = true;
input bool                InpSmartSafetyUseHighVolatilityBlock  = true;

input group "=== MARGIN & RISK PROTECTION ==="
input double              InpMinimumMarginLevelPercent = 200.0;
input double              InpMinimumFreeMarginMoney    = 100.0;
input int                 InpMaximumRiskScoreForDCA    = 70;

input group "=== BASKET EXIT (ACCOUNT CURRENCY) ==="
input double              InpBasketTakeProfitMoney    = 10.0;
input double              InpBasketStopLossMoney      = 50.0;

input group "=== ACCOUNT PROTECTION ==="
input double              InpMaxEquityDrawdownPercent = 15.0;
input bool                InpCloseBasketOnEquityProtection = true;

input group "=== SESSION FILTER ==="
input bool                InpEnableSessionFilter      = false;
input int                 InpSessionStartHour         = 7;
input int                 InpSessionEndHour           = 22;

input group "=== DAILY PROTECTION ==="
input double              InpMaxDailyLossMoney        = 0.0;

input group "=== JOURNAL ==="
input bool                InpEnableTradeJournal       = true;
input string              InpTradeJournalFile         = "SmartGoldDCAPro_Journal.csv";

#endif
