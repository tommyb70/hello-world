@isTest
public class ActivityContactTriggerHandlerTest {
    
    @testSetup
    public static void testSetup() {
        
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        hsettings.CannotCUDActivityAfterDays__c = 5;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        DataFactory.CreateNGAMCustomSettings(); 
        
        List<Account> myAccounts = DataFactory.createTestAccounts(1);
        insert myAccounts;
        
        List<Contact> myContacts = DataFactory.createTestContacts(2, myAccounts, false);
        insert myContacts;     
        
        List<Task> myTasks = DataFactory.createTestTasks_outlookPlugin(3,myContacts,'Email');  
        insert myTasks; 
        
        //Added by Prabhpreet
        List<Event> myEvents = DataFactory.createTestEvents(2,myContacts,'Call');  
        insert myEvents; 

        //Added by Prabhpreet
        List<Case> myCases = DataFactory.createCases(3,myAccounts);  
        insert myCases; 

        List<ActivityContact__c> myACs = DataFactory.createActivityContacts(myTasks, myContacts);
        insert myACs;

        //Added by Prabhpreet
        List<ActivityContact__c> lstEventACs = DataFactory.createActivityContactsEvents(myEvents, myContacts);
        insert lstEventACs;

        

    }
    
    @isTest
    public static void testAll() {
        
        List<ActivityContact__c> myACs = [SELECT Id
                                          FROM ActivityContact__c];
        
        myACs[0].Date__c = Date.today().addDays(-1);
        update myACs;
        delete myACs[0];
        undelete myACs[0];
        
        myACs[1].Date__c = Date.today().addDays(-10);
        update myACs[1];
        
        try {
            delete myACs[1]; 
        } catch(DmlException e) {        
        }
        
        
    }

    // Test for new method in ActivityContactTriggerHandler to update Case's Requested Speakers field
    @isTest
    public static void testCaseSpeakersUpdate() {
        
        Test.startTest();
        List<Contact> lstContacts = [SELECT Name, AffiliateContactFlag__c
                                          FROM Contact];
        lstContacts[0].AffiliateContactFlag__c = true;
        update lstContacts[0];

        List<Case> lstCase = [SELECT Id
                                          FROM Case];
        List<Event> lstEvent = [SELECT WhatId, WhoId
                                          FROM Event];

        lstEvent[0].WhatId = lstCase[0].Id;
        update lstEvent[0];

        List<ActivityContact__c> myACs = [SELECT ActivityId__c
                                          FROM ActivityContact__c];
        update myACs;
        
        Case objCase = [SELECT Id,RequestedSpeakers__c
                                          FROM Case WHERE Id =: lstCase[0].Id ];
        System.assertEquals(lstContacts[0].Name, objCase.RequestedSpeakers__c);
        
        
        Test.stopTest();



    }
    

    // Test for new method in ActivityContactTriggerHandler to update Case's Requested Speakers field
    @isTest
    public static void testCaseSpeakersBulkUpdate() {
        
        Test.startTest();
        List<Contact> lstContacts = [SELECT Id, Name, AffiliateContactFlag__c
                                          FROM Contact];
        List<Contact> lstToUpdateContacts = new List<Contact>();
        List<Event> lstToUpdateEvents = new List<Event>();
        List<ActivityContact__c> lstActContacts = new List<ActivityContact__c>();

        for(Contact objContact: lstContacts) {
            objContact.AffiliateContactFlag__c = true;
            lstToUpdateContacts.add(objContact);
        }

        update lstToUpdateContacts;
        List<Case> lstCase = [SELECT Id
                                          FROM Case];
        List<Event> lstEvent = [SELECT Id, WhatId, WhoId
                                          FROM Event];
        for(Event objEvent: lstEvent) {
            objEvent.WhatId = lstCase[0].Id;
            lstToUpdateEvents.add(objEvent);
        }
       
        update lstToUpdateEvents;

        List<ActivityContact__c> myACs = [SELECT ActivityId__c
                                          FROM ActivityContact__c];
        update myACs;

        Case objCase = [SELECT Id,RequestedSpeakers__c
                                          FROM Case WHERE Id =: lstCase[0].Id ];
        System.assertEquals(lstContacts[0].Name +'; '+ lstContacts[1].Name,objCase.RequestedSpeakers__c);

        Test.stopTest();

    }
}