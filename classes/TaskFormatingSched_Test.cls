@isTest
private class TaskFormatingSched_Test {
    
    static testmethod void TaskFormatingSchedTesting() 
    {
    
         NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
   
        
        NGAMSettings__c NS = new NGAMSettings__c(Name='test1'); 
        NS.ActivityContactRollupBatchFromDate__c = system.today();
        NS.FailureNotificationEmailAddress__c = 'dat@natixis.com';
        insert NS;         
        
        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        insert myAccounts;
        
        List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
        insert myContacts;     
        
        List<Task> myTasks = DataFactory.createTestTasks(3,myContacts,'Mass Email:TEST');  
        insert myTasks;      
        
        Test.startTest();
        TaskFormatingSched.scheduleMe();
        Test.stopTest();
    }
}