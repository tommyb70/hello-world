@isTest
public class ProdPerfMaintBatchTest {
    
    // This test class covers all ProdPerfMaint batch classes
    
    @testSetup static void SetupTest() {
        
        Id SCRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Share Class').getRecordTypeId();
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId();
        
        Date ppAsOfDate = Date.today();
        Date priorMonthDate = ppAsOfDate.addMonths(-1);
        Integer priorDaysInMonth = Date.daysInMonth(priorMonthDate.year(),priorMonthDate.month());
        Date ppMonthEndDate = Date.newInstance(priorMonthDate.year(),priorMonthDate.month(),priorDaysInMonth);   
        Date ppQuarterEndDate1 = getQuarterEndDate(ppAsOfDate.addMonths(-4));
        Date ppQuarterEndDate2 = getQuarterEndDate(ppAsOfDate.addMonths(-7));
        Date ppQuarterEndDate3 = getQuarterEndDate(ppAsOfDate.addMonths(-10));
        Date ppQuarterEndDate4 = getQuarterEndDate(ppAsOfDate.addMonths(-13));
        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     BusinessHoursName__c = '24 Hours, Monday - Friday GMT', 
                                                     DeleteHarris__c = TRUE,
                                                     DeleteFundstation__c = TRUE,
                                                     ProdPerfBatchLASTNDAYS__c = '500');
        insert settings;
        
        String BHName = settings.BusinessHoursName__c;
        
        businessHours bh = [SELECT Id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, 
                            WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, 
                            SaturdayStartTime, SundayEndTime, SundayStartTime 
                            FROM BusinessHours WHERE Name = :BHName LIMIT 1];
        
        List<Holiday> holidays = [SELECT Id, ActivityDate, RecurrenceType, RecurrenceDayOfMonth, RecurrenceMonthOfYear from Holiday];
        
        List<Product2> mfp = DataFactory.createProduct2(2,'MF_');
        mfp[0].RecordTypeId = MFRecTypeId;
        mfp[1].RecordTypeId = MFRecTypeId;
        insert mfp;
        
        List<Product2> scp = DataFactory.createProduct2(3,'SC_');
        //Two Share Classes with Parent Product of MF_1
        scp[0].RecordTypeId = SCRecTypeId;
        scp[0].ParentProduct__c = mfp[0].Id;
        scp[1].RecordTypeId = SCRecTypeId;
        scp[1].ParentProduct__c = mfp[0].Id;
        
        //One Share Class with Parent Product of MF_2
        scp[2].RecordTypeId = SCRecTypeId;
        scp[2].ParentProduct__c = mfp[1].Id;
        insert scp;
        
        List<ProductPerformance__c> ppToInsert = new List<ProductPerformance__c>();
        
