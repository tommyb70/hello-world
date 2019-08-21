trigger TransactionSummaryByTerritoryTrigger on TransactionSummaryByTerritory__c (after insert) {	
	TransactionSumByTerritoryTriggerHandler.updtBusinessDays(trigger.new);
}