#ifndef SMARTGOLDDCAPRO_TRADE_EXIT_REQUEST_MQH
#define SMARTGOLDDCAPRO_TRADE_EXIT_REQUEST_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Exit Request                    |
//| DTO chứa dữ liệu yêu cầu đóng basket hoặc position               |
//+------------------------------------------------------------------+

enum ENUM_EXIT_ACTION
{
   EXIT_ACTION_NONE = 0,
   EXIT_ACTION_CLOSE_BASKET,
   EXIT_ACTION_CLOSE_POSITION
};

enum ENUM_EXIT_REASON
{
   EXIT_REASON_NONE = 0,
   EXIT_REASON_BASKET_TAKE_PROFIT,
   EXIT_REASON_BASKET_STOP_LOSS,
   EXIT_REASON_EQUITY_PROTECTION,
   EXIT_REASON_DAILY_LOSS_PROTECTION,
   EXIT_REASON_MANUAL,
   EXIT_REASON_EMERGENCY
};

//+------------------------------------------------------------------+
//| Human-readable Exit Action                                       |
//+------------------------------------------------------------------+
string SGDPExitActionName(
   const ENUM_EXIT_ACTION action
)
{
   switch(action)
   {
      case EXIT_ACTION_CLOSE_BASKET:
         return "CLOSE_BASKET";

      case EXIT_ACTION_CLOSE_POSITION:
         return "CLOSE_POSITION";

      case EXIT_ACTION_NONE:
         return "NONE";
   }

   return "UNKNOWN";
}

//+------------------------------------------------------------------+
//| Human-readable Exit Reason                                       |
//+------------------------------------------------------------------+
string SGDPExitReasonName(
   const ENUM_EXIT_REASON reason
)
{
   switch(reason)
   {
      case EXIT_REASON_BASKET_TAKE_PROFIT:
         return "BASKET_TAKE_PROFIT";

      case EXIT_REASON_BASKET_STOP_LOSS:
         return "BASKET_STOP_LOSS";

      case EXIT_REASON_EQUITY_PROTECTION:
         return "EQUITY_PROTECTION";

      case EXIT_REASON_DAILY_LOSS_PROTECTION:
         return "DAILY_LOSS_PROTECTION";

      case EXIT_REASON_MANUAL:
         return "MANUAL";

      case EXIT_REASON_EMERGENCY:
         return "EMERGENCY";

      case EXIT_REASON_NONE:
         return "NONE";
   }

   return "UNKNOWN";
}

//+------------------------------------------------------------------+
//| Exit Request DTO                                                 |
//+------------------------------------------------------------------+
struct SExitRequest
{
   ENUM_EXIT_ACTION action;
   ENUM_EXIT_REASON reasonCode;

   ulong positionTicket;

   double basketProfit;
   double triggerValue;

   datetime createdTime;

   string reason;
   string comment;

   bool urgent;
   bool valid;

   //+----------------------------------------------------------------+
   //| Reset request                                                   |
   //+----------------------------------------------------------------+
   void Reset()
   {
      action =
         EXIT_ACTION_NONE;

      reasonCode =
         EXIT_REASON_NONE;

      positionTicket =
         0;

      basketProfit =
         0.0;

      triggerValue =
         0.0;

      createdTime =
         0;

      reason =
         "Exit Request has not been prepared.";

      comment =
         "";

      urgent =
         false;

      valid =
         false;
   }

   //+----------------------------------------------------------------+
   //| Validate request                                                |
   //+----------------------------------------------------------------+
   bool IsValid() const
   {
      if(!valid)
         return false;

      if(action != EXIT_ACTION_CLOSE_BASKET &&
         action != EXIT_ACTION_CLOSE_POSITION)
      {
         return false;
      }

      if(reasonCode == EXIT_REASON_NONE)
         return false;

      if(createdTime <= 0)
         return false;

      if(reason == "")
         return false;

      if(action == EXIT_ACTION_CLOSE_POSITION &&
         positionTicket == 0)
      {
         return false;
      }

      return true;
   }

   bool IsBasketClose() const
   {
      return
         IsValid() &&
         action == EXIT_ACTION_CLOSE_BASKET;
   }

   bool IsPositionClose() const
   {
      return
         IsValid() &&
         action == EXIT_ACTION_CLOSE_POSITION;
   }

   bool IsEmergency() const
   {
      return
         IsValid() &&
         (
            urgent ||
            reasonCode == EXIT_REASON_EQUITY_PROTECTION ||
            reasonCode == EXIT_REASON_DAILY_LOSS_PROTECTION ||
            reasonCode == EXIT_REASON_EMERGENCY
         );
   }

   string ActionName() const
   {
      return
         SGDPExitActionName(
            action
         );
   }

   string ReasonName() const
   {
      return
         SGDPExitReasonName(
            reasonCode
         );
   }
};

#endif