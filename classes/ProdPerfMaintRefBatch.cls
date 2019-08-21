global class ProdPerfMaintRefBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public CDRSettings__c settings = CDRSettings__c.getvalues('NGAM');
    String lastNDaysParm = settings.ProdPerfBatchLASTNDAYS__c;
    
    global Set<Id> prodIdSet = new Set<Id>();
    
    public String query = ' SELECT Id, AsOfDate__c, Product__c, PriorDate__c, PriorBusinessDate__c, MonthEndDate__c, PriorMonthEndDate__c, PriorMonthEndBusinessDate__c, IsAsOfDateBusinessDate__c, ' +
        ' QuarterEndDate__c, PriorQuarterEndDate__c, PriorQuarterEndBusinessDate__c, YearEndDate__c, PriorYearEndDate__c, PriorYearEndBusinessDate__c, IsYearEnd__c, IsMonthEnd__c, ' +
        ' IsQuarterEnd__c, PriorProductPerfExtId__c, PriorMonthEndProdPerfExtId__c, PriorQuarterEndProdPerfExtId__c, PriorYearEndProdPerfExtId__c, ' +
        ' PriorProductPerformance__c, PriorMonthEndProductPerformance__c, PriorQuarterEndProductPerformance__c, PriorYearEndProductPerformance__c, ExternalID__c ' +
        ' FROM ProductPerformance__c ' +
        ' WHERE AsOfDate__c = LAST_N_DAYS:' + lastNDaysParm + ' ';
    
    global ProdPerfMaintRefBatch() {
        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {      
        System.Debug('Query - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ProductPerformance__c> scope) {
        
        List<ProductPerformance__c> ppToUpdate = new List<ProductPerformance__c>();
        
        Set<String> extIdSet = new Set<String>();
        Map<String,ProductPerformance__c> refMap = new Map<String,ProductPerformance__c>();
        
        for (ProductPerformance__c pp : scope) {
            extIdSet.add(pp.PriorProductPerfExtId__c);
            extIdSet.add(pp.PriorMonthEndProdPerfExtId__c);
            extIdSet.add(pp.PriorQuarterEndProdPerfExtId__c);
            extIdSet.add(pp.PriorYearEndProdPerfExtId__c);
            prodIdSet.add(pp.Product__c);
        }
        
        for (ProductPerformance__c pp : [SELECT Id, ExternalId__c, Product__c
                                         FROM ProductPerformance__c
                                         WHERE ExternalId__c in :extIdSet]) {
                                             refMap.put(pp.ExternalId__c,pp); 
                                         }
        
        for (ProductPerformance__c pp : scope) {
            if (refMap.containsKey(pp.PriorProductPerfExtId__c)) pp.PriorProductPerformance__c = refMap.get(pp.PriorProductPerfExtId__c).Id;
            if (refMap.containsKey(pp.PriorMonthEndProdPerfExtId__c)) pp.PriorMonthEndProductPerformance__c = refMap.get(pp.PriorMonthEndProdPerfExtId__c).Id;
            if (refMap.containsKey(pp.PriorQuarterEndProdPerfExtId__c)) pp.PriorQuarterEndProductPerformance__c = refMap.get(pp.PriorQuarterEndProdPerfExtId__c).Id;
            if (refMap.containsKey(pp.PriorYearEndProdPerfExtId__c)) pp.PriorYearEndProductPerformance__c = refMap.get(pp.PriorYearEndProdPerfExtId__c).Id;
            ppToUpdate.add(pp);
        }
        
        update ppToUpdate; 

    }
    
    global void finish(Database.BatchableContext BC) {
        
        Id batchJobId = Database.executeBatch(new ProdPerfMaintPublishBatch());
        
    }
    
}