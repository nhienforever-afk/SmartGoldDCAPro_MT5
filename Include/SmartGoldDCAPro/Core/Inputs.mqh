#ifndef SMARTGOLDDCAPRO_CORE_INPUTS_MQH
#define SMARTGOLDDCAPRO_CORE_INPUTS_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.1 - Vietnamese Inputs               |
//| Tên biến kỹ thuật được giữ nguyên để bảo đảm tương thích         |
//+------------------------------------------------------------------+

//==================================================================
// 01. CÀI ĐẶT CHUNG
//==================================================================

input group "===== 01. CÀI ĐẶT CHUNG ====="

input long   InpMagicNumber          = 260713;             // Mã Magic Number của EA
input string InpTradeComment         = "SmartGoldDCAPro";  // Ghi chú gắn vào lệnh
input bool   InpAllowNewTrades       = true;               // Cho phép EA mở lệnh mới
input bool   InpRequireGoldSymbol    = true;               // Chỉ cho phép giao dịch XAU/GOLD
input int    InpTradeCooldownSeconds = 20;                 // Thời gian chờ giữa các lệnh (giây)

//==================================================================
// 02. THỰC THI LỆNH
//==================================================================

input group "===== 02. THỰC THI LỆNH ====="

input double InpInitialLot          = 0.01;  // Lot ban đầu
input int    InpMaximumSpreadPoints = 80;    // Spread tối đa cho phép (point)
input int    InpSlippagePoints      = 30;    // Độ trượt giá tối đa (point)

//==================================================================
// 03. BẬT / TẮT BỘ LỌC TÍN HIỆU
//==================================================================

input group "===== 03. BẬT / TẮT BỘ LỌC TÍN HIỆU ====="

input bool InpUseEMAFilter = true;  // Sử dụng bộ lọc EMA
input bool InpUseRSIFilter = true;  // Sử dụng bộ lọc RSI
input bool InpUseADXFilter = true;  // Sử dụng bộ lọc ADX
input bool InpUseATRFilter = true;  // Sử dụng bộ lọc ATR

//==================================================================
// 04. THÔNG SỐ TÍN HIỆU
//==================================================================

input group "===== 04. THÔNG SỐ TÍN HIỆU ====="

input ENUM_TIMEFRAMES InpSignalTimeframe = PERIOD_M15;  // Khung thời gian phân tích tín hiệu

input int InpFastEMAPeriod = 20;  // Chu kỳ EMA nhanh
input int InpSlowEMAPeriod = 50;  // Chu kỳ EMA chậm

input int    InpRSIPeriod      = 14;    // Chu kỳ RSI
input double InpRSIBuyMinimum  = 52.0;  // RSI tối thiểu để xem xét BUY
input double InpRSISellMaximum = 48.0;  // RSI tối đa để xem xét SELL

input int    InpADXPeriod  = 14;    // Chu kỳ ADX
input double InpMinimumADX = 20.0;  // ADX tối thiểu xác nhận xu hướng

input int    InpATRPeriod        = 14;     // Chu kỳ ATR
input double InpMinimumATRPoints = 100.0;  // ATR tối thiểu cho phép giao dịch (point)

//==================================================================
// 05. TÍN HIỆU CÓ TRỌNG SỐ
//==================================================================

input group "===== 05. TÍN HIỆU CÓ TRỌNG SỐ ====="

input bool   InpUseWeightedSignal     = true;  // Sử dụng hệ thống chấm điểm tín hiệu
input double InpMinimumSignalScore    = 65.0;  // Điểm tín hiệu tối thiểu
input double InpMinimumScoreAdvantage = 10.0;  // Chênh lệch điểm BUY/SELL tối thiểu

input double InpEMAWeight = 40.0;  // Trọng số EMA
input double InpRSIWeight = 25.0;  // Trọng số RSI
input double InpADXWeight = 35.0;  // Trọng số ADX

//==================================================================
// 06. ĐIỀU KHIỂN DCA
//==================================================================

input group "===== 06. ĐIỀU KHIỂN DCA ====="

input bool InpEnableDCA = true;  // Bật chức năng DCA

input ENUM_DCA_CONTROL_MODE InpDCAControlMode =
   DCA_CONTROL_ADAPTIVE;  // Chế độ điều khiển DCA

input int InpMaximumDCALevels =
   6;  // Số lượng lệnh tối đa trong một giỏ

//==================================================================
// 07. KHOẢNG CÁCH DCA CỐ ĐỊNH / THÍCH ỨNG
//==================================================================

input group "===== 07. KHOẢNG CÁCH DCA CỐ ĐỊNH / THÍCH ỨNG ====="

input double InpDCADistancePoints =
   500.0;  // Khoảng cách DCA cố định (point)

input bool InpUseAdaptiveGrid =
   true;  // Sử dụng Grid thích ứng theo ATR

