@isTest
public class CommunitiesInactivateUserBatch_Test {
    
    @testSetup static void SetupTest() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

    
        DataFactory.CreateNGAMCustomSettings(); 
        DataFactory.insertEstatementCommunityCustomSettings();
        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        insert myAccounts;
        
        Id ECRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('End Client').getRecordTypeId();
        
        List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
        List<Contact> contacts = new List<Contact>();
        List<Contact> contactsWithFAC = new List<Contact>();
        
        myContacts[0].RecordTypeId = ECRecordTypeId;
        myContacts[0].LastName = 'Test for T&C';
        
        myContacts[1].RecordTypeId = ECRecordTypeId;
        myContacts[1].LastName = 'Test for remain Active';    
        
        myContacts[2].RecordTypeId = ECRecordTypeId;
        myContacts[2].LastName = 'Test for No Fin Accounts';
        
        insert myContacts;
        system.debug('myContacts 1 ID: ' + myContacts[1].Id);
        
        contactsWithFAC.add(myContacts[0]);        
        contactsWithFAC.add(myContacts[1]);
        
        List<FinancialAccount__c> faList =  DataFactory.createFinancialAccounts(1) ;
        insert faList;
        
        List<FinancialAccountContact__c> facList = DataFactory.createFinancialAccountContacts(faList,contactsWithFAC);
        insert facList;
        system.debug('facList: ' + facList);
        
    }
    
    
    static testMethod void CommunitiesInactivateUserBatchTesting() {
        
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
        
        Profile p = [select id from profile where name='System Administrator']; 
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                           UserRoleId = portalRole.Id,
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                           localesidkey='en_US', profileid = p.Id,
                           isActive = TRUE,
                           timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2) 
        {
            Profile UserProfile = [select id from profile where name = :ProfileForEndClient];
            Contact conCU1 = [SELECT id, FirstName, LastName from Contact WHERE LastName = 'Test for T&C' LIMIT 1];
            Contact conCU2 = [SELECT id, FirstName, LastName from Contact WHERE LastName = 'Test for remain Active' LIMIT 1];
            Contact conCU3 = [SELECT id, FirstName, LastName from Contact WHERE LastName = 'Test for No Fin Accounts' LIMIT 1];
            
            List<User> users = new List<User>(); 
            User communityUser1 = new User(contactId=conCU1.Id,
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
                                           timezonesidkey='America/Los_Angeles',
                                           CommunityStatus__c = 'Active',
                                           TermsandConditionsLastDeclined__c =  System.now());  
            users.add(communityUser1);
            
            User communityUser2 = new User(contactId=conCU2.Id,
                                           username='Email@emal.com.crmstage1234', 
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
                                           timezonesidkey='America/Los_Angeles',
                                           CommunityStatus__c = 'Active');  
            users.add(communityUser2);
            
            User communityUser3 = new User(contactId=conCU3.Id,
                                           username='Email@emal.com.crmstageX', 
                                           firstname=conCU3.FirstName,
                                           lastname=conCU3.LastName, 
                                           email= 'Email@emal.com.crmstage',
                                           communityNickname = 'uesridX',
                                           alias = 'uesridX', 
                                           UserID__c  = 'uesridX', 
                                           profileid =UserProfile.Id, 
                                           emailencodingkey='UTF-8',
                                           languagelocalekey='en_US', 
                                           localesidkey='en_US', 
                                           timezonesidkey='America/Los_Angeles',
                                           CommunityStatus__c = 'Active');  
            users.add(communityUser3);
            insert users;
            
            List<PermissionSetAssignment> permSetToAssign = New List<PermissionSetAssignment>();
            
            PermissionSetAssignment permassign1 = new PermissionSetAssignment(PermissionSetId = profPermSetIdMap.get(PermissionSetForEndClient), AssigneeId=communityUser1.Id);
            PermissionSetAssignment permassign2 = new PermissionSetAssignment(PermissionSetId = profPermSetIdMap.get(PermissionSetForEndClient), AssigneeId=communityUser2.Id);
            permSetToAssign.add(permassign1);            
            permSetToAssign.add(permassign2);
            insert permSetToAssign;            
            
            Test.startTest(); 
            System.Debug(' ########## -Test Started ');
            CommunitiesInactivateUserBatch usersBtach = new CommunitiesInactivateUserBatch();
            usersBtach.execute(null, users) ;
            ID tracid = database.executeBatch(usersBtach,2000); 
            System.Debug(' ########## -Test Ended ');
            Test.stopTest();
            
            User cu1 = [SELECT Id, IsActive, CommunityStatus__c FROM User WHERE ContactId =: conCU1.Id LIMIT 1];
            User cu2 = [SELECT Id, IsActive, CommunityStatus__c FROM User WHERE ContactId =: conCU2.Id LIMIT 1];
            User cu3 = [SELECT Id, IsActive, CommunityStatus__c FROM User WHERE ContactId =: conCU3.Id LIMIT 1];
            
            List<FinancialAccountContact__c> activeCU1 = [SELECT Id FROM FinancialAccountContact__c 
                                                          WHERE Contact__c =: conCU1.Id 
                                                          AND Status__c != 'Inactivated'];
            
            List<FinancialAccountContact__c> activeCU2 = [SELECT Id FROM FinancialAccountContact__c 
                                                          WHERE Contact__c =: conCU2.Id 
                                                          AND Status__c != 'Inactivated'];
            
            List<FinancialAccountContact__c> activeCU3 = [SELECT Id FROM FinancialAccountContact__c 
                                                          WHERE Contact__c =: conCU3.Id 
                                                          AND Status__c != 'Inactivated'];
            
            
            system.assertEquals(cu1.IsActive,FALSE);
            system.assertEquals(cu1.CommunityStatus__c,'Inactive: Declined Terms and Conditions');
            system.assertEquals(activeCU1.size(),0);
            
            system.assertEquals(cu2.IsActive,TRUE);
            system.assertEquals(cu2.CommunityStatus__c,'Active');
            system.assertNotEquals(activeCU2.size(),0);
            
            system.assertEquals(cu3.IsActive,FALSE);
            system.assertEquals(cu3.CommunityStatus__c,'Inactive: No Financial Accounts');            
            system.assertEquals(activeCU3.size(),0);            
            
        }        
    }
}