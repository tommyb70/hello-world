global class ProdPerfMaintRollupBatch implements Database.Batchable<sObject> {
    
    Id ShareClassRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Share Class').getRecordTypeId();

    public CDRSettings__c settings = CDRSettings__c.getvalues('NGAM');
    String lastNDaysParm = settings.ProdPerfBatchLASTNDAYS__c;
    
    global final String query = ' SELECT Id, AsOfDate__c, Product__c, Product__r.ParentProduct__c ' +
        ' FROM ProductPerformance__c ' +
        ' WHERE Product__r.RecordTypeId = :ShareClassRecTypeId ' +
        ' AND AsOfDate__c = LAST_N_DAYS:' + lastNDaysParm + ' ' +
        ' ORDER BY Product__r.ParentProduct__c, AsOfDate__c DESC';
    
    global ProdPerfMaintRollupBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {      
        System.Debug('Query - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ProductPerformance__c> scope) {
        
        Set<Id> parentProductIdSet = new Set<Id>();
        Set<Date> asOfDateSet = new Set<Date>();
        Map<String,ProductPerformance__c> parentProdPerfMap = new Map<String,ProductPerformance__c>();
        
        for (ProductPerformance__c pp : scope) {
            parentProductIdSet.add(pp.Product__r.ParentProduct__c);
            asOfDateSet.add(pp.AsOfDate__c);
        }
        
        AggregateResult[] groupedResults = [SELECT Product__r.ParentProduct__c ppId, AsOfDate__c aod, SUM(TotalNetAssets__c) TNA, SUM(SharesOutstanding__c) SO
                                            FROM ProductPerformance__c
                                            WHERE Product__r.ParentProduct__c in :parentProductIdSet
                                            AND AsOfDate__c in :asOfDateSet
                                            GROUP BY Product__r.ParentProduct__c, AsOfDate__c];
        
        for (AggregateResult ar : groupedResults)  {
            String parentProductId = (String)ar.get('ppId');
            Date parentProductAsOfDate = (Date)ar.get('aod');
            String parentProdPerfExtId = parentProductId + '|' + parentProductAsOfDate.format();
            parentProdPerfMap.put(parentProdPerfExtId, new ProductPerformance__c(Product__c = parentProductId, TotalNetAssets__c = (Decimal)ar.get('TNA'), SharesOutstanding__c = (Decimal)ar.get('SO'),
                                                                                 AsOfDate__c = parentProductAsOfDate, ExternalId__c = parentProdPerfExtId));
        }
        
        upsert parentProdPerfMap.values() ExternalId__c;
        
    }
    
    
    global void finish(Database.BatchableContext BC) {
        
        Id batchJobId = Database.executeBatch(new ProdPerfMaintDateBatch());

    }
    
}