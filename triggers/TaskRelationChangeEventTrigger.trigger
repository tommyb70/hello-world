trigger TaskRelationChangeEventTrigger on TaskRelationChangeEvent (after insert) {
    
	TaskRelationChangeEventTriggerHandler.taskRelationChangeEventAfterInsert(Trigger.New);
    
}