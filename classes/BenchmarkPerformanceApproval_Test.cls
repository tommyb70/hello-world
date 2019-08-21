@isTest 
private class BenchmarkPerformanceApproval_Test{
    
    static testMethod void methodOne() { 
        
        Id BMRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Benchmark').getRecordTypeId(); 
        //inserting the product record
        Product2 prod = new Product2(Name = 'Laptop X200',PartNum__c='123',Family = 'Hardware',RecordtypeId = BMRecTypeId);
        insert prod;
        
        Product2 prodpad = new Product2(Name = 'Laptop y500',PartNum__c='456',Family = 'Hardware',PrimaryBenchmark__c = prod.Id);
        insert prodpad;
        
        Product2 prodpa = new Product2(Name = 'Laptop y200',PartNum__c='789',Family = 'Hardware',ParentProduct__c = prodpad.Id);
        insert prodpa;
        
        
        ProductPerformance__c pp = new ProductPerformance__c(AsofDate__c = system.today(),Product__c =prodpa.Id);
        insert pp;
        
        //inserting the benchmark perormance approval record 
        BenchmarkPerformanceApproval__c BPA = new BenchmarkPerformanceApproval__c(Benchmark__c = prod.Id,
                                                                                  AsofDate__c = System.Date.today(),ExternalID__c = '12345');
        insert BPA;
        
        BPA.Approved__c = TRUE;
        update BPA;
        
        //calculating the last day of the month
        Integer numberOfDays = Date.daysInMonth(System.today().year(), System.today().month());
        Date lastDayOfMonth = Date.newInstance(System.today().year(), System.today().month(), numberOfDays);
        
        //inserting the benchmark performace approval record with end of the month date    
        BenchmarkPerformanceApproval__c BA1 = new BenchmarkPerformanceApproval__c(Benchmark__c = prod.Id,AsofDate__c = lastDayOfMonth ,ExternalID__c='345');
        insert BA1;
        
        //update BA1;
        
        
        
        BenchmarkPerformanceApprovalController BAC = new BenchmarkPerformanceApprovalController();
        BAC.BenchmarkSelections();
        BAC.asOfDateSelections();
        BAC.go();
        BenchmarkPerformanceApprovalController.wrapBenchmarkPerformance wrp = new BenchmarkPerformanceApprovalController.wrapBenchmarkPerformance(BA1);
        wrp.selected = true;
        BAC.approveSelected();  
        
        
        Id SCRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Share Class').getRecordTypeId(); 
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId(); 
        //Id BMRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Benchmark').getRecordTypeId(); 
        
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
        
        
        BenchmarkPerformanceApproval__c BA = new BenchmarkPerformanceApproval__c(Benchmark__c = bmp[0].Id,
                                                                                 AsofDate__c = ppAsOfDate
                                                                                );
        
        BA.ExternalID__c = bmp[0].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format();    
        try{                                                                     
            insert BA;
        }catch(Exception e){
            system.assertEquals(e.getMessage().contains('No Product Performance Record found'),true); 
        }                
    } 
    
    private static testmethod void BenchmarkPerformanceApprovalControllerTest(){
        
        Id SCRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Share Class').getRecordTypeId(); 
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId(); 
        Id BMRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Benchmark').getRecordTypeId(); 
        
        Date inceptionDate1 = Date.newInstance(2010,3,31); 
        Date inceptionDate2 = Date.newInstance(2011,4,30); 
        Date inceptionDate3 = Date.newInstance(2011,6,30); 
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
        
        List <BenchmarkPerformanceApproval__c> bma = new List<BenchmarkPerformanceApproval__c>();
        
        bma.add(new BenchmarkPerformanceApproval__c(Benchmark__c = bmp[0].Id,
                                                    AsofDate__c = ppAsOfDate,
                                                    ExternalID__c = bmp[0].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format(),
                                                    InceptionDate__c = inceptionDate1));
        bma.add(new BenchmarkPerformanceApproval__c(Benchmark__c = bmp[0].Id,
                                                    AsofDate__c = ppAsOfDate,
                                                    ExternalID__c = bmp[0].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format(),
                                                    InceptionDate__c = inceptionDate2));
        bma.add(new BenchmarkPerformanceApproval__c(Benchmark__c = bmp[1].Id,
                                                    AsofDate__c = ppAsOfDate,
                                                    ExternalID__c = bmp[1].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format(),
                                                    InceptionDate__c = inceptionDate1));
        bma.add(new BenchmarkPerformanceApproval__c(Benchmark__c = bmp[1].Id,
                                                    AsofDate__c = ppAsOfDate,
                                                    ExternalID__c = bmp[1].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format(),
                                                    InceptionDate__c = inceptionDate2));
        bma.add(new BenchmarkPerformanceApproval__c(Benchmark__c = bmp[2].Id,
                                                    AsofDate__c = ppAsOfDate,
                                                    ExternalID__c = bmp[2].id + ':' + inceptionDate1.format() + '|' + ppAsOfDate.format(),
                                                    InceptionDate__c = inceptionDate1));
        bma.add(new BenchmarkPerformanceApproval__c(Benchmark__c = bmp[2].Id,
                                                    AsofDate__c = ppAsOfDate,
                                                    ExternalID__c = bmp[2].id + ':' + inceptionDate2.format() + '|' + ppAsOfDate.format(),
                                                    InceptionDate__c = inceptionDate2));
		insert bma;

        BenchmarkPerformanceApproval__c BA = new BenchmarkPerformanceApproval__c(Benchmark__c = bmp[0].Id,
                                                                                 AsofDate__c = ppAsOfDate,
                                                                                 ExternalID__c = bmp[0].id + ':' + inceptionDate3.format() + '|' + ppAsOfDate.format(),
                                                                                 InceptionDate__c = inceptionDate3);
        
        insert BA;
        BA.Approved__c = TRUE;
        

        try{                                                                     
        	update BA;    
        }catch(Exception e){
            system.assertEquals(e.getMessage().contains('No Product Performance Record found'),true); 
        }  
        
        
        
        
        
        /*        Id BMRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Benchmark').getRecordTypeId(); 
//inserting the product record
Product2 prod = new Product2(Name = 'Laptop X200',PartNum__c='123',Family = 'Hardware',RecordtypeId = BMRecTypeId);
insert prod;


BenchmarkPerformanceApproval__c BA1 = new BenchmarkPerformanceApproval__c(Benchmark__c = prod.Id,ExternalID__c='345');
insert BA1;

update BA1;*/
        
        BenchmarkPerformanceApprovalController BAC = new BenchmarkPerformanceApprovalController();
        BAC.BenchmarkSelections();
        BAC.asOfDateSelections();
        BAC.go();
        BenchmarkPerformanceApprovalController.wrapBenchmarkPerformance wrp = new BenchmarkPerformanceApprovalController.wrapBenchmarkPerformance(bma[0]);
        wrp.selected = true;
        BAC.approveSelected();  
        
    }
    
}