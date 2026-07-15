#ifndef SMARTGOLDDCAPRO_TRADE_ENTRY_REQUEST_MQH
#define SMARTGOLDDCAPRO_TRADE_ENTRY_REQUEST_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Entry Request                   |
//| DTO chứa toàn bộ dữ liệu cần thiết để chuẩn bị mở một lệnh       |
//+------------------------------------------------------------------+
struct SEntryRequest
{
   ENUM_DECISION_ACTION action;
   ENUM_POSITION_TYPE   positionType;

   double lot;
   double stopLoss;
   double takeProfit;

   double decisionScore;
   double confidence;
   double quality;

   datetime createdTime;

   string comment;
   string reason;

   bool valid;

   //+----------------------------------------------------------------+
   //| Reset request                                                   |
   //+----------------------------------------------------------------+
   void Reset()
   {
      action =
         DECISION_WAIT;

      positionType =
         POSITION_TYPE_BUY;

      lot =
         0.0;

      stopLoss =
         0.0;

      takeProfit =
         0.0;

      decisionScore =
         0.0;

      confidence =
         0.0;

      quality =
         0.0;

      createdTime =
         0;

      comment =
         "";

      reason =
         "Entry Request has not been prepared.";

      valid =
         false;
   }

   //+----------------------------------------------------------------+
   //| Validate request fields                                         |
   //+----------------------------------------------------------------+
   bool IsValid() const
   {
      if(!valid)
         return false;

      if(action != DECISION_BUY &&
         action != DECISION_SELL)
      {
         return false;
      }

      if(lot <= 0.0)
         return false;

      if(decisionScore < 0.0 ||
         decisionScore > 100.0)
      {
         return false;
      }

      if(confidence < 0.0 ||
         confidence > 100.0)
      {
         return false;
      }

      if(quality < 0.0 ||
         quality > 100.0)
      {
         return false;
      }

      if(action == DECISION_BUY &&
         positionType != POSITION_TYPE_BUY)
      {
         return false;
      }

      if(action == DECISION_SELL &&
         positionType != POSITION_TYPE_SELL)
      {
         return false;
      }

      return true;
   }

   //+----------------------------------------------------------------+
   //| Check BUY request                                               |
   //+----------------------------------------------------------------+
   bool IsBuy() const
   {
      return
         IsValid() &&
         action == DECISION_BUY &&
         positionType == POSITION_TYPE_BUY;
   }

   //+----------------------------------------------------------------+
   //| Check SELL request                                              |
   //+----------------------------------------------------------------+
   bool IsSell() const
   {
      return
         IsValid() &&
         action == DECISION_SELL &&
         positionType == POSITION_TYPE_SELL;
   }

   //+----------------------------------------------------------------+
   //| Human-readable action                                           |
   //+----------------------------------------------------------------+
   string ActionName() const
   {
      return
         SGDPDecisionActionName(
            action
         );
   }

   //+----------------------------------------------------------------+
   //| Human-readable position direction                               |
   //+----------------------------------------------------------------+
   string PositionTypeName() const
   {
      if(positionType == POSITION_TYPE_BUY)
         return "BUY";

      if(positionType == POSITION_TYPE_SELL)
         return "SELL";

      return "UNKNOWN";
   }
};

#endif