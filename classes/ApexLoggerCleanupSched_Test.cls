@isTest
private class ApexLoggerCleanupSched_Test {

   static testmethod void ApexLoggerCleanupSchTesting() {
   
        NGAMSettingsHierarchy__c settings = NGAMSettingsHierarchy__c.getOrgDefaults();
        settings.ByPassAccountValidationRules__c  = TRUE;
        upsert settings NGAMSettingsHierarchy__c.Id;

        
        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        insert myAccounts;
                    
        List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
        insert myContacts;     
                    
        List<Task> myTasks = DataFactory.createTestTasks(3,myContacts,'Mass Email:TEST');  
        insert myTasks;      
            
            
            
        Test.startTest();
        ApexLoggerCleanupSched.scheduleMe();
        Test.stopTest();
        }
}