#property strict

#include <SmartGoldDCAPro/Dashboard/DashboardData.mqh>

SDashboardData g_dashboard;

int OnInit()
{
   g_dashboard.Reset();

   g_dashboard.symbol = _Symbol;

   g_dashboard.serverTime = TimeCurrent();

   g_dashboard.valid = true;

   if(!g_dashboard.IsValid())
      return INIT_FAILED;

   Print("DashboardData OK");

   return INIT_SUCCEEDED;
}

void OnTick()
{
}