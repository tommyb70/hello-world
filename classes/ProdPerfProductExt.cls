public class ProdPerfProductExt {
    
    public Product2 pr { get; set; }
    public ProductPerformance__c pp {get;set;}
    public Date ppd {get;set;}
    public Date ppcd {get;set;}
    public List<ProductPerformance__c> daily {get;set;}
    public List<ProductPerfHelper.DailyPerformanceItemROR> dailyPerfROR {get;set;}
    public List<ProductPerfHelper.DailyPerformanceItem> dailyPerf {get;set;}
    public List<ProductPerfHelper.AnnualPerformanceItem> annualPerf {get;set;}
    public List<ProductPerfHelper.YieldItem> yield {get;set;}
    public List<ProductPerformance__c> children {get;set;}
    public List<ProductPerfHelper.MSRatingsItem> msrating {get;set;}
    public List<ProductPerfHelper.MSRankingsItem> msranking {get;set;}
    public String threadbackPerfFN {get;set;}
    public String asOfDateDisp {get;set;}
    public String prevDateDisp {get;set;}
    public String annualPerfY0 {get;set;}
    public String annualPerfY1 {get;set;}
    public String annualPerfY2 {get;set;}
    public String annualPerfY3 {get;set;}
    public String annualPerfY4 {get;set;}
    public String annualPerfY5 {get;set;}
    public String annualPerfY6 {get;set;}
    public String annualPerfY7 {get;set;}
    public String annualPerfY8 {get;set;}
    public String annualPerfY9 {get;set;}
    public String prodPerfId {get;set;}
    public String inceptionDt {get;set;}
    public boolean dispTaxEqYield {get;set;}
    
    public ProdPerfProductExt(ApexPages.StandardController controller) {
        
        Id SCRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Share Class').getRecordTypeId();
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId();
        Id ETFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('ETF').getRecordTypeId();
        
        pr = (Product2)controller.getRecord();
        
        if (pr.RecordTypeId == SCRecTypeId || pr.RecordTypeId == ETFRecTypeId) {    
            
            List<Product2> spl = [SELECT Id, ParentProduct__c, MaxInternalProductPerformance__r.AsOfDate__c 
                                  FROM Product2 WHERE Id = :pr.Id LIMIT 1];
            
            if (!spl.isEmpty() && spl[0].MaxInternalProductPerformance__r.AsOfDate__c != null) {       
                
                ppd = spl[0].MaxInternalProductPerformance__r.AsOfDate__c;
                
                pp = ProductPerfHelper.getProductPerformanceRow(spl[0].Id, spl[0].MaxInternalProductPerformance__r.AsOfDate__c);
                
                // Miscellaneous Strings
                Map<String,String> miscStringMap = new Map<String,String>();
                miscStringMap = ProductPerfHelper.getMiscStrings(pp);
                prodPerfId = miscStringMap.get('prodPerfId');
                annualPerfY0 = miscStringMap.get('aY0');
                annualPerfY1 = miscStringMap.get('aY1');
                annualPerfY2 = miscStringMap.get('aY2');
                annualPerfY3 = miscStringMap.get('aY3');
                annualPerfY4 = miscStringMap.get('aY4');
                annualPerfY5 = miscStringMap.get('aY5');
                annualPerfY6 = miscStringMap.get('aY6');
                annualPerfY7 = miscStringMap.get('aY7');
                annualPerfY8 = miscStringMap.get('aY8');
                annualPerfY9 = miscStringMap.get('aY9');
                asOfDateDisp = miscStringMap.get('asOfDateDisp');
                prevDateDisp = miscStringMap.get('prevDateDisp');
                inceptionDt = miscStringMap.get('inceptionDt');
                
                // Yield Item Rows
                yield = new List<ProductPerfHelper.YieldItem>();
                yield = ProductPerfHelper.getYieldItemList(pp);
                
                // Daily Performace Item Rows
                dailyPerf = new List<ProductPerfHelper.DailyPerformanceItem>();
                dailyPerf = ProductPerfHelper.getDailyPerformanceItemList(pp);
                
                // Daily Performance ROR Rows
                dailyPerfROR = new List<ProductPerfHelper.DailyPerformanceItemROR>();
                dailyPerfROR = ProductPerfHelper.getDailyPerformanceItemRORList(pp);
                if (pp.Product__r.DisplaySECTaxEquivalentYield__c) dispTaxEqYield = TRUE;
                
                // Annual Performace Item Rows
                annualPerf = new List<ProductPerfHelper.AnnualPerformanceItem>();
                annualPerf = ProductPerfHelper.getAnnualPerformanceItemList(pp);
                
                // Morningstar Rating Rows
                msrating = new List<ProductPerfHelper.MSRatingsItem>();
                msrating = ProductPerfHelper.getMSRatingsItemList(pp);
                
                // Morningstar Ranking Rows
                msranking = new List<ProductPerfHelper.MSRankingsItem>();
                msranking = ProductPerfHelper.getMSRankingsItemList(pp);
                
                threadbackPerfFN = ProductPerfHelper.getThreadbackPerformanceFootnote(pp.Product__r.ShareClassName__c, 
                                                                                      pp.Product__r.ThreadbackPerformanceShareClass__r.ShareClassName__c,
                                                                                      pp.InceptionDate__c, ppd);
                
                if (!pp.IsAsofDateBusinessDate__c){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The date you have chosen is not a business date.  Unless the date falls on a Month End, Quarter End, or Year End, it will not have daily returns'));
                }
                
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This product does not have any product performance rows in the database'));
            }
        } else {
            threadbackPerfFN = '';
            List<Product2> spl = [SELECT ParentProduct__c, MaxInternalProductPerformance__r.AsOfDate__c, Id FROM Product2 WHERE ParentProduct__c = :pr.Id AND MaxInternalProductPerformance__r.AsOfDate__c != null LIMIT 1];
            ppcd = spl[0].MaxInternalProductPerformance__r.AsOfDate__c;
            pp = ProductPerfHelper.getProductPerformanceRow(spl[0].ParentProduct__c, ppcd);
            children = new List<ProductPerformance__c>();
            children = ProductPerfHelper.getChildProductPerformance(pr,ppcd);
            if (children.size() == 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The date you chose either does not exist in the database or is not yet internally published'));
            }
            
            for (ProductPerformance__c pp : children) {
                
                String tbTemp = '';
                tbTemp = ProductPerfHelper.getThreadbackPerformanceFootnote(pp.Product__r.ShareClassName__c, 
                                                                            pp.Product__r.ThreadbackPerformanceShareClass__r.ShareClassName__c,
                                                                            pp.InceptionDate__c, ppcd);
                
                if (tbTemp != '' && tbTemp != 'null') {
                    threadbackPerfFN = threadbackPerfFN + tbTemp;
                }                
            }
            
        }
        
    }
    
    public PageReference getChildProductPerf() {
        String errorMessage;
        threadbackPerfFN = '';
        pp = ProductPerfHelper.getProductPerformanceRow(pr.Id, ppcd);
        children = new List<ProductPerformance__c>();
        children = ProductPerfHelper.getChildProductPerformance(pr,ppcd);
        if (children.size() == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The date you chose either does not exist in the database or is not yet internally published'));
        }
        
        if (!pp.IsAsofDateBusinessDate__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The date you have chosen is not a business date.  Unless the date falls on a Month End, Quarter End, or Year End, it will not have daily returns'));
        }
        
        for (ProductPerformance__c pp : children) {
            
            String tbTemp = '';
            tbTemp = ProductPerfHelper.getThreadbackPerformanceFootnote(pp.Product__r.ShareClassName__c, 
                                                                        pp.Product__r.ThreadbackPerformanceShareClass__r.ShareClassName__c,
                                                                        pp.InceptionDate__c, ppcd);
            
            
            
            if (tbTemp != '' && tbTemp != 'null') {
                threadbackPerfFN = threadbackPerfFN + tbTemp;
            }
        }
        
        return null;
    }
    
    public PageReference getProductPerf() {
        String errorMessage;
        
        pp = ProductPerfHelper.getProductPerformanceRow(pr.Id, ppd);
        
        if (pp != null) {
            
            Map<String,String> miscStringMap = new Map<String,String>();
            miscStringMap = ProductPerfHelper.getMiscStrings(pp);
            prodPerfId = miscStringMap.get('prodPerfId');
            annualPerfY0 = miscStringMap.get('aY0');
            annualPerfY1 = miscStringMap.get('aY1');
            annualPerfY2 = miscStringMap.get('aY2');
            annualPerfY3 = miscStringMap.get('aY3');
            annualPerfY4 = miscStringMap.get('aY4');
            annualPerfY5 = miscStringMap.get('aY5');
            annualPerfY6 = miscStringMap.get('aY6');
            annualPerfY7 = miscStringMap.get('aY7');
            annualPerfY8 = miscStringMap.get('aY8');
            annualPerfY9 = miscStringMap.get('aY9');
            asOfDateDisp = miscStringMap.get('asOfDateDisp');
            prevDateDisp = miscStringMap.get('prevDateDisp');
            
            //TNA
            daily = new List<ProductPerformance__c>();
            daily.add(pp);
            
            // Yield Item Rows
            yield = new List<ProductPerfHelper.YieldItem>();
            yield = ProductPerfHelper.getYieldItemList(pp);
            
            // Daily Performace Item Rows
            dailyPerf = new List<ProductPerfHelper.DailyPerformanceItem>();
            dailyPerf = ProductPerfHelper.getDailyPerformanceItemList(pp);
            
            // Daily Performance ROR Rows
            dailyPerfROR = new List<ProductPerfHelper.DailyPerformanceItemROR>();
            dailyPerfROR = ProductPerfHelper.getDailyPerformanceItemRORList(pp);
            if (pp.Product__r.DisplaySECTaxEquivalentYield__c) dispTaxEqYield = TRUE;
            
            // Annual Performance Item Rows
            annualPerf = new List<ProductPerfHelper.AnnualPerformanceItem>();
            annualPerf = ProductPerfHelper.getAnnualPerformanceItemList(pp);
            
            // Morningstar Rating Rows
            msrating = new List<ProductPerfHelper.MSRatingsItem>();
            msrating = ProductPerfHelper.getMSRatingsItemList(pp);
            
            // Morningstar Ranking Rows
            msranking = new List<ProductPerfHelper.MSRankingsItem>();
            msranking = ProductPerfHelper.getMSRankingsItemList(pp);

            threadbackPerfFN = ProductPerfHelper.getThreadbackPerformanceFootnote(pp.Product__r.ShareClassName__c, 
                                                                                  pp.Product__r.ThreadbackPerformanceShareClass__r.ShareClassName__c,
                                                                                  pp.InceptionDate__c, ppd);
            
            if (!pp.IsAsofDateBusinessDate__c){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The date you have chosen is not a business date.  Unless the date falls on a Month End, Quarter End, or Year End, it will not have daily returns'));
            }
            
        } else {
            daily = new List<ProductPerformance__c>();
            yield = new List<ProductPerfHelper.YieldItem>();
            dailyPerf = new List<ProductPerfHelper.DailyPerformanceItem>();
            dailyPerfROR = new List<ProductPerfHelper.DailyPerformanceItemROR>();
            annualPerf = new List<ProductPerfHelper.AnnualPerformanceItem>();
            msrating = new List<ProductPerfHelper.MSRatingsItem>();
            msranking = new List<ProductPerfHelper.MSRankingsItem>();
            
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The date you chose either does not exist in the database or is not yet internally published'));
            return null;
        }
        
        return null;                            
        
    }
    
}