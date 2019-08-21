@isTest
private class RollupBatch_Test {
    
    static testMethod void myTest() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        insert myAccounts;
        
        List<Contact> myTaskContacts = DataFactory.createTestContacts(3, myAccounts, false);
        insert myTaskContacts;   
        
        List<dlrs__LookupRollupSummary2__mdt> rollupMetadata =[select id from dlrs__LookupRollupSummary2__mdt where DeveloperName='ZApexTestCoverageDoNotDelete' LIMIT 1];

        List<dlrs__LookupRollupSummary__c> lrs = new List<dlrs__LookupRollupSummary__c>();
        
        lrs.add(new dlrs__LookupRollupSummary__c(dlrs__Active__c = False, 
                                                 dlrs__AggregateOperation__c = 'Count',
                                                 dlrs__aggregateresultfield__c = 'Id',
                                                 dlrs__calculationmode__c = 'Scheduled',
                                                 dlrs__childobject__c = 'contact', 
                                                 dlrs__fieldtoaggregate__c = 'Id',
                                                 dlrs__parentobject__c = 'Account',
                                                 dlrs__relationshipcriteria__c = 'id != null',
                                                 dlrs__relationshipcriteriafields__c = 'Id', 
                                                 dlrs__relationshipfield__c = 'AccountId', 
                                                 Name = 'AccQTDNumberOfMeetings'));
        
/*        lrs.add(new dlrs__LookupRollupSummary__c(dlrs__Active__c = False, 
                                                 dlrs__AggregateOperation__c = 'Count', 
                                                 dlrs__aggregateresultfield__c = 'Id',
                                                 dlrs__calculationmode__c = 'Scheduled', 
                                                 dlrs__childobject__c = 'contact', 
                                                 dlrs__fieldtoaggregate__c = 'Id',
                                                 dlrs__parentobject__c = 'Account',
                                                 dlrs__relationshipcriteria__c = 'id != null',
                                                 dlrs__relationshipcriteriafields__c = 'Id', 
                                                 dlrs__relationshipfield__c = 'AccountId', 
                                                 DeveloperName = 'AccQTDNumberOfMeetings'));        */
        
        insert lrs;
        
        List<dlrs__LookupRollupSummaryScheduleItems__c> lstSI = new List<dlrs__LookupRollupSummaryScheduleItems__c>();
        
        lstSI.add(new dlrs__LookupRollupSummaryScheduleItems__c(dlrs__LookupRollupSummary__c=lrs[0].Id,
                                                                dlrs__LookupRollupSummary2__c=rollupMetadata[0].Id,
                                                                dlrs__QualifiedParentID__c=myAccounts[0].Id+'#'+myTaskContacts[0].Id,
                                                                dlrs__ParentId__c = myAccounts[0].Id));                                                                
        
        lstSI.add(new dlrs__LookupRollupSummaryScheduleItems__c(dlrs__LookupRollupSummary__c=lrs[0].Id,
                                                                dlrs__LookupRollupSummary2__c=rollupMetadata[0].Id,
                                                                dlrs__QualifiedParentID__c=myAccounts[1].Id+'#'+myTaskContacts[1].Id,
                                                                dlrs__ParentId__c = myAccounts[1].Id));        
        insert lstSI;
        
        delete myAccounts[1];
        
        test.StartTest();
        RollupBatch  BI = new RollupBatch();
        Database.Executebatch(BI);
        test.StopTest();
        
        //check
        List<dlrs__LookupRollupSummaryScheduleItems__c> check = [SELECT Id
                                                                 FROM dlrs__LookupRollupSummaryScheduleItems__c
                                                                 WHERE dlrs__ParentId__c = :myAccounts[1].Id];
        
        system.assertEquals(0, check.size(), 'ParentId still exists in LookupRollupSummaryScheduleItems, but should not');
        
    }
    
}