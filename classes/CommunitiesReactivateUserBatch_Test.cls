@isTest
public class CommunitiesReactivateUserBatch_Test {
    
    @testSetup static void SetupTest() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

    
        DataFactory.CreateNGAMCustomSettings(); 
        DataFactory.insertEstatementCommunityCustomSettings();
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
        string EndClientOwnerId = myCustomSetting.EndClientOwnerId__c;
        
        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        for (Account a : myAccounts)
        {
            a.OwnerId = EndClientOwnerId;
        }
        insert myAccounts;
        
        Id ECRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('End Client').getRecordTypeId();
        
        List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
        List<Contact> contacts = new List<Contact>();
        List<Contact> contactsWithFAC = new List<Contact>();
        
        myContacts[0].RecordTypeId = ECRecordTypeId;
        myContacts[0].LastName = 'Test for Reactivate';
        
        myContacts[1].RecordTypeId = ECRecordTypeId;
        myContacts[1].LastName = 'Test for remain InActive';    

        myContacts[2].RecordTypeId = ECRecordTypeId;
        myContacts[2].LastName = 'Test for Activate';    
        
        insert myContacts;
        system.debug('myContacts 1 ID: ' + myContacts[1].Id);
        
        contactsWithFAC.add(myContacts[0]); 
        contactsWithFAC.add(myContacts[2]); 
        
        List<FinancialAccount__c> faList =  DataFactory.createFinancialAccounts(1) ;
        insert faList;
        
        List<FinancialAccountContact__c> facList = DataFactory.createFinancialAccountContacts(faList,contactsWithFAC);
        insert facList;
        system.debug('facList: ' + facList);
        
    }
    
    
    static testMethod void CommunitiesReactivateUserBatch_Test() {
        
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
        string EStatementFirmName = myCustomSetting.EndClientCommunityAccountName__c;
        string PortalUserName = myCustomSetting.PotalUserName__c;
        string PermissionSetForEndClient =   myCustomSetting.PemissionSetForEndClient__c;
        String ProfileForEndClient = myCustomSetting.ProfileForEndClient__c;
        string ProfileForFAUser =  myCustomSetting.ProfileForFAUser__c;
        String PermissionSetsForFAUser = myCustomSetting.PermissionSetsForFAUser__c;
        Integer InactivateDaysForUserLogin = (Integer)myCustomSetting.InactivateDaysForUserLogin__c;
        Map<String,Id> profPermSetIdMap = new Map<String,Id>();
        PermissionSet FAPS = [SELECT Name, Id FROM PermissionSet WHERE name=:PermissionSetsForFAUser LIMIT 1];
        PermissionSet ECPS = [SELECT Name, Id FROM PermissionSet WHERE name=:PermissionSetForEndClient LIMIT 1];
        Profile FAProfile = [SELECT Name, Id FROM Profile WHERE name=:ProfileForFAUser LIMIT 1];  
        Profile EndClientProfile = [SELECT Name, Id FROM profile WHERE name=:ProfileForEndClient LIMIT 1]; 
        profPermSetIdMap.put(FAProfile.Name, FAProfile.Id);
        profPermSetIdMap.put(EndClientProfile.Name, EndClientProfile.Id);
        profPermSetIdMap.put(FAPS.Name, FAPS.Id);
        profPermSetIdMap.put(ECPS.Name, ECPS.Id);
        
        Profile UserProfile = [select id from profile where name = :ProfileForEndClient];
        
        Contact conCU1 = [SELECT id, FirstName, LastName from Contact WHERE LastName = 'Test for Reactivate' LIMIT 1];
        Contact conCU2 = [SELECT id, FirstName, LastName from Contact WHERE LastName = 'Test for remain InActive' LIMIT 1];
        Contact conCU3 = [SELECT id, FirstName, LastName from Contact WHERE LastName = 'Test for Activate' LIMIT 1];
        
        List<User> users = new List<User>(); 
        User communityUser1 = new User(contactId=conCU1.Id,
                                       IsActive=False,
                                       username='Email@emal.com.crmstage123', 
                                       firstname=conCU1.FirstName,
                                       lastname=conCU1.LastName, 
                                       email= 'Email@emal.com.crmstage',
                                       communityNickname = 'uesrid123456',
                                       alias = 'uesrid43', 
                                       UserID__c  = 'uesrid43', 
                                       profileid =UserProfile.Id, 
                                       emailencodingkey='UTF-8',
                                       languagelocalekey='en_US', 
                                       localesidkey='en_US', 
                                       timezonesidkey='America/Los_Angeles');  
        users.add(communityUser1);
        
        User communityUser2 = new User(contactId=conCU2.Id,
                                       username='Email@emal.com.crmstage1234',
                                       IsActive = false,
                                       firstname=conCU2.FirstName,
                                       lastname=conCU2.LastName, 
                                       email= 'Email@emal.com.crmstage',
                                       communityNickname = 'uesrid123',
                                       alias = 'uesrid4', 
                                       UserID__c  = 'uesrid4', 
                                       profileid =UserProfile.Id, 
                                       emailencodingkey='UTF-8',
                                       languagelocalekey='en_US', 
                                       localesidkey='en_US', 
                                       timezonesidkey='America/Los_Angeles'
                                       
                                      );  
        users.add(communityUser2);
        insert users;
        
        Test.startTest(); 
        CommunitiesReactivateUserBatch b1 = new CommunitiesReactivateUserBatch();
        ID b1id = Database.executeBatch(b1,2000);
        Test.stopTest();
        
        User cu1 = [SELECT Id, IsActive, CommunityStatus__c FROM User WHERE ContactId =: conCU1.Id LIMIT 1];
        User cu2 = [SELECT Id, IsActive, CommunityStatus__c FROM User WHERE ContactId =: conCU2.Id LIMIT 1];
        User cu3 = [SELECT Id, IsActive, CommunityStatus__c FROM User WHERE ContactId =: conCU3.Id LIMIT 1];
        
        system.assertEquals(cu1.IsActive,TRUE);
        system.assertEquals(cu2.IsActive,FALSE);
        system.assertEquals(cu3.IsActive,TRUE);
        
    }
    
}