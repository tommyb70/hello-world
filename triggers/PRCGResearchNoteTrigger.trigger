trigger PRCGResearchNoteTrigger on PRCGResearchNote__c (before insert, before update) {
    
    if (trigger.IsBefore && trigger.IsInsert) {
        PRCGResearchNoteTriggerHandler.beforeInsert(trigger.new);
    }

    if (trigger.IsBefore && trigger.IsUpdate) {
        PRCGResearchNoteTriggerHandler.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
    }


}