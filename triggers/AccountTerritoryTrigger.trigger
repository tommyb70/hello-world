trigger AccountTerritoryTrigger on AccountTerritory__c (after delete) {
    AccountTerritoryTriggerHandler.deleteAccountShare(trigger.old);
}