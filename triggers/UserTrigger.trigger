trigger UserTrigger on User (before update, after update, after insert) {
    // This trigger allows to update the UserRoleid
    
    if(trigger.isUpdate && trigger.isBefore) {
        UserTriggerHandler.SetUserRoleId(trigger.new);
        UserTriggerHandler.SetReactivatedDatetime(trigger.new,trigger.oldMap);
        UserTriggerHandler.userInactiveFunctionalities(trigger.new,trigger.oldMap); 
    } 

    if(trigger.isUpdate && trigger.isAfter) {
       UserTriggerHandler.setUserPicture(trigger.newMap, trigger.oldMap);
    }

    if(trigger.isInsert && trigger.isAfter){
        UserTriggerHandler.handleAfterInsert(trigger.new);
    }
    
}