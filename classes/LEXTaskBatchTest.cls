@isTest
private class LEXTaskBatchTest {
    
    @testSetup
    static void testSetup() {
        insert new NGAMSettingsHierarchy__c(SetupOwnerId=UserInfo.getOrganizationId(), CannotCUDActivityAfterDays__c = 60);
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        hsettings.CannotCUDActivityAfterDays__c = 120;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        
        LEXConversionContext.runningConversion = TRUE;
        
        //insert new NGAMSettings__c(Name='NGAM_ALL', RunningLEXConversion__c = TRUE);
        
    }
    
    static testMethod void myTest() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        
        Integer CannotCUDActivityAfterDays = (Integer)NGAMSettingsHierarchy__c.getInstance().CannotCUDActivityAfterDays__c;        
        Date cutOffDateForActivityChanges = Date.Today().addDays(-CannotCUDActivityAfterDays);
        
        List<Account> myAccounts = DataFactory.createTestAccounts(1);
        insert myAccounts;
        
        List<Contact> myContacts = DataFactory.createTestContacts(2, myAccounts, false) ;
        insert myContacts; 
        
        List<Product2> testProducts = DataFactory.createProduct2(3,'Test Prod');
        insert testProducts;
        
        List<Task> myTasks = DataFactory.createTestTasks(4,myContacts,'Call - Informative'); 
        myTasks[0].ActivityType__c = 'Call - Informative';
        myTasks[1].ActivityType__c = 'Follow Up';
        myTasks[1].ActivitySubType__c = 'Email Follow Up';
        insert myTasks;
        
        List<ActivityProduct__c> myAPs = new List<ActivityProduct__c>();
        myAPs.add(new ActivityProduct__c(ActivityId__c = (String)myTasks[1].Id, Product__c = testProducts[0].Id));
        myAPs.add(new ActivityProduct__c(ActivityId__c = (String)myTasks[2].Id, Product__c = testProducts[0].Id));
        myAPs.add(new ActivityProduct__c(ActivityId__c = (String)myTasks[2].Id, Product__c = testProducts[1].Id));
        insert myAPs;

        List<ActivityContact__c> myACs = new List<ActivityContact__c>();
        myACs.add(new ActivityContact__c(ActivityId__c = (String)myTasks[0].Id, Contact__c = myContacts[0].Id));
        myACs.add(new ActivityContact__c(ActivityId__c = (String)myTasks[0].Id, Contact__c = myContacts[1].Id));
        myACs.add(new ActivityContact__c(ActivityId__c = (String)myTasks[1].Id, Contact__c = myContacts[0].Id));
        myACs.add(new ActivityContact__c(ActivityId__c = (String)myTasks[1].Id, Contact__c = myContacts[1].Id));
        insert myACs;

        Test.startTest();
        LEXTaskBatch LTB = new LEXTaskBatch();
        LTB.whereCriteria = '';    
        Id LTBId = database.executeBatch(LTB);     
        Test.stopTest();
        
        for (Task t : [SELECT Id, ProductList__c, Type, ActivityType__c, ActivitySubType__c FROM Task]) {
            if (t.Id == myTasks[0].Id) system.assertEquals('Call', t.Type, 'Type should be Call');
            if (t.Id == myTasks[0].Id) system.assertEquals('Call', t.ActivityType__c, 'Type should be Call');            
            if (t.Id == myTasks[0].Id) system.assertEquals('Product/Promotional', t.ActivitySubType__c, 'Type should be Product/Promotional');                        
            if (t.Id == myTasks[1].Id) system.assertEquals('Email', t.Type, 'Type should be Email');
            if (t.Id == myTasks[1].Id) system.assertEquals('Email', t.ActivityType__c, 'Type should be Email');            
            if (t.Id == myTasks[1].Id) system.assertEquals('Follow-Up/Service', t.ActivitySubType__c, 'Type should be Follow-Up/Service');                        
            
            if (t.Id == myTasks[0].Id) system.assertEquals(null, t.ProductList__c, 'ProductList__c should be null - no activity products');
            if (t.Id == myTasks[1].Id) system.assertEquals(testProducts[0].Id, t.ProductList__c, 'ProductList__c should have one item with correct product');            
            if (t.Id == myTasks[2].Id) system.assertEquals(testProducts[0].Id + ';' + testProducts[1].Id, t.ProductList__c, 'ProductList__c should have two items with correct products');            
            if (t.Id == myTasks[3].Id) system.assertEquals(null, t.ProductList__c, 'ProductList__c should have been set to null - no activity products'); 
            
        }
        
        Map<Id,TaskRelation> taskRelationMap = new Map<Id,TaskRelation>([SELECT Id, TaskId, RelationId
                                FROM TaskRelation
                                WHERE TaskId IN :myTasks
                                AND RelationId IN :myContacts]);
        
        for (ActivityContact__c ac : [SELECT Id, ActivityId__c, ActivityRelationId__c, Contact__c FROM ActivityContact__c]) {
            system.debug(ac.ActivityRelationId__c + ' ' + ac.ActivityId__c + ' ' + ac.Contact__c);
            if (ac.ActivityRelationId__c != null) { 
            Id relId = taskRelationMap.get(ac.ActivityRelationId__c).RelationId;
            system.assert(ac.Contact__c == relId,'Activity Contact and Task Relation out-of-sync; ActivityContact__c Id: ' + ac.Id);
            }
        }
        
    }
    
}