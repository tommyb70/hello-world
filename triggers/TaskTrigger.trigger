trigger TaskTrigger on Task (before insert, before update, after update, after delete, after insert, after undelete) {
    
    SWITCH ON Trigger.operationType  {
        WHEN BEFORE_INSERT {
            TaskTriggerHandler.TaskTriggerBeforeInsert(trigger.new, trigger.newMap);
        }
        WHEN BEFORE_UPDATE {
            TaskTriggerHandler.TaskTriggerBeforeUpdate(trigger.new, trigger.newMap);
        }
        WHEN AFTER_INSERT {
            TaskTriggerHandler.syncActivityProducts(trigger.new, trigger.newMap, null);
            //TaskTriggerHandler.updateTotalActivityPoints(trigger.newMap);
        }
        WHEN AFTER_UPDATE {
            TaskTriggerHandler.syncActivityProducts(trigger.new, trigger.newMap, trigger.oldMap);
            TaskTriggerHandler.syncActivityContacts(trigger.new, trigger.newMap, trigger.oldMap);
            //TaskTriggerHandler.updateTotalActivityPoints(trigger.newMap);
        }
        WHEN AFTER_DELETE {
            TaskTriggerHandler.TaskTriggerAfterDelete(trigger.oldMap);
        }
        WHEN AFTER_UNDELETE {
            TaskTriggerHandler.syncActivityProducts(trigger.new, trigger.newMap, null);
            //TaskTriggerHandler.updateTotalActivityPoints(trigger.newMap);
        }
        
    }    
    
  	dlrs.RollupService.triggerHandler();    

}