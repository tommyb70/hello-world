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
        
        List<Contact> myContacts = DataFactory.createTestContacts(4, myAccounts, false);
        insert myContacts;     
        
        List<Task> myTasks = DataFactory.createTestTasks_outlookPlugin(3,myContacts,'Email');  
        insert myTasks; 
        
        //Added by Prabhpreet
        List<Event> myEvents = DataFactory.createTestEvents(3,myContacts,'Call');  
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

    // Added by Prabhpreet
    @isTest
    public static void testCaseSpeakersUpdate() {
        
        List<Contact> lstContacts = [SELECT Name, AffiliateContactFlag__c
                                          FROM Contact];

        
        lstContacts[0].AffiliateContactFlag__c = true;
        
        update lstContacts[0];

        List<Case> lstCase = [SELECT Id
                                          FROM Case];

        List<Event> lstEvent = [SELECT WhatId, WhoId
                                          FROM Event];


        lstEvent[0].WhatId = lstCase[0].Id;
        lstEvent[0].WhoId = lstContacts[0].Id;

        update lstEvent[0];

        List<ActivityContact__c> myACs = [SELECT ActivityId__c
                                          FROM ActivityContact__c];
        
        myACs[0].ActivityId__c = lstEvent[0].Id;
        update myACs[0];

        Case objCase = [SELECT Id,RequestedSpeakers__c
                                          FROM Case WHERE Id =: lstCase[0].Id ];

        
       System.assertEquals(lstContacts[0].Name, objCase.RequestedSpeakers__c);
    }
    
}