input double InpGridATRMultiplier =
   1.50;  // Hệ số nhân ATR để tính Grid

input double InpMinimumGridPoints =
   200.0;  // Khoảng cách Grid tối thiểu (point)

input double InpMaximumGridPoints =
   1200.0;  // Khoảng cách Grid tối đa (point)

input double InpHighVolatilityATRPoints =
   800.0;  // Ngưỡng ATR xác định biến động mạnh (point)

input bool InpBlockDCAInHighVolatility =
   true;  // Chặn DCA khi thị trường biến động mạnh

//==================================================================
// 08. DCA THỦ CÔNG
//==================================================================

input group "===== 08. DCA THỦ CÔNG ====="

input double InpManualInitialLot =
   0.01;  // Lot ban đầu trong chế độ thủ công

input double InpManualDCALot =
   0.01;  // Lot cho mỗi lệnh DCA thủ công

input double InpManualDCADistancePoints =
   500.0;  // Khoảng cách DCA thủ công (point)

//==================================================================
// 09. QUẢN LÝ KHỐI LƯỢNG
//==================================================================

input group "===== 09. QUẢN LÝ KHỐI LƯỢNG ====="

input ENUM_LOT_MODE InpLotMode =
   LOT_MODE_SMART_RISK;  // Chế độ tính Lot

input double InpLotMultiplier =
   1.30;  // Hệ số nhân Lot cho lệnh DCA tiếp theo

input double InpMaximumLot =
   1.00;  // Lot tối đa được phép

//==================================================================
// 10. BẢO VỆ THÔNG MINH
//==================================================================

input group "===== 10. BẢO VỆ THÔNG MINH ====="

input bool InpEnableSmartSafety =
   true;  // Bật Smart Safety

input int InpSmartSafetyStartOrder =
   3;  // Bắt đầu Smart Safety từ lệnh số

input bool InpSmartSafetyUseRiskScore =
   true;  // Chặn DCA theo điểm rủi ro

input bool InpSmartSafetyUseMarginProtection =
   true;  // Bảo vệ theo Margin

input bool InpSmartSafetyUseHighVolatilityBlock =
   true;  // Bảo vệ khi biến động mạnh

//==================================================================
// 11. MARGIN VÀ RỦI RO DCA
//==================================================================

input group "===== 11. MARGIN VÀ RỦI RO DCA ====="

input double InpMinimumMarginLevelPercent =
   200.0;  // Mức Margin tối thiểu cho phép (%)

input double InpMinimumFreeMarginMoney =
   100.0;  // Free Margin tối thiểu

input int InpMaximumRiskScoreForDCA =
   70;  // Điểm rủi ro tối đa cho phép DCA

//==================================================================
// 12. ĐÓNG GIỎ LỆNH
//==================================================================

input group "===== 12. ĐÓNG GIỎ LỆNH ====="

input double InpBasketTakeProfitMoney =
   10.0;  // Lợi nhuận giỏ để đóng toàn bộ

input double InpBasketStopLossMoney =
   50.0;  // Mức lỗ giỏ để đóng toàn bộ

//==================================================================
// 13. BẢO VỆ TÀI KHOẢN
//==================================================================

input group "===== 13. BẢO VỆ TÀI KHOẢN ====="

input double InpMaxEquityDrawdownPercent =
   15.0;  // Drawdown Equity tối đa (%)

input bool InpCloseBasketOnEquityProtection =
   true;  // Đóng giỏ khi kích hoạt bảo vệ Equity

//==================================================================
// 14. GIỚI HẠN LỖ TRONG NGÀY
//==================================================================

input group "===== 14. GIỚI HẠN LỖ TRONG NGÀY ====="

input double InpMaxDailyLossMoney =
   0.0;  // Lỗ tối đa trong ngày, 0 = tắt bảo vệ

//==================================================================
// 15. BỘ LỌC PHIÊN GIAO DỊCH
//==================================================================

input group "===== 15. BỘ LỌC PHIÊN GIAO DỊCH ====="

input bool InpEnableSessionFilter =
   false;  // Bật giới hạn phiên giao dịch

input int InpSessionStartHour =
   7;  // Giờ bắt đầu giao dịch theo giờ Server

input int InpSessionEndHour =
   22;  // Giờ kết thúc giao dịch theo giờ Server

//==================================================================
// 16. NHẬT KÝ GIAO DỊCH
//==================================================================

input group "===== 16. NHẬT KÝ GIAO DỊCH ====="

input bool InpEnableTradeJournal =
   true;  // Bật ghi nhật ký giao dịch CSV

input string InpTradeJournalFile =
   "SmartGoldDCAPro_Journal.csv";  // Tên file nhật ký giao dịch

//==================================================================
// 17. DASHBOARD
//==================================================================

input group "===== 17. DASHBOARD ====="

input bool InpEnableDashboard =
   true;  // Hiển thị Dashboard trên biểu đồ

#endif