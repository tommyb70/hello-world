global class WCMRelationshipAccountSyncBatch implements Database.batchable<sObject>, Database.stateful {
    
    global Map<Id,Boolean> parentWCMMap0 = new Map<Id,Boolean>();
    
    public String query = ' SELECT Id, Type, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, ' +
        ' WCMRelationshipFlag__c ' +
        ' FROM Account ' +
        ' ORDER BY ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId ';
    
    global Database.querylocator start(Database.BatchableContext BC){   
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
        Set<Id> wcmOverrideSet = new Set<Id>();
        WCMRelationshipSyncOverride__mdt[] wcmOverrides = [SELECT SFID__c FROM WCMRelationshipSyncOverride__mdt];
        
        for (WCMRelationshipSyncOverride__mdt w : wcmOverrides) {
            wcmOverrideSet.add(w.SFID__c);
        }    
        
        List<Account> wcmOverrideAcctList = [SELECT Id, WCMRelationshipFlag__c
                                             FROM Account
                                             WHERE Id IN :wcmOverrideSet];
        
        for (Account a : wcmOverrideAcctList) {
            parentWCMMap0.put(a.Id,a.WCMRelationshipFlag__c); 
        }
        
        List<Account> acctsToUpdate = new List<Account>();
        
        for (Account a : [SELECT Id, WCMRelationshipFlag__c
                          FROM Account
                          WHERE ParentId = null]) {
                              parentWCMMap0.put(a.Id,a.WCMRelationshipFlag__c);
                          }
        
        for (Account a : scope) {
            
            if (parentWCMMap0.containsKey(a.ParentId)) {
                if (a.WCMRelationshipFlag__c != parentWCMMap0.get(a.ParentId)) {
                    if (!wcmOverrideSet.contains(a.Id)) {
                        a.WCMRelationshipFlag__c = parentWCMMap0.get(a.ParentId);
                        acctsToUpdate.add(a);
                    }
                }
            } else {
                
                if (parentWCMMap0.containsKey(a.Parent.ParentId)) {
                    if (a.WCMRelationshipFlag__c != parentWCMMap0.get(a.Parent.ParentId)) {
                        if (!wcmOverrideSet.contains(a.Id)) {
                            a.WCMRelationshipFlag__c = parentWCMMap0.get(a.Parent.ParentId);
                            acctsToUpdate.add(a);
                        }
                    }
                } else {
                    
                    if (parentWCMMap0.containsKey(a.Parent.Parent.ParentId)) {
                        if (a.WCMRelationshipFlag__c != parentWCMMap0.get(a.Parent.Parent.ParentId)) {
                            if (!wcmOverrideSet.contains(a.Id)) {
                                a.WCMRelationshipFlag__c = parentWCMMap0.get(a.Parent.Parent.ParentId);
                                acctsToUpdate.add(a);
                            }
                        }
                    } else {
                        
                        if (parentWCMMap0.containsKey(a.Parent.Parent.Parent.ParentId)) {
                            if (a.WCMRelationshipFlag__c != parentWCMMap0.get(a.Parent.Parent.Parent.ParentId)) {
                                if (!wcmOverrideSet.contains(a.Id)) {
                                    a.WCMRelationshipFlag__c = parentWCMMap0.get(a.Parent.Parent.Parent.ParentId);
                                    acctsToUpdate.add(a);
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        if (!acctsToUpdate.isEmpty()) update acctsToUpdate;
        
    }     
    
    global void finish(Database.BatchableContext BC) {
        
        if (!test.isRunningTest()) {
            Id batchJobId = Database.executeBatch(new WCMRelationshipContactSyncBatch(),10000);
        }
        
    }
    
    
}