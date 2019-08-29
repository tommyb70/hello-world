trigger EventTrigger on Event (before delete, before insert, before update, after update, after delete, after insert, after undelete) {

        SWITCH ON Trigger.operationType  {
        WHEN BEFORE_INSERT {
            EventTriggerHandler.EventTriggerBeforeInsert(trigger.new, trigger.newMap);
        }
        WHEN BEFORE_UPDATE {
            EventTriggerHandler.EventTriggerBeforeUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
        WHEN AFTER_INSERT {
            EventTriggerHandler.EventTriggerAfterInsert(trigger.new);
        }
        WHEN AFTER_UPDATE {
            EventTriggerHandler.EventTriggerAfterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
            
            EventTriggerHandler.updateCaseSpeakerNames(trigger.new, trigger.newMap, trigger.oldMap);
            
        }
        WHEN AFTER_DELETE {
            EventTriggerHandler.EventTriggerAfterDelete(trigger.oldMap);
        }
        WHEN AFTER_UNDELETE {
            //EventTriggerHandler.syncActivityProducts(trigger.new, trigger.newMap, null);
        }
        
    }    
    
    dlrs.RollupService.triggerHandler();    

}