public class TaskTriggerHandler {
    
    //public static Boolean runningLEXConversion = NGAMSettings__c.getValues('NGAM_ALL').RunningLEXConversion__c;
    public static Boolean runningLEXConversion = LEXConversionContext.runningConversion == null ? FALSE : LEXConversionContext.runningConversion;
    
    public static void taskFieldsPreset(List<Task> myTasks, Map<Id,Task> taskMap){
        
        if (runningLEXConversion != TRUE) {
        if (trigger.IsUpdate) myTasks = taskMap.values();
        
        Id pardotUserId;
        Map<Id,User> userMap = Util.getUserTerritoryMap();
        for (User u : userMap.values()) {
            if (u.Username.startsWith('pnatixis')) pardotUserId = u.Id;
        }
        
        Map<Id, ActivityContact__c> activityContactMap = new Map<Id, ActivityContact__c>();
        
        if (trigger.IsUpdate) activityContactMap = UtilActivity.getActivityContactMap(taskMap);
        
        Set<Id> contactIdSet = new Set<Id>();
        for (ActivityContact__c ac : activityContactMap.values()) {
            contactIdSet.add(ac.Contact__c);
        }
        
        Map<Id,Contact> contactMap = UtilActivity.getContactPrimaryTerritoryMap(contactIdSet);

        Map<Id, Product2> productMap = UtilActivity.getProductMapFromProductList(myTasks);
        system.debug('productMap: ' + productMap);

        system.debug('Number of Tasks coming in: ' + myTasks.size());
        
        for (Task eachTask : myTasks) {
            system.debug('-- Start new Task Iteration in TaskFieldsPreset');
            system.debug('---- Owner: ' + eachTask.OwnerId);
            system.debug('---- Subject: ' + eachTask.Subject);
            system.debug('---- Type: ' + eachTask.Type);
            system.debug('---- WhoId: ' + eachTask.WhoId);
            system.debug('---- WhatId: ' + eachTask.WhatId);
            system.debug('---- WhoCount: ' + eachTask.WhoCount);
            system.debug('---- Description: ' + eachTask.Description);
            
            eachTask = UtilActivity.setUserFields(eachTask, userMap);
            eachTask = UtilActivity.syncWhatIdToLookupFields(eachTask);
            eachTask.Status = eachTask.Status == null ? 'Completed' : eachTask.Status;
            eachTask.ActivityComments__c = String.isBlank(eachTask.Description) ? null : eachTask.Description.left(255).trim();
            eachTask.ActivityDateProxy__c = eachTask.ActivityDate;
            eachTask = UtilActivity.getTaskTypeSubtype(eachTask);
            system.debug('ProductList__c: ' + eachTask.ProductList__c);
            eachTask.Products__c = UtilActivity.convertProductListToProducts(eachTask.ProductList__c, productMap);
            
        }
        }

        myTasks = UtilActivity.setActivityPoints(myTasks);

    }
    
    /*    public static void updateTotalActivityPoints(List<Task> myTasks) {
List<Task> tasksToUpdateTotActPnts = UtilActivity.calculateTotalActivityPoints(myTasks);
update tasksToUpdateTotActPnts;
}*/
    
    public static void TaskTriggerBeforeUpdate(List<Task> myTasks, Map<Id,Task> taskMap){
        taskFieldsPreset(myTasks, taskMap);
    }
    
    public static void TaskTriggerBeforeInsert(List<Task> myTasks, Map<Id,Task> taskMap){
        taskFieldsPreset(myTasks, taskMap); 
    }    
    
