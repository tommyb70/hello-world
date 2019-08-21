@isTest
private class ExchangeOptoutTriggerHandler_Test {

    static testMethod void ExchangeOptoutTriggerHandlerTesting() 
        {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

            //Profile p = [select id from profile where name='System Administrator']; 
            DataFactory.CreateNGAMCustomSettings(); 
            NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
            string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
            
            User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                              localesidkey='en_US', profileid = p, 
                              timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u) 
                {
                List<Account> myAccounts = DataFactory.createTestAccounts(1);
                insert myAccounts;  
                
                List<Contact> myContacts =  DataFactory.createTestContacts(1, myAccounts, false);
                insert myContacts;
                
                List<ExchangeOptout__c> myExchangeOptouts = DataFactory.createExchangeOptouts(10);
                insert myExchangeOptouts;
                
                delete myExchangeOptouts;
                delete myContacts;
                delete myAccounts;
                }
    
    
        }
    
}