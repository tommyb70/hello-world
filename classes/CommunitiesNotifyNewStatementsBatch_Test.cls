@isTest 
private class CommunitiesNotifyNewStatementsBatch_Test {
    
     @testSetup static void SetupTest() {      
     
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
  
        DataFactory.insertEstatementCommunityCustomSettings();
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
        String ProfileForFAUser = myCustomSetting.ProfileForFAUser__c;
         
          DataFactory.insertEstatementCommunityCustomSettings();
        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        insert myAccounts;
        
        Id ECRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('End Client').getRecordTypeId();
        
        List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
        List<Contact> contacts = new List<Contact>();
        List<Contact> contactsWithFAC = new List<Contact>();
        
        myContacts[0].RecordTypeId = ECRecordTypeId;
        myContacts[0].LastName = 'Test 1';
        
        myContacts[1].RecordTypeId = ECRecordTypeId;
        myContacts[1].LastName = 'Test 2';    
        
        myContacts[2].RecordTypeId = ECRecordTypeId;
        myContacts[2].LastName = 'Test 3';
        
        insert myContacts;
        system.debug('myContacts 1 ID: ' + myContacts[1].Id);
        
        contactsWithFAC.add(myContacts[0]);        
        contactsWithFAC.add(myContacts[1]);
        
        List<FinancialAccount__c> faList =  DataFactory.createFinancialAccounts(1) ;
        insert faList;
        
        List<FinancialAccountContact__c> facList = DataFactory.createFinancialAccountContacts(faList,contactsWithFAC);
        insert facList;
        Profile FAProfile = [SELECT Name, Id FROM Profile WHERE name=:ProfileForFAUser LIMIT 1];  
     
        system.debug('facList: ' + facList);
         
           User nCU = new User(contactId=myContacts[0].Id, 
                                                                username='username@test.com', 
                                                                IsActive=TRUE,
                                                                firstname=myContacts[0].FirstName,
                                                                lastname=myContacts[0].LastName, 
                                                                email= myContacts[0].Email,
                                                                communityNickname = myContacts[0].LastName + '_12345',
                                                                alias = 'test123', 
                                                                UserID__c  = 'test123', 
                                                                profileid = FAProfile.Id, 
                                                                emailencodingkey='UTF-8',
                                                                languagelocalekey='en_US', 
                                                                localesidkey='en_US', 
                                                                timezonesidkey='America/Los_Angeles',
                                                                CommunityStatus__c = 'Active');  
         insert nCU;
         
                
         List<FinancialAccountFile__c>  fafList = DataFactory.createFinancialAccountFiles( 5,faList                                                                                    );
         insert fafList;
    }
    
    
    static testMethod void CommunitiesNotifyNewStatementsBatchTesting() {        
       
            List<FinancialAccountFile__c>  fafList = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, FinancialAccount__c, DoNotDisplayReason__c, DoNotDisplayinCommunity__c, DocumentDate__c, DocumentType__c, OriginalFileName__c FROM FinancialAccountFile__c where OriginalFileName__c like 'Test %' ];                          
            Test.startTest(); 
            System.Debug(' ########## -Test Started ');           
            CommunitiesNotifyNewStatementsBatch usersBtach = new CommunitiesNotifyNewStatementsBatch();           
            ID tracid = database.executeBatch(usersBtach,2000); 
            System.Debug(' ########## -Test Ended ');
            Test.stopTest();
             
    }
    
     
    
    
    
   }