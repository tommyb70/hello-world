/**
* @author: Tom Barad
* @Created Date: 09/06/2018
* @description : test class for BenchmarkPerformanceTriggerHandler class. 
**/

@isTest 
private class BenchmarkPerformanceTriggerHandler_Test{
    
    private static testmethod void methodOne(){
        
        Id SCRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Share Class').getRecordTypeId();
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId();
        Id BMRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Benchmark').getRecordTypeId();
        
        Date inceptionDate1 = Date.newInstance(2010,3,31);
        Date inceptionDate2 = Date.newInstance(2011,4,30);
        Date ppAsOfDate = Date.today();
        
        //Inserting 3 benchmark products
        List<Product2> bmp = DataFactory.createProduct2(3,'BM_');
        bmp[0].RecordTypeId = BMRecTypeId;
        bmp[1].RecordTypeId = BMRecTypeId;
        bmp[2].RecordTypeId = BMRecTypeId;
        insert bmp;
        
        //Inserting 2 mutual fund products
        List<Product2> mfp = DataFactory.createProduct2(2,'MF_');
        mfp[0].RecordTypeId = MFRecTypeId;
        mfp[0].PrimaryBenchmark__c = bmp[0].Id;
        mfp[0].SecondaryBenchmark__c = bmp[1].Id;
        mfp[0].TertiaryBenchmark__c = bmp[2].Id;
        mfp[1].RecordTypeId = MFRecTypeId;
        mfp[1].PrimaryBenchmark__c = bmp[1].Id;
        mfp[1].SecondaryBenchmark__c = bmp[2].Id;
        mfp[1].TertiaryBenchmark__c = bmp[0].Id;
        insert mfp;
        
        //Inserting 3 schare class products
        List<Product2> scp = DataFactory.createProduct2(3,'SC_');
        //Two Share Class with Parent Product of MF_1, different inception dates
        scp[0].RecordTypeId = SCRecTypeId;
        scp[0].ParentProduct__c = mfp[0].Id;
        scp[0].InceptionDate__c = inceptionDate1;
        scp[1].RecordTypeId = SCRecTypeId;
        scp[1].ParentProduct__c = mfp[0].Id;
        scp[1].InceptionDate__c = inceptionDate2;
        
        //One Share Class with Parent Product of MF_2
        scp[2].RecordTypeId = SCRecTypeId;
        scp[2].ParentProduct__c = mfp[1].Id;
        scp[2].InceptionDate__c = inceptionDate1;                
        insert scp;
        
        List<ProductPerformance__c> ppToInsert = new List<ProductPerformance__c>();
        
        //inserting the product performance records
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate, Product__c = scp[0].Id, 
                                                 ExternalID__c = scp[0].id + '|' + ppAsOfDate.format())); 
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate, Product__c = scp[1].Id, 
                                                 ExternalID__c = scp[1].id + '|' + ppAsOfDate.format())); 
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate, Product__c = scp[2].Id, 
                                                 ExternalID__c = scp[2].id + '|' + ppAsOfDate.format())); 
        insert ppToInsert;
        
        //inserting the benchmarkperformance records
        List<BenchmarkPerformance__c> bpToInsert = new List<BenchmarkPerformance__c>();
        
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[0].Id, InceptionDate__c = inceptionDate1,
                                                   ExternalID__c = bmp[0].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format()));
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[1].Id, InceptionDate__c = inceptionDate1,
                                                   ExternalID__c = bmp[1].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format()));
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[2].Id, InceptionDate__c = inceptionDate1,
                                                   ExternalID__c = bmp[2].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format()));
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[0].Id, InceptionDate__c = inceptionDate2,
                                                   ExternalID__c = bmp[0].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format()));
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[1].Id, InceptionDate__c = inceptionDate2,
                                                   ExternalID__c = bmp[1].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format()));
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[2].Id, InceptionDate__c = inceptionDate2,
                                                   ExternalID__c = bmp[2].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format()));
        insert bpToInsert;
        
        ProductPerformance__c pp0 = [SELECT Id, Product__c, PrimaryBenchmarkPerformance__c, SecondaryBenchmarkPerformance__c, TertiaryBenchmarkPerformance__c
                                                    FROM ProductPerformance__c WHERE Id = :ppToInsert[0].Id];
        ProductPerformance__c pp1 = [SELECT Id, Product__c, PrimaryBenchmarkPerformance__c, SecondaryBenchmarkPerformance__c, TertiaryBenchmarkPerformance__c
                                                    FROM ProductPerformance__c WHERE Id = :ppToInsert[1].Id];
        ProductPerformance__c pp2 = [SELECT Id, Product__c, PrimaryBenchmarkPerformance__c, SecondaryBenchmarkPerformance__c, TertiaryBenchmarkPerformance__c
                                                    FROM ProductPerformance__c WHERE Id = :ppToInsert[2].Id];
        
        system.assertEquals(bpToInsert[0].Id, pp0.PrimaryBenchmarkPerformance__c);
        system.assertEquals(bpToInsert[1].Id, pp0.SecondaryBenchmarkPerformance__c);
        system.assertEquals(bpToInsert[2].Id, pp0.TertiaryBenchmarkPerformance__c);
        system.assertEquals(bpToInsert[3].Id, pp1.PrimaryBenchmarkPerformance__c);
        system.assertEquals(bpToInsert[4].Id, pp1.SecondaryBenchmarkPerformance__c);
        system.assertEquals(bpToInsert[5].Id, pp1.TertiaryBenchmarkPerformance__c);
        system.assertEquals(bpToInsert[1].Id, pp2.PrimaryBenchmarkPerformance__c);
        system.assertEquals(bpToInsert[2].Id, pp2.SecondaryBenchmarkPerformance__c);
        system.assertEquals(bpToInsert[0].Id, pp2.TertiaryBenchmarkPerformance__c);        
    }
    
    private static testmethod void methodTwo(){ 

        Id SCRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Share Class').getRecordTypeId(); 
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId(); 
        Id BMRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Benchmark').getRecordTypeId(); 
        
        Date inceptionDate1 = Date.newInstance(2010,3,31); 
        Date inceptionDate2 = Date.newInstance(2011,4,30); 
        Date ppAsOfDate = Date.today(); 
        
        //Inserting 3 benchmark products 
        List<Product2> bmp = DataFactory.createProduct2(3,'BM_'); 
        bmp[0].RecordTypeId = BMRecTypeId; 
        bmp[1].RecordTypeId = BMRecTypeId; 
        bmp[2].RecordTypeId = BMRecTypeId; 
        insert bmp; 
        
        //Inserting 2 mutual fund products 
        List<Product2> mfp = DataFactory.createProduct2(2,'MF_'); 
        mfp[0].RecordTypeId = MFRecTypeId; 
        mfp[0].PrimaryBenchmark__c = bmp[0].Id; 
        mfp[0].SecondaryBenchmark__c = bmp[1].Id; 
        mfp[0].TertiaryBenchmark__c = bmp[2].Id; 
        mfp[1].RecordTypeId = MFRecTypeId; 
        mfp[1].PrimaryBenchmark__c = bmp[1].Id; 
        mfp[1].SecondaryBenchmark__c = bmp[2].Id; 
        mfp[1].TertiaryBenchmark__c = bmp[0].Id; 
        insert mfp; 
        
        //Inserting 3 schare class products 
        List<Product2> scp = DataFactory.createProduct2(3,'SC_'); 
        //Two Share Class with Parent Product of MF_1, different inception dates 
        scp[0].RecordTypeId = SCRecTypeId; 
        scp[0].ParentProduct__c = mfp[0].Id; 
        scp[0].InceptionDate__c = inceptionDate1; 
        scp[1].RecordTypeId = SCRecTypeId; 
        scp[1].ParentProduct__c = mfp[0].Id; 
        scp[1].InceptionDate__c = inceptionDate2; 
        
        //One Share Class with Parent Product of MF_2 
        scp[2].RecordTypeId = SCRecTypeId; 
        scp[2].ParentProduct__c = mfp[1].Id; 
        scp[2].InceptionDate__c = inceptionDate1; 
        insert scp; 
        
        //inserting the benchmarkperformance records 
        List<BenchmarkPerformance__c> bpToInsert = new List<BenchmarkPerformance__c>(); 
        
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[0].Id, InceptionDate__c = inceptionDate1, 
        ExternalID__c = bmp[0].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format())); 
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[1].Id, InceptionDate__c = inceptionDate1, 
        ExternalID__c = bmp[1].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format())); 
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[2].Id, InceptionDate__c = inceptionDate1, 
        ExternalID__c = bmp[2].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format())); 
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[0].Id, InceptionDate__c = inceptionDate2, 
        ExternalID__c = bmp[0].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format())); 
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[1].Id, InceptionDate__c = inceptionDate2, 
        ExternalID__c = bmp[1].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format()));
        bpToInsert.add(new BenchmarkPerformance__c(AsOfDate__c = ppAsOfDate, Benchmark__c = bmp[2].Id, InceptionDate__c = inceptionDate2, 
        ExternalID__c = bmp[2].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format())); 
        
        try{
          insert bpToInsert; 
        }catch(Exception e){
          system.assertEquals(e.getMessage().contains('No Product Performance Record found'),true); 
        }
    } 
}