public class EventRelationChangeEventTriggerHandler {
    
    public static void eventRelationChangeEventAfterInsert(List<EventRelationChangeEvent> events) {

        Map<Id,Event> eventMap = getEventMap(events);
        
        Set<Id> userIdSet = new Set<Id>();
        for (Event e : eventMap.values()) {
            userIdSet.add(e.OwnerId);
        }
        
        Map<Id,User> userMap = Util.getUserTerritoryMap(userIdSet);
        Map<Id,Channel__c> channelMap = Util.getChannelMap();

        Set<Id> contactIdSet = new Set<Id>();
        Set<String> activityContactKeySet = new Set<String>();
        for (EventRelationChangeEvent event : events) {
            contactIdSet.add(event.RelationId);
            activityContactKeySet.add((String)event.EventId + (String)event.RelationId);
        }
        Map<Id,Contact> contactMap = UtilActivity.getContactPrimaryTerritoryMap(contactIdSet);

        Map<String,ActivityContact__c> activityContactKeyMap = UtilActivity.getActivityContactKeyMap(activityContactKeySet);
        
        List<ActivityContact__c> activityContactToUpsert = new List<ActivityContact__c>();
        List<ActivityContact__c> activityContactToDelete = new List<ActivityContact__c>();
        Set<Id> activityRelatedIdsForDelete = new Set<Id>();

       
                                                    
                                                    
        for (EventRelationChangeEvent event : events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            System.debug('Received change event for ' + 
                         header.entityName +
                         ' for the ' + header.changeType + ' operation.'); 
            
            System.debug('Event Relation Changed Record Fields');
            if (event.EventId != null) {
                System.debug('EventId: ' + event.EventId);
            }
            if (event.IsWhat != null) {
                System.debug('IsWhat: ' + event.IsWhat);
            }           
            if (event.RelationId != null) {
                System.debug('RelationId: ' + event.RelationId);
            }
            if (event.AccountId != null) {
                System.debug('AccountId: ' + event.AccountId);
            }
            
            
            SWITCH ON header.changetype {
                WHEN 'CREATE', 'UPDATE', 'UNDELETE' {
                    
                    String relationIdString = (String)event.RelationId;
                    
                    if (relationIdString.startsWith('003')) {
                        ActivityContact__c myAC = new ActivityContact__c();
                        myAC.ActivityId__c = (String)event.EventId;     
                        myAC.Contact__c = (String)event.RelationId;
                        if (activityContactKeyMap.containsKey((String)event.EventId + (String)event.RelationId)) myAC = activityContactKeyMap.get((String)event.EventId + (String)event.RelationId);
                        
                        Event myEvent = new Event();
                        if (eventMap.containsKey(event.EventId)) myEvent = eventMap.get(event.EventId);
                        
                        myAC = UtilActivity.activityContactEventFieldPreset(myAC,myEvent,contactMap,userMap,channelMap);
                        activityContactToUpsert.add(myAC);
                    }
                    
                    
                            
                }
                WHEN 'DELETE' {
                    
                
                    for(Id delRecId : header.recordids) {
                        activityRelatedIdsForDelete.add(delRecId);
                    }
                    
                    
                        
                 
                    

                }
            }
        }
        
        if (!activityRelatedIdsForDelete.isEmpty()) activityContactToDelete = UtilActivity.getActivityContactsByRelatedIds(activityRelatedIdsForDelete);       
        if (!activityContactToUpsert.isEmpty()) upsert activityContactToUpsert;
        if (!activityContactToDelete.isEmpty()) delete activityContactToDelete;
        
    }
    
    
    private static Map<Id,Event> getEventMap(List<EventRelationChangeEvent> events) {
        
        Set<Id> eventIdSet = new Set<Id>();
        
        for (EventRelationChangeEvent event : events) {
            eventIdSet.add(event.EventId);
        }
        
        
        Map<Id,Event> eventMap = new Map<Id,Event>([SELECT Id, Subject, ShortSubject__c, ActivityDate, Type, ActivitySource__c,
                                                    OwnerChannel__c, OwnerChannelId__c, OwnerTerritory__c, OwnerTerritoryMARS__c,
                                                    OwnerTerritoryId__c, OwnerZoneFormula__c, Ownerid, WhatId, WhoId, Description,
                                                    ActivityType__c, ActivitySubType__c, ActivityPoints__c, RecordTypeId, WhoCount, WhatCount,
                                                    AccountId, Firm__c, MARSOfficeId__c, Campaign__c, Opportunity__c
                                                    FROM Event
                                                    WHERE Id IN :eventIdSet]);
        
        return eventMap;
        
    }    
    
}