@isTest 
public class ApexActivitiesStatsLoggerCleanup_Test {
 static testMethod void ApexActivitiesStatsLoggerCleanupTesting() {
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
                test.startTest();    
               // ApexActivitiesStatsLoggerCleanup.CleanupLoggger(2);
                ApexActivitiesStatsLoggerCleanup trac = new ApexActivitiesStatsLoggerCleanup();
                ID tracid = database.executeBatch(trac,2000); 
                ApexActivitiesStatsLoggerCleanup.CleanupLoggger(2);
                test.stopTest();
                }
 }
}