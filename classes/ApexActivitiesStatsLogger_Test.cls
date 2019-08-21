@isTest 
public class ApexActivitiesStatsLogger_Test {

 static testMethod void ApexActivitiesStatsLoggerTesting() {
       Profile p = [select id from profile where name='System Administrator']; 
       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
            				emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            				localesidkey='en_US', profileid = p.Id, 
            				timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');        
		System.runAs(u2) 
        		{           
                test.startTest();    
                ApexActivitiesStatsLogger.logMessage('TEST1', 'TEST2', 'TEST3', 'TEST - Query', 'TESTING', 'TESTING');
               	test.stopTest();
                }
 }
}