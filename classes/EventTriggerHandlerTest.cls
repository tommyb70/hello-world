@isTest 
public class EventTriggerHandlerTest { 
    
    @testSetup
    static void setup() {
        
        DataFactory.CreateNGAMCustomSettings(); 
        Account acc = new Account(); 
        acc.Name = 'Test'; 
        acc.type = 'Affiliate'; 
        insert acc; 
        
    }
    
    static testMethod void myTest() { 
        Id affiliateEventRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Affiliate Event').getRecordTypeId(); 
        Id affiliateCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Affiliate Request').getRecordTypeId(); 
        
        List<Account> myAccounts = DataFactory.createTestAccounts(1);
        myAccounts[0].Name = 'Test'; 
        myAccounts[0].Type = 'Affiliate'; 
        insert myAccounts;
        
        List<Contact> myContacts = DataFactory.createTestContacts(2, myAccounts, false) ;
        insert myContacts; 
        
        
        
        
        //Profile pf = [select id from profile where name='System Administrator']; 
        
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string pf = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        User u = new User(alias = 'standt', email='SFDCadmin@natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = pf, 
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@natixis.com',UserID__c='SFDCadmin'); 
        System.runAs(u) {     
            
            User u0 = new User(alias = 's0', email='Sales0@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing0', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = pf, 
                               timezonesidkey='America/Los_Angeles', username='Sales0@ngam.natixis.com',UserID__c='Sales0');             
            insert u0; 
            
            DateTime myDateTime = datetime.now(); 
            
            Test.startTest(); 
            
            Case c1 = new Case(ownerid= u0.id,
                               recordtypeid =affiliateCaseRecTypeId, 
                               Requestor__c = u0.id, 
                               AccountId = myAccounts[0].Id) ;             
            insert c1; 
            
            Event e00 = new Event(WhatId=c1.Id,ShortSubject__c='Test1',
                                  Type='Call',
                                  WhoId = myContacts[0].Id,
                                  StartDateTime=myDateTime,
                                  EndDateTime=myDateTime.addMinutes(30)); 
            insert e00; 
            
            Event e02 = New Event(WhatId=c1.Id,
                                  ShortSubject__c='Test2',
                                  Type='Meeting',
                                  WhoId = myContacts[0].Id,
                                  StartDateTime=myDateTime.addMinutes(10),
                                  EndDateTime=myDateTime.addMinutes(30)); 
            insert e02;    
            
            Event e01 = New Event(WhatId=c1.Id,
                                  ShortSubject__c='Test3', 
                                  Type='Onsite',
                                  WhoId = myContacts[0].Id,
                                  StartDateTime=myDateTime.addMinutes(5), 
                                  EndDateTime=myDateTime.addMinutes(30));             
            insert e01; 
            
            List<ActivityContact__c> myACs = new List<ActivityContact__c>();
            myACs.add(new ActivityContact__c(ActivityId__c = (String)e00.Id, Contact__c = myContacts[0].Id));
            myACs.add(new ActivityContact__c(ActivityId__c = (String)e00.Id, Contact__c = myContacts[1].Id));
            myACs.add(new ActivityContact__c(ActivityId__c = (String)e02.Id, Contact__c = myContacts[0].Id));
            myACs.add(new ActivityContact__c(ActivityId__c = (String)e02.Id, Contact__c = myContacts[1].Id));
            myACs.add(new ActivityContact__c(ActivityId__c = (String)e01.Id, Contact__c = myContacts[0].Id));
            myACs.add(new ActivityContact__c(ActivityId__c = (String)e01.Id, Contact__c = myContacts[1].Id));
            insert myACs;
            
            //AfterUpdate 
            e01.StartDateTime = myDateTime.addMinutes(15); 
            update e01;
            delete e01;
                          
            Test.stopTest(); 
        } 
    } 
}