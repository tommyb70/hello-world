@isTest
private class TaskTriggerHandler_Test {
    
    @testSetup
    static void testSetup() {
        insert new NGAMSettingsHierarchy__c(SetupOwnerId=UserInfo.getOrganizationId(), CannotCUDActivityAfterDays__c = 60);

        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        hsettings.CannotCUDActivityAfterDays__c = 120;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        
    }
    
    static testMethod void myTest() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        
        Integer CannotCUDActivityAfterDays = (Integer)NGAMSettingsHierarchy__c.getInstance().CannotCUDActivityAfterDays__c;        
        Date cutOffDateForActivityChanges = Date.Today().addDays(-CannotCUDActivityAfterDays);
        
        List<Account> myAccounts = DataFactory.createTestAccounts(1);
        insert myAccounts;
        
        List<Contact> myContacts = DataFactory.createTestContacts(2, myAccounts, false) ;
        insert myContacts; 

        List<Product2> testProducts = DataFactory.createProduct2(2,'Test Prod');
        insert testProducts;

        List<Task> myTasks = DataFactory.createTestTasks(1,myContacts,'Call - Informative'); 
        insert myTasks;
        
            List<ActivityContact__c> myACs = new List<ActivityContact__c>();
            myACs.add(new ActivityContact__c(ActivityId__c = (String)myTasks[0].Id, Contact__c = myContacts[0].Id));
            myACs.add(new ActivityContact__c(ActivityId__c = (String)myTasks[0].Id, Contact__c = myContacts[1].Id));
            myACs.add(new ActivityContact__c(ActivityId__c = (String)myTasks[1].Id, Contact__c = myContacts[0].Id));
            myACs.add(new ActivityContact__c(ActivityId__c = (String)myTasks[1].Id, Contact__c = myContacts[1].Id));
        insert myACs;
                
        myTasks[1].ProductList__c = testProducts[0].Id;
        update myTasks[1];
        List<ActivityProduct__c> apCheck = [SELECT Id FROM ActivityProduct__c WHERE ActivityId__c =: myTasks[1].Id];
        system.AssertEquals(apCheck.size(),1,'Activity Product update with one product did not work');

        myTasks[1].ProductList__c = testProducts[0].Id + ';' + testProducts[1].Id;
        update myTasks[1];
        List<ActivityProduct__c> apCheck3 = [SELECT Id FROM ActivityProduct__c WHERE ActivityId__c =: myTasks[1].Id];
        system.AssertEquals(apCheck3.size(),2,'Activity Product update with two products did not work');

        delete myTasks[1];
        List<ActivityProduct__c> apCheck4 = [SELECT Id FROM ActivityProduct__c WHERE ActivityId__c =: myTasks[1].Id];
        system.AssertEquals(apCheck4.size(),0,'Activity Product delete did not work');
        
        undelete myTasks[1];
        List<ActivityProduct__c> apCheck5 = [SELECT Id FROM ActivityProduct__c WHERE ActivityId__c =: myTasks[1].Id];
        system.AssertEquals(apCheck5.size(),2,'Activity Product undelete did not work');        
        
        myTasks[1].ProductList__c = '';
        update myTasks[1];
        List<ActivityProduct__c> apCheck2 = [SELECT Id FROM ActivityProduct__c WHERE ActivityId__c =: myTasks[1].Id];
        system.AssertEquals(apCheck2.size(),0,'Activity Product update with no products did not work');
                      
    }
    
}