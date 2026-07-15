#ifndef SMARTGOLDDCAPRO_TRADE_ENTRY_REQUEST_BUILDER_MQH
#define SMARTGOLDDCAPRO_TRADE_ENTRY_REQUEST_BUILDER_MQH

#include <SmartGoldDCAPro/Core/Types.mqh>
#include <SmartGoldDCAPro/Core/Inputs.mqh>
#include <SmartGoldDCAPro/Core/RiskManager.mqh>

#include <SmartGoldDCAPro/Decision/DecisionTypes.mqh>
#include <SmartGoldDCAPro/Decision/DecisionSnapshot.mqh>
#include <SmartGoldDCAPro/Decision/DecisionEngine.mqh>

#include <SmartGoldDCAPro/Trade/EntryRequest.mqh>

//+------------------------------------------------------------------+
//| SmartGoldDCAPro Framework v2.0 - Entry Request Builder           |
//| Converts an approved Decision into a validated Entry Request     |
//+------------------------------------------------------------------+
class CEntryRequestBuilder
{
private:
   CRiskManager *m_risk;

   bool   m_initialized;
   string m_lastReason;

   //+----------------------------------------------------------------+
   //| Select the configured initial lot                              |
   //+----------------------------------------------------------------+
   double GetConfiguredInitialLot() const
   {
      if(InpDCAControlMode ==
         DCA_CONTROL_MANUAL)
      {
         return InpManualInitialLot;
      }

      return InpInitialLot;
   }

   //+----------------------------------------------------------------+
   //| Store a build failure                                          |
   //+----------------------------------------------------------------+
   bool Fail(
      SEntryRequest &request,
      const string reason
   )
   {
      request.Reset();
      request.reason = reason;

      m_lastReason = reason;

      return false;
   }

   //+----------------------------------------------------------------+
   //| Validate the Decision Snapshot                                 |
   //+----------------------------------------------------------------+
   bool ValidateDecisionSnapshot(
      const SDecisionSnapshot &snapshot,
      string &reason
   ) const
   {
      reason = "";

      if(!snapshot.valid)
      {
         reason =
            "Decision Snapshot is invalid.";

         return false;
      }

      if(snapshot.action ==
         DECISION_WAIT)
      {
         reason =
            "Decision action is WAIT. " +
            snapshot.reason;

         return false;
      }

      if(snapshot.action ==
         DECISION_BLOCK)
      {
         reason =
            "Decision action is BLOCK. " +
            snapshot.reason;

         return false;
      }

      if(snapshot.action != DECISION_BUY &&
         snapshot.action != DECISION_SELL)
      {
         reason =
            "Decision action is unsupported.";

         return false;
      }

      if(!snapshot.HasTradeDecision())
      {
         reason =
            "Decision Snapshot does not contain an approved trade.";

         return false;
      }

      return true;
   }

   //+----------------------------------------------------------------+
   //| Fill request direction and Decision metrics                    |
   //+----------------------------------------------------------------+
   void FillDecisionData(
      const SDecisionSnapshot &snapshot,
      SEntryRequest &request
   ) const
   {
      request.action =
         snapshot.action;

      request.confidence =
         SGDPNormalizeScore(
            snapshot.confidence
         );

      request.quality =
         SGDPNormalizeScore(
            snapshot.quality
         );

      if(snapshot.action ==
         DECISION_BUY)
      {
         request.positionType =
            POSITION_TYPE_BUY;

         request.decisionScore =
            SGDPNormalizeScore(
               snapshot.buyScore
            );
      }
      else
      {
         request.positionType =
            POSITION_TYPE_SELL;

         request.decisionScore =
            SGDPNormalizeScore(
               snapshot.sellScore
            );
      }
   }

public:
   CEntryRequestBuilder()
   {
      m_risk =
         NULL;

      m_initialized =
         false;

      m_lastReason =
         "Entry Request Builder is not initialized.";
   }

