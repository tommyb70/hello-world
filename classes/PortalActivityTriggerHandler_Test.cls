@isTest
private class PortalActivityTriggerHandler_Test {

    static testMethod void PortalActivityTriggerHandlerUpdateContactLookup() {
    
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
                          
        System.runAs(u) {
            // create test contact
            
            List<Account> myA = DataFactory.createTestAccounts(1);
            insert myA;
            
            contact c = new contact(MarsRepID__c = '1111', FirstName = 'user', LastName = 'test',AccountId=myA[0].Id);
            insert c;
            
             // create test user
            User user = new User(alias = 'test1', email='test1@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='test1', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='test1@ngam.natixis.com',UserID__c='test1' + Math.random());
                            
            insert(user);
            
            // create test portal activities
            List<PortalActivity__c> portalActivities = new List<PortalActivity__c>();
            portalActivities.add(new PortalActivity__c(Code__c='1111', RepId__c = c.MarsRepId__c, UserId__c = c.MarsRepId__c));    
            portalActivities.add(new PortalActivity__c(Code__c='1112', RepId__c = user.UserID__c, UserId__c = user.UserID__C)); 
            portalActivities.add(new PortalActivity__c( RepId__c = user.UserID__c, UserId__c = user.UserID__C));  
            insert portalActivities;           
        }   
    }    
}