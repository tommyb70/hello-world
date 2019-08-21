global class EventRelationSyncBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    // This Batch job synchs up TaskRelation and ActivityContact__c
    // 
/*20190707 - No Longer Need this since using trigger on TaskRelationChangeEvent
    Public integer Count = 0;
    
    public static String affiliateRequestEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Affiliate Event').getRecordTypeId();
    public String query = 'select  Product__c,Type,id,ActivityType__c,Whoid,WhatId,EventWhoIds,Subject,ActivityDate,OwnerId,recordTypeID, (select id, RelationId,EventId from EventRelations where iswhat=false) from Event Where SystemModStamp >= LAST_N_DAYS:1';
    
    Public String msg = '';
    
    public Map<String, List<String>> m = new Map<String,  List<String>>(); */

	Public String query = 'SELECT Id from Event WHERE Id = null';
    
    global EventRelationSyncBatch() {
        System.Debug('EventRelation to ActivityContact__c');
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {   
        
        System.Debug('Query - ' + query);
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Event> scope) {
/*20190707 - No Longer Need this since using trigger on TaskRelationChangeEvent
        // global void execute(List<Event> scope) {
        List<String> temp = new List<String>();     
        set<id> ActivityIds = new set<id>();
        set<id> ContactIds = new set<id>();
        
        for (Event tsk : scope)
        {
            ActivityIds.add(tsk.id); 
            temp.Add(tsk.id );
        } 
        // Create msg to add in the email
        msg = 'Activity Ids Count ' +  ActivityIds.size();
        m.put('Task-Activity Ids' , temp );  
        
        List<Event> TaskToUdpate = new List<Event>();       
        List<ActivityContact__c> newRElatedAC = new List<ActivityContact__c>();
        
        for (Event e : scope)
        {   
            if((e.recordTypeID == affiliateRequestEventRecordTypeId) 
               && ((e.Type=='Call') || (e.Type=='Meeting') ||(e.Type=='Onsite') ||(e.Type=='Webex'))) 
            {
                String ActivityType = EventTriggerHandler.FindContactActivity(e);
                for (EventRelation cTr : e.EventRelations) 
                {
                    ActivityContact__c ac = new ActivityContact__c();
                    ac.ActivityId__c = e.Id;
                    ac.ActivityType__c = ActivityType;
                    ac.Status__c = 'Completed';
                    ac.Subject__c = e.Subject;
                    ac.Type__c = e.Subject;
                    ac.Date__c = e.ActivityDate;
                    ac.Contact__c = (id)cTr.RelationId; 
                    if( ac.Contact__c == e.WhoId)ac.Primary__c=true;else ac.Primary__c=false;
                    ac.case__c = e.WhatId;
                    ac.IsEvent__c = true;
                    ContactIds.add(ac.Contact__c);               
                    newRElatedAC.add(ac); 
                    Count = Count + 1;
                }
            }
            
        }
        
        List<ActivityContact__c> ActivityContactsToDelete = [select id from ActivityContact__c where ActivityId__c in: ActivityIds]; 
        // Create msg to add in the email
        msg = msg + '   ActivityContactsToDelete Count : ' + ActivityContactsToDelete.size();
        List<String> ActivityContactsToDeleteList = new List<String>();
        for(ActivityContact__c ac: ActivityContactsToDelete){
            ActivityContactsToDeleteList.add(ac.Id);
        }
        m.put('ActivityContacts - Delete - ActivityContact Ids' , ActivityContactsToDeleteList );  
        
        
        if (ActivityContactsToDelete.size()>0)
        {
            delete ActivityContactsToDelete;
        }
        
        
        
        // Create msg to add in the email
        msg = msg + '   newRElatedAC Count: ' + newRElatedAC.size();
        List<String> newRElatedACList = new List<String>();
        for(ActivityContact__c ac: newRElatedAC){
            newRElatedACList.add(ac.ActivityId__c);
        }
        m.put('Contact Activity - Create - Activity Ids' , newRElatedACList );  
        
        if (newRElatedAC.size()>0)
        {
            insert newRElatedAC;
            //ActivityContactTriggerHandler.rollupCId(ContactIds);
        }  */
    }
    
    
    global void finish(Database.BatchableContext BC) {
    
    }
    
}