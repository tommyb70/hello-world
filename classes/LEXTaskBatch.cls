global class LEXTaskBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    //confirm translation map
    //update activity points settings
    //ALWAYS send the where clause, or this will run for all tasks
    //Turn off validation rule for updating old tasks
    
    global String whereCriteria;
    
    global Database.querylocator start(Database.BatchableContext BC){   
	    String query = 'SELECT Id, ActivityType__c, Status, ActivitySubType__c, ProductList__c, ActivitySource__c FROM Task ' + whereCriteria;
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> scope) { 
        
        LEXConversionContext.runningConversion = TRUE;

        Map<String,String> typeSubTypeTranslation = new Map<String,String>();
        typeSubTypeTranslation.put('Call - Informative|null','Call|Product/Promotional');
        typeSubTypeTranslation.put('Call - Left Message|null','Call|Other/Voicemail');
        typeSubTypeTranslation.put('Call - Substantive|null','Call|Product/Promotional');
        typeSubTypeTranslation.put('Email - Contact|null','Email|Product/Promotional');
        typeSubTypeTranslation.put('Email - Contact|Email','Email|Email');        
        typeSubTypeTranslation.put('Meeting - Group|null','Meeting|Product/Promotional');
        typeSubTypeTranslation.put('Meeting - One on One|null','Meeting|Product/Promotional');
        typeSubTypeTranslation.put('High Impact|AIA','Call|Product/Promotional');
        typeSubTypeTranslation.put('High Impact|IDU/RADU Prospecting','Research|Research');
        typeSubTypeTranslation.put('High Impact|IDU/RADU Research','Research|Research');
        typeSubTypeTranslation.put('High Impact|ISG/CPM/DCG Call','Call|Product/Promotional');
        typeSubTypeTranslation.put('High Impact|PRCG - Comprehensive Portfolio Review','Call|Solutions');
        typeSubTypeTranslation.put('High Impact|Retirement/RSA Client Call','Call|Product/Promotional');
        typeSubTypeTranslation.put('High Impact|Sales Desk Focus','Call|Product/Promotional');
        typeSubTypeTranslation.put('High Impact|Sales Interaction','Call|Product/Promotional');
        typeSubTypeTranslation.put('High Impact|Sales Interaction Converted from Service','Call|Product/Promotional');
        typeSubTypeTranslation.put('High Impact|Sales Interaction Converted from Follow Up','Call|Product/Promotional');
        typeSubTypeTranslation.put('Servicing|Phone Servicing an Asset','Call|Follow-Up/Service');
        typeSubTypeTranslation.put('Servicing|Email Servicing an Asset','Email|Follow-Up/Service');
        typeSubTypeTranslation.put('Servicing|Call Scheduling Meetings for the field','Call|Follow-Up/Service');
        typeSubTypeTranslation.put('Servicing|Email Scheduling Meetings for the field','Email|Follow-Up/Service');
        typeSubTypeTranslation.put('Servicing|Gathering Territory/Client Intell','Research|Research');
        typeSubTypeTranslation.put('Servicing|Advisor Web Portal','Call|Follow-Up/Service');
        typeSubTypeTranslation.put('Follow Up|Phone Call Follow up','Call|Follow-Up/Service');
        typeSubTypeTranslation.put('Follow Up|Email Follow Up','Email|Follow-Up/Service');
        typeSubTypeTranslation.put('Follow Up|Territory Email Campaign','Email|Follow-Up/Service');
        typeSubTypeTranslation.put('Follow Up|CPE Pre Calls','Call|Follow-Up/Service');
        typeSubTypeTranslation.put('Follow Up|Natixis Resource Lead In or Follow Up','Call|Follow-Up/Service');
        typeSubTypeTranslation.put('Meeting|One-On-One','Meeting|Product/Promotional');
        typeSubTypeTranslation.put('Meeting|Group','Meeting|Product/Promotional');
        typeSubTypeTranslation.put('Left Message|Left Message','Call|Other/Voicemail');
        typeSubTypeTranslation.put('Email|Email','Email|Email');
        typeSubTypeTranslation.put('Seismic - Contact|Email Follow Up','Email|Follow-Up/Service');
        typeSubTypeTranslation.put('Seismic - Contact|Email Servicing an Asset','Email|Follow-Up/Service');
        typeSubTypeTranslation.put('Seismic LiveSend|Seismic LiveSend','Email|Marketing');

        typeSubTypeTranslation.put('Call - Informative|Email','Call|Product/Promotional');
        typeSubTypeTranslation.put('Call - Informative|Seismic LiveSend','Call|Product/Promotional');
        typeSubTypeTranslation.put('Call - Left Message|Phone Call Follow up','Call|Other/Voicemail');
        typeSubTypeTranslation.put('Meeting - Group|ISG/CPM/DCG Call','Meeting|Product/Promotional');
        typeSubTypeTranslation.put('Meeting - Group|Phone Servicing an Asset','Meeting|Follow-Up/Service');
        typeSubTypeTranslation.put('Seismic - Contact|Email','Email|Product/Promotional');
        typeSubTypeTranslation.put('Seismic - Contact|Seismic LiveSend','Email|Product/Promotional');
        typeSubTypeTranslation.put('Follow Up|Email','Email|Follow-Up/Service');
        typeSubTypeTranslation.put('Left Message|Phone Call Follow up','Call|Other/Voicemail');
        typeSubTypeTranslation.put('Email - Contact|Email Servicing an Asset','Email|Follow-Up/Service');        
        typeSubTypeTranslation.put('Email - Contact|Phone Call Follow up','Call|Follow-Up/Service');        
        typeSubTypeTranslation.put('Email - Contact|Email Follow Up','Follow-Up/Service');        
        typeSubTypeTranslation.put('Email - Contact|Seismic LiveSend','Email|Product/Promotional');        
        typeSubTypeTranslation.put('Call - Substantive|Email','Call|Product/Promotional');

        Map<Id,Task> taskMap = new Map<Id,Task>();
        for (Task t : scope) {
            taskMap.put(t.Id, t); 
        }
        
        Map<String,ActivityProduct__c> activityProductKeyMap = UtilActivity.getActivityProductKeyMap(taskMap);
        Map<Id,List<Id>> taskProductMap = new Map<Id,List<Id>>();
        
        for (ActivityProduct__c ap : activityProductKeyMap.values()) {
            
            if (taskProductMap.containsKey(ap.ActivityId__c)) {
                List<Id> tempList = taskProductMap.get(ap.ActivityId__c);
                tempList.add(ap.Product__c);
                taskProductMap.put(ap.ActivityId__c, tempList);
            } else {
                List<Id> tempList = new List<Id>();
                tempList.add(ap.Product__c);
                taskProductMap.put(ap.ActivityId__c, tempList);
            }
        }
        
        for (Task t : scope) {
//            String typeSubTypeOld = t.ActivitySubType__c == null ? t.ActivityType__c + '|' : t.ActivityType__c + '|' + t.ActivitySubType__c;
            String typeSubTypeOld = t.ActivityType__c + '|' + t.ActivitySubType__c;
            system.debug('old subtype: ' + typeSubTypeOld);
            
            if (typeSubTypeTranslation.containsKey(typeSubTypeOld)) {
                system.debug('found it');
                String typeSubTypeNew = typeSubTypeTranslation.get(typeSubTypeOld);
                t.ActivityType__c = typeSubTypeNew.substringBefore('|');
                t.ActivitySubType__c = typeSubTypeNew.substringAfter('|');
                t.Type = t.ActivityType__c;
            }
        }
        
        update scope;
        
        for (Task t : scope) {
            if (taskProductMap.containsKey(t.Id)) {
                List<Id> productIdList = taskProductMap.get(t.Id);
                t.ProductList__c = String.join(productIdList,';');
            }
        }

        update scope;
            
        Map<String,ActivityContact__c> acContactMap = UtilActivity.getActivityContactKeyMap(taskMap);
        Map<String,TaskRelation> taskRelMap = new Map<String,TaskRelation>();
        Set<String> acActivityIdSet = new Set<String>();
        Set<String> acContactIdSet = new Set<String>();
        List<TaskRelation> trToInsert = new List<TaskRelation>();
        List<ActivityContact__c> acToUpdate = new List<ActivityContact__c>();
        
        for (ActivityContact__c ac : acContactMap.values()) {
            acActivityIdSet.add(ac.ActivityId__c);
            acContactIdSet.add(ac.Contact__c);
        }
        
        for (TaskRelation tr :[SELECT Id, TaskId, RelationId
                               FROM TaskRelation
                               WHERE TaskId IN :acActivityIdSet
                               AND RelationId IN :acContactIdSet]) {
                                   taskRelMap.put((String)tr.TaskId + (String)tr.RelationId, tr);
                               }
        
        for (ActivityContact__c ac : acContactMap.values()) {
            if (ac.ActivityId__c.startsWith('00T')) {
                if(!taskRelMap.containsKey(ac.ActivityId__c+ac.Contact__c)) {
                    trToInsert.add(new TaskRelation(RelationId = ac.Contact__c, TaskId = ac.ActivityId__c, IsWhat = FALSE));
                }
            } 
            
        }  
        
        if (!trToInsert.isEmpty()) insert trToInsert;
        
        for (TaskRelation tr : [SELECT Id, TaskId, RelationId
                                FROM TaskRelation
                                WHERE TaskId IN :acActivityIdSet
                                AND RelationId IN :acContactIdSet]) {
                                    if (acContactMap.containsKey((String)tr.TaskId + (String)tr.RelationId)) {
                                        ActivityContact__c ac = acContactMap.get((String)tr.TaskId + (String)tr.RelationId);
                                        ac.ActivityRelationId__c = tr.Id;
                                        acToUpdate.add(ac);
                                    }
                                }
        
        if (!acToUpdate.isEmpty()) update acToUpdate;
        
        update scope;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}