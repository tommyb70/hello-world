/** 
* @author Pratibha Potluri 
* @Created Date: 09/05/2018 
* @description : handler class for BenchmarkPerformanceTrigger. 
**/ 

public class BenchmarkPerformanceTriggerHandler{ 
    /** 
Method Fired when a BenchMarkPerformance Record is created or Updated 
This method will accept List of BenchMark Performance Records as Input 
**/ 
    public static void populateProductPerformance(List<BenchmarkPerformance__c> lstBP){ 
        
        set<Id> processedIds = new set<Id>(); 
        
        // set to store asOfDate field value 
        set<Date> asOfDates = new set<Date>(); 
        
        // set to store product field value 
        set<Id> productIDs= new set<Id>(); 
        
        //Map to store ExternalId field value and BenchmarkPerformance Record 
        Map<Id,List<BenchmarkPerformance__c>> mapBPM = new Map<id,List<BenchmarkPerformance__c>>(); 
        
        //Looped all the BenchmarkPerformance Records Came In, and added them to AsofDates Set and Map 
        for(BenchmarkPerformance__c bp:lstBP){ 
            if(bp.Benchmark__c != null){
                productIDs.add(bp.Benchmark__c); 
                if(!mapBPM.containsKey(bp.Benchmark__c)){ 
                    mapBPM.put(bp.Benchmark__c,new List<BenchmarkPerformance__c>()); 
                } 
                mapBPM.get(bp.Benchmark__c).add(bp); 
            } 
            if(bp.AsOfDate__c != null){asOfDates.add(bp.AsOfDate__c);} 
        } 
        // Checking whether Set and Map are not Empty 
        if(!productIDs.IsEmpty() && !asOfDates.IsEmpty()){ 
            
            /** Querying ProductPerformance Records with filter conditions like 
AsOfDate__c In Set and (PrimaryBenchmarkPerfExtId__c Is null 
or SecondaryBenchmarkPerfExtId__c Is null or TertiaryBenchmarkPerfExtId__c Is null) 
**/ 
            
            List<ProductPerformance__c> lstPP = [select id,InceptionDate__c, 
                                                 PrimaryBenchmarkPerformance__c, 
                                                 SecondaryBenchmarkPerformance__c, 
                                                 TertiaryBenchmarkPerformance__c, 
                                                 Product__r.ParentProduct__c, 
                                                 Product__r.InceptionDate__c, 
                                                 AsOfDate__c,
                                                 Product__r.ParentProduct__r.PrimaryBenchmark__c, 
                                                 Product__r.ParentProduct__r.SecondaryBenchmark__c, 
                                                 Product__r.ParentProduct__r.TertiaryBenchmark__c,
                                                 Product__r.ParentProduct__r.PrimaryBenchmark__r.Name, 
                                                 Product__r.ParentProduct__r.SecondaryBenchmark__r.Name, 
                                                 Product__r.ParentProduct__r.TertiaryBenchmark__r.Name,
                                                 Product__r.ParentProduct__r.PrimaryBenchmark__r.RichTextName__c, 
                                                 Product__r.ParentProduct__r.SecondaryBenchmark__r.RichTextName__c, 
                                                 Product__r.ParentProduct__r.TertiaryBenchmark__r.RichTextName__c 
                                                 from ProductPerformance__c where 
                                                 AsOfDate__c IN:asOfDates and (PrimaryBenchmarkPerformance__c = null or 
                                                                               SecondaryBenchmarkPerformance__c = null or TertiaryBenchmarkPerformance__c = null) 
                                                 and (Product__r.ParentProduct__r.PrimaryBenchmark__c In:productIDs or 
                                                      Product__r.ParentProduct__r.SecondaryBenchmark__c In:productIDs or 
                                                      Product__r.ParentProduct__r.TertiaryBenchmark__c In:productIDs)
                                                 ORDER BY AsOfDate__c, Product__r.ParentProduct__r.PrimaryBenchmark__c, Product__r.ParentProduct__r.SecondaryBenchmark__c, 
                                                 Product__r.ParentProduct__r.TertiaryBenchmark__c]; 
            
            system.debug('lstPP==='+lstPP); 
            // checking ProductPerformance list is Empty or not 
            if(!lstPP.IsEmpty()){ 
                //List to hold ProductPerformance records to Update 
                List<ProductPerformance__c> toUpdatePP = new List<ProductPerformance__c>(); 
                
                for(ProductPerformance__c pp:lstPP){ 
                    
                    ProductPerformance__c p = new ProductPerformance__c(); 
                    p.Id = pp.Id; 
                    
                    //Assigning BenchmarkPerformance Id value to PrimaryBenchmarkPerformance Field based on product Performance ParentProduct PrimaryBenchmark field (product Performance ParentProduct PrimaryBenchmark field need to be Equal to External Id of BPM) 
                    if(pp.Product__r.ParentProduct__r.PrimaryBenchmark__c != null && mapBPM.containsKey(pp.Product__r.ParentProduct__r.PrimaryBenchmark__c) 
                       && pp.PrimaryBenchmarkPerformance__c == null){ 
                           p.PrimaryBenchmarkPerformance__c = frameBenchMarkId(pp.Product__r.ParentProduct__r.PrimaryBenchmark__c,pp,mapBPM); 
                           p.PrimaryBenchmark__c = pp.Product__r.ParentProduct__r.PrimaryBenchmark__r.Name;
                           p.PrimaryBenchmarkRichTextName__c = pp.Product__r.ParentProduct__r.PrimaryBenchmark__r.RichTextName__c;
                           processedIds.add(p.PrimaryBenchmarkPerformance__c); 
                       } 
                    //Assigning BenchmarkPerformance Id value to SecondaryBenchmarkPerformance Field based on product Performance ParentProduct SecondaryBenchmark field (product Performance ParentProduct SecondaryBenchmark field need to be Equal to External Id of BPM) 
                    if(pp.Product__r.ParentProduct__r.SecondaryBenchmark__c != null && mapBPM.containsKey(pp.Product__r.ParentProduct__r.SecondaryBenchmark__c)
                       && pp.SecondaryBenchmarkPerformance__c == null){ 
                           p.SecondaryBenchmarkPerformance__c = frameBenchMarkId(pp.Product__r.ParentProduct__r.SecondaryBenchmark__c,pp,mapBPM); 
                           p.SecondaryBenchmark__c = pp.Product__r.ParentProduct__r.SecondaryBenchmark__r.Name;
                           p.SecondaryBenchmarkRichTextName__c = pp.Product__r.ParentProduct__r.SecondaryBenchmark__r.RichTextName__c;
                           processedIds.add(p.SecondaryBenchmarkPerformance__c); 
                       } 
                    //Assigning BenchmarkPerformance Id value to TertiaryBenchmarkPerformance Field based on product Performance ParentProduct TertiaryBenchmark field (product Performance ParentProduct TertiaryBenchmark field need to be Equal to External Id of BPM) 
                    if(pp.Product__r.ParentProduct__r.TertiaryBenchmark__c != null && mapBPM.containsKey(pp.Product__r.ParentProduct__r.TertiaryBenchmark__c) 
                       && pp.TertiaryBenchmarkPerformance__c == null){ 
                           p.TertiaryBenchmarkPerformance__c = frameBenchMarkId(pp.Product__r.ParentProduct__r.TertiaryBenchmark__c,pp,mapBPM); 
                           p.TertiaryBenchmark__c = pp.Product__r.ParentProduct__r.TertiaryBenchmark__r.Name;
                           p.TertiaryBenchmarkRichTextName__c = pp.Product__r.ParentProduct__r.TertiaryBenchmark__r.RichTextName__c;
                           processedIds.add(p.TertiaryBenchmarkPerformance__c); 
                       } 
                    // collection PP records to List 
                    toUpdatePP.add(p); 
                } 
/*                for(BenchmarkPerformance__c bps:lstBP){ 
                    if(!processedIds.contains(bps.Id) && staticBooleanVariables.benchmarkPerformanceError){ 
                        lstBP[0].addError('No Product Performance Record found'); 
                    } 
                } */
                if(!toUpdatePP.IsEmpty()){ 
                    // Updated the collected PP List 
                    update toUpdatePP; 
                } 
            }/*else if(staticBooleanVariables.benchmarkPerformanceError){ 
                lstBP[0].addError('No Product Performance Record found'); 
            } */
        } 
    } 
    
    // Method to Return Benchmark Id based on Primary or Secondary or Tertiary field values of Parent Prodcut 
    public static string frameBenchMarkId(string benchmarkPPId,ProductPerformance__c pp,Map<id,List<BenchmarkPerformance__c>> mapBPM){ 
        
        List<BenchmarkPerformance__c> LstexistingRecord = mapBPM.get(benchmarkPPId); 
        string benchMarkId = null; 
        
        for(BenchmarkPerformance__c existingRecord :LstexistingRecord){ 
            
            if(existingRecord.InceptionDate__c == pp.InceptionDate__c && existingRecord.AsOfDate__c == pp.AsOfDate__c){ 
                benchMarkId = existingRecord.Id; 
            } 
        } 
        return benchMarkId; 
    } 
}