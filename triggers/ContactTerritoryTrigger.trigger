trigger ContactTerritoryTrigger on ContactTerritory__c (after delete) 
	{
    ContactTerritoryTriggerHandler.deleteContactShare(trigger.old);
	}