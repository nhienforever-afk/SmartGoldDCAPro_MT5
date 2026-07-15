#ifndef SMARTGOLDDCAPRO_TRADE_ENTRY_ENGINE_MQH
#define SMARTGOLDDCAPRO_TRADE_ENTRY_ENGINE_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/Logger.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

#include <SmartGoldDCAPro/Decision/DecisionEngine.mqh>

#include <SmartGoldDCAPro/Trade/EntryRequest.mqh>
#include <SmartGoldDCAPro/Trade/EntryRequestBuilder.mqh>
#include <SmartGoldDCAPro/Trade/OrderManager.mqh>
#include <SmartGoldDCAPro/Trade/PositionManager.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Entry Engine                    |
//| Validates and executes a prepared Entry Request                  |
//+------------------------------------------------------------------+
class CEntryEngine
{
private:
   CRiskManager         *m_risk;
   COrderManager        *m_orders;
   CPositionManager     *m_positions;
   CEntryRequestBuilder *m_builder;
   CLogger              *m_logger;

   bool     m_initialized;
   datetime m_lastEntryTime;

   SEntryRequest m_lastRequest;

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
   //| Store an Entry failure                                         |
   //+----------------------------------------------------------------+
   bool Fail(
      const string reason
   )
   {
      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         reason;

      LogWarning(
         "Entry blocked: " +
         reason
      );

      return false;
   }

   //+----------------------------------------------------------------+
   //| Verify all dependencies                                        |
   //+----------------------------------------------------------------+
   bool ModulesReady() const
   {
      return
         m_initialized &&
         m_risk      != NULL &&
         m_orders    != NULL &&
         m_positions != NULL &&
         m_builder   != NULL;
   }

   //+----------------------------------------------------------------+
   //| Check cooldown after the last successful Entry                 |
   //+----------------------------------------------------------------+
   bool CheckCooldown(
      string &reason
   ) const
   {
      reason = "";

      if(InpTradeCooldownSeconds <= 0)
         return true;

      if(m_lastEntryTime <= 0)
         return true;

      int elapsedSeconds =
         (int)(
            TimeCurrent() -
            m_lastEntryTime
         );

      if(elapsedSeconds >=
         InpTradeCooldownSeconds)
      {
         return true;
      }

      reason =
         "Trade cooldown is active. Elapsed=" +
         IntegerToString(
            elapsedSeconds
         ) +
         "s, required=" +
         IntegerToString(
            InpTradeCooldownSeconds
         ) +
         "s.";

      return false;
   }

   //+----------------------------------------------------------------+
   //| Validate request before execution                              |
   //+----------------------------------------------------------------+
   bool ValidateRequest(
      const SEntryRequest &request,
      string &reason
   ) const
   {
      reason = "";

      if(!request.IsValid())
      {
         reason =
            "Entry Request is invalid.";

         return false;
      }

      if(request.action != DECISION_BUY &&
         request.action != DECISION_SELL)
      {
         reason =
            "Entry Request action is unsupported.";

         return false;
      }

      if(request.lot <= 0.0)
      {
         reason =
            "Entry Request lot must be greater than zero.";

         return false;
      }

      if(request.action == DECISION_BUY &&
         request.positionType != POSITION_TYPE_BUY)
      {
         reason =
            "BUY Entry Request contains an invalid position type.";

         return false;
      }

      if(request.action == DECISION_SELL &&
         request.positionType != POSITION_TYPE_SELL)
      {
         reason =
            "SELL Entry Request contains an invalid position type.";

         return false;
      }

      return true;
   }

   //+----------------------------------------------------------------+
   //| Check account and trading conditions                           |
   //+----------------------------------------------------------------+
   bool ValidateTradingConditions(
      const SEntryRequest &request,
      string &reason
   )
   {
      reason = "";

      if(!InpAllowNewTrades)
      {
         reason =
            "New trades are disabled by input.";

         return false;
      }

      if(m_positions.CountAll() > 0)
      {
         reason =
            "An active basket already exists.";

         return false;
      }

      if(!CheckCooldown(reason))
         return false;

      if(!m_risk.CanOpenTrade(
            request.lot,
            InpMaximumSpreadPoints,
            reason
         ))
      {
         return false;
      }

      return true;
   }

   //+----------------------------------------------------------------+
   //| Execute BUY request                                            |
   //+----------------------------------------------------------------+
   bool ExecuteBuy(
      const SEntryRequest &request
   )
   {
      bool opened =
         m_orders.OpenBuy(
            request.lot,
            request.stopLoss,
            request.takeProfit,
            request.comment
         );

      if(!opened)
      {
         return Fail(
            "BUY execution failed. " +
            m_orders.LastMessage()
         );
      }

      m_lastEntryTime =
         TimeCurrent();

      m_lastExecutionSucceeded =
         true;

      m_lastReason =
         "BUY Entry executed. Lot=" +
         DoubleToString(
            request.lot,
            2
         ) +
         ", score=" +
         DoubleToString(
            request.decisionScore,
            2
         ) +
         ", confidence=" +
         DoubleToString(
            request.confidence,
            2
         ) +
         ", quality=" +
         DoubleToString(
            request.quality,
            2
         ) +
         ".";

      LogInfo(m_lastReason);

      return true;
   }