        //One Parent Product Performance for test coverage
        //AsOfDate
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate, Product__c = mfp[1].Id, 
                                                 ExternalID__c = mfp[1].id + '|' + ppAsOfDate.format(), 
                                                 TotalNetAssets__c = 100,  
                                                 SourceSystem__c = 'SFDC',
                                                 SharesOutstanding__c = 10));
        
        //All the Share Class Product Performances
        //AsOfDate
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate, Product__c = scp[0].Id, 
                                                 ExternalID__c = scp[0].id + '|' + ppAsOfDate.format(), 
                                                 TotalNetAssets__c = 100, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 10));
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate, Product__c = scp[1].Id, 
                                                 ExternalID__c = scp[1].id + '|' + ppAsOfDate.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 20));
        //Parent Product of MF_2, Source is Harris
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate, Product__c = scp[2].Id, 
                                                 ExternalID__c = scp[2].id + '|' + ppAsOfDate.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE,  
                                                 SourceSystem__c = 'Harris',
                                                 SharesOutstanding__c = 20));
        
        //Prior Month End Date
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppMonthEndDate, Product__c = scp[0].Id, 
                                                 ExternalID__c = scp[0].id + '|' + ppMonthEndDate.format(), 
                                                 TotalNetAssets__c = 100, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 10));
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppMonthEndDate, Product__c = scp[1].Id, 
                                                 ExternalID__c = scp[1].id + '|' + ppMonthEndDate.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 20));
        //Parent Product of MF_2, Source is Harris
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppMonthEndDate, Product__c = scp[2].Id, 
                                                 ExternalID__c = scp[2].id + '|' + ppMonthEndDate.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE,  
                                                 SourceSystem__c = 'Harris',
                                                 SharesOutstanding__c = 20));
        
        //Prior Quarter End Date
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate1, Product__c = scp[0].Id, 
                                                 ExternalID__c = scp[0].id + '|' + ppQuarterEndDate1.format(), 
                                                 TotalNetAssets__c = 100, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 10));
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate1, Product__c = scp[1].Id, 
                                                 ExternalID__c = scp[1].id + '|' + ppQuarterEndDate1.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 20));
        //Parent Product of MF_2, Source is Harris
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate1, Product__c = scp[2].Id, 
                                                 ExternalID__c = scp[2].id + '|' + ppQuarterEndDate1.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE,  
                                                 SourceSystem__c = 'Harris',
                                                 SharesOutstanding__c = 20));
        
        //Prior Prior Quarter End Date
        // *** ppAsOfDate = Date.today();
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate2, Product__c = scp[0].Id, 
                                                 ExternalID__c = scp[0].id + '|' + ppQuarterEndDate2.format(), 
                                                 TotalNetAssets__c = 100, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 10));
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate2, Product__c = scp[1].Id, 
                                                 ExternalID__c = scp[1].id + '|' + ppQuarterEndDate2.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 20));
        //Parent Product of MF_2, Source is Harris
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate2, Product__c = scp[2].Id, 
                                                 ExternalID__c = scp[2].id + '|' + ppQuarterEndDate2.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE,  
                                                 SourceSystem__c = 'Harris',
                                                 SharesOutstanding__c = 20));
        
        //Prior Prior Prior Quarter End Date
        // *** ppAsOfDate = Date.today();
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate3, Product__c = scp[0].Id, 
                                                 ExternalID__c = scp[0].id + '|' + ppQuarterEndDate3.format(), 
                                                 TotalNetAssets__c = 100, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 10));
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate3, Product__c = scp[1].Id, 
                                                 ExternalID__c = scp[1].id + '|' + ppQuarterEndDate3.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 20));
        //Parent Product of MF_2, Source is Harris
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate3, Product__c = scp[2].Id, 
                                                 ExternalID__c = scp[2].id + '|' + ppQuarterEndDate3.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE,  
                                                 SourceSystem__c = 'Harris',
                                                 SharesOutstanding__c = 20));
        
        //Prior Prior Prior Prior Quarter End Date
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate4, Product__c = scp[0].Id, 
                                                 ExternalID__c = scp[0].id + '|' + ppQuarterEndDate4.format(), 
                                                 TotalNetAssets__c = 100, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 10));
        //Parent Product of MF_1, Source is Fundstation
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate4, Product__c = scp[1].Id, 
                                                 ExternalID__c = scp[1].id + '|' + ppQuarterEndDate4.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE, 
                                                 SourceSystem__c = 'Fundstation',
                                                 SharesOutstanding__c = 20));
        //Parent Product of MF_2, Source is Harris
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppQuarterEndDate4, Product__c = scp[2].Id, 
                                                 ExternalID__c = scp[2].id + '|' + ppQuarterEndDate4.format(), 
                                                 TotalNetAssets__c = 200, HasRates__c = TRUE, HasDailyReturns__c = TRUE, HasYields__c = TRUE,  
                                                 SourceSystem__c = 'Harris',
                                                 SharesOutstanding__c = 20));
        
        
        //Prior Year End Date
        //One of the Prior Quarter End Dates will cover this
        
        insert ppToInsert;
        
    }
    
    static testMethod void ProdPerfMaintBatchTest() {
        
        Test.startTest(); 
        Id batchJobId = Database.executeBatch(new ProdPerfMaintRollupBatch());
        Test.stopTest();		        
        
    }
    
    static testMethod void ProdPerfMaintDeleteBatchTest() {
        
        Test.startTest(); 
        Id batchJobId = Database.executeBatch(new ProdPerfMaintDeleteBatch());
        Test.stopTest();		        
        
    }
    
    private static Date getQuarterEndDate(Date d) {
        
        Date qed = Date.today();
        
        switch on d.month() {
            when 1,2,3 {
                qed = Date.newInstance(d.year(),3,31);   
            }
            when 4,5,6 {
                qed = Date.newInstance(d.year(),6,30);   
            }
            when 7,8,9 {
                qed = Date.newInstance(d.year(),9,30);   
            }
            when 10,11,12 {
                qed = Date.newInstance(d.year(),12,31);   
            }
        }
        
        return qed;
        
    }
    
    
    
}