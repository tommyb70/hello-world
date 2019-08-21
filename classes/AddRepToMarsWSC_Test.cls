@isTest 
public class AddRepToMarsWSC_Test {

    static testMethod void AddRepToMarsWSCTesting() {
    
        NGAMSettingsHierarchy__c settings = NGAMSettingsHierarchy__c.getOrgDefaults();
        settings.ByPassAccountValidationRules__c  = TRUE;
        upsert settings NGAMSettingsHierarchy__c.Id;


       //Profile p = [select id from profile where name='System Administrator']; 
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);

       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2) 
                {
                NGAMSettings__c cs = new NGAMSettings__c();
                cs.Name='NGAM_ALL';
                cs.RepService__c = 'https://servicestest.ngam.natixis.com/repsvc/RepSvc.svc';
                insert cs;    
                    
                List<Account> myAccounts = DataFactory.createTestAccounts(1);
                insert myAccounts;
                    
                List<Contact> myContacts = DataFactory.createTestContacts(1, myAccounts, false);
                insert myContacts;    
                
                test.startTest();    
                Test.setMock(HttpCalloutMock.class, new AddRepToMarsWSC_Mock());   
                AddRepToMarsWSC.addRepMarsById(myContacts[0].id);
                AddRepToMarsWSC.DeleteRepMarsById(myContacts[0].id);
                test.stopTest();

                }
        }
}