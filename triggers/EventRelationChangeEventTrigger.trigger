trigger EventRelationChangeEventTrigger on EventRelationChangeEvent (after insert) {
        
        System.debug('Here '+Trigger.New);
         System.debug('Here Old '+Trigger.Old);
        EventRelationChangeEventTriggerHandler.eventRelationChangeEventAfterInsert(Trigger.New);
    
    
}