@isTest
private class EventRelationSyncBatch_Test {
    static testMethod void EventRelationSyncBatchTesting() {
        
/*20190707 - No Longer Need this since using trigger on EventRelationChangeEvent    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        User u = DataFactory.createSystemAdminUser();
        insert u; 
        
        List<Account> myAccounts = DataFactory.createTestAccounts(1);
        insert myAccounts;
        
        List<Contact> myContacts = DataFactory.createTestContacts(201, myAccounts, false);
        insert myContacts;   
        
        //Setup Data
        Id affiliateEventRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Affiliate Event').getRecordTypeId();
        Id affiliateCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Affiliate Request').getRecordTypeId();
        Id affiliateAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliate').getRecordTypeId();
        
        List<Account> myAffiliateAccounts = DataFactory.createTestAccounts(1);
        myAffiliateAccounts[0].Type = 'Affiliate';
        myAffiliateAccounts[0].RecordTypeId = affiliateAccountRecTypeId;
        insert myAffiliateAccounts;
        
        List<Contact> myAffiliateContacts = DataFactory.createTestContacts(1, myAffiliateAccounts, false);
        insert myAffiliateContacts;   
        
        List<Account> affiliateAccountId = [SELECT Id,Name FROM Account WHERE Type = 'Affiliate' LIMIT 1]; 
        List<Contact> contacts = DataFactory.createTestContacts(1, affiliateAccountId, false);
        insert contacts;
        
        List<User> OwnerId = [SELECT Id,ActivityTerritoryName__c,ActivityChannelName__c
                              FROM User
                              WHERE IsActive = TRUE
                              AND UserType = 'Standard'
                              AND ActivityTerritoryName__c != null
                              AND ActivityChannelName__c != null
                              LIMIT 1];
        
        List<User> RequestorId = [SELECT Id 
                                  FROM User
                                  WHERE IsActive = TRUE
                                  AND UserType = 'Standard'
                                  LIMIT 1];
        
        Case c1 = New Case(OwnerId=u.Id,Requestor__c = u.Id,Type='Travel',Contact=contacts[0],RecordTypeId=affiliateCaseRecTypeId,AccountId=myAffiliateAccounts[0].Id,CaseCreatedviaFlow__c=TRUE);
        insert c1;
        
        Datetime myDateTime = DateTime.Now();
        //BeforeInsert
        Event e00 = New Event(OwnerId=u.Id,WhatId=c1.Id,
                              ShortSubject__c='Test1',Type='Meeting',
                              StartDateTime=myDateTime,
                              EndDateTime=myDateTime.addMinutes(30), WhoId=contacts[0].Id);
        insert e00;
        
        List<EventRelation> listEr= new List<EventRelation>();
        for(Contact cur:myContacts)
        {
            listEr.Add(new eventrelation(eventid=e00.id,relationid=cur.id,status='Accepted'));
        }
        insert listEr;    */        
        
        Test.startTest(); 
        EventRelationSyncBatch trac = new EventRelationSyncBatch();
        
/*20190707 - No Longer Need this since using trigger on TaskRelationChangeEvent
        DateTime X30MinutesAgo = myDateTime.addMinutes(-15);
        String dateTimeFormat = X30MinutesAgo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        trac.query = 'Select Product__c,Type,id,ActivityType__c,Whoid,WhatId,EventWhoIds,Subject,ActivityDate,OwnerId,recordTypeID, (select id, RelationId,EventId from EventRelations where iswhat=false) from Event Where LastModifiedDate = TODAY AND  LastModifiedDate > ' + dateTimeFormat;
*/      
        trac.query = 'Select Id FROM EventRelation WHERE Id = null';
        ID tracid = database.executeBatch(trac,2000); 
        Test.stopTest();
/*20190707 - No Longer Need this since using trigger on TaskRelationChangeEvent
        List<ActivityContact__c> aCTest = [SELECT Id,ActivityId__c FROM ActivityContact__c WHERE Contact__c in :myContacts];
        system.assertEquals(acTest.size(),myContacts.size());
*/
    }
}