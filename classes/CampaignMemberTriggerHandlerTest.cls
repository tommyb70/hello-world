@isTest
public class CampaignMemberTriggerHandlerTest {
    
    static testMethod void ValidateAll() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        hsettings.CannotCUDActivityAfterDays__c = 999;
        hsettings.ApexSystemUserOrProfile__c = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        string EventRecTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();

       // Profile p = [select id from profile where name='System Administrator']; 
       // Profile pSales = [select id from profile where name='NGAM Sales']; 
       
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSales__c,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string pSales = Util.getCustomSettingProfileId(ngamSettings.ProfileSales__c);
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        
        User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p, 
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        User u2 = new User(alias = 'standt2', email='SFDCSales@ngam.natixis.com', 
                           emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US', 
                           localesidkey='en_US', profileid = pSales, 
                           timezonesidkey='America/Los_Angeles', username='SFDCSales@ngam.natixis.com',UserID__c='SFDCSales');
        
//        NGAMSettingsHierarchy__c settings = new NGAMSettingsHierarchy__c(SetupOwnerId=p, ApexSystemUserOrProfile__c = TRUE,
//                                                                        CannotCUDActivityAfterDays__c = 360);
//        insert settings;
        
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name='Test Event',RecordTypeId=EventRecTypeId,Description='Test',StartDate=Date.today(),EndDate=Date.Today()));
        campaigns.add(new Campaign(Name='Test Event2',RecordTypeId=EventRecTypeId,Description='Test2',StartDate=Date.today(),EndDate=Date.Today()));
        insert campaigns;
        
        List<CampaignMemberStatus> cms = new List<CampaignMemberStatus>();
        cms.add(new CampaignMemberStatus(CampaignId = campaigns[0].Id, IsDefault=TRUE, Label = 'Added to List'));
        cms.add(new CampaignMemberStatus(CampaignId = campaigns[0].Id, IsDefault=FALSE, Label = 'Invitation Sent'));
        insert cms;

        List<Account> TestFirm = DataFactory.createTestFirms(1);
        insert TestFirm;
        
        List<Account> TestAccount = DataFactory.createTestAccountswithFirms(1,TestFirm);
        insert TestAccount;
        
        List<CampaignMember> cm = new List<CampaignMember>();
        
        List<Contact> TestContact = DataFactory.createTestContacts(5,TestAccount,false);
        for (Contact c : TestContact) {
            c.pi__url__c = 'www.google.com';
        }
        insert TestContact;
        
        for (Contact c : TestContact) {
            cm.add(new CampaignMember(CampaignId=campaigns[0].Id,ContactId=c.Id,Status='Added to List'));
        }
        insert cm;
        
        CampaignMember cmc = new CampaignMember(CampaignId=campaigns[1].Id,ContactId=TestContact[0].Id,Status='Added to List');
        
        try {
            insert cmc;
        } catch (Exception e) {
            
        }

        for (CampaignMember cmu : cm) {
            cmu.Status = 'Invitation Sent';
        }
        
        try {
        update cm;
        } catch (Exception e) {
            
        }
        
        try {
        delete cm[0];
        } catch (Exception e) {
            
        }
        
        System.runAs(u) {
            delete cm[1];
        }
        
    }
    
}