   //+----------------------------------------------------------------+
   //| Connect Risk Manager                                           |
   //+----------------------------------------------------------------+
   void Initialize(
      CRiskManager &risk
   )
   {
      m_risk =
         &risk;

      m_initialized =
         true;

      m_lastReason =
         "Entry Request Builder initialized.";
   }

   bool IsInitialized() const
   {
      return
         m_initialized &&
         m_risk != NULL;
   }

   //+----------------------------------------------------------------+
   //| Build an initial Entry Request from DecisionEngine             |
   //+----------------------------------------------------------------+
   bool BuildInitial(
      CDecisionEngine &decision,
      SEntryRequest &request
   )
   {
      request.Reset();
      m_lastReason = "";

      if(!IsInitialized())
      {
         return Fail(
            request,
            "Entry Request Builder is not initialized."
         );
      }

      if(!decision.IsInitialized())
      {
         return Fail(
            request,
            "Decision Engine is not initialized."
         );
      }

      SDecisionSnapshot snapshot =
         decision.Snapshot();

      string validationReason;

      if(!ValidateDecisionSnapshot(
            snapshot,
            validationReason
         ))
      {
         return Fail(
            request,
            validationReason
         );
      }

      double requestedLot =
         GetConfiguredInitialLot();

      double normalizedLot =
         m_risk.NormalizeLot(
            requestedLot
         );

      if(normalizedLot <= 0.0)
      {
         return Fail(
            request,
            "Initial lot is invalid after normalization."
         );
      }

      FillDecisionData(
         snapshot,
         request
      );

      request.lot =
         normalizedLot;

      request.stopLoss =
         0.0;

      request.takeProfit =
         0.0;

      request.createdTime =
         TimeCurrent();

      if(request.action ==
         DECISION_BUY)
      {
         request.comment =
            "Initial BUY";
      }
      else
      {
         request.comment =
            "Initial SELL";
      }

      request.reason =
         snapshot.reason;

      request.valid =
         true;

      if(!request.IsValid())
      {
         return Fail(
            request,
            "Generated Entry Request failed validation."
         );
      }

      m_lastReason =
         "Initial " +
         request.ActionName() +
         " Entry Request prepared successfully.";

      return true;
   }

   //+----------------------------------------------------------------+
   //| Build a request from a supplied Decision Snapshot              |
   //| Useful for testing and future controlled integrations          |
   //+----------------------------------------------------------------+
   bool BuildFromSnapshot(
      const SDecisionSnapshot &snapshot,
      const double requestedLot,
      const double stopLoss,
      const double takeProfit,
      const string comment,
      SEntryRequest &request
   )
   {
      request.Reset();
      m_lastReason = "";

      if(!IsInitialized())
      {
         return Fail(
            request,
            "Entry Request Builder is not initialized."
         );
      }

      string validationReason;

      if(!ValidateDecisionSnapshot(
            snapshot,
            validationReason
         ))
      {
         return Fail(
            request,
            validationReason
         );
      }

      double normalizedLot =
         m_risk.NormalizeLot(
            requestedLot
         );

      if(normalizedLot <= 0.0)
      {
         return Fail(
            request,
            "Requested lot is invalid after normalization."
         );
      }

      FillDecisionData(
         snapshot,
         request
      );

      request.lot =
         normalizedLot;

      request.stopLoss =
         MathMax(
            0.0,
            stopLoss
         );

      request.takeProfit =
         MathMax(
            0.0,
            takeProfit
         );

      request.createdTime =
         TimeCurrent();

      request.comment =
         comment;

      if(request.comment == "")
      {
         request.comment =
            request.action == DECISION_BUY
            ? "BUY Entry"
            : "SELL Entry";
      }

      request.reason =
         snapshot.reason;

      request.valid =
         true;

      if(!request.IsValid())
      {
         return Fail(
            request,
            "Generated Entry Request failed validation."
         );
      }

      m_lastReason =
         request.ActionName() +
         " Entry Request prepared successfully.";

      return true;
   }

   string LastReason() const
   {
      return m_lastReason;
   }

   void Reset()
   {
      m_lastReason =
         "Entry Request Builder reset.";
   }
};

#endif