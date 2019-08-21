@isTest
public class DictionaryItemBatchTest {
    
    
    static testMethod void DictionaryItemBatchTest() {
        
    
        Id objectRecordTypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
        DictionaryItem__c di = new DictionaryItem__c(APIName__c = 'Test__c', RecordTypeId = objectRecordTypeId, Custom__c = TRUE);
        insert di;
        
        Test.startTest(); 
        TestContext.testCase = 'YES';    
        Id batchJobId = Database.executeBatch(new DictionaryItemObjectBatch());
        Test.stopTest();		        
        
    }        
    
}