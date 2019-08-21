trigger FinancialAccountContactTrigger on FinancialAccountContact__c (before delete, before insert, before update, after update, after delete, after insert, after undelete) {

    if (Trigger.isBefore && Trigger.isInsert) 
        {
        }
    
    if (Trigger.isBefore && Trigger.isUpdate) 
        {
        }
    
    if (trigger.IsDelete && trigger.IsAfter)
        { 
        FinancialAccountContactTriggerHandler.TriggerAfterDelete(trigger.old);
        }
    
    if (trigger.isUpdate && trigger.isAfter)
        {      
        FinancialAccountContactTriggerHandler.TriggerAfterUpdate(trigger.new,trigger.oldMap);
        }
    
    if (trigger.IsInsert && trigger.isAfter)
        {
        FinancialAccountContactTriggerHandler.TriggerAfterInsert(trigger.new);
        }
}