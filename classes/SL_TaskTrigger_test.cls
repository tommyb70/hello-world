@isTest
public class SL_TaskTrigger_test {
    
    @isTest
    public static void insert_test() {
        
        Account acc = new Account(Name = 'testAccount' + Math.random(), type = 'Affiliate', NumberOfOpenTasks__c = 3 );
        insert acc;

        Account returnedAcc = [SELECT id, NumberOfOpenTasks__c FROM Account WHERE id =: acc.Id LIMIT 1];

        System.assertEquals(returnedAcc.NumberOfOpenTasks__c, 3);

        List<Task> lstTaskToInsert = new List<Task>();
            lstTaskToInsert.add(new Task(WhatId = acc.Id));
            lstTaskToInsert.add(new Task(WhatId = acc.Id));
        insert lstTaskToInsert;

        returnedAcc = [SELECT id, NumberOfOpenTasks__c FROM Account WHERE id =: acc.Id LIMIT 1];

        System.assertEquals(returnedAcc.NumberOfOpenTasks__c, 2);

        List<Task> lstTaskToInsert2 = new List<Task>();
            lstTaskToInsert2.add(new Task(WhatId = acc.Id));
            lstTaskToInsert2.add(new Task(WhatId = acc.Id));
        insert lstTaskToInsert2;

        returnedAcc = [SELECT id, NumberOfOpenTasks__c FROM Account WHERE id =: acc.Id LIMIT 1];

        System.assertEquals(returnedAcc.NumberOfOpenTasks__c, 4);

        Account acc2 = new Account(Name = 'testAccount2', type = 'Affiliate', NumberOfOpenTasks__c = 3 );
        insert acc2;
        lstTaskToInsert2[0].WhatId = acc2.Id ;
        update lstTaskToInsert2;
    }

    @isTest
    public static void insertFromActionPlan_test() {

        Account acc = new Account(Name = 'testAccount', type = 'Affiliate', NumberOfOpenTasks__c = 3 );
        insert acc;

        ActionPlan__c actionPlan = new ActionPlan__c();
            actionPlan.Name			= 'test name' + Math.random();
            actionPlan.StartDate__c 	= Date.today();
            actionPlan.OwnerId		= Userinfo.getUserId();
            actionPlan.Account__c = acc.Id; 		
 		insert actionPlan;

        APTaskTemplate__c APTask = new APTaskTemplate__c();
            APTask.Subject__c           = 'test subject' + Math.random();
            APTask.DaysFromStart__c     = 2;
            APTask.Dependent__c         = '2';
            APTask.Type__c              = 'Email';
            APTask.Priority__c          = 'Hight';
            APTask.Action_Plan__c       = actionPlan.Id;
        insert APTask;

        List<APTaskTemplate__c> returnedAAPTask = [SELECT id FROM APTaskTemplate__c WHERE id =: APTask.Id ];

        System.assertEquals(returnedAAPTask.size(), 1);

        List<Task> lstTaskToInsert = new List<Task>();
            lstTaskToInsert.add(new Task(WhatId = APTask.Id));
        insert lstTaskToInsert;

        List<Task> afterInsert = [SELECT id, Action_Plan_Task__c FROM Task];
        System.assertEquals(afterInsert[0].Action_Plan_Task__c, true);
    }

    @isTest
    public static void update_test() {
        
         Account acc = new Account(Name = 'testAccount', type = 'Affiliate', NumberOfOpenTasks__c = 3 );
        insert acc;

        ActionPlan__c actionPlan = new ActionPlan__c();
            actionPlan.Name			= 'test name' + Math.random();
            actionPlan.StartDate__c 	= Date.today();
            actionPlan.OwnerId		= Userinfo.getUserId();
            actionPlan.Account__c = acc.Id; 		
 		insert actionPlan;

        APTaskTemplate__c APTask = new APTaskTemplate__c();
            APTask.Subject__c           = 'test subject' + Math.random();
            APTask.DaysFromStart__c     = 2;
            APTask.Dependent__c         = '2';
            APTask.Type__c              = 'Email';
            APTask.Priority__c          = 'Hight';
            APTask.Action_Plan__c       = actionPlan.Id;
        insert APTask;

        List<Task> lstTaskToInsert = new List<Task>();
            lstTaskToInsert.add(new Task(WhatId = APTask.Id, ActivityDate = date.today().addDays(-1)));
        insert lstTaskToInsert;

        List<Task> afterInsert = [SELECT id, ActivityDate FROM Task];
        for (Integer i = 0; i < afterInsert.size(); i++) {
            System.assertEquals(afterInsert[0].ActivityDate, date.today().addDays(-1));
        }

        
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p.id, 
                            timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2){

            lstTaskToInsert[0].Status = 'Completed';
            update lstTaskToInsert;
        }
        afterInsert = [SELECT id, ActivityDate FROM Task];
        for (Integer i = 0; i < afterInsert.size(); i++) {
            System.assertEquals(afterInsert[0].ActivityDate, date.today());
        }
    }
}