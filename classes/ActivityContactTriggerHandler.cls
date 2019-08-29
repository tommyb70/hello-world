public without sharing class ActivityContactTriggerHandler {

    public static void ActivityContactBeforeDelete(List<ActivityContact__c> ac) {
        //preventDeletionOfOldRecords(ac);
    }

    public static void ActivityContactAfterDelete (List<ActivityContact__c> ActivityContacts){
        //deleteAssociatedActivityProducts(ActivityContacts);
        Set<Id> contactIdSet = getContactIdsForRollup(ActivityContacts); 
        futurerollupCId(contactIdSet); 
    }

    public static void ActivityContactAfterInsert (List<ActivityContact__c> ActivityContacts){
        Set<Id> contactIdSet = getContactIdsForRollup(ActivityContacts); 
        futurerollupCId(contactIdSet); 
    }    

    public static void ActivityContactAfterUndelete(List<ActivityContact__c> ActivityContacts){
        Set<Id> contactIdSet = getContactIdsForRollup(ActivityContacts); 
        futurerollupCId(contactIdSet); 
    }   

    public static void ActivityContactBeforeInsert(List<ActivityContact__c> ActivityContacts) {
        
        List<ActivityContact__c> eac = new List<ActivityContact__c>();
        List<ActivityContact__c> tac = new List<ActivityContact__c>();
        
        for (ActivityContact__c ac : ActivityContacts) {
            if (ac.ActivityId__c.startsWith('00T')) {tac.add(ac);}
        if (ac.ActivityId__c.startsWith('00U')) eac.add(ac);
        }
        
        ActivityContacts = setActivityRelationIdTask(tac);
        ActivityContacts = setActivityRelationIdEvent(eac);
    }        

    /*    public static void preventDeletionOfOldRecords(list<ActivityContact__c> ActivityContacts)  {
        
        Integer CannotCUDActivityAfterDays = (Integer)NGAMSettingsHierarchy__c.getInstance().CannotCUDActivityAfterDays__c;        
        
        for (ActivityContact__c acd : ActivityContacts) {
            if (acd.date__c.daysBetween(Date.Today()) >= CannotCUDActivityAfterDays) {
                acd.addError('Cannot Delete Activity Contact more than '+ CannotCUDActivityAfterDays + ' days after Activity Date');
            }
        }
    }*/

    public static Set<Id> getContactIdsForRollup(List<ActivityContact__c> ac) {
        
        Set<Id> contactIds = new Set<Id>();
        if (!system.isBatch() && !system.isFuture()) {
            for (ActivityContact__c ac1 : ac) {
                contactIds.add(ac1.Contact__c);
            }
        }
        
        return contactIds;
        
    }

    @future
    public static void futurerollupCId(Set<Id> recordIds) {
        List<ActivityContact__c> myAcs = [select contact__c, account__c,case__c from ActivityContact__c where contact__c in :recordIds];
        List<SObject> parents = (List<SObject>) dlrs.RollupService.rollup(myAcs);
        update parents;
    }

    public static List<ActivityContact__c> setActivityRelationIdTask(List<ActivityContact__c> ActivityContacts) {
        
        Set<Id> TaskIdSet = new Set<Id>();
        Set<Id> ContactIdSet = new Set<Id>();
        
        for (ActivityContact__c ac : ActivityContacts) {
            TaskIdSet.add(ac.ActivityId__c);
            ContactIdSet.add(ac.Contact__c);
        }
        
        for (TaskRelation tr : [SELECT Id, TaskId, RelationId
                                FROM TaskRelation
                                WHERE TaskId IN :TaskIdSet
                                AND RelationId IN: ContactIdSet]) {
                                    
                                    for (ActivityContact__c ac : ActivityContacts) {
                                        if (tr.TaskId == ac.ActivityId__c && tr.RelationId == ac.Contact__c) ac.ActivityRelationId__c = tr.Id;
                                    }
                                    
                                }
        return ActivityContacts; 
        
    }

    public static List<ActivityContact__c> setActivityRelationIdEvent(List<ActivityContact__c> ActivityContacts) {
        
        Set<Id> EventIdSet = new Set<Id>();
        Set<Id> ContactIdSet = new Set<Id>();
        
        for (ActivityContact__c ac : ActivityContacts) {
            EventIdSet.add(ac.ActivityId__c);
            ContactIdSet.add(ac.Contact__c);
        }
        
        for (EventRelation er : [SELECT Id, EventId, RelationId
                                    FROM EventRelation
                                    WHERE EventId IN :EventIdSet
                                    AND RelationId IN: ContactIdSet]) {
                                        
                                        for (ActivityContact__c ac : ActivityContacts) {
                                            if (er.EventId == ac.ActivityId__c && er.RelationId == ac.Contact__c) ac.ActivityRelationId__c = er.Id;
                                        }
                                        
                                    }
        return ActivityContacts; 
        
    }  

    private static void deleteAssociatedActivityProducts(List<ActivityContact__c> ActivityContacts) {
        
        Set<Id> ActivityRelationIdSet = new Set<Id>();
        
        for (ActivityContact__c ac : ActivityContacts) {
            ActivityRelationIdSet.add(ac.ActivityRelationId__c);
        }
        
        delete [SELECT Id FROM ActivityProduct__c WHERE ActivityRelationId__c IN :ActivityRelationIdSet];
    }


    /*Added by Prabhpreet
        Method Name: getActivityEventContactDetails
        Purpose: Method for Updating the Speaker Name field on Case associated with the Event
        Parameters: List<ActivityContact__c> ActivityContacts
        Return Type: void
        */
    public static void getActivityEventContactDetails(List<ActivityContact__c> ActivityContacts) {

        // Method variables
        Set<Id> eventIdSet = new Set<Id>();
        List<Case> lstCaseToUpdate = new List<Case>();
        Set<Id> caseIdSet = new Set<Id>();
        Map<Event,List<Contact>> mapEventContacts = new Map<Event,List<Contact>>();
        Map<Id,Case> caseEventMap = new Map<Id,Case>();

        for (ActivityContact__c ac : ActivityContacts) {
            if (ac.ActivityId__c.startsWith('00U')) {
                eventIdSet.add(ac.ActivityId__c);
            }
        }
        System.debug('Event ID'+ eventIdSet);
        if(!eventIdSet.isEmpty()) {   
            List<Event> lstEvent = new List<Event>([SELECT Id,  WhatId, WhoId
                                                    FROM Event
                                                    WHERE Id IN :eventIdSet]); 
            for (Event e : lstEvent) {
                if(e.WhatId != null) {
                	String strWhatId = e.WhatId;
                    if (strWhatId.startsWith('500')) {
                        caseIdSet.add(e.WhatId);
                    }
                }
            }
        }
        if(!caseIdSet.isEmpty()) {  
            List<Case> lstCases = [SELECT Id, Subject, RequestedSpeakers__c
                                                    FROM Case
                                                    WHERE Id =:caseIdSet ];
            List<Event> lstAllCaseEvents = [Select Id,WhatId from Event WHERE WhatId IN:caseIdSet];
            Set<Id> eventsAllIds = new Set<Id>();
            for (Event e : lstAllCaseEvents) {
                eventsAllIds.add(e.Id);
                for(Case objCase: lstCases) {
                    if (e.WhatId == objCase.Id) {
                        caseEventMap.put(e.Id, objCase);
                    }
                }
            }
            System.debug('caseEventMap'+ caseEventMap);
            System.debug('eventsAllIds'+ eventsAllIds);
            mapEventContacts = getEventContactRepsDetails(eventsAllIds);
            System.debug('mapEventContacts'+ mapEventContacts);
            lstCaseToUpdate = getCaseToUpdateDetails( mapEventContacts, caseEventMap);
        }
        if (!lstCaseToUpdate.isEmpty()) {
            update lstCaseToUpdate;
        } 

    }

    /*Added by Prabhpreet
        Helper Method Name: getEventContactRepsDetails
        Purpose: Method for Updating the Speaker Name field on Case associated with the Event
        Parameters: Set<Id> eventsAllIds
        Return Type: Map<Event, List<Contact>>
        */
    public static Map<Event, List<Contact>> getEventContactRepsDetails(Set<Id> eventsAllIds) {
        Set<Id> setContactIds = new Set<Id>();
        Map<Id,Contact> mapContacts = new Map<Id, Contact>();
        List<Contact> lstContacts = new List<Contact>();
    
        Map<Event,List<Contact>> mapEventContacts = new Map<Event,List<Contact>>();
        if(!eventsAllIds.isEmpty()) { 
            List<Event> lstAllEvents = new List<Event>([SELECT Id,  WhatId, WhoId
                                                    FROM Event
                                                    WHERE Id IN :eventsAllIds]);
        
            List<EventRelation> lstEventRelation = [SELECT EventId,RelationId FROM EventRelation WHERE EventId IN: eventsAllIds]; 
            for(EventRelation objEvent: lstEventRelation){
                String strId = objEvent.RelationId;
                if (strId.startsWith('003')) {
                    setContactIds.add(strId);
                }
            }
            System.debug('setContactIds'+ setContactIds);
            if(!setContactIds.isEmpty()) {
                lstContacts = [SELECT AffiliateContactFlag__c, Name FROM Contact WHERE Id =: setContactIds];
                for(Contact objContact: lstContacts) {
                    mapContacts.put(objContact.Id,objContact);
                }
            }
            system.debug('lstEventRelation -->'+lstEventRelation);
            system.debug('lstAllEvents -->'+lstAllEvents);
            if(!lstAllEvents.isEmpty()) {
                for(Event objEvent: lstAllEvents){
                    for(EventRelation objER : lstEventRelation) {
                        if(objEvent.Id == objER.EventId) {
                            String strId = objER.RelationId;
                            if (strId.startsWith('003')) {
                                if(!mapEventContacts.containsKey(objEvent)) {
                                    List<Contact> lst = new List<Contact>();
                                    lst.add(mapContacts.get(objER.RelationId));
                                    mapEventContacts.put(objEvent,lst);
                                }
                                else {
                                    List<Contact> lst = mapEventContacts.get(objEvent);
                                    lst.add(mapContacts.get(objER.RelationId));
                                    mapEventContacts.put(objEvent,lst);
                                }
                            }
                        }
                    }        
                }
            }
        }
        return mapEventContacts;
    }

    /*Added by Prabhpreet
    Helper Method Name: getCaseToUpdateDetails
    Purpose: Method for Updating the Speaker Name field on Case associated with the Event
    Parameters: Map<Event, List<Contact>> mapEventContacts, Map<Id,Case> caseEventMap
    Return Type: List<Case>
    */
    public static List<Case> getCaseToUpdateDetails(Map<Event, List<Contact>> mapEventContacts, Map<Id,Case> caseEventMap) {
        List<Case> lstCaseToUpdate = new List<Case>();
        Map<Case,List<String>> mapCaseSpeakers = new Map<Case,List<String>>();
        if(!mapEventContacts.isEmpty()) {
            for (Event objEvent : mapEventContacts.keySet()) {
                List<Contact> lst =  mapEventContacts.get(objEvent);
                if(! lst.isEmpty()) {
                    List<String> lstSpeakers = new List<String>();
                    for(Contact objContact: lst) {
                        if(objContact.AffiliateContactFlag__c) {
                            lstSpeakers.add(objContact.Name);
                        }
                    }
                    Case objCase = caseEventMap.get(objEvent.Id);
                    if(!mapCaseSpeakers.containsKey(objCase)) {
                        mapCaseSpeakers.put(objCase, lstSpeakers);
                    }
                    else {
                        List<String> newSpeakers = mapCaseSpeakers.get(objCase);
                        newSpeakers.addAll(lstSpeakers);
                        mapCaseSpeakers.put(objCase,newSpeakers);
                    }
                }
            }
        }
        System.debug('mapCaseSpeakers'+ mapCaseSpeakers);
        if(!mapCaseSpeakers.isEmpty()) {
            for (Case objCase : mapCaseSpeakers.keySet()) {
                Set<String> setSpeakers = new Set<String>();
                List<String> lstUniqueSpeakers = new List<String>();
                setSpeakers.addAll(mapCaseSpeakers.get(objCase));
                lstUniqueSpeakers.addAll(setSpeakers);
                objCase.RequestedSpeakers__c   =  String.join(lstUniqueSpeakers,'; ');
                lstCaseToUpdate.add(objCase);
            }
        }
        return lstCaseToUpdate;
    }
}