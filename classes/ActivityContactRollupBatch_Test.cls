@isTest 
public class ActivityContactRollupBatch_Test {
    static testMethod void ActivityContactRollupBatchTesting() {
        
        NGAMSettingsHierarchy__c settings = NGAMSettingsHierarchy__c.getOrgDefaults();
        settings.ByPassAccountValidationRules__c  = TRUE;
        upsert settings NGAMSettingsHierarchy__c.Id;        
        
        NGAMSettings__c NS = new NGAMSettings__c(Name='test1'); 
        NS.ActivityContactRollupBatchFromDate__c = system.today();
        NS.FailureNotificationEmailAddress__c = 'dat@natixis.com';
        insert NS; 
        
        List<dlrs__LookupRollupSummary__c> lrs = new List<dlrs__LookupRollupSummary__c>();
        
        lrs.add(new dlrs__LookupRollupSummary__c(dlrs__Active__c = TRUE, dlrs__AggregateOperation__c = 'Count', dlrs__aggregateresultfield__c = 'YTDNumberOfMeetings__c',
                                                 dlrs__calculationmode__c = 'Developer', dlrs__childobject__c = 'ActivityContact__c', dlrs__fieldtoaggregate__c = 'Count__c',
                                                 dlrs__parentobject__c = 'Account',dlrs__relationshipcriteria__c = 'type__c like \'Meeting%\' and Date__c = THIS_QUARTER and status__c=\'completed\'',
                                                 dlrs__relationshipcriteriafields__c = 'Type__c\r\nDate__c\r\nStatus__c', dlrs__relationshipfield__c = 'Account__c', name = 'AccQTDNumberOfMeetings'));
        
        lrs.add(new dlrs__LookupRollupSummary__c(dlrs__Active__c = TRUE, dlrs__AggregateOperation__c = 'Count', dlrs__aggregateresultfield__c = 'YTDNumberOfCalls__c',
                                                 dlrs__calculationmode__c = 'Developer', dlrs__childobject__c = 'ActivityContact__c', dlrs__fieldtoaggregate__c = 'Count__c',
                                                 dlrs__parentobject__c = 'Account',dlrs__relationshipcriteria__c = 'type__c like \'Call%\' and Date__c = THIS_QUARTER and status__c=\'completed\'',
                                                 dlrs__relationshipcriteriafields__c = 'Type__c\r\nDate__c\r\nStatus__c', dlrs__relationshipfield__c = 'Account__c', name = 'AccQTDNumberOfCalls'));
        
        lrs.add(new dlrs__LookupRollupSummary__c(dlrs__Active__c = TRUE, dlrs__AggregateOperation__c = 'Count', dlrs__aggregateresultfield__c = 'YTDNumberOfMeetings__c',
                                                 dlrs__calculationmode__c = 'Developer', dlrs__childobject__c = 'ActivityContact__c', dlrs__fieldtoaggregate__c = 'Count__c',
                                                 dlrs__parentobject__c = 'Contact',dlrs__relationshipcriteria__c = 'type__c like \'Meeting%\' and Date__c = THIS_YEAR and status__c=\'completed\'',
                                                 dlrs__relationshipcriteriafields__c = 'Type__c\r\nDate__c\r\nStatus__c', dlrs__relationshipfield__c = 'Contact__c', name = 'RepYTDNumberOfMeetings'));
        
        lrs.add(new dlrs__LookupRollupSummary__c(dlrs__Active__c = TRUE, dlrs__AggregateOperation__c = 'Count', dlrs__aggregateresultfield__c = 'YTDNumberOfCalls__c',
                                                 dlrs__calculationmode__c = 'Developer', dlrs__childobject__c = 'ActivityContact__c', dlrs__fieldtoaggregate__c = 'Count__c',
                                                 dlrs__parentobject__c = 'Contact',dlrs__relationshipcriteria__c = 'type__c like \'Call%\' and Date__c = THIS_YEAR and status__c=\'completed\'',
                                                 dlrs__relationshipcriteriafields__c = 'Type__c\r\nDate__c\r\nStatus__c', dlrs__relationshipfield__c = 'Contact__c', name = 'RepNumberOfCallsThisYear'));
        
        insert lrs;
        
        List<Account> myAccounts = DataFactory.createTestAccounts(3);
        insert myAccounts;
        
        List<Contact> myTaskContacts = DataFactory.createTestContacts(3, myAccounts, false);
        insert myTaskContacts;     
        
        List<Task> myTasks = DataFactory.createTestTasks(3,myTaskContacts,'Test Task'); 
        myTasks[0].Type = 'Meeting';
        myTasks[0].Status = 'Complete';
        myTasks[1].Type = 'Call';
        myTasks[1].Status = 'Complete';        
        insert myTasks;
        
        List<Contact> myACContacts = DataFactory.createTestContacts(15, myAccounts, false);
        insert myACContacts;

        List<ActivityContact__c> myActivityContacts = DataFactory.createActivityContacts(myTasks,myACContacts);
        insert myActivityContacts;

        delete myTasks[2];
        
        Test.startTest();    
        ActivityContactRollupBatch batch = new ActivityContactRollupBatch();
        ID tracid = database.executeBatch(batch,10000); 
        Test.stopTest();
                
    }
}