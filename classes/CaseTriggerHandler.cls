public class CaseTriggerHandler {    
    
    public static void runCaseSharing (List<Case> myCases, Map<Id,Case> myOldCaseMap) { 
        
        List<Case> casesToShare = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case c : myCases) {
           
            if (Trigger.isInsert || 
                c.OwnerId != myOldCaseMap.get(c.Id).OwnerId ||
                 c.Requestor__c != myOldCaseMap.get(c.Id).Requestor__c || 
                 c.SubmittedOnBehalfOf__c != myOldCaseMap.get(c.Id).SubmittedOnBehalfOf__c ||
                c.RunCaseSharing__c == TRUE) {
                    casesToShare.add(c);
            }
            
        }
        
        if (!casesToShare.IsEmpty()) RunCaseSharing.runCaseSharing(casesToShare);
        
    }
    
    public static void setFieldValues (List<Case> myCases, Map<Id,Case> myOldCaseMap) {     
        
        Set<Id> pWCaseRecIds = getPwCaseRecIds();
        
        Id affRequestRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Affiliate Request').getRecordTypeId();
        Id IPMRFPRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RFP').getRecordTypeId();
        Id IPMIntReqRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPM Internal Request').getRecordTypeId();
        Map<Id,Schema.RecordTypeInfo> recordTypeNameMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
        Map<String,Schema.RecordTypeInfo> recordTypeIdMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
        
        Set<Id> requestorIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Map<Id,Product2> productAffiliateMap = new Map<Id,Product2>();
        
        for (Case c : myCases) {
            if (c.Requestor__c == null) c.Requestor__c = c.CreatedById;
            if (c.Requestor__c != null) requestorIdSet.add(c.Requestor__c);
            if (c.AccountId != null) accountIdSet.add(c.AccountId);
            if (c.ProductStrategyMutualFund__c != null) productIdSet.add(c.ProductStrategyMutualFund__c);
        }
        
        if (productIdSet.size()>0) {
            
            productAffiliateMap = new Map<Id,Product2>([SELECT Id, MARSAffiliate__c
                                                        FROM Product2
                                                        WHERE Id in : productIdSet]);
        }
        
        Map<Id,User> userMap = new Map<Id,User>([SELECT ActivityTerritoryId__c, ActivityTerritoryParentId__c, ActivityChannelId__c, LastName, FirstName
                                                 FROM User
                                                 WHERE Id in :requestorIdSet]);
        
        
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Name
                                                          FROM Account
                                                          WHERE Id in :accountIdSet]);
        
        for (Case c : myCases) {
            
            if (userMap.containsKey(c.Requestor__c)) {
                c.CaseChannel__c = userMap.get(c.Requestor__c).ActivityChannelId__c;                
                c.CaseTerritory__c = userMap.get(c.Requestor__c).ActivityTerritoryId__c;     
                c.CaseRegionDept__c = userMap.get(c.Requestor__c).ActivityTerritoryParentId__c;     
            }
            
            if (Trigger.IsInsert) {
                c.LastEventEndDatetime__c = null;
                c.FirstEventStartDatetime__c = null;
                c.LastCommentDatetime__c = null;
                c.LastCommentText__c = null;
                c.RunCaseSharing__c = TRUE;
            } 
            
            if (Trigger.IsInsert || c.Requestor__c != myOldCaseMap.get(c.Id).Requestor__c || c.SubmittedOnBehalfOf__c != myOldCaseMap.get(c.Id).SubmittedOnBehalfOf__c) {
                c.RunCaseSharing__c = TRUE;
            }
            
            if ((c.ProductStrategyMutualFund__c != null) && (productAffiliateMap.containsKey(c.ProductStrategyMutualFund__c)) && 
                (Trigger.IsInsert || c.ProductStrategyMutualFund__c != myOldCaseMap.get(c.Id).ProductStrategyMutualFund__c))  {
                    c.AffiliateFirmName__c = productAffiliateMap.get(c.ProductStrategyMutualFund__c).MARSAffiliate__c;
                }
            
            //Set Subject for Affiliate Request Cases   
            If (c.AccountId != null && c.Requestor__c != null && c.RecordTypeId == affRequestRecTypeId) {
                c.Subject = accountMap.get(c.AccountId).Name + '-' + c.RequestedSpeakers__c + '-' +  c.RequestFirm__c + '-' + userMap.get(c.Requestor__c).FirstName + ' ' + userMap.get(c.Requestor__c).LastName;
            }
            
            //Set Subject for IPM Cases
            If (c.AccountId != null && c.Requestor__c != null && c.IsIPMCase__c && c.RecordTypeId != IPMIntReqRecTypeId ) {
                c.Subject = recordTypeNameMapById.get(c.RecordTypeId).Name + ': ' + accountMap.get(c.AccountId).Name;
            }
            
            //Private Wealth Cases
            if (Trigger.IsInsert &&
                recordTypeIdMapByName.containsKey(c.Type)) {
                   if (PwCaseRecIds.contains(recordTypeIdMapByName.get(c.Type).getRecordTypeId())){   
                       c.RecordTypeId = recordTypeIdMapByName.get(c.Type).getRecordTypeId();
                   }
               }
            
            if (pWCaseRecIds.contains(c.RecordTypeId)) {
                c.IsPrivateWealthCase__c = TRUE;
                c.Type = recordTypeNameMapById.get(c.RecordTypeId).getName();
            }
            
        }
    }
    
    public static void runCaseAssignmentRules(List<Case> myCases) {
        
        List<Case> runRules = new List<Case>();
        
        for (Case c : myCases) {
            if (c.RunCaseAssignmentRules__c == TRUE) runRules.add(c);
        }
        
        if (!runRules.isEmpty()) RunCaseAssignmentRules.runCaseAssignmentRules(runRules);
        
    }
    
    public static Set<Id> getPwCaseRecIds() {
        
        Set<Id> PwCaseRecIds = new Set<Id>();
        
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Wealth Portal').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Investment Change').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Opening').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ad Hoc Request').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bulk Investment Strategy Swap').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Model Update Request').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Model Request').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Requestor').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Tax Harvest').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Termination').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Update to Requestor').getRecordTypeId());
        PwCaseRecIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Withdrawal').getRecordTypeId());
        
        return PwCaseRecIds;
    }
    
}