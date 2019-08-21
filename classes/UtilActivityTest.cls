@isTest
private class UtilActivityTest {
    
    @testSetup static void setup() {
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c,ProfileSales__c from NGAMSettings__c limit 1]; 
    }
    
    @isTest static void testSetTaskUserFields() {
        
        Map<Id,User> userMap = Util.getUserTerritoryMap();
        Id userIdToCheck;
        String activityTerritoryNameToCheck;
        
        for (User u : userMap.values()) {
            if (u.ActivityTerritoryName__c != null) {
                userIdToCheck = u.Id;
                activityTerritoryNameToCheck = u.ActivityTerritoryName__c;
                break;
            }
        }
        
        Task t = new Task(OwnerId = userIdToCheck);
        t = UtilActivity.setUserFields(t, userMap);
        system.assertEquals(t.OwnerTerritory__c, activityTerritoryNameToCheck, 'setUserFields(task,Map<Id,User>) did not return the right values');

        Event e = new Event(OwnerId = userIdToCheck);
        e = UtilActivity.setUserFields(e, userMap);
        system.assertEquals(e.OwnerTerritory__c, activityTerritoryNameToCheck, 'setUserFields(event,Map<Id,User>) did not return the right values');

    }
    
    @isTest static void testSetActivityPoints() {
        
        TestContext.testCase = 'YES';
        
        List<Task> myTasks = new List<Task>();
        myTasks.add(new Task());
        myTasks.add(new Task(ActivityType__c='Follow Up'));
        myTasks.add(new Task(ActivityType__c='Follow Up',ActivitySubType__c='Phone Call Follow up'));
        myTasks.add(new Task(ActivityType__c='Follow Up',ActivitySubType__c='Email Follow Up',ActivitySource__c='Process CPE'));
        
        myTasks = UtilActivity.setActivityPoints(myTasks);
               
        system.assertEquals(myTasks[0].ActivityPoints__c,0,'Task activity points for no categories calculated incorrectly');
        system.assertEquals(myTasks[1].ActivityPoints__c,2,'Task activity points for one category calculated incorrectly');
        system.assertEquals(myTasks[2].ActivityPoints__c,1,'Task activity points for two categories calculated incorrectly');
        system.assertEquals(myTasks[3].ActivityPoints__c,0,'Task activity points for all categories calculated incorrectly');
        
        List<Event> myEvents = new List<Event>();
        myEvents.add(new Event());
        myEvents.add(new Event(ActivityType__c='Follow Up'));
        myEvents.add(new Event(ActivityType__c='Follow Up',ActivitySubType__c='Phone Call Follow up'));
        myEvents.add(new Event(ActivityType__c='Follow Up',ActivitySubType__c='Email Follow Up',ActivitySource__c='Process CPE'));
        
        myEvents = UtilActivity.setActivityPoints(myEvents);
               
        TestContext.testCase = '';
        
        system.assertEquals(myEvents[0].ActivityPoints__c,0,'Event activity points for no categories calculated incorrectly');
        system.assertEquals(myEvents[1].ActivityPoints__c,2,'Event activity points for one category calculated incorrectly');
        system.assertEquals(myEvents[2].ActivityPoints__c,1,'Event activity points for two categories calculated incorrectly');
        system.assertEquals(myEvents[3].ActivityPoints__c,0,'Event activity points for all categories calculated incorrectly');        
        
    }    
    
    @isTest static void testsyncWhatIdToLookupFields() {
        
        List<Campaign> myCampaigns = DataFactory.createCampaigns(1);
        insert myCampaigns;

        List<Account> myAccounts = DataFactory.createTestFirms(1);
        insert myAccounts;
        
		List<Case> myCases = DataFactory.createCases(1, myAccounts);
        insert myCases;

		List<Opportunity> myOpptys = DataFactory.createOpportunities(1, myAccounts);
        insert myOpptys;
        
        Task t = new Task();
        t.WhatId = myCampaigns[0].Id;
        t = UtilActivity.syncWhatIdToLookupFields(t);
        system.assertEquals(t.Campaign__c, myCampaigns[0].Id, 'Task Campaign__c did not sync with Campaign WhatId correctly');
        system.assertEquals(t.Opportunity__c, null, 'Task Opportunity__c did not sync with Campaign WhatId correctly');
        system.assertEquals(t.Case__c, null, 'Task Case__c did not sync with Campaign WhatId correctly');

        t.WhatId = myOpptys[0].Id;
        t = UtilActivity.syncWhatIdToLookupFields(t);
        system.assertEquals(t.Campaign__c, null, 'Task Campaign__c did not sync with Opportunity WhatId correctly');
        system.assertEquals(t.Opportunity__c, myOpptys[0].Id, 'Task Opportunity__c did not sync with Opportunity WhatId correctly');
        system.assertEquals(t.Case__c, null, 'Task Case__c did not sync with Opportunity WhatId correctly');
        
        t.WhatId = myCases[0].Id;
        t = UtilActivity.syncWhatIdToLookupFields(t);
        system.assertEquals(t.Campaign__c, null, 'Task Campaign__c did not sync with Case WhatId correctly');
        system.assertEquals(t.Opportunity__c, null, 'Task Opportunity__c did not sync with Case WhatId correctly');
        system.assertEquals(t.Case__c, myCases[0].Id, 'Task Case__c did not sync with Case WhatId correctly');        
        
        Event e = new Event();
        e.WhatId = myCampaigns[0].Id;
        e = UtilActivity.syncWhatIdToLookupFields(e);
        system.assertEquals(e.Campaign__c, myCampaigns[0].Id, 'Event Campaign__c did not sync with Campaign WhatId correctly');
        system.assertEquals(e.Opportunity__c, null, 'Event Opportunity__c did not sync with Campaign WhatId correctly');
        system.assertEquals(e.Case__c, null, 'Event Case__c did not sync with Campaign WhatId correctly');

        e.WhatId = myOpptys[0].Id;
        e = UtilActivity.syncWhatIdToLookupFields(e);
        system.assertEquals(e.Campaign__c, null, 'Event Campaign__c did not sync with Opportunity WhatId correctly');
        system.assertEquals(e.Opportunity__c, myOpptys[0].Id, 'Event Opportunity__c did not sync with Opportunity WhatId correctly');
        system.assertEquals(e.Case__c, null, 'Event Case__c did not sync with Opportunity WhatId correctly');
        
        e.WhatId = myCases[0].Id;
        e = UtilActivity.syncWhatIdToLookupFields(e);
        system.assertEquals(e.Campaign__c, null, 'Event Campaign__c did not sync with Case WhatId correctly');
        system.assertEquals(e.Opportunity__c, null, 'Event Opportunity__c did not sync with Case WhatId correctly');
        system.assertEquals(e.Case__c, myCases[0].Id, 'Event Case__c did not sync with Case WhatId correctly');                
        
    }
    
    @isTest static void testGetActivityContactsByRelatedIds() {
       
        Set<Id> relatedIdSet = new Set<Id>();
        
        List<ActivityContact__c> ACs = UtilActivity.getActivityContactsByRelatedIds(relatedIdSet);
        
    }

    @isTest static void testGetActivityProductsByRelatedIds() {

        Set<Id> relatedIdSet = new Set<Id>();
        
        List<ActivityProduct__c> APs = UtilActivity.getActivityProductsByRelatedIds(relatedIdSet);

    }

    @isTest static void testGetActivityContactMap() {

        Map<Id,Task> taskMap = new Map<Id,Task>();
        Map<Id,ActivityContact__c> taskActivityContactMap = UtilActivity.getActivityContactMap(taskMap);

        Map<Id,Event> eventMap = new Map<Id,Event>();
        Map<Id,ActivityContact__c> eventActivityContactMap = UtilActivity.getActivityContactMap(eventMap);        
    }

    @isTest static void testGetActivityProductMap() {

        Map<Id,Task> taskMap = new Map<Id,Task>();
        Map<Id,ActivityProduct__c> taskActivityProductMap = UtilActivity.getActivityProductMap(taskMap);        

    }

    @isTest static void testGetActivityProductKeyMap() {

        Map<Id,Task> taskMap = new Map<Id,Task>();
        Map<String,ActivityProduct__c> taskActivityProductKeyMap = UtilActivity.getActivityProductKeyMap(taskMap);        
        
    }
    
    @isTest static void testGetContactPrimaryTerritoryMap() {

        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,Contact> contactPrimaryTerritoryMap = UtilActivity.getContactPrimaryTerritoryMap(contactIdSet);
        
    }
    
    @isTest static void testGetActivityContactKeyMap() {

        Map<Id,Task> taskMap = new Map<Id,Task>();
        Map<String,ActivityContact__c> activityContactKeyMap = UtilActivity.getActivityContactKeyMap(taskMap);

        Set<String> myActivityContactKeySet = new Set<String>();
        Map<String,ActivityContact__c> activityContactKeySetMap = UtilActivity.getActivityContactKeyMap(myActivityContactKeySet);
        
    }    

    @isTest static void testActivityContactTaskFieldPreset() {
        
        ActivityContact__c myAC = new ActivityContact__c();
        Task myTask = new Task();

        Double rand = Math.random() * 1000;
        Account acc = new Account();
            acc.Name = 'test' + rand;
            acc.PotentialScore__c = '1';
            acc.RiskScore__c = '1';
            acc.MktOppMarketShareAUM__c = 1.0;
            acc.MktOppPYIndustryNetSales__c = 1.0;
            acc.MktOppPYMarketSharePurchases__c = 1.0;
            acc.NumberOfOpenTasks__c = 1.0;
            acc.type = 'Affiliate';
        insert acc;

        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Contact cont = new Contact();
            cont.FirstName = 'test' + Math.random();
            cont.LastName = 'test' + Math.random();
            cont.AccountId = acc.Id;
        insert cont;

        myAC.Contact__c = cont.Id;
        myAC = UtilActivity.activityContactTaskFieldPreset(myAC, myTask);
        myAC.Contact__c = cont.Id;

        contactMap.put(myAc.Contact__c, cont);

        Map<Id,User> userMap = new Map<Id,User>();
        Map<Id,Channel__c> channelMap = new Map<Id,Channel__c>();
        
        myAC = UtilActivity.activityContactTaskFieldPreset(myAC, myTask, contactMap, userMap, channelMap);
        
    }
     
    @isTest static void testActivityContactEventFieldPreset() {

        ActivityContact__c myAC = new ActivityContact__c();
        
        Double rand = Math.random() * 1000;
        Account acc = new Account();
            acc.Name = 'test' + rand;
            acc.PotentialScore__c = '1';
            acc.RiskScore__c = '1';
            acc.MktOppMarketShareAUM__c = 1.0;
            acc.MktOppPYIndustryNetSales__c = 1.0;
            acc.MktOppPYMarketSharePurchases__c = 1.0;
            acc.NumberOfOpenTasks__c = 1.0;
            acc.type = 'Affiliate';
        insert acc;

        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Contact cont = new Contact();
            cont.FirstName = 'test' + Math.random();
            cont.LastName = 'test' + Math.random();
            cont.AccountId = acc.Id;
        insert cont;
       
        Event myEvent = new Event();
        myAC.Contact__c = cont.Id;
        myAC = UtilActivity.activityContactEventFieldPreset(myAC, myEvent);
        myAC.Contact__c = cont.Id;

        contactMap.put(myAc.Contact__c, cont);

        Map<Id,User> userMap = new Map<Id,User>();
        Map<Id,Channel__c> channelMap = new Map<Id,Channel__c>();
        
        myAC = UtilActivity.activityContactEventFieldPreset(myAC, myEvent, contactMap, userMap, channelMap);
        
    }
     
    @isTest static void testActivityProductFieldPreset() {

        Id taskId = (Id)'00T000000000000';
        Task t = new Task(Id = taskId, ActivityDate = Date.TODAY());
        ActivityProduct__c ap = new ActivityProduct__c(ActivityId__c = taskId);
        
        ap = UtilActivity.activityProductFieldPreset(ap,t);
        
        system.assertEquals(ap.Date__c,t.ActivityDate,'Activity Product fields did not set correctly from Task');
        
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Map<Id,User> userMap = new Map<Id,User>();
        Map<Id,Channel__c> channelMap = new Map<Id,Channel__c>();
        
        ap = UtilActivity.activityProductFieldPreset(ap, t, contactMap, userMap, channelMap);
        
    }
    
    @isTest static void testGetTaskTypeSubtype() {
        
        Task t = new Task(Subject='sent via LiveSend', ActivityType__c = 'Email');
        t = UtilActivity.getTaskTypeSubtype(t);
        system.assertEquals(t.ActivitySubType__c, 'Marketing', 'Seismic Task was not categorized correctly');
        
        Task t2 = new Task(Subject='test', Type = 'Email');
        t2 = UtilActivity.getTaskTypeSubtype(t2);
        system.assertEquals(t2.ActivitySubType__c, 'Email', 'General email Task was not categorized correctly');

    
    }
        
}