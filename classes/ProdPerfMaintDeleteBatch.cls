global class ProdPerfMaintDeleteBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> prodIdSet = new Set<Id>();
	global Set<Id> parentProdIdSet = new Set<Id>();        
    global Map<Id,Product2> pToUpdateMap = new Map<Id,Product2>();
    
    public CDRSettings__c settings = CDRSettings__c.getvalues('NGAM');
    Date fromDate = settings.ProdPerfMaintDeleteBatchFromDate__c;
    Boolean deleteHarris = settings.DeleteHarris__c;
    Boolean deleteFundstation = settings.DeleteFundstation__c;
    
    public String query = ' SELECT Id, AsOfDate__c, Product__c, Product__r.ParentProduct__c, PriorDate__c, PriorBusinessDate__c, MonthEndDate__c, PriorMonthEndDate__c, PriorMonthEndBusinessDate__c, IsAsOfDateBusinessDate__c, ' +
        ' QuarterEndDate__c, PriorQuarterEndDate__c, PriorQuarterEndBusinessDate__c, YearEndDate__c, PriorYearEndDate__c, PriorYearEndBusinessDate__c, IsYearEnd__c, IsMonthEnd__c, ' +
        ' IsQuarterEnd__c, PriorProductPerfExtId__c, PriorMonthEndProdPerfExtId__c, PriorQuarterEndProdPerfExtId__c, PriorYearEndProdPerfExtId__c, ' +
        ' PriorProductPerformance__c, PriorMonthEndProductPerformance__c, PriorQuarterEndProductPerformance__c, PriorYearEndProductPerformance__c, ExternalID__c, ' +
        ' PublishInternally__c, PublishExternally__c, AuditFlag__c, AuditMessage__c, Product__r.InceptionDate__c, SourceSystem__c ' +        
        ' FROM ProductPerformance__c ' +
        ' WHERE AsOfDate__c >= :fromDate ' ;
    
    global ProdPerfMaintDeleteBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {      
        System.Debug('Query - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ProductPerformance__c> scope) {
        
        List<ProductPerformance__c> ppToDelete = new List<ProductPerformance__c>();
        
        for (ProductPerformance__c pp : scope) {
            if (deleteHarris && pp.SourceSystem__c == 'Harris') {
                ppToDelete.add(pp);
                prodIdSet.add(pp.Product__c);
                parentProdIdSet.add(pp.Product__r.ParentProduct__c);
            }
            
            if (deleteFundstation && pp.SourceSystem__c == 'Fundstation') {
                ppToDelete.add(pp);
                prodIdSet.add(pp.Product__c);
                parentProdIdSet.add(pp.Product__r.ParentProduct__c);
            }
            
        }
        
        for (ProductPerformance__c parentPP : [SELECT Id, Product__c FROM ProductPerformance__c 
                                               WHERE Product__c in :parentProdIdSet
                                               AND AsOfDate__c >= :fromDate]) {
                                                   prodIdSet.add(parentPP.Product__c);                                        
                                                   ppToDelete.add(parentPP);                                                    
                                               }
        
        delete ppToDelete;
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
        for (Product2 p : [SELECT Id, MaxInternalProductPerformance__c, MaxExternalProductPerformance__c, 
                           (SELECT Id
                            FROM ProductPerformance__r 
                            WHERE PublishInternally__c = TRUE
                            AND IsAsOfDateBusinessDate__c = TRUE
                            ORDER BY AsOfDate__c DESC LIMIT 1) 
                           FROM Product2
                           WHERE Id in :prodIdSet]) {
                               
                               for (ProductPerformance__c pp : p.ProductPerformance__r ) {
                                   
                                   if (pToUpdateMap.containsKey(p.Id)) {
                                       Product2 pt = pToUpdateMap.get(p.Id);
                                       pt.MaxInternalProductPerformance__c = pp.Id;
                                       pToUpdateMap.put(p.Id,pt);
                                   } else {
                                       Product2 pt = new Product2(Id = p.Id, MaxInternalProductPerformance__c = pp.Id);
                                       pToUpdateMap.put(p.Id,pt);
                                   }
                                   
                               }
                           }
        
        for (Product2 p : [SELECT Id, MaxInternalProductPerformance__c, MaxExternalProductPerformance__c, 
                           (SELECT Id 
                            FROM ProductPerformance__r 
                            WHERE PublishExternally__c = TRUE
                            AND IsAsOfDateBusinessDate__c = TRUE
                            ORDER BY AsOfDate__c DESC LIMIT 1) 
                           FROM Product2
                           WHERE Id in :prodIdSet]) {
                               
                               for (ProductPerformance__c pp : p.ProductPerformance__r ) {
                                   
                                   if (pToUpdateMap.containsKey(p.Id)) {
                                       Product2 pt = pToUpdateMap.get(p.Id);
                                       pt.MaxExternalProductPerformance__c = pp.Id;
                                       pToUpdateMap.put(p.Id,pt);
                                   } else {
                                       Product2 pt = new Product2(Id = p.Id, MaxExternalProductPerformance__c = pp.Id);
                                       pToUpdateMap.put(p.Id,pt);
                                   }
                                   
                               }
                           }
        
        update pToUpdateMap.values();             
        
    }
    
}