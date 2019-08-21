@isTest 
public class FinancialAccountContactTrigger_Test { 

   static testMethod void FinancialAccountContactTriggerTest() { 
   
           NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;


        ExternalCommunitySettings__c ECS = new ExternalCommunitySettings__c(); 
        ECS.Name = 'EstatementCommunity'; 
        ECS.UseMPANamedCredential__c = 'testugng'; 
        ECS.UserNameFormat__c = 'TEstcom'; 
        ECS.TestUserEmail__c = 'TEst@gmail.com'; 
        insert ECS; 
        
        Account a = new Account(Name = 'TEST Account'); 
        insert a; 
        
        contact con = new contact(FirstName='ABC',LastName = 'TEST Account',AccountId = a.Id); 
        insert con; 
       
        Id p = [select id from profile where name='NGAM Community Plus User'].id; 

        User user = new User(alias = 'test123', email='test123@noemail.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, country='United States',IsActive =true, 
                            ContactId = con.Id,userId__c ='sstfr', 
                            timezonesidkey='America/Los_Angeles', username='tester@noemail.com');         
        insert user;        
        
        FinancialAccount__c testAcc = new FinancialAccount__c(Name='Test Name',AccountID__c=123); 
        testAcc.RSAAccount__c = false; 
        testAcc.AccountNameEncrypted__c ='abc'; 
        insert testAcc; 
        
        FinancialAccountContact__c FAC = new FinancialAccountContact__c(); 
        FAC.Financial_Account__c = testAcc.Id; 
        FAC.contact__c = con.Id; 
        FAC.Status__c = 'Current'; 
        FAC.View_Financial_Account_in_Community__c = true; 
        insert FAC; 
        
        
        FinancialAccountContact__c finAcctContact = [SELECT Financial_Account__r.Id, 
                                                            Contact__c FROM FinancialAccountContact__c 
                                                            LIMIT 1]; 
        
        FinancialAccount__c finAcct = [SELECT Id FROM FinancialAccount__c WHERE Id = :finAcctContact.Financial_Account__r.Id LIMIT 1]; 
        
        //start the test execution context 
        Test.startTest(); 
        
        finAcctContact.Status__c = 'Former' ; 
        update finAcctContact; 
        
        finAcctContact.Status__c = 'Current' ; 
        update finAcctContact; 
        
        delete finAcctContact; 
        
        Test.stopTest(); 
   } 
}