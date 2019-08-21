public class AccountTerritoryTriggerHandler {
    public static void deleteAccountShare(List<AccountTerritory__c> atc) {
    Set<Id> ids = new Set<Id> {};
    for(AccountTerritory__c p : atc) ids.add(p.Account__c); 
    if (ids.size() > 0)
        delete [select id from AccountShare where AccountId IN : ids and RowCause = 'Manual'];      
    }
}