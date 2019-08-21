@isTest(SeeAllData=false)
public class TopProducers_Test {
    
    
            static testMethod void TopProducersTest() 
            {
            
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

            //Profile p = [select id from profile where name='System Administrator']; 
            DataFactory.CreateNGAMCustomSettings(); 
            NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
            string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);   
            //Zone__c myZOne = [select id from zone__c limit 1][0];  
            User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', 
                                username='SFDCadmin@ngam.natixis.com',
                                UserID__c='SFDCadmin',
                                PrimaryChannelId__c='a1EF00000005Ws3MAE',
                                PrimaryChannel__c='WIREHOUSE'
                                //ZoneId__c = myZOne.id
                             );
        
        System.runAs(u2) 
                {
              List<Account> myAccounts = DataFactory.createTestAccounts(3);
             insert myAccounts;
                    
                List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
                insert myContacts;    
                 //start the test execution context
                Test.startTest();
                TopProducers topproducers = new TopProducers(); 
                List<Contact> c  = topproducers.getContacts() ;
                 Test.stopTest();  
                }
                }

}