public without sharing class AccountTriggerHandler {
    
    public static Id firmRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Firm').getRecordTypeId();
    public static Id officeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Office').getRecordTypeId();
    
    public static void onAfterInsert(List<Account> newList, Map<Id,Account> newMap) {
        
        List<Account> acctList = newList;
        
        Map<Id,Account> parentMap = getParentMap(acctList);
        addAcctToMARS(acctList);
        setFirmHomeOfficeId(acctList, parentMap);
        
    }
    
    public static void onAfterUpdate(List<Account> newList, Map<Id,Account> newMap, List<Account> oldList, Map<Id,Account> oldMap) {
        
        List<Account> acctList = newList;
        
        Map<Id,Account> parentMap = getParentMap(acctList);
        setFirmHomeOfficeId(acctList, parentMap);
        
    }    
    
    public static void onBeforeInsert(List<Account> newList, Map<Id,Account> newMap) {
        
        List<Account> acctList = newList;
        
        Map<Id,Account> parentMap = getParentMap(acctList);
        acctList = setWCMRelationshipFieldBeforeInsert(acctList, parentMap);
        acctList = setFirmType(acctList, parentMap);
        
    }
    
    public static void onBeforeUpdate(List<Account> newList, Map<Id,Account> newMap, List<Account> oldList, Map<Id,Account> oldMap) {
        
        List<Account> acctList = newList;
        
        Map<Id,Account> parentMap = getParentMap(acctList);
        
        acctList = setWCMRelationshipFieldBeforeUpdate(acctList, oldMap, parentMap);
        acctList = setFirmType(acctList, parentMap);
        
    } 
    
    public static void addAcctToMARS (List<Account> newAccounts) {
        
        for (Account a : newAccounts) {
            if (!test.isRunningTest() && a.MarsAccountId__c == null 
                && (a.RecordTypeId == firmRecTypeId || a.RecordTypeId == officeRecTypeId)) {              
                    AddAccountToMarsWSC.AddAccountMarsById(a.Id);  
                }
        }
        
    }
    
    public static Map<Id,Account> getParentMap(List<Account> newAccounts) {
        
        Set<Id> parentIdSet = new Set<Id>();
        
        for (Account a : newAccounts) {
            parentIdSet.add(a.ParentId);
        }
        
        Map<Id,Account> parentMap = new Map<Id,Account>([SELECT Id, WCMRelationshipFlag__c, FirmType__c
                                                         FROM Account
                                                         WHERE Id IN :parentIdSet]);         
        
        return parentMap;
        
    }
    
    
    public static List<Account> setWCMRelationshipFieldBeforeInsert(List<Account> newAccounts, Map<Id,Account> parentMap) {
        
        Set<Id> wcmOverrideSet = new Set<Id>();
        WCMRelationshipSyncOverride__mdt[] wcmOverrides = [SELECT SFID__c FROM WCMRelationshipSyncOverride__mdt];
        
        for (WCMRelationshipSyncOverride__mdt w : wcmOverrides) {
            wcmOverrideSet.add(w.SFID__c);
        }        
        
        for (Account a : newAccounts) {
        if (parentMap.containsKey(a.ParentId) && !wcmOverrideSet.contains(a.Id)) {
                a.WCMRelationshipFlag__c = parentMap.get(a.ParentId).WCMRelationshipFlag__c;
            }
        }
        
        return newAccounts;
    }
    
    public static List<Account> setWCMRelationshipFieldBeforeUpdate(List<Account> newAccounts, Map<Id,Account> oldMap, Map<Id,Account> parentMap) {
        
        Set<Id> wcmOverrideSet = new Set<Id>();
        WCMRelationshipSyncOverride__mdt[] wcmOverrides = [SELECT SFID__c FROM WCMRelationshipSyncOverride__mdt];
        
        for (WCMRelationshipSyncOverride__mdt w : wcmOverrides) {
            wcmOverrideSet.add(w.SFID__c);
        }        
        
        for (Account a : newAccounts) {
            if (a.ParentId != oldMap.get(a.Id).ParentId) {
            if (parentMap.containsKey(a.ParentId) && !wcmOverrideSet.contains(a.Id)) {
                    a.WCMRelationshipFlag__c = parentMap.get(a.ParentId).WCMRelationshipFlag__c;
                }
            }
        }
        
        return newAccounts;
    }    
    
    public static List<Account> setFirmType(List<Account> newAccounts, Map<Id,Account> parentMap) {
        
        for (Account a : newAccounts) {
            if (parentMap.containsKey(a.ParentId) && a.FirmType__c == null) {
                a.FirmType__c = parentMap.get(a.ParentId).FirmType__c;
            }
        }
        
        return newAccounts;
    }    
    
    public static void setFirmHomeOfficeId(List<Account> newAccounts, Map<Id,Account> parentMap) {
        
        Set<Id> homeIdSet = new Set<Id>();
        
        for (Account a : newAccounts) {
            if (a.Type == 'Home') homeIdSet.add(a.Id);
        }
        
        if (!homeIdSet.isEmpty()) {
            List<Account> accountsToUpdate = new List<Account>();
            
            for (Account a : [SELECT Id, ParentId, Parent.HomeOfficeId__c, MARSAccountId__c, HomeOfficeId__c
                              FROM Account
                              WHERE Id IN :homeIdSet]) {
                                  if (a.Parent.HomeOfficeId__c != a.MarsAccountId__c && a.MarsAccountId__c != null) {
                                      accountsToUpdate.add(new Account(Id = a.ParentId, HomeOfficeId__c = a.MarsAccountId__c));
                                  }
                              }
            
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
        
    }
}