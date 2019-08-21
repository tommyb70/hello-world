@isTest
private class EventRelationSyncSchedule_Test {
public static String CRON_EXP = '0 0 0 15 3 ? 2022';
   static testmethod void EventRelationSyncScheduleTest() 
        {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        insert myAccounts;
                    
        List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
        insert myContacts;     
                    
        List<Task> myTasks = DataFactory.createTestTasks(3,myContacts,'Mass Email:TEST');  
        insert myTasks; 
            
        Test.startTest();
        //String jobId = System.schedule('EventRelationSyncSchedule_Test', CRON_EXP, new EventRelationSyncBatch());
        EventRelationSyncSchedule.scheduleMe();
        Test.stopTest();
        }
    
}