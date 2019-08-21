trigger npe4RelationshipTrigger on npe4__Relationship__c
    (after delete, after insert, after update)
{
    if (trigger.isInsert && trigger.isAfter) {
         RelationshipTriggerHandler.RelationshipAfterInsert();         
    }
    //dlrs.RollupService.triggerHandler();
}