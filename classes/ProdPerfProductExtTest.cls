@isTest
public class ProdPerfProductExtTest {
    
    @isTest
    public static void myTest()
    {
        
        CDRSettings__c settings = new CDRSettings__c(name='NGAM', BusinessHoursName__c = '24 Hours, Monday - Friday GMT');
        insert settings;

        Id SCRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Share Class').getRecordTypeId();
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId();
        
        Date inceptionDateOld = Date.newInstance(2001,1,15);
        Date inceptionDateNew = Date.newInstance(2015,1,15);
        Date asOfDate = Date.newInstance(2017,11,7);
        Date priorBusinessDate = Date.newInstance(2017,11,6);
        Date pMEDate = Date.newInstance(2017,10,31);
        Date pQEDate = Date.newInstance(2017,9,30);
        Date p0YEDate = Date.newInstance(2016,12,31);
        Date p1YEDate = Date.newInstance(2015,12,31);
        Date p2YEDate = Date.newInstance(2014,12,31);
        Date p3YEDate = Date.newInstance(2013,12,31);
        Date p4YEDate = Date.newInstance(2012,12,31);
        Date p5YEDate = Date.newInstance(2011,12,31);
        Date p6YEDate = Date.newInstance(2010,12,31);
        Date p7YEDate = Date.newInstance(2009,12,31);
        Date p8YEDate = Date.newInstance(2008,12,31);
        Date p9YEDate = Date.newInstance(2007,12,31);
                
        List<Product2> prod = DataFactory.createProduct2(2,'Test_');
        prod[0].InceptionDate__c = inceptionDateOld;
        prod[0].RecordTypeId = MFRecTypeId;
        prod[1].InceptionDate__c = inceptionDateOld;
        prod[1].RecordTypeId = MFRecTypeId;
        insert prod;
        
        Id MFProd0Id = prod[0].Id;
        Id MFProd1Id = prod[1].Id;
        
        List<Product2> cprod = DataFactory.createProduct2(2,'TestChild_');
        cprod[0].InceptionDate__c = inceptionDateOld;
        cprod[0].ParentProduct__c = prod[0].Id;
        cprod[0].ShareClass__c = 'A';
        cprod[0].RecordTypeId = SCRecTypeId;
        
        cprod[1].InceptionDate__c = inceptionDateNew;
        cprod[1].ParentProduct__c = prod[0].Id;
        cprod[1].ShareClass__c = 'Y';
        cprod[1].RecordTypeId = SCRecTypeId;
        insert cprod;

        cprod[0].ThreadbackPerformanceShareClass__c = cprod[1].Id;
        update cprod;

        Id SCProd0Id = cprod[0].Id;
        Id SCProd1Id = cprod[1].Id;
        
        List<ProductPerformance__c> pp = new List<ProductPerformance__c>();
        pp.add(new ProductPerformance__c(AsOfDate__c = asOfDate,Product__c=MFProd0Id, PriorBusinessDate__c = priorBusinessDate,IsAsOfDateBusinessDate__c = TRUE,PublishInternally__c=TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = priorBusinessDate,Product__c=MFProd0Id, PriorBusinessDate__c = priorBusinessDate.addDays(-1),IsAsOfDateBusinessDate__c = FALSE,PublishInternally__c = TRUE));

        
        pp.add(new ProductPerformance__c(AsOfDate__c = asOfDate,Product__c=SCProd0Id, PriorBusinessDate__c = priorBusinessDate, PriorMonthEndDate__c = pMEDate, 
                                        PriorQuarterEndDate__c = pQEDate, PriorYearEndDate__c = p0YEDate, IsAsOfDateBusinessDate__c = TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = priorBusinessDate,Product__c=SCProd0Id, PriorBusinessDate__c = priorBusinessDate.addDays(-1), PriorMonthEndDate__c = pMEDate, 
                                        PriorQuarterEndDate__c = pQEDate, PriorYearEndDate__c = p0YEDate, IsAsOfDateBusinessDate__c = FALSE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = pMEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,NAVYTD__c=.99,MSCYTD__c=.99,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = pQEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, NAVYTD__c=-.99,MSCYTD__c=-.99,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p0YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p1YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p2YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p3YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p4YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p5YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p6YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p7YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p8YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        pp.add(new ProductPerformance__c(AsOfDate__c = p9YEDate,Product__c=SCProd0Id,IsMonthEnd__c=TRUE,IsQuarterEnd__c=TRUE, IsYearEnd__c=TRUE,PublishInternally__c = TRUE));
        insert pp;
        
        prod[0].MaxInternalProductPerformance__c = pp[0].Id;
        update prod;
        cprod[0].MaxInternalProductPerformance__c = pp[2].Id;
        update cprod;
        
        
        
        
        
       
        Test.StartTest();
        Test.setCurrentPage(Page.ProdPerfShareClass);
        ProdPerfProductExt controller1 = new ProdPerfProductExt(new ApexPages.StandardController(cprod[0]));
        controller1.ppcd = Date.newInstance(2017,11,6);
        PageReference nextPage1 = controller1.getProductPerf();
        controller1.ppcd = Date.newInstance(2017,11,3);
        PageReference nextPage2 = controller1.getProductPerf();        
        Test.setCurrentPage(Page.ProdPerfMutualFund);
        ProdPerfProductExt controller2 = new ProdPerfProductExt(new ApexPages.StandardController(prod[0]));
        controller2.ppcd = Date.newInstance(2017,11,6);
        PageReference nextPage3 = controller2.getChildProductPerf();
        Test.StopTest();
        
    } 
    
}