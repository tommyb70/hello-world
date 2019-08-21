trigger TerritoryTrigger on Territory__c (after update) { 
    
    SWITCH ON Trigger.OperationType  {
        WHEN AFTER_UPDATE {
            TerritoryTriggerHandler.UpdateTerritorySharing(trigger.new, trigger.oldMap);
            TerritoryTriggerHandler.UpdateUserTerritoryName(trigger.new, trigger.oldMap);
        }
    }
    
}