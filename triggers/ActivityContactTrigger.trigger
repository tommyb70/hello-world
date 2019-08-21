trigger ActivityContactTrigger on ActivityContact__c  (before delete, before insert, before update, after delete, after insert, after undelete, after update) {
    
    SWITCH ON Trigger.operationType  {
        WHEN BEFORE_INSERT {
            ActivityContactTriggerHandler.ActivityContactBeforeInsert(trigger.new);
        }
        WHEN BEFORE_DELETE {
            ActivityContactTriggerHandler.ActivityContactBeforeDelete(trigger.old);
        }
        WHEN AFTER_INSERT {
            ActivityContactTriggerHandler.ActivityContactAfterInsert(trigger.new);
            
            //Added by Prabhpreet. To Update Case Speaker Name details
            ActivityContactTriggerHandler.getActivityEventContactDetails(trigger.new);
        }
        WHEN AFTER_UPDATE {
            ActivityContactTriggerHandler.ActivityContactBeforeDelete(trigger.old);
            
            //Added by Prabhpreet. To Update Case Speaker Name details
            ActivityContactTriggerHandler.getActivityEventContactDetails(trigger.new);
        }
        WHEN AFTER_DELETE {
            ActivityContactTriggerHandler.ActivityContactAfterDelete(trigger.old);
            
            //Added by Prabhpreet. To Update Case Speaker Name details
            ActivityContactTriggerHandler.getActivityEventContactDetails(trigger.old);
        }
        WHEN AFTER_UNDELETE {
            ActivityContactTriggerHandler.ActivityContactAfterUndelete(trigger.new);
        }
        
    }
    
}