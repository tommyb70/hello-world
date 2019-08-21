trigger CDRQualitativeDataTrigger on CDRQualitativeData__c (after update, after insert, before insert, before delete, before update) {
    
    switch on Trigger.operationType {
        
        when BEFORE_INSERT,BEFORE_UPDATE {
            CDRQualitativeDataTriggerHandler.dateDupeChecks(trigger.new, trigger.oldMap);
            CDRQualitativeDataTriggerHandler.setFieldValuesBefore(trigger.new);
        }
        
        when AFTER_UPDATE {
            CDRQualitativeDataTriggerHandler.bumpCDRRecordStatus(trigger.newMap, trigger.oldMap);
            CDRQualitativeDataTriggerHandler.lockAndUnlockRecords(trigger.new);
            CDRQualitativeDataTriggerHandler.updateParentsOnActive(trigger.new);
        }     
    }
    
}