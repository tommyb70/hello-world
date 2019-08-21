public with sharing class ContactTerritoryTriggerHandler {
    
    
    
    public static void deleteContactShare(List<ContactTerritory__c> atc) {
        Set<Id> ids = new Set<Id> {};
        for(ContactTerritory__c p : atc) ids.add(p.Contact__c); 
        if (ids.size() > 0)
            delete [select id from ContactShare where ContactId IN : ids and RowCause = 'Manual'];      
    }
}