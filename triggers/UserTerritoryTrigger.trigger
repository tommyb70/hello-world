trigger UserTerritoryTrigger on UserTerritory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) { 

    if(trigger.isInsert && trigger.isBefore)
            {    
            UserTerritoryTriggerHandler.UserTerritoryBeforeInsert(trigger.new);    
            } 
    
    if(trigger.isInsert && trigger.isAfter)
            {    
            UserTerritoryTriggerHandler.UserTerritoryAfterInsert(trigger.new);    
            } 
    
    if(trigger.isUpdate && trigger.isAfter)
            {    
            UserTerritoryTriggerHandler.UserTerritoryAfterUpdate(trigger.new);    
            }        
    
    if(trigger.isDelete && trigger.isAfter)
            { 
            UserTerritoryTriggerHandler.UserTerritoryAfterDelete(trigger.old);   
            }    

}