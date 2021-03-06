@isTest 
private class MassTaskUpdateBatch_Test {
    static testMethod void MassTaskUpdateBatchTesting() {
    
            NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;


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
                List<Account> myAccounts = DataFactory.createTestAccounts(3);
                insert myAccounts;
                    
                List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
                insert myContacts;     
                    
                List<Task> myTasks = DataFactory.createTestTasks(3,myContacts,'Mass Email:TEST');  
                insert myTasks;   
                     
                Test.startTest();    
                
                MassTaskUpdateBatch mtub = new MassTaskUpdateBatch();
                mtub.query = 'select id from Task where ActivityDateProxy__c >= 2015-01-01 and ActivityDateProxy__c <= TODAY';
                ID mtubid = database.executeBatch(mtub,2000); 
                Test.stopTest();
                }
        }
}