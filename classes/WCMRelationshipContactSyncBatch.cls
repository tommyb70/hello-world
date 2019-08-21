global class WCMRelationshipContactSyncBatch implements Database.batchable<sObject>{

    public String query = ' SELECT Account.WCMRelationshipFlag__c, WCMRelationshipFlag__c ' +
        				  ' FROM Contact ' +
        				  ' WHERE AccountId != null ';
    
    global Database.querylocator start(Database.BatchableContext BC){   
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        
		Set<Id> wcmOverrideSet = new Set<Id>();
        WCMRelationshipSyncOverride__mdt[] wcmOverrides = [SELECT SFID__c FROM WCMRelationshipSyncOverride__mdt];

		for (WCMRelationshipSyncOverride__mdt w : wcmOverrides) {
			wcmOverrideSet.add(w.SFID__c);
		}            
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Contact c : scope) {
            
            if (c.WCMRelationshipFlag__c != c.Account.WCMRelationshipFlag__c) {
                if (!wcmOverrideSet.contains(c.Id)) {
            		c.WCMRelationshipFlag__c = c.Account.WCMRelationshipFlag__c;
            		contactsToUpdate.add(c);
                }
            }
            
        }
        
        if (!contactsToUpdate.isEmpty()) update contactsToUpdate;
        
    }
    
    global void finish(Database.BatchableContext BC) {

    }
    
    
}