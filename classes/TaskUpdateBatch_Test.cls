@isTest 
private class TaskUpdateBatch_Test {
    static testMethod void TaskUpdateBatchTesting() {

        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;


      // Profile p = [select id from profile where name='System Administrator']; 
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        
       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2) 
                {
                List<Zone__c> myZones =  DataFactory.createAllZones ();  
                    
                List<Channel__c> myChannels = DataFactory.createChannels();
                insert myChannels;  
                    
                List<Territory__c> myTerritories = DataFactory.createTerritories(myChannels[0]);
                upsert myTerritories;   
                    
                UserTerritory__c myUT = new UserTerritory__c(User__c = u2.id, Zoning__c = myZones[0].id, ActivityTerritory__c=true,PrimaryTerritory__c=true,Territory__c=myTerritories[0].id);
                insert myUT;    
                
                List<Account> myAccounts = new List<Account>();
                Account myFirm = new Account(name='Test Firm',FocusFirmIAG__c=true);
                insert myFirm;
                Account myAcc =  new Account(name='Test Child',Parentid=myFirm.id); 
                insert myAcc;  
                myAccounts.add(myAcc);

                List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
                insert myContacts;     
                    
                List<Task> myTasks = DataFactory.createTestTasks(3,myContacts,'This is a test');  
                insert myTasks;   
                     
                Test.startTest();  
                TaskUpdateBatch Tub = new TaskUpdateBatch();
                Tub.query =  'Select id, Current_Owner_Channel__c, OwnerCurrentTerritory__c, OwnerCurrentZoneId__c, RepCurrentBPLStatus__c, contact__r.BPL__c, Account__r.Parent.FocusFirmFS__c, Account__r.Parent.FocusFirmIAG__c, Account__r.Parent.FocusFirmRS__c, Account__r.Parent.FocusFirmWHSE__c, Contact__r.PROTierFS__c, Contact__r.PROTierIAG__c, Contact__r.TierRADU__c, Contact__r.PROTierWHSE__c, Contact__r.PROZoneFS__c, Contact__r.PROZoneIAG__c, Contact__r.ZoneRADU__c, Contact__r.PROZoneWHSE__c, OwnerChannelId__c from ActivityContact__c where Date__c >= 2014-01-01';
                ID tracid = database.executeBatch(Tub,2000); 
                Test.stopTest();
                }
        }
}