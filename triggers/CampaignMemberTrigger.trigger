trigger CampaignMemberTrigger on CampaignMember (before delete, before insert, before update, after insert, after update, after delete) {
    
    if(trigger.isBefore)
    {   
        CampaignMemberTriggerHandler.errorChecks(trigger.new, trigger.old);
        if (!trigger.isDelete) {
        CampaignMemberTriggerHandler.setFieldValues(trigger.new, trigger.oldMap);
        }
    }
    
    if(trigger.isAfter)
    {   
        CampaignMemberTriggerHandler.setContactFields(trigger.new, trigger.oldMap);
    }
    
    
}