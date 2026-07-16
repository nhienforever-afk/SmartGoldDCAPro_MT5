#property strict

#include <SmartGoldDCAPro/Dashboard/DashboardData.mqh>
#include <SmartGoldDCAPro/Dashboard/DashboardRenderer.mqh>

SDashboardData g_data;
CDashboardRenderer g_renderer;

int OnInit()
{
   g_data.Reset();

   g_data.symbol = _Symbol;
   g_data.serverTime = TimeCurrent();
   g_data.valid = true;

   g_data.marketTrend = "BULLISH";
   g_data.signal = "BUY";
   g_data.decision = "BUY";

   g_data.basketDirection = "BUY";
   g_data.basketOrders = 3;
   g_data.basketProfit = 25.40;

   g_data.dcaLevel = 3;
   g_data.riskScore = 28;

   g_data.balance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_data.equity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_data.marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

   g_renderer.Initialize();

   if(!g_renderer.Update(g_data))
      return INIT_FAILED;

   Print("DashboardRenderer OK");

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   g_renderer.Release();
}

void OnTick()
{
}