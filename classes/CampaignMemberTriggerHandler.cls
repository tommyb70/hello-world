public class CampaignMemberTriggerHandler {
    
    public static void errorChecks(List<CampaignMember> myCampaignMembers, List<CampaignMember> myOldCampaignMembers){
        
        Set<Id> ContactIdSet = new Set<Id>();
        if (!Trigger.IsDelete) {
            for (CampaignMember cis : myCampaignMembers) {
                ContactIdSet.add(cis.ContactId);
            }
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, InvitedBy__c, EventCampaignName__c 
                                                            FROM Contact
                                                            WHERE Id in: ContactIdSet]);
        
        Boolean systemUser = (Boolean)NGAMSettingsHierarchy__c.getInstance().ApexSystemUserOrProfile__c; 
        
        if (Trigger.IsDelete) {
            for (CampaignMember cm : myOldCampaignMembers) {
                if (!systemUser && cm.RecordTypeOfCampaign__c == 'Event' && cm.Status != 'Added to List') {
                    cm.addError('You can only delete Event campaign members if they are in a status of Added to List');
                }
            }
        }
        
        if (!Trigger.IsDelete) {
            for (CampaignMember cm : myCampaignMembers) {
                if (contactMap.containsKey(cm.ContactId)) {
                    if  (contactMap.get(cm.ContactId).InvitedBy__c != null && cm.RecordTypeOfCampaign__c == 'Event' && Trigger.IsInsert) {
                        cm.addError('This contact is part of another event campaign (' + contactMap.get(cm.ContactId).EventCampaignName__c + ') and invitations have not yet gone out.  You cannot add this contact right now.  Please call Event Planning.');
                    }
                }
            }
        }
    }
    
    public static void setFieldValues (List<CampaignMember> myCampaignMembers, Map<Id,CampaignMember> myCampaignMembersOldMap) {
        
        Set<Id> userSet = new Set<Id>();
        
        for (CampaignMember cm : myCampaignMembers) {
            
            if (cm.InvitedBy__c == null && cm.RecordTypeOfCampaign__c == 'Event') {
                cm.InvitedBy__c = cm.CreatedById;
                userSet.add(cm.InvitedBy__c);
            }
        }
        
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, ActivityChannelName__c, ActivityTerritoryName__c, ActivityTerritoryZoneName__c
                                                 FROM User
                                                 WHERE Id IN :userSet]);
        
        for (CampaignMember cm : myCampaignMembers) {
            
            if (userMap.containsKey(cm.InvitedBy__c) && cm.RecordTypeOfCampaign__c == 'Event' &&
                (cm.InvitedBy__c != myCampaignMembersOldMap.get(cm.Id).InvitedBy__c || Trigger.IsInsert)) {
                    cm.InvitedByChannel__c = userMap.get(cm.InvitedBy__c).ActivityChannelName__c;
                    cm.InvitedByTerritory__c = userMap.get(cm.InvitedBy__c).ActivityTerritoryName__c;
                    cm.InvitedByZone__c = userMap.get(cm.InvitedBy__c).ActivityTerritoryZoneName__c;
                }
        }
        
    }
    
    public static void setContactFields (List<CampaignMember> myCampaignMembers, Map<Id,CampaignMember> myCampaignMembersOldMap) {
        
        Set<Id> eventContactSetId = new Set<Id>();
        
        if (!Trigger.IsDelete) {
            for (CampaignMember cm : myCampaignMembers) {
                if (cm.RecordTypeOfCampaign__c == 'Event') eventContactSetId.add(cm.ContactId);
            }
        } else {
            for (CampaignMember cm : myCampaignMembersOldMap.values()) {
                if (cm.RecordTypeOfCampaign__c == 'Event') eventContactSetId.add(cm.ContactId);
            }
        }
        
        Map<Id,Contact> contactsToUpdateMap = new Map<Id,Contact>([SELECT Id, 
                                                                   EventCampaignFieldsLastUpdatedBy__c, EventCampaignFieldsLastUpdated__c, 
                                                                   EventCampaignName__c, InvitedBy__c
                                                                   FROM Contact
                                                                   WHERE Id IN :eventContactSetId]);
        
        if (Trigger.IsDelete) {
            for (CampaignMember cm : myCampaignMembersOldMap.values()) {
                
                if (contactsToUpdateMap.containsKey(cm.ContactId)) {
                    Contact c = contactsToUpdateMap.get(cm.ContactId);
                    c.EventCampaignFieldsLastUpdatedBy__c = null;
                    c.EventCampaignFieldsLastUpdated__c = null;
                    c.EventCampaignName__c = null;
                    c.InvitedBy__c = null;
                    c.EventRegistrationType__c = null;
                    c.InvitedByPersonalizationText__c = null;
                    contactsToUpdateMap.put(c.Id,c);
                }
                
            }
        } else {
            
            for (CampaignMember cm : myCampaignMembers) {
                
                if (contactsToUpdateMap.containsKey(cm.ContactId)) {
                    Contact c = contactsToUpdateMap.get(cm.ContactId);
                    system.debug('Status: ' + cm.Status);
                    if (cm.Status == 'Added to List') {
                        c.EventCampaignFieldsLastUpdatedBy__c = UserInfo.getUserId();
                        c.EventCampaignFieldsLastUpdated__c = datetime.now();
                        c.EventCampaignName__c = cm.Name;
                        c.InvitedBy__c = cm.InvitedBy__c;
                        c.EventRegistrationType__c = cm.RegistrationType__c;
                        c.InvitedByPersonalizationText__c = cm.InvitedByPersonalizationText__c;
                    } else {
                        c.EventCampaignFieldsLastUpdatedBy__c = null;
                        c.EventCampaignFieldsLastUpdated__c = null;
                        c.EventCampaignName__c = null;
                        c.InvitedBy__c = null;
                        c.EventRegistrationType__c = null;
                        c.InvitedByPersonalizationText__c = null;
                    }
                    contactsToUpdateMap.put(c.Id,c);
                }
            }
            
        }
        
        if (!contactsToUpdateMap.isEmpty()) update contactsToUpdateMap.values();         
        
    }
    
    
}