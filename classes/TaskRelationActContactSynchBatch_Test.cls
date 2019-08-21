@isTest 
private class TaskRelationActContactSynchBatch_Test {
    static testMethod void TaskRelationActContactSynchBatchTesting() {
    
/*20190707 - No Longer Need this since using trigger on TaskRelationChangeEvent
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
              NGAMSettings__c cs = new NGAMSettings__c();
              cs.Name='NGAM_ALL';
              cs.TaskRelationOutlookSyncQuery__c = 'where Type like \'%Email%\' and LastModifiedDate >= LAST_N_DAYS:5 and owner.isactive = true and whocount>0 and CreatedDate >= 2015-01-01T00:00:00.000Z and LastModifiedBy.alias != \'inatixis\'  and ActivitySource__c  = null LIMIT 2000';
              insert cs;    
             List<Account> myAccounts = DataFactory.createTestAccounts(3);
             insert myAccounts;
                    
                List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
                insert myContacts;     
                    
                List<Task> myTasks = DataFactory.createTestTasks_outlookPlugin(3,myContacts,'Email');  
                                insert myTasks; 
               System.Debug('myTasks ########## - ' + myTasks.size());
                    
                List<Task> myTasks2 = DataFactory.updateTestTasks_outlookplugin(myTasks, 'Email','test');
                update myTasks2;   
                                 
                List<Contact> myContacts2 = DataFactory.createTestContacts(3, myAccounts, false);
                insert myContacts2;     
                
                List<TaskRelation> myTRs = DataFactory.createTaskRelations(myTasks2,  myContacts2);
                insert myTRs;
20190707 */                

				Test.startTest(); 
                System.Debug(' ########## -Test Started ');
                TaskRelationActContactSynchBatch trac = new TaskRelationActContactSynchBatch();
                ID tracid = database.executeBatch(trac,2000); 
                System.Debug(' ########## -Test Ended ');
                Test.stopTest();
            }       
        
}