@istest 
private class BatchJobErrorNotificationBatchTest {
    
    static testmethod void test() {
        
        NGAMSettingsHierarchy__c settings = NGAMSettingsHierarchy__c.getOrgDefaults();
        settings.ByPassAccountValidationRules__c  = TRUE;
        upsert settings NGAMSettingsHierarchy__c.Id;

        
        NGAMSettings__c NS = new NGAMSettings__c(Name='test1'); 
        NS.LastBatchJobErrorNotificationCompletion__c = system.today(); 
        insert NS; 
        
        String query = 'SELECT ApexClassId, TotalJobItems, CompletedDate, ExtendedStatus, JobItemsProcessed, JobType, MethodName, NumberOfErrors, Status ';
        query += 'FROM AsyncApexJob LIMIT 10';
        //query += 'WHERE CompletedDate >= 1901-01-01T00:00:00Z LIMIT 10';
                 
        Test.startTest();
        BatchJobErrorNotificationBatch bjnb = new BatchJobErrorNotificationBatch(query);
        database.executebatch(bjnb);
        Test.stopTest();        
    }    
}