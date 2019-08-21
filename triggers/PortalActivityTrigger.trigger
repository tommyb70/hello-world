trigger PortalActivityTrigger on PortalActivity__c (after insert) {
    if (trigger.isInsert && trigger.isAfter) {
        PortalactivityTriggerHandler.PortalActivityAfterInsert(trigger.new);
    }
}