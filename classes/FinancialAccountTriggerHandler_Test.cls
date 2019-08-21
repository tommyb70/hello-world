@isTest  
public class FinancialAccountTriggerHandler_Test {
    
    static testMethod void FinancialAccountTriggerHandlerTest() {    
    
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

        contact con = new contact(FirstName='ABC', LastName = 'TEST Account',AccountId = a.Id); 
        insert con; 
        
        FinancialAccount__c testAcc = new FinancialAccount__c(Name='Test Name',AccountID__c=123); 
        testAcc.RSAAccount__c = false; 
        testAcc.AccountNameEncrypted__c ='abc'; 
        testAcc.ViewableinCommunity__c = TRUE; 
        insert testAcc; 
        
        FinancialAccountContact__c FAC = new FinancialAccountContact__c(); 
        FAC.Financial_Account__c = testAcc.Id; 
        FAC.contact__c = con.Id; 
        FAC.Status__c = 'Current'; 
        FAC.View_Financial_Account_in_Community__c = true; 
        insert FAC; 
        
        FinancialAccountContact__c finAcctContact = [SELECT Financial_Account__r.Id,Contact__c FROM FinancialAccountContact__c WHERE Status__c = 'Current'
                                                           AND View_Financial_Account_in_Community__c = TRUE
                                                           AND Financial_Account__r.ViewableinCommunity__c = TRUE LIMIT 1];
        
        FinancialAccount__c finAcct = [SELECT Id FROM FinancialAccount__c WHERE Id = :finAcctContact.Financial_Account__r.Id LIMIT 1];
       
        //start the test execution context
        Test.startTest();
                
        finAcct.ViewableinCommunity__c = false;
        update finAcct;
    
        finAcct.ViewableinCommunity__c = true;
        update finAcct;
        
      
        
        Test.stopTest();    
    }
}