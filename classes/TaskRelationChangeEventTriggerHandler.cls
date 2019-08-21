public class TaskRelationChangeEventTriggerHandler {
    
    //Keeps Activity Contact in Sync with TaskRelation
    
    //Following value is set by TaskRelationChangeEventTriggerHandler and EventRelationChangeEventTrigerHandler
    //to keep TotalActivityPoints__c from being set to null when it updates Task after change in TaskRelation
    //or EventRelation
        
    public static void taskRelationChangeEventAfterInsert(List<TaskRelationChangeEvent> events) {
        
        Map<Id,Task> taskMap = getTaskMapFromTaskChangeEvents(events);
        
        Set<Id> userIdSet = new Set<Id>();
        for (Task t : taskMap.values()) {
            userIdSet.add(t.OwnerId);
        }
        
        Map<Id,User> userMap = Util.getUserTerritoryMap(userIdSet);
        
        List<Task> TasksToUpdate = new List<Task>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> relationIdSet = new Set<Id>();
        Set<String> activityContactKeySet = new Set<String>();
        for (TaskRelationChangeEvent event : events) {
            String relId = (String)event.RelationId;
            if (relId != null && relId.startsWith('003')) {
            	contactIdSet.add(event.RelationId);
            activityContactKeySet.add((String)event.TaskId + (String)event.RelationId);
            }
        }
        Map<Id,Contact> contactMap = UtilActivity.getContactPrimaryTerritoryMap(contactIdSet);
        
        Map<String,ActivityContact__c> activityContactKeyMap = UtilActivity.getActivityContactKeyMap(activityContactKeySet);
        Map<Id,Channel__c> channelMap = Util.getChannelMap();
        
        List<ActivityContact__c> activityContactToUpsert = new List<ActivityContact__c>();
        List<ActivityContact__c> activityContactToDelete = new List<ActivityContact__c>();
        Set<Id> activityRelatedIdsForDelete = new Set<Id>();
        
        for (TaskRelationChangeEvent event : events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            System.debug('Received change event for ' + 
                         header.entityName +
                         ' for the ' + header.changeType + ' operation.'); 
            
            System.debug('Task Relation Changed Record Fields');
            if (event.TaskId != null) {
                System.debug('TaskId: ' + event.TaskId);
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
                        myAC.ActivityId__c = (String)event.TaskId;     
                        myAC.Contact__c = (String)event.RelationId;
                        if (activityContactKeyMap.containsKey((String)event.TaskId + (String)event.RelationId)) myAC = activityContactKeyMap.get((String)event.TaskId + (String)event.RelationId);
                        
                        Task myTask = new Task();
                        if (taskMap.containsKey(event.TaskId)) myTask = taskMap.get(event.TaskId);
                        
                        myAC = UtilActivity.activityContactTaskFieldPreset(myAC,myTask,contactMap,userMap,channelMap);
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
        delete activityContactToDelete;
        if (!activityContactToUpsert.isEmpty()) upsert activityContactToUpsert;
        
    }    
    
    private static Map<Id,Task> getTaskMapFromTaskChangeEvents(List<TaskRelationChangeEvent> events) {
        
        Set<Id> taskIdSet = new Set<Id>();
        
        for (TaskRelationChangeEvent event : events) {
            taskIdSet.add(event.TaskId);
        }
        
        Map<Id,Task> taskMap = new Map<Id,Task>([SELECT Id, Subject, ActivityDate, Type, TaskSubType, Status, ActivitySource__c,
                                                 OwnerChannel__c, OwnerChannelId__c, OwnerTerritory__c, OwnerTerritoryMARS__c,
                                                 OwnerTerritoryId__c, OwnerZoneFormula__c, Ownerid, WhatId, WhoId, Description,
                                                 ActivityType__c, ActivitySubType__c, ActivityPoints__c, RecordTypeId, WhoCount, WhatCount, 
                                                 Priority, IsHighPriority, AccountId, IsClosed, Firm__c, MARSOfficeId__c,
                                                 Campaign__c, Opportunity__c
                                                 FROM Task
                                                 WHERE Id IN :taskIdSet]);
        
        return taskMap;
        
    }        
    
}