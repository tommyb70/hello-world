trigger FinancialAccountTrigger on FinancialAccount__c (before delete, before insert, before update, after update, after delete, after insert, after undelete) {

    if (Trigger.isBefore && Trigger.isInsert) 
        {
       // system.debug ('-----------------------TaskTriggerHandler.Triggerbefore insert');     
      //  FinancialAccountContactTriggerHandler.TriggerBeforeInsert(trigger.new);
        }
    
    if (Trigger.isBefore && Trigger.isUpdate) 
        {
        //system.debug ('-----------------------TaskTriggerHandler.TaskTriggerBeforeUpdate');
        //TaskTriggerHandler.TaskTriggerBeforeUpdate(trigger.new);
        }
    
    if (trigger.IsDelete && trigger.IsAfter)
        { 
        //system.debug ('-----------------------FinancialAccountContactTriggerHandler.TriggerAfterDelete');  
       // FinancialAccountContactTriggerHandler.TriggerAfterDelete(trigger.old);
      
        }
    
    if (trigger.isUpdate && trigger.isAfter)
        {      
        system.debug ('-----------------------FinancialAccountTriggerHandler.TriggerAfterUpdate');  
        FinancialAccountTriggerHandler.TriggerAfterUpdate(trigger.newMap,trigger.oldMap);
        }
    
    if (trigger.IsInsert && trigger.isAfter)
        {
        //system.debug ('-----------------------TaskTriggerHandler.TaskTriggerAfterInsert');     
        //FinancialAccountContactTriggerHandler.TriggerAfterInsert(trigger.new);
        //TaskTriggerHandler.FutureTaskTriggerAfterInsert(Trigger.newMap.keySet());
        }
    
    
}