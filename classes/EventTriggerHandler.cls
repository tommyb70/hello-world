public class EventTriggerHandler {

    public static String AffiliateRecordType = 'Affiliate Request';
    
    public static Map<Id,User> userMap = new Map<Id,User>([SELECT Id,ActivityTerritoryName__c, ActivityChannelName__c,ActivityTerritoryZoneName__c,
                                                           ActivityTerritoryMARSName__c, ActivityTerritoryId__c
                                                           FROM User
                                                           WHERE UserType = 'Standard']);
    
    public static Id affiliateRequestEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Affiliate Event').getRecordTypeId();
    
    public static void EventTriggerBeforeInsert(List<Event> myEvents, Map<Id,Event> eventNewMap){
        eventFieldsPreset(myEvents, eventNewMap);  
    }
    
    public static void EventTriggerAfterInsert(List<Event> myEvents){
        SetLastEventDatetime(myEvents);
    } 
    
    
    public static void EventTriggerBeforeUpdate(List<Event> myEvents, Map<Id,Event> eventNewMap, Map<Id,Event> eventOldMap){
        eventFieldsPreset(myEvents, eventNewMap); 
    } 
    
    
    public static void EventTriggerAfterUpdate(List<Event> myEvents, Map<Id,Event> eventNewMap, Map<Id,Event> eventOldMap){
        setLastEventDatetime(myEvents);
        syncActivityContacts(myEvents, eventNewMap, eventOldMap);        
    } 
    
    public static void EventTriggerAfterDelete(Map<Id,Event> oldEventMap) {

        SetLastEventDatetimeDelete(oldEventMap.values());
        delete [SELECT Id from ActivityContact__c WHERE ActivityId__c IN :oldEventMap.keySet()];
        //delete [SELECT Id from ActivityProduct__c WHERE ActivityId__c IN :oldEventMap.keySet()];
        
    }    

    public static void eventFieldsPreset(List<Event> myEvents, Map<Id,Event> eventMap){
        
        if (trigger.IsUpdate) myEvents = eventMap.values();
        
        Id pardotUserId;
        Map<Id,User> userMap = Util.getUserTerritoryMap();
        for (User u : userMap.values()) {
            if (u.Username.startsWith('pnatixis')) pardotUserId = u.Id;
        }
        
        Map<Id, ActivityContact__c> activityContactMap = new Map<Id, ActivityContact__c>();
        
        if (trigger.IsUpdate) activityContactMap = UtilActivity.getActivityContactMap(eventMap);

        Set<Id> contactIdSet = new Set<Id>();
        for (ActivityContact__c ac : activityContactMap.values()) {
            contactIdSet.add(ac.Contact__c);
        }
        Map<Id,Contact> contactMap = UtilActivity.getContactPrimaryTerritoryMap(contactIdSet);

        for (Event e : myEvents) {
            
            e = UtilActivity.setUserFields(e, userMap);
            e = UtilActivity.syncWhatIdToLookupFields(e);
            e.LastAssignedOwner__c = e.OwnerId;
            
            e.ActivityType__c = e.ActivityType__c == null ? e.Type : e.ActivityType__c;
            e.ActivityDateProxy__c = e.ActivityDate;
            e.ActivitySubType__c = 'Product/Promotional';
            e.ActivityComments__c = String.isBlank(e.Description) ? null : e.Description.left(255).trim();
            
            SWITCH ON e.Type {
                WHEN 'Meeting','WebEx' {
                    e.ActivityType__c = 'Meeting';
                }
                WHEN 'Call' {
                    e.ActivityType__c = 'Call';
                }
            }      
            
        }
        myEvents = UtilActivity.setActivityPoints(myEvents);
    }


    public static void setLastEventDatetime(List<Event> myEvents) {
        
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> relatedCasesSet = new Set<Id>();
        for(Event eId : myEvents){
            if ('Case' == eId.WhatId.getSObjectType().getDescribe().getName()) relatedCasesSet.add(eId.WhatId);
        }
        
        if(!relatedCasesSet.isEmpty()){
            Map<string, Case> cMap = new Map<string, Case>();
            AggregateResult[] events = [select WhatId, Max(EndDateTime), MIN(StartDateTime) from Event where WhatId IN :relatedCasesSet GROUP BY WhatId];
            if(events.size()>0){
                for(AggregateResult e: events){
                    If (e.get('expr0')!=null && e.get('expr1') != null) {
                        cMap.put((string)e.get('WhatId'), new Case(Id=(string)e.get('WhatId'), LastEventEndDatetime__c=(datetime)e.get('expr0'), FirstEventStartDatetime__c=(datetime)e.get('expr1')));
                    } else {
                        cMap.put((string)e.get('WhatId'), new Case(Id=(string)e.get('WhatId'), LastEventEndDatetime__c=null,FirstEventStartDatetime__c=null));
                    }
                }
            }
            update(cMap.values());
        }  
        
    }
    
    public static void SetLastEventDatetimeDelete(List<Event> myEvents) {
        
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> relatedCasesSet = new Set<Id>();
        for(Event eId : myEvents){
            if ('Case' == eId.WhatId.getSObjectType().getDescribe().getName()) relatedCasesSet.add(eId.WhatId);
        }
        
        if(!relatedCasesSet.isEmpty()){
            Map<string, Case> cMap = new Map<string, Case>();
            
            AggregateResult[] events = [select WhatId, Max(EndDateTime) from Event where WhatId IN :relatedCasesSet GROUP BY WhatId];
            if(events.size()>0){
                for(AggregateResult e: events){
                    If (e.get('expr0')!=null) {
                        cMap.put((string)e.get('WhatId'), new Case(Id=(string)e.get('WhatId'), LastEventEndDatetime__c=(datetime)e.get('expr0')));
                    } else {
                        cMap.put((string)e.get('WhatId'), new Case(Id=(string)e.get('WhatId'), LastEventEndDatetime__c=null));
                    }
                }
            }
            update(cMap.values());
        }  
    }
    
    public static void syncActivityContacts(List<Event> myNewEvents, Map<Id,Event> myNewEventMap, Map<Id,Event> myOldEventMap) {
        
        Map<Id, ActivityContact__c> activityContactMap = UtilActivity.getActivityContactMap(myNewEventMap);
        List<ActivityContact__c> activityContactToUpdate = new List<ActivityContact__c>();
                
        Map<String, List<ActivityContact__c>> activityContactToUpdateMap = new Map<String, List<ActivityContact__c>>();
        
        for (ActivityContact__c ac : activityContactMap.values()) {
            if (activityContactToUpdateMap.containsKey(ac.ActivityId__c)) {
                List<ActivityContact__c> tempAC = activityContactToUpdateMap.get(ac.ActivityId__c);
                tempAC.add(ac);
                activityContactToUpdateMap.put(ac.ActivityId__c, tempAC);
            } else {
                List<ActivityContact__c> tempAC = new List<ActivityContact__c>();
                tempAC.add(ac);
                activityContactToUpdateMap.put(ac.ActivityId__c, tempAC);
            }
        }
        
        for (Event e : myNewEvents) {
            
            if (activityContactToUpdateMap.containsKey(e.Id)) {
                List<ActivityContact__c> acList = activityContactToUpdateMap.get(e.Id);
                
                for (ActivityContact__c ac : acList) {
                    if (ac.ActivityId__c.startsWith('00U')) ac = UtilActivity.activityContactEventFieldPreset(ac, e);
                    activityContactToUpdate.add(ac);
                }
            }
        }
        
        update activityContactToUpdate;

    } 
    
  
    
}