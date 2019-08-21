public class UtilActivity {
    
    // setTaskUserFields(Task, Map<Id,User>) 
    // 		takes a task and a map of user Id to Users and sets key fields based on OwnerId
    // setActivityProductFieldsFromTask(ActivityProduct__c, Map<Id,Task>) 
    // 		takes an activity product and a map of Task Ids to Task and sets key fields
    //   	on the ActivityProduct__c from its parent task
    // setActivityPoints(List<Task>) 
    // 		takes a list of Task and returns the list with activity points set
    // syncWhatIdToLookupFieldsOnTask(Task) 
    // 		takes a task and return the task with lookup Ids (such as opportunity__c) 
    
    public static Task setUserFields(Task t, Map<Id,User> userMap) {
        
        if (userMap.containsKey(t.OwnerId)) {
            t.OwnerChannel__c = userMap.get(t.OwnerId).ActivityChannelName__c;
            t.OwnerTerritoryMARS__c = userMap.get(t.OwnerId).ActivityTerritoryMARSName__c;
            t.OwnerTerritory__c = userMap.get(t.OwnerId).ActivityTerritoryName__c;
            t.OwnerTerritoryId__c = userMap.get(t.OwnerId).ActivityTerritoryId__c;
        }
        
        return t;
    }
    
    public static Map<Id,Product2> getProductMapFromProductList(List<Task> myTasks) {
        
        Set<Id> productIdSet = new Set<Id>();
        for (Task t : myTasks) {
            if (t.ProductList__c != null) {
                List<String> products =new List<String>();
                if (t.ProductList__c != null) {
                    products = t.ProductList__c.split(';');
                    for (String product : products) {
                        productIdSet.add(product);
                    }
                }
            }
        }
        
        Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Name 
                                                                      FROM Product2
                                                                      WHERE Id IN :productIdSet
                                                                      AND Name != null]);
        
        return productMap;
        
    }
    
    public static String convertProductListToProducts(String productList, Map<Id,Product2> productMap) {
        
        List<String> productNameList = new List<String>();
		String productNames;
        
        if (productList != null) {
            List<String> productIds = new List<String>();
            if (productList != null) {
                productIds = productList.split(';');
                for (String p : productIds) {
                    if (productMap.containsKey(p)) {
                        productNameList.add(productMap.get(p).Name);
                    }
                }
            }
        }
        
        productNames = String.join(productNameList,'; ');
        return productNames;
        
    }
    
    public static Event setUserFields(Event e, Map<Id,User> userMap) {
        
        if (userMap.containsKey(e.OwnerId)) {
            e.OwnerChannel__c = userMap.get(e.OwnerId).ActivityChannelName__c;
            e.OwnerTerritoryMARS__c = userMap.get(e.OwnerId).ActivityTerritoryMARSName__c;
            e.OwnerTerritory__c = userMap.get(e.OwnerId).ActivityTerritoryName__c;
            e.OwnerTerritoryId__c = userMap.get(e.OwnerId).ActivityTerritoryId__c;
        }
        
        return e;
    }    
    
    public static List<Task> setActivityPoints(List<Task> myTasks) {
        
        // Normally TestCase__c will be null; only calling from test class will make this value not null
        List<ActivityPointSetting__mdt> apSettings = new List<ActivityPointSetting__mdt>([SELECT ActivityType__c,ActivitySubType__c,ActivitySource__c, Points__c
                                                                                          FROM ActivityPointSetting__mdt
                                                                                          WHERE TestCase__c =:TestContext.testCase]);
        
        Map<String,Decimal> PointsTypeMap = new Map<String,Decimal>();
        Map<String,Decimal> PointsTypeSubTypeMap = new Map<String,Decimal>();
        Map<String,Decimal> PointsTypeSubTypeSourceMap = new Map<String,Decimal>();
        
        for (ActivityPointSetting__mdt aps : apSettings) {
            if (aps.ActivityType__c != null && aps.ActivitySubType__c != null && aps.ActivitySource__c != null){
                PointsTypeSubTypeSourceMap.put(aps.ActivityType__c + aps.ActivitySubType__c + aps.ActivitySource__c, aps.points__c);
            }
            if (aps.ActivityType__c != null && aps.ActivitySubType__c != null && aps.ActivitySource__c == null){
                PointsTypeSubTypeMap.put(aps.ActivityType__c + aps.ActivitySubType__c + aps.ActivitySource__c, aps.points__c);
            }
            if (aps.ActivityType__c != null && aps.ActivitySubType__c == null && aps.ActivitySource__c == null){
                PointsTypeMap.put(aps.ActivityType__c + aps.ActivitySubType__c + aps.ActivitySource__c, aps.points__c);
            }
        }
        
        for (Task t : myTasks) {        
            if (t.Status == 'Completed') {
            
            String PointLookUp = t.ActivityType__c + t.ActivitySubType__c + t.ActivitySource__c;
            if (PointsTypeSubTypeSourceMap.containsKey(PointLookUp)) {
                t.ActivityPoints__c = PointsTypeSubTypeSourceMap.get(PointLookUp);
            } else {
                PointLookUp = t.ActivityType__c + t.ActivitySubType__c+'null';
                if (PointsTypeSubTypeMap.containsKey(PointLookUp)) {
                    t.ActivityPoints__c = PointsTypeSubTypeMap.get(PointLookUp);
                } else {
                    PointLookUp = t.ActivityType__c+'null'+'null';
                    if (PointsTypeMap.containsKey(PointLookUp)) {
                        t.ActivityPoints__c = PointsTypeMap.get(PointLookUp);
                    } else {
                        t.ActivityPoints__c = 0;
                    }
                }
                
            }
            }
        }
        
        return myTasks;
        
    }



    
    public static List<Event> setActivityPoints(List<Event> myEvents) {
        
        // Normally TestCase__c will be null; only calling from test class will make this value not null
        List<ActivityPointSetting__mdt> apSettings = new List<ActivityPointSetting__mdt>([SELECT ActivityType__c,ActivitySubType__c,ActivitySource__c, Points__c
                                                                                          FROM ActivityPointSetting__mdt
                                                                                          WHERE TestCase__c =:TestContext.testCase]);
        
        Map<String,Decimal> PointsTypeMap = new Map<String,Decimal>();
        Map<String,Decimal> PointsTypeSubTypeMap = new Map<String,Decimal>();
        Map<String,Decimal> PointsTypeSubTypeSourceMap = new Map<String,Decimal>();
        
        for (ActivityPointSetting__mdt aps : apSettings) {
            if (aps.ActivityType__c != null && aps.ActivitySubType__c != null && aps.ActivitySource__c != null){
                PointsTypeSubTypeSourceMap.put(aps.ActivityType__c + aps.ActivitySubType__c + aps.ActivitySource__c, aps.points__c);
            }
            if (aps.ActivityType__c != null && aps.ActivitySubType__c != null && aps.ActivitySource__c == null){
                PointsTypeSubTypeMap.put(aps.ActivityType__c + aps.ActivitySubType__c + aps.ActivitySource__c, aps.points__c);
            }
            if (aps.ActivityType__c != null && aps.ActivitySubType__c == null && aps.ActivitySource__c == null){
                PointsTypeMap.put(aps.ActivityType__c + aps.ActivitySubType__c + aps.ActivitySource__c, aps.points__c);
            }
        }
        
        for (Event e : myEvents) {        
            String PointLookUp = e.ActivityType__c + e.ActivitySubType__c + e.ActivitySource__c;
            if (PointsTypeSubTypeSourceMap.containsKey(PointLookUp)) {
                e.ActivityPoints__c = PointsTypeSubTypeSourceMap.get(PointLookUp);
            } else {
                PointLookUp = e.ActivityType__c + e.ActivitySubType__c+'null';
                if (PointsTypeSubTypeMap.containsKey(PointLookUp)) {
                    e.ActivityPoints__c = PointsTypeSubTypeMap.get(PointLookUp);
                } else {
                    PointLookUp = e.ActivityType__c+'null'+'null';
                    if (PointsTypeMap.containsKey(PointLookUp)) {
                        e.ActivityPoints__c = PointsTypeMap.get(PointLookUp);
                    } else {
                        e.ActivityPoints__c = 0;
                    }
                }
                
                
            }  
            
            
        }
        
        return myEvents;
        
    }   
    
    public static Map<Id,Task> getTaskMapFromTaskList(List<Task> tasks) {
        
        Map<Id,Task> taskMap = new Map<Id,Task>();
        
        for (Task t : tasks) {
            taskMap.put(t.Id, t);
        }
        
        return taskMap;
        
    }
    
    public static Map<Id,Event> getEventMapFromEventList(List<Event> events) {
        
        Map<Id,Event> eventMap = new Map<Id,Event>();
        
        for (Event e : events) {
            eventMap.put(e.Id, e);
        }
        
        return eventMap;
        
    }
    
    public static Task getTaskTypeSubtype(Task t) {
        
        t.ActivityType__c = t.ActivityType__c == null ? t.Type : t.ActivityType__c;
        
        if (!String.isBlank(t.Subject) && t.Subject.contains('sent via LiveSend') ||
            (!String.isBlank(t.Description) && t.Description.contains('natixisus') 
             && t.Description.countMatches('FROM:') <= 1)) {
                 t.Type = 'Email';
                 t.ActivityType__c = 'Email';
                 t.ActivitySubType__c = 'Marketing';
             }
        
        t.ActivitySubType__c = (t.ActivitySubType__c == null && t.Type == 'Email') ? 'Email' : t.ActivitySubType__c;
        
        return t;
    }
    
    
    
    public static Task syncWhatIdToLookupFields(Task t) {
        
        if (t.WhatId != null) {
            String WhatIdString = (String)t.WhatId;
            SWITCH ON WhatIdString.left(3) {
                WHEN '500' {
                    t.Case__c = t.WhatId ;
                    t.Opportunity__c = null;
                    t.Campaign__c = null;
                }
                WHEN '701' {
                    t.Campaign__c = t.WhatId ;
                    t.Case__c = null;
                    t.Opportunity__c = null;
                }
                WHEN '006' {
                    t.Opportunity__c = t.WhatId ;
                    t.Case__c = null ;
                    t.Campaign__c = null;
                }                
            }
            
        }      
        
        return t;
        
    }
    
    public static Event syncWhatIdToLookupFields(Event e) {
        
        if (e.WhatId != null) {
            String WhatIdString = (String)e.WhatId;
            SWITCH ON WhatIdString.left(3) {
                WHEN '500' {
                    e.Case__c = e.WhatId ;
                    e.Opportunity__c = null;
                    e.Campaign__c = null;
                }
                WHEN '701' {
                    e.Campaign__c = e.WhatId ;
                    e.Case__c = null;
                    e.Opportunity__c = null;
                }
                WHEN '006' {
                    e.Opportunity__c = e.WhatId ;
                    e.Case__c = null ;
                    e.Campaign__c = null;
                }                
            }
            
        }      
        
        return e;
        
    }    
    
    public static List<ActivityContact__c> getActivityContactsByRelatedIds(Set<Id> relatedIds) {
        
        List<ActivityContact__c> activityContactRelatedIdsList = [SELECT Id, ActivityRelationId__c
                                                                  FROM ActivityContact__c
                                                                  WHERE ActivityRelationId__c IN :relatedIds];
        
        return activityContactRelatedIdsList;
        
    }     
    
    
    public static List<ActivityProduct__c> getActivityProductsByRelatedIds(Set<Id> relatedIds) {
        
        List<ActivityProduct__c> activityProductRelatedIdsList = [SELECT Id, ActivityRelationId__c
                                                                  FROM ActivityProduct__c
                                                                  WHERE ActivityRelationId__c IN :relatedIds];
        
        return activityProductRelatedIdsList;
        
    }        
    
    public static Map<String,ActivityContact__c> getActivityContactKeyMap(Map<Id,Task> taskMap) {
        
        Map<String,ActivityContact__c> activityContactKeyMap = new Map<String,ActivityContact__c>();
        
        for (ActivityContact__c ac : [SELECT Id, Subject__c, Type__c, Status__c, ActivitySource__c, Date__c, ActivityContact__c, ActivityId__c, Contact__c,
                                      OwnerChannel__c, OwnerTerritory__c, OwnerTerritoryId__c, OwnerTerritoryMARS__c,
                                      OwnerZone__c, OwnerId
                                      FROM ActivityContact__c
                                      WHERE ActivityId__c IN :taskMap.keySet()]) {
                                          activityContactKeyMap.put(ac.ActivityContact__c,ac);
                                      }
        
        return activityContactKeyMap;
        
    }    
    
    public static Map<Id,ActivityContact__c> getActivityContactMap(Map<Id,Task> taskMap) {
        
        Map<Id,ActivityContact__c> activityContactMap = new Map<Id,ActivityContact__c>([SELECT Id, Subject__c, Type__c, Status__c, ActivitySource__c, Date__c, ActivityContact__c, 
                                                                                        ActivityId__c, Contact__c, OwnerChannel__c, OwnerTerritory__c, OwnerTerritoryId__c, 
                                                                                        OwnerTerritoryMARS__c, OwnerZone__c, OwnerId
                                                                                        FROM ActivityContact__c
                                                                                        WHERE ActivityId__c IN :taskMap.keySet()]);
        
        return activityContactMap;
        
    }    
    
    public static Map<Id,ActivityContact__c> getActivityContactMap(Map<Id,Event> eventMap) {
        
        Map<Id,ActivityContact__c> activityContactMap = new Map<Id,ActivityContact__c>([SELECT Id, Subject__c, Type__c, Status__c, ActivitySource__c, Date__c, ActivityContact__c, 
                                                                                        ActivityId__c, Contact__c, OwnerChannel__c, OwnerTerritory__c, OwnerTerritoryId__c, 
                                                                                        OwnerTerritoryMARS__c, OwnerZone__c, OwnerId
                                                                                        FROM ActivityContact__c
                                                                                        WHERE ActivityId__c IN :eventMap.keySet()]);
        
        return activityContactMap;
        
    }       
    
    public static Map<Id,ActivityProduct__c> getActivityProductMap(Map<Id,Task> taskMap) {  
        
        Set<Id> productIdSet = new Set<Id>();
        
        for (Task t : taskMap.values()) {        
            if (t.ProductList__c != null) {
                for (String p : t.ProductList__c.split(';')) {
                    productIdSet.add((Id)p);
                }
            }
        }
        
        Map<Id, ActivityProduct__c> activityProductMap = new Map<Id,ActivityProduct__c>([SELECT Id, ActivityId__c, Product__c, Date__c,
                                                                                         Subject__c, Type__c, Status__c, ActivitySource__c,
                                                                                         OwnerChannel__c, OwnerTerritory__c, OwnerTerritoryId__c, OwnerTerritoryMARS__c,
                                                                                         OwnerZone__c, OwnerId
                                                                                         FROM ActivityProduct__c
                                                                                         WHERE ActivityId__c IN :taskMap.keySet()
                                                                                         AND Product__c IN :productIdSet]);
        
        return activityProductMap;
    }
    
    public static Map<String,ActivityProduct__c> getActivityProductKeyMap(Map<Id,Task> taskMap) {  
        
        Map<String,ActivityProduct__c> activityProductKeyMap = new Map<String,ActivityProduct__c>();
        
        for (ActivityProduct__c ap : [SELECT Id, ActivityId__c, Product__c, Date__c,
                                      Subject__c, Type__c, Status__c, ActivitySource__c,
                                      OwnerChannel__c, OwnerTerritory__c, OwnerTerritoryId__c, OwnerTerritoryMARS__c,
                                      OwnerZone__c, OwnerId
                                      FROM ActivityProduct__c
                                      WHERE ActivityId__c IN :taskMap.keySet()]) {
                                          activityProductKeyMap.put(ap.ActivityId__c + '|' + (String)ap.Product__c, ap);
                                      }
        
        
        return activityProductKeyMap;
    }  
    
    public static Map<Id,Contact> getContactPrimaryTerritoryMap(Set<Id> contactIdSet) {
        
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, BPL__c, PrimaryTerritory__c, PrimaryRegion__c,
                                                          PrimaryRegionName__c, PrimaryTerritoryName__c, PROTierIAG__c, PROZoneIAG__c,
                                                          PRORotationIAG__c, FocusFirmIAG__c, AccountId
                                                          FROM Contact
                                                          WHERE Id IN :contactIdSet]);        
        
        return contactMap;
        
    }    
    
    public static Map<String,ActivityContact__c> getActivityContactKeyMap(Set<String> activityContactKeySet) {
        
        Map<String,ActivityContact__c> activityContactKeyMap = new Map<String,ActivityContact__c>();
        
        for (ActivityContact__c ac : [SELECT Id, AccountId__c, Account__c, ActivityContact__c, ActivityId__c, ActivitySource__c, 
                                      Contact__c, Count__c, Date__c, OwnerChannelId__c, OwnerChannel__c, OwnerTerritory__c, 
                                      OwnerOwner__c, Primary__c, RepBPL__c, RepTier__c, Firm__c, Status__c, Subject__c, 
                                      Type__c, SubjectURL__c, Current_Owner_Channel__c, ChannelFocusFirm__c, Channel__c, 
                                      OwnerReportingTo__c, OwnerZone__c, RepZone__c, TypeGroup__c, ActivityComments__c, 
                                      ActivityProducts__c, Campaign__c, Opportunity__c, RepContactName__c, OwnerId__c, 
                                      OwnerCurrentTerritory__c, OwnerCurrentZoneId__c, RepCurrentBPLStatus__c, 
                                      ActivityPoints__c, ActivitySubType__c, ActivityType__c, Case__c, RepRegion__c, 
                                      RepTerritory__c, RepMARSRegion__c, RepMARSTerritory__c, Contact_Firm_Type__c, 
                                      MARS_Rep_ID__c, MARS_Office_ID__c, AffiliateContactFlag__c, OwnerTerritoryId__c, 
                                      OwnerTerritoryMARS__c, WhatId__c, WhatIdObjectAPIName__c, WhatIdObjectLabel__c, ActivityRelationId__c
                                      FROM ActivityContact__c
                                      WHERE ActivityContact__c IN :activityContactKeySet]) {
                                          activityContactKeyMap.put(ac.ActivityContact__c, ac);
                                      }        
        
        return activityContactKeyMap;
        
    }    
    
    public static ActivityContact__c activityContactTaskFieldPreset(ActivityContact__c myAC, Task myTask) {
        
        myAC.WhatId__c = myTask.WhatId;
        myAC.WhatIdObjectAPIName__c = myAc.WhatId__c != null ? myTask.WhatId.getSObjectType().getDescribe().getName() : null;
        myAC.WhatIdObjectLabel__c = myAc.WhatId__c != null ? myTask.WhatId.getSObjectType().getDescribe().getLabel() : null;
        myAC.ActivityId__c = myTask.Id;
        myAC.Date__c = myTask.ActivityDate;
        myAC.Subject__c = myTask.Subject;
        myAC.Type__c = myTask.Type;
        myAC.ActivityType__c = myTask.ActivityType__c;
        myAC.ActivitySubType__c = myTask.ActivitySubType__c;
        myAC.ActivityPoints__c = myTask.ActivityPoints__c;
        myAC.Status__c = myTask.Status;
        myAC.ActivitySource__c = myTask.ActivitySource__c; 
        myAC.Campaign__c = myTask.Campaign__c; 
        myAC.Opportunity__c = myTask.Opportunity__c; 
        myAC.OwnerChannel__c = myTask.OwnerChannel__c;
        myAC.Channel__c = myTask.OwnerChannelId__c;
        myAC.OwnerTerritory__c = myTask.OwnerTerritory__c;
        myAC.OwnerTerritoryMARS__c = myTask.OwnerTerritoryMARS__c;
        myAC.OwnerTerritoryId__c = myTask.OwnerTerritoryId__c;
        myAC.OwnerZone__c = (id)myTask.OwnerZoneFormula__c; 
		myAC.ActivityComments__c = myTask.Description != null ? myTask.Description.left(254) : null;        
        myAC.OwnerId = myTask.ownerid;                       
        
        return myAC;
        
    } 
    
    public static ActivityContact__c activityContactTaskFieldPreset(ActivityContact__c myAC, Task myTask, Map<Id,Contact> contactMap, Map<Id,User> userMap, Map<Id,Channel__c> channelMap) {
        
        myAC.WhatId__c = myTask.WhatId;
        myAC.WhatIdObjectAPIName__c = myAc.WhatId__c != null ? myTask.WhatId.getSObjectType().getDescribe().getName() : null;
        myAC.WhatIdObjectLabel__c = myAc.WhatId__c != null ? myTask.WhatId.getSObjectType().getDescribe().getLabel() : null;
        myAC.Date__c = myTask.ActivityDate;
        myAC.Subject__c = myTask.Subject;
        myAC.Type__c = myTask.Type;
        myAC.ActivityType__c = myTask.ActivityType__c;
        myAC.ActivitySubType__c = myTask.ActivitySubType__c;
        myAC.ActivityPoints__c = myTask.ActivityPoints__c;
        myAC.Status__c = myTask.Status;
        myAC.ActivitySource__c = myTask.ActivitySource__c; 
        myAC.Campaign__c = myTask.Campaign__c; 
        myAC.Opportunity__c = myTask.Opportunity__c; 
        myAC.OwnerChannel__c = myTask.OwnerChannel__c;
        myAC.Channel__c = myTask.OwnerChannelId__c;
        myAC.OwnerTerritory__c = myTask.OwnerTerritory__c;
        myAC.OwnerTerritoryMARS__c = myTask.OwnerTerritoryMARS__c;
        myAC.OwnerTerritoryId__c = myTask.OwnerTerritoryId__c;
        myAC.OwnerZone__c = (id)myTask.OwnerZoneFormula__c; 
        myAC.OwnerId = myTask.Ownerid;
        myAC.Account__c = ContactMap.get(myAC.Contact__c).AccountId;
        myAC.ActivityComments__c = myTask.Description != null ? myTask.Description.left(254) : null;
        
        return myAC;
        
    } 
    
    public static ActivityContact__c activityContactEventFieldPreset(ActivityContact__c myAC, Event myEvent) {
        
        myAC.WhatId__c = myEvent.WhatId;
        myAC.WhatIdObjectAPIName__c = myAC.WhatId__c != null ? myEvent.WhatId.getSObjectType().getDescribe().getName() : null;
        myAC.WhatIdObjectLabel__c = myAc.WhatId__c != null ? myEvent.WhatId.getSObjectType().getDescribe().getLabel() : null;
        myAC.ActivityId__c = myEvent.Id;
        myAC.Date__c = myEvent.ActivityDate;
        myAC.Subject__c = myEvent.Subject;
        myAC.Type__c = myEvent.Type;
        myAC.ActivityType__c = myEvent.ActivityType__c;
        myAC.ActivitySubType__c = myEvent.ActivitySubType__c;
        myAC.ActivityPoints__c = myEvent.ActivityPoints__c;
        myAC.ActivitySource__c = myEvent.ActivitySource__c; 
        myAC.Campaign__c = myEvent.Campaign__c; 
        myAC.Opportunity__c = myEvent.Opportunity__c; 
        myAC.OwnerChannel__c = myEvent.OwnerChannel__c;
        myAC.Channel__c = myEvent.OwnerChannelId__c;
        myAC.OwnerTerritory__c = myEvent.OwnerTerritory__c;
        myAC.OwnerTerritoryMARS__c = myEvent.OwnerTerritoryMARS__c;
        myAC.OwnerTerritoryId__c = myEvent.OwnerTerritoryId__c;
        myAC.OwnerZone__c = (id)myEvent.OwnerZoneFormula__c; 
        myAC.OwnerId = myEvent.ownerid;   
        myAC.ActivityComments__c = myEvent.Description != null ? myEvent.Description.left(254) : null;        
        myAC.IsEvent__c = TRUE;
        
        return myAC;
        
    } 
    
    public static ActivityContact__c activityContactEventFieldPreset(ActivityContact__c myAC, Event myEvent, Map<Id,Contact> contactMap, Map<Id,User> userMap, Map<Id,Channel__c> channelMap) {
        
        myAC.WhatId__c = myEvent.WhatId;
        myAC.WhatIdObjectAPIName__c = myAc.WhatId__c != null ? myEvent.WhatId.getSObjectType().getDescribe().getName() : null;
        myAC.WhatIdObjectLabel__c = myAc.WhatId__c != null ? myEvent.WhatId.getSObjectType().getDescribe().getLabel() : null;
        myAC.Date__c = myEvent.ActivityDate;
        myAC.Subject__c = myEvent.Subject;
        myAC.Type__c = myEvent.Type;
        myAC.ActivityType__c = myEvent.ActivityType__c;
        myAC.ActivitySubType__c = myEvent.ActivitySubType__c;
        myAC.ActivityPoints__c = myEvent.ActivityPoints__c;
        myAC.ActivitySource__c = myEvent.ActivitySource__c; 
        myAC.Campaign__c = myEvent.Campaign__c; 
        myAC.Opportunity__c = myEvent.Opportunity__c; 
        myAC.OwnerChannel__c = myEvent.OwnerChannel__c;
        myAC.Channel__c = myEvent.OwnerChannelId__c;
        myAC.OwnerTerritory__c = myEvent.OwnerTerritory__c;
        myAC.OwnerTerritoryMARS__c = myEvent.OwnerTerritoryMARS__c;
        myAC.OwnerTerritoryId__c = myEvent.OwnerTerritoryId__c;
        myAC.OwnerZone__c = (id)myEvent.OwnerZoneFormula__c; 
        myAC.OwnerId = myEvent.ownerid;   
        myAC.Account__c = ContactMap.get(myAC.Contact__c).AccountId;
        myAC.ActivityComments__c = myEvent.Description != null ? myEvent.Description.left(254) : null;
        myAC.IsEvent__c = TRUE;
        
        return myAC;
        
    }     
    public static ActivityProduct__c activityProductFieldPreset(ActivityProduct__c ap, Task myTask) {
        
        ap.WhatId__c = myTask.WhatId;
        ap.WhatIdObjectAPIName__c = ap.WhatId__c != null ? myTask.WhatId.getSObjectType().getDescribe().getName() : null;
        ap.WhatIdObjectLabel__c = ap.WhatId__c != null ? myTask.WhatId.getSObjectType().getDescribe().getLabel() : null;
        ap.Date__c = myTask.ActivityDate;
        ap.ActivityId__c = myTask.Id;
        ap.Subject__c = myTask.Subject;
        ap.Type__c = myTask.Type;
        ap.ActivityType__c = myTask.ActivityType__c;
        ap.ActivitySubType__c = myTask.ActivitySubType__c;
        ap.Status__c = myTask.Status;
        ap.ActivitySource__c = myTask.ActivitySource__c; 
        ap.Campaign__c = myTask.Campaign__c; 
        ap.Opportunity__c = myTask.Opportunity__c; 
        ap.OwnerChannel__c = myTask.OwnerChannel__c;
        ap.Channel__c = myTask.OwnerChannelId__c;
        ap.OwnerTerritory__c = myTask.OwnerTerritory__c;
        ap.OwnerTerritoryMARS__c = myTask.OwnerTerritoryMARS__c;
        ap.OwnerTerritoryId__c = myTask.OwnerTerritoryId__c;
        ap.OwnerZone__c = (id)myTask.OwnerZoneFormula__c; 
        ap.OwnerId = myTask.ownerid;
        ap.ActivityComments__c = myTask.description != null ? myTask.description.left(254) : null;
        
        return ap;
        
    } 
    
    public static ActivityProduct__c activityProductFieldPreset(ActivityProduct__c ap, Task myTask, Map<Id,Contact> contactMap, Map<Id,User> userMap, Map<Id,Channel__c> channelMap) {
        
        ap.WhatId__c = myTask.WhatId;
        ap.WhatIdObjectAPIName__c = ap.WhatId__c != null ? myTask.WhatId.getSObjectType().getDescribe().getName() : null;
        ap.WhatIdObjectLabel__c = ap.WhatId__c != null ? myTask.WhatId.getSObjectType().getDescribe().getLabel() : null;
        ap.ActivityId__c = myTask.Id;
        ap.Date__c = myTask.ActivityDate;
        ap.Subject__c = myTask.Subject;
        ap.Type__c = myTask.Type;
        ap.ActivityType__c = myTask.ActivityType__c;
        ap.ActivitySubType__c = myTask.ActivitySubType__c;
        ap.Status__c = myTask.Status;
        ap.ActivitySource__c = myTask.ActivitySource__c; 
        ap.Campaign__c = myTask.Campaign__c; 
        ap.Opportunity__c = myTask.Opportunity__c; 
        ap.OwnerChannel__c = myTask.OwnerChannel__c;
        ap.Channel__c = myTask.OwnerChannelId__c;
        ap.OwnerTerritory__c = myTask.OwnerTerritory__c;
        ap.OwnerTerritoryMARS__c = myTask.OwnerTerritoryMARS__c;
        ap.OwnerTerritoryId__c = myTask.OwnerTerritoryId__c;
        ap.OwnerZone__c = (id)myTask.OwnerZoneFormula__c; 
        ap.OwnerId = myTask.ownerid;    
        ap.ActivityComments__c = myTask.description != null ? myTask.description.left(254) : null;
        
        return ap;
        
    }     
    
    
    
}