@isTest(SeeAllData=TRUE)
private class LEXOpportunityBatchTest {
    static testMethod void ValidateAll() {
        
        Test.startTest();
        String myQuery = 'SELECT Id, Product__c, Amount, RepContact__c, HasOpportunityLineItem, Pricebook2Id, RecordType.Name FROM Opportunity ORDER BY CreatedDate DESC LIMIT 200';      
		LEXOpportunityBatch LOB = new LEXOpportunityBatch();
        LOB.query = myQuery;        
        Id LOBId = database.executeBatch(LOB);     
        Test.stopTest();
        
    }
    
}