   //+----------------------------------------------------------------+
   //| Execute SELL request                                           |
   //+----------------------------------------------------------------+
   bool ExecuteSell(
      const SEntryRequest &request
   )
   {
      bool opened =
         m_orders.OpenSell(
            request.lot,
            request.stopLoss,
            request.takeProfit,
            request.comment
         );

      if(!opened)
      {
         return Fail(
            "SELL execution failed. " +
            m_orders.LastMessage()
         );
      }

      m_lastEntryTime =
         TimeCurrent();

      m_lastExecutionSucceeded =
         true;

      m_lastReason =
         "SELL Entry executed. Lot=" +
         DoubleToString(
            request.lot,
            2
         ) +
         ", score=" +
         DoubleToString(
            request.decisionScore,
            2
         ) +
         ", confidence=" +
         DoubleToString(
            request.confidence,
            2
         ) +
         ", quality=" +
         DoubleToString(
            request.quality,
            2
         ) +
         ".";

      LogInfo(m_lastReason);

      return true;
   }

public:
   CEntryEngine()
   {
      m_risk      = NULL;
      m_orders    = NULL;
      m_positions = NULL;
      m_builder   = NULL;
      m_logger    = NULL;

      m_initialized =
         false;

      m_lastEntryTime =
         0;

      m_lastRequest.Reset();

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "Entry Engine is not initialized.";
   }

   //+----------------------------------------------------------------+
   //| Connect Entry Engine dependencies                              |
   //+----------------------------------------------------------------+
   void Initialize(
      CRiskManager &risk,
      COrderManager &orders,
      CPositionManager &positions,
      CEntryRequestBuilder &builder,
      CLogger &logger
   )
   {
      m_risk      = &risk;
      m_orders    = &orders;
      m_positions = &positions;
      m_builder   = &builder;
      m_logger    = &logger;

      m_initialized =
         true;

      m_lastEntryTime =
         0;

      m_lastRequest.Reset();

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "Entry Engine initialized.";

      LogInfo(m_lastReason);
   }

   bool IsInitialized() const
   {
      return ModulesReady();
   }

   //+----------------------------------------------------------------+
   //| Build an initial request without executing an order            |
   //| Used by tests, Dashboard and controlled integrations           |
   //+----------------------------------------------------------------+
   bool PrepareInitial(
      CDecisionEngine &decision,
      SEntryRequest &request
   )
   {
      request.Reset();

      if(!ModulesReady())
      {
         return Fail(
            "Entry Engine dependencies are not initialized."
         );
      }

      if(!m_builder.BuildInitial(
            decision,
            request
         ))
      {
         return Fail(
            m_builder.LastReason()
         );
      }

      m_lastRequest =
         request;

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "Entry Request prepared successfully.";

      LogInfo(
         m_lastReason +
         " Action=" +
         request.ActionName() +
         ", lot=" +
         DoubleToString(
            request.lot,
            2
         ) +
         "."
      );

      return true;
   }

   //+----------------------------------------------------------------+
   //| Validate and execute an existing request                       |
   //+----------------------------------------------------------------+
   bool Execute(
      const SEntryRequest &request
   )
   {
      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "";

      if(!ModulesReady())
      {
         return Fail(
            "Entry Engine dependencies are not initialized."
         );
      }

      string validationReason;

      if(!ValidateRequest(
            request,
            validationReason
         ))
      {
         return Fail(
            validationReason
         );
      }

      if(!ValidateTradingConditions(
            request,
            validationReason
         ))
      {
         return Fail(
            validationReason
         );
      }

      m_lastRequest =
         request;

      if(request.IsBuy())
         return ExecuteBuy(request);

      if(request.IsSell())
         return ExecuteSell(request);

      return Fail(
         "Entry Request contains no executable direction."
      );
   }

   //+----------------------------------------------------------------+
   //| Build and execute the initial Entry                            |
   //+----------------------------------------------------------------+
   bool TryOpenInitial(
      CDecisionEngine &decision
   )
   {
      SEntryRequest request;

      if(!PrepareInitial(
            decision,
            request
         ))
      {
         return false;
      }

      return Execute(request);
   }

   //+----------------------------------------------------------------+
   //| Check a request without executing an order                     |
   //+----------------------------------------------------------------+
   bool CanExecute(
      const SEntryRequest &request,
      string &reason
   )
   {
      reason = "";

      if(!ModulesReady())
      {
         reason =
            "Entry Engine dependencies are not initialized.";

         return false;
      }

      if(!ValidateRequest(
            request,
            reason
         ))
      {
         return false;
      }

      return ValidateTradingConditions(
         request,
         reason
      );
   }

   datetime LastEntryTime() const
   {
      return m_lastEntryTime;
   }

   SEntryRequest LastRequest() const
   {
      return m_lastRequest;
   }

   ENUM_DECISION_ACTION LastAction() const
   {
      return m_lastRequest.action;
   }

   string LastActionName() const
   {
      return
         m_lastRequest.ActionName();
   }

   double LastLot() const
   {
      return m_lastRequest.lot;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   bool LastExecutionSucceeded() const
   {
      return m_lastExecutionSucceeded;
   }

   bool LastEntryWasBuy() const
   {
      return
         m_lastExecutionSucceeded &&
         m_lastRequest.IsBuy();
   }

   bool LastEntryWasSell() const
   {
      return
         m_lastExecutionSucceeded &&
         m_lastRequest.IsSell();
   }

   void Reset()
   {
      m_lastEntryTime =
         0;

      m_lastRequest.Reset();

      m_lastExecutionSucceeded =
         false;

      m_lastReason =
         "Entry Engine reset.";
   }
};

#endif