    public static void syncActivityProducts(List<Task> myNewTasks, Map<Id,Task> myNewTaskMap, Map<Id,Task> myOldTaskMap) {
        
        if (!runningLEXConversion) {
        
        Map<Id, ActivityProduct__c> activityProductOldMap = new Map<Id, ActivityProduct__c>();
        if (trigger.isUpdate) activityProductOldMap = UtilActivity.getActivityProductMap(myNewTaskMap);
        Map<Id, ActivityContact__c> activityContactMap = UtilActivity.getActivityContactMap(myNewTaskMap);
        
        Map<String, ActivityProduct__c> activityProductOldStringMap = new Map<String, ActivityProduct__c>();
        Map<String, ActivityProduct__c> activityProductNewStringMap = new Map<String, ActivityProduct__c>();
        List<ActivityProduct__c> activityProductToDelete = new List<ActivityProduct__c>();
        Map<String, ActivityProduct__c> activityProductToUpsertStringMap = new Map<String, ActivityProduct__c>();
        Set<Id> activityProductToDeletebyTaskIdSet = new Set<Id>();
        
        for (ActivityProduct__c ap : activityProductOldMap.values()) {
            activityProductOldStringMap.put(ap.ActivityId__c + (String)ap.Product__c, ap);
        }
        
        for (Task t : myNewTasks) {
            
            if ((Trigger.isInsert && t.ProductList__c != null) ||
                (Trigger.isUnDelete && t.ProductList__c != null) ||
                (Trigger.isUpdate && t.ProductList__c != myOldTaskMap.get(t.Id).ProductList__c)) {
                    
                    List<String> products =new List<String>();
                    if (t.ProductList__c != null) {
                        
                        products = t.ProductList__c.split(';');
                        
                        for (String product : products) {
                            
                            ActivityProduct__c ap = new ActivityProduct__c();
                            
                            String activityProductString = (String)t.Id + product;
                            
                            if (activityProductOldStringMap.containsKey(activityProductString)) {
                                ap = activityProductOldStringMap.get(activityProductString);
                                ap.Product__c = product;
                                ap = UtilActivity.activityProductFieldPreset(ap,t);
                                activityProductToUpsertStringMap.put(activityProductString, ap);
                            } else {
                                ap.Product__c = product;
                                ap = UtilActivity.activityProductFieldPreset(ap,t);
                                activityProductToUpsertStringMap.put(activityProductString, ap);
                            }
                            
                        }
                        
                        for (String aps : activityProductOldStringMap.keySet()) {
                            
                            if (!activityProductToUpsertStringMap.containsKey(aps)) {
                                activityProductToDelete.add(activityProductOldStringMap.get(aps));
                            }
                            
                        }
                        
                        
                    } else {
                        
                        activityProductToDeletebyTaskIdSet.add(t.Id);
                        
                    }
                }
        }
        
        for (ActivityProduct__c ap : [SELECT Id from ActivityProduct__c WHERE ActivityId__c IN: activityProductToDeletebyTaskIdSet]) {
            activityProductToDelete.add(ap);
        }
        
        upsert activityProductToUpsertStringMap.values();
        delete activityProductToDelete;
        }
        
    }
    
    public static void syncActivityContacts(List<Task> myNewTasks, Map<Id,Task> myNewTaskMap, Map<Id,Task> myOldTaskMap) {
        
        Map<Id, ActivityContact__c> activityContactMap = UtilActivity.getActivityContactMap(myNewTaskMap);
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
        
        for (Task t : myNewTasks) {
            
            if (activityContactToUpdateMap.containsKey(t.Id)) {
                List<ActivityContact__c> acList = activityContactToUpdateMap.get(t.Id);
                
                for (ActivityContact__c ac : acList) {
                    if (ac.ActivityId__c.startsWith('00T')) ac = UtilActivity.activityContactTaskFieldPreset(ac, t);
                    activityContactToUpdate.add(ac);
                }
            }
        }
        
        update activityContactToUpdate;
        
    }    
    
    public static void TaskTriggerAfterDelete(Map<Id,Task> myOldTaskMap) {
        
        delete [SELECT Id from ActivityContact__c WHERE ActivityId__c IN :myOldTaskMap.keySet()];
        delete [SELECT Id from ActivityProduct__c WHERE ActivityId__c IN :myOldTaskMap.keySet()];
        
    }   
    
}