@isTest
private class CommunitiesScheduleJob_Test {
    @testSetup static void SetupTest() {
        
        DataFactory.insertEstatementCommunityCustomSettings();
        DataFactory.CreateNGAMCustomSettings(); 
    }    
    
   static testmethod void CommunitiesScheduleJobTesting() 
        {
/*        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        insert myAccounts;
                    
        List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
        insert myContacts;     
                    
        List<Task> myTasks = DataFactory.createTestTasks(3,myContacts,'Mass Email:TEST');  
        insert myTasks;    */  
        
        Test.startTest();
        CommunitiesScheduleJob.scheduleMe();
        Test.stopTest();
        }
}