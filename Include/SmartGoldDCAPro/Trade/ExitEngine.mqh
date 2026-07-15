#ifndef SMARTGOLDDCAPRO_TRADE_EXIT_ENGINE_MQH
#define SMARTGOLDDCAPRO_TRADE_EXIT_ENGINE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/Logger.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

#include <SmartGoldDCAPro/Risk/DailyRiskManager.mqh>

#include <SmartGoldDCAPro/Trade/ExitRequest.mqh>
#include <SmartGoldDCAPro/Trade/BasketManager.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Exit Engine                     |
//| Builds and executes basket exit requests                         |
//+------------------------------------------------------------------+
class CExitEngine
{
private:
   CBasketManager    *m_basket;
   CPositionManager  *m_positions;
   CRiskManager      *m_risk;
   CDailyRiskManager *m_dailyRisk;
   CLogger           *m_logger;

   bool m_initialized;

   SExitRequest m_lastRequest;

   bool   m_lastExecutionSucceeded;
   string m_lastReason;

   //+----------------------------------------------------------------+
   //| Informational logging                                          |
   //+----------------------------------------------------------------+
   void LogInfo(
      const string message
   ) const
   {
      if(m_logger != NULL)
         m_logger.Info(message);
   }

   //+----------------------------------------------------------------+
   //| Warning logging                                                |
   //+----------------------------------------------------------------+
   void LogWarning(
      const string message
   ) const
   {
      if(m_logger != NULL)
         m_logger.Warn(message);
   }

   //+----------------------------------------------------------------+
   //| Error logging                                                  |
   //+----------------------------------------------------------------+
   void LogError(
      const string message
   ) const
   {
      if(m_logger != NULL)
         m_logger.Error(message);
   }

   //+----------------------------------------------------------------+
   //| Verify all dependencies                                        |
   //+----------------------------------------------------------------+
   bool ModulesReady() const
   {
      return
         m_initialized &&
         m_basket     != NULL &&
         m_positions  != NULL &&
         m_risk       != NULL &&
         m_dailyRisk  != NULL;
   }

   //+----------------------------------------------------------------+
   //| Store a rejected Exit reason                                   |
   //+----------------------------------------------------------------+
   bool Reject(
      SExitRequest &request,
      const string reason
   )
   {
      request.Reset();

      request.reason =
         reason;

      m_lastRequest =
         request;

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         reason;

      return false;
   }

   //+----------------------------------------------------------------+
   //| Fill a Basket Exit Request                                     |
   //+----------------------------------------------------------------+
   void BuildBasketRequest(
      const ENUM_EXIT_REASON reasonCode,
      const string reason,
      const double basketProfit,
      const double triggerValue,
      const bool urgent,
      SExitRequest &request
   ) const
   {
      request.Reset();

      request.action =
         EXIT_ACTION_CLOSE_BASKET;

      request.reasonCode =
         reasonCode;

      request.positionTicket =
         0;

      request.basketProfit =
         basketProfit;

      request.triggerValue =
         triggerValue;

      request.createdTime =
         TimeCurrent();

      request.reason =
         reason;

      request.comment =
         SGDPExitReasonName(
            reasonCode
         );

      request.urgent =
         urgent;

      request.valid =
         true;
   }

   //+----------------------------------------------------------------+
   //| Validate an Exit Request                                       |
   //+----------------------------------------------------------------+
   bool ValidateRequest(
      const SExitRequest &request,
      string &reason
   ) const
   {
      reason =
         "";

      if(!request.IsValid())
      {
         reason =
            "Exit Request is invalid.";

         return false;
      }

      if(request.action != EXIT_ACTION_CLOSE_BASKET)
      {
         reason =
            "Only basket-close requests are supported by this Exit Engine.";

         return false;
      }

      return true;
   }

public:
   CExitEngine()
   {
      m_basket =
         NULL;

      m_positions =
         NULL;

      m_risk =
         NULL;

      m_dailyRisk =
         NULL;

      m_logger =
         NULL;

      m_initialized =
         false;

      m_lastRequest.Reset();

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "Exit Engine is not initialized.";
   }

   //+----------------------------------------------------------------+
   //| Connect Exit Engine dependencies                               |
   //+----------------------------------------------------------------+
   void Initialize(
      CBasketManager &basket,
      CPositionManager &positions,
      CRiskManager &risk,
      CDailyRiskManager &dailyRisk,
      CLogger &logger
   )
   {
      m_basket =
         &basket;

      m_positions =
         &positions;

      m_risk =
         &risk;

      m_dailyRisk =
         &dailyRisk;

      m_logger =
         &logger;

      m_initialized =
         true;

      m_lastRequest.Reset();

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "Exit Engine initialized.";

      LogInfo(
         m_lastReason
      );
   }

   bool IsInitialized() const
   {
      return ModulesReady();
   }

   //+----------------------------------------------------------------+
   //| Build an Exit Request from current account and basket state    |
   //| This method does not close any position                        |
   //+----------------------------------------------------------------+
   bool Evaluate(
      SExitRequest &request
   )
   {
      request.Reset();

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "";

      if(!ModulesReady())
      {
         return Reject(
            request,
            "Exit Engine dependencies are not initialized."
         );
      }

      int positionCount =
         m_positions.CountAll();

      if(positionCount <= 0)
      {
         return Reject(
            request,
            "No active basket."
         );
      }

      double basketProfit =
         m_basket.TotalProfit();

      //==============================================================
      // EQUITY PROTECTION
      //==============================================================

      if(m_risk.IsEquityProtectionTriggered())
      {
         BuildBasketRequest(
            EXIT_REASON_EQUITY_PROTECTION,
            m_risk.LastReason(),
            basketProfit,
            m_risk.MaximumEquityDrawdownPercent(),
            true,
            request
         );

         m_lastRequest =
            request;

         m_lastReason =
            request.reason;

         return true;
      }

      //==============================================================
      // DAILY LOSS PROTECTION
      //==============================================================

      if(m_dailyRisk.IsBlocked())
      {
         BuildBasketRequest(
            EXIT_REASON_DAILY_LOSS_PROTECTION,
            m_dailyRisk.LastReason(),
            basketProfit,
            m_dailyRisk.MaximumDailyLossMoney(),
            true,
            request
         );

         m_lastRequest =
            request;

         m_lastReason =
            request.reason;

         return true;
      }

      //==============================================================
      // BASKET TAKE PROFIT
      //==============================================================

      if(InpBasketTakeProfitMoney > 0.0 &&
         basketProfit >=
         InpBasketTakeProfitMoney)
      {
         BuildBasketRequest(
            EXIT_REASON_BASKET_TAKE_PROFIT,
            "Basket Take Profit reached.",
            basketProfit,
            InpBasketTakeProfitMoney,
            false,
            request
         );

         m_lastRequest =
            request;

         m_lastReason =
            request.reason;

         return true;
      }

      //==============================================================
      // BASKET STOP LOSS
      //==============================================================

      if(InpBasketStopLossMoney > 0.0 &&
         basketProfit <=
         -InpBasketStopLossMoney)
      {
         BuildBasketRequest(
            EXIT_REASON_BASKET_STOP_LOSS,
            "Basket Stop Loss reached.",
            basketProfit,
            InpBasketStopLossMoney,
            true,
            request
         );

         m_lastRequest =
            request;

         m_lastReason =
            request.reason;

         return true;
      }

      return Reject(
         request,
         "No Exit condition is active."
      );
   }

   //+----------------------------------------------------------------+
   //| Build a manual basket-close request                            |
   //| Useful for controlled manual and test workflows                |
   //+----------------------------------------------------------------+
   bool BuildManualBasketClose(
      const string reason,
      SExitRequest &request
   )
   {
      request.Reset();

      if(!ModulesReady())
      {
         return Reject(
            request,
            "Exit Engine dependencies are not initialized."
         );
      }

      if(m_positions.CountAll() <= 0)
      {
         return Reject(
            request,
            "No active basket."
         );
      }

      string resolvedReason =
         reason;

      if(resolvedReason == "")
      {
         resolvedReason =
            "Manual basket close requested.";
      }

      BuildBasketRequest(
         EXIT_REASON_MANUAL,
         resolvedReason,
         m_basket.TotalProfit(),
         0.0,
         false,
         request
      );

      m_lastRequest =
         request;

      m_lastReason =
         request.reason;

      return true;
   }

   //+----------------------------------------------------------------+
   //| Execute a validated Exit Request                               |
   //+----------------------------------------------------------------+
   bool Execute(
      const SExitRequest &request
   )
   {
      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "";

      if(!ModulesReady())
      {
         m_lastReason =
            "Exit Engine dependencies are not initialized.";

         LogError(
            m_lastReason
         );

         return false;
      }

      string validationReason;

      if(!ValidateRequest(
            request,
            validationReason
         ))
      {
         m_lastReason =
            validationReason;

         LogWarning(
            "Exit blocked: " +
            m_lastReason
         );

         return false;
      }

      bool closed =
         m_basket.CloseAll(
            request.reason
         );

      if(!closed)
      {
         m_lastReason =
            "Basket close failed. " +
            m_basket.LastReason();

         LogError(
            m_lastReason
         );

         return false;
      }

      m_lastRequest =
         request;

      m_lastExecutionSucceeded =
         true;

      m_lastReason =
         "Exit executed. Action=" +
         request.ActionName() +
         ", reason=" +
         request.ReasonName() +
         ", basket profit=" +
         DoubleToString(
            request.basketProfit,
            2
         ) +
         ".";

      LogInfo(
         m_lastReason
      );

      return true;
   }

   //+----------------------------------------------------------------+
   //| Evaluate and execute in one call                               |
   //+----------------------------------------------------------------+
   bool Manage()
   {
      SExitRequest request;

      if(!Evaluate(
            request
         ))
      {
         return false;
      }

      return Execute(
         request
      );
   }

   SExitRequest LastRequest() const
   {
      return m_lastRequest;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   bool LastExecutionSucceeded() const
   {
      return m_lastExecutionSucceeded;
   }

   bool LastExitWasEmergency() const
   {
      return
         m_lastExecutionSucceeded &&
         m_lastRequest.IsEmergency();
   }

   void Reset()
   {
      m_lastRequest.Reset();

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "Exit Engine reset.";
   }
};

#endif