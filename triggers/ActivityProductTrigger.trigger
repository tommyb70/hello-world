trigger ActivityProductTrigger on ActivityProduct__c (after insert, before insert, before update, after delete, before delete) {
    
    if (trigger.isdelete  && trigger.IsBefore)
    {            
        ActivityProductTriggerHandler.PreventDeletionOfOldRecords (trigger.old);
    }
    
    if (trigger.isdelete  && trigger.IsAfter)
    {            
        ActivityProductTriggerHandler.ActivityProductAfterDelete(trigger.old);
    }
    
    if (trigger.isUpdate  && trigger.IsBefore)
    {
        ActivityProductTriggerHandler.ActivityProductBeforeUpdate(trigger.new);
    } 
    
    if (trigger.isInsert && trigger.IsBefore)
    {    
        ActivityProductTriggerHandler.ActivityProductBeforeInsert(trigger.new);
    }   
    
    if (trigger.isInsert  && trigger.IsAfter)
    {
        ActivityProductTriggerHandler.ActivityProductAfterInsert(trigger.new);
    }
    
}