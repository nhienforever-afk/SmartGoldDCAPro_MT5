# SmartGoldDCAPro v1.32 — Option Modes Patch

## Tính năng mới

1. Chọn lệnh bắt đầu kích hoạt Smart Safety:
   - `InpEnableSmartSafety`
   - `InpSmartSafetyStartOrder`
   - Ví dụ đặt `3`: khi EA chuẩn bị mở lệnh thứ 3, các bảo vệ thông minh bắt đầu hoạt động.

2. Bật/tắt riêng từng chỉ báo:
   - `InpUseEMAFilter`
   - `InpUseRSIFilter`
   - `InpUseATRFilter`

3. Chế độ DCA:
   - `DCA_CONTROL_SMART`: Adaptive Grid + lot multiplier/Smart Lot.
   - `DCA_CONTROL_MANUAL`: lot đầu, lot DCA và khoảng cách DCA cố định do người dùng nhập.

4. Từng lớp Smart Safety có thể bật/tắt:
   - Risk Score
   - Margin Protection
   - High-Volatility Block

## Quy tắc an toàn

- Trong `AUTO`, phải bật EMA hoặc RSI để có hướng BUY/SELL.
- Nếu tắt EMA và RSI, hãy chọn `BUY ONLY` hoặc `SELL ONLY`.
- Manual mode chỉ cố định lot và khoảng cách; các bảo vệ tài khoản cấp cao như Equity Protection và Basket Stop Loss vẫn hoạt động.
- Khi Smart Safety chưa đến lệnh kích hoạt, EA vẫn tuân thủ spread, cooldown, maximum DCA levels và basket